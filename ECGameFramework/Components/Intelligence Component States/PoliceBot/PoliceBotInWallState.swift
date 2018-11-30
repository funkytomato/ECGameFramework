/*
//
//  PoliceBotInWallState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 19/09/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//
Abstract:

Police are in wall state

*/

import SpriteKit
import GameplayKit

class PoliceBotInWallState: GKState
{
    // MARK:- Properties
    unowned var entity: PoliceBot
    
    // The amount of time the 'ManBot' has been in its "Detained" state
    var elapsedTime: TimeInterval = 0.0
    
    
    /// The `TemperamentComponent` associated with the `entity`.
    var intelligenceComponent: IntelligenceComponent
    {
        guard let intelligenceComponent = entity.component(ofType: IntelligenceComponent.self) else { fatalError("A PoliceBotInWallState entity must have an IntelligenceComponent.") }
        return intelligenceComponent
    }
    
    /// The `OrientationComponent` associated with the `entity`.
    var orientationComponent: OrientationComponent
    {
        guard let orientationComponent = entity.component(ofType: OrientationComponent.self) else { fatalError("A ManBotRotateToAttackState's entity must have an OrientationComponent.") }
        return orientationComponent
    }
    
    /// The `WallComponent` associated with the `entity`.
    var wallComponent: WallComponent
    {
        guard let wallComponent = entity.component(ofType: WallComponent.self) else { fatalError("A PoliceBotInWallState entity must have an WallComponent.") }
        return wallComponent
    }
    
    /// The `MovementComponent` associated with the `entity`.
    var movementComponent: MovementComponent
    {
        guard let movementComponent = entity.component(ofType: MovementComponent.self) else { fatalError("A PoliceBotInWallState's entity must have a MovementComponent.") }
        return movementComponent
    }
    
    /// The `targetPosition` from the `entity`.
    var targetPosition: float2
    {
        guard let targetPosition = entity.targetPosition else { fatalError("A PoliceBotInWallState entity must have a targetLocation set.") }
        return targetPosition
    }
    
    
    //MARK:- Initializers
    required init(entity: PoliceBot)
    {
        self.entity = entity
    }
    
    
    deinit {
        //        print("Deallocating PoliceBotInWallState")
    }
    
    //MARK:- GKState Life Cycle
    override func didEnter(from previousState: GKState?)
    {
        
        super.didEnter(from: previousState)
        elapsedTime = 0.0
        
        //PoliceBot is no longer enroute to support, but is in the Wall
//        entity.isSupporting = false
        
        guard let policeBot = entity as? PoliceBot else { return }
//        print("PoliceBotInWallState didEnter: entity: \(entity.debugDescription), Current behaviour mandate: \(entity.mandate), isWall: \(entity.isWall), requestWall: \(entity.requestWall), isSupporting: \(entity.isSupporting), wallComponentisTriggered: \(String(describing: entity.component(ofType: WallComponent.self)?.isTriggered))")

        
//        // `movementComponent` is a computed property. Declare a local version so we don't compute it multiple times.
//        let movementComponent = self.movementComponent
//
//        // Move the `ManBot` towards the target at an increased speed.
//        movementComponent.movementSpeed *= GameplayConfiguration.TaskBot.movementSpeedMultiplierWhenAttacking
//        movementComponent.angularSpeed *= GameplayConfiguration.TaskBot.angularSpeedMultiplierWhenAttacking
//
////        movementComponent.nextTranslation = MovementKind(displacement: targetVector)
//        movementComponent.nextRotation = nil
        
        //When TaskBot has joined wall, move TaskBot to the side of the joined TaskBot.  (How do we know which side to put it on?  Always position to the right maybe?
        

    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        elapsedTime += seconds
        
//        print("PoliceBotInWallState: \(elapsedTime.description), entity: \(entity.debugDescription), Current behaviour mandate: \(entity.mandate), isWall: \(entity.isWall), requestWall: \(entity.requestWall), isSupporting: \(entity.isSupporting), wallComponentisTriggered: \(String(describing: entity.component(ofType: WallComponent.self)?.isTriggered))")

        

        
        
        //Ensure PoliceBot orientated in the correct direction
        
        // `orientationComponent` is a computed property. Declare a local version so we don't compute it multiple times.
        let orientationComponent = self.orientationComponent
        
        // Calculate the angle the `ManBot` needs to turn to face the `targetPosition`.
        let angleDeltaToTarget = shortestAngleDeltaToTargetFromRotation(entityRotation: Float(orientationComponent.zRotation))
        
        // Calculate the amount of rotation that should be applied during this update.
        var delta = CGFloat(seconds * GameplayConfiguration.TaskBot.preAttackRotationSpeed)
        if angleDeltaToTarget < 0
        {
            delta *= -1
        }
        
        // Check if the `ManBot` would reach the angle required to face the target during this update.
        if abs(delta) >= abs(angleDeltaToTarget)
        {
            // Finish the rotation and enter `PoliceBotPreAttackState`.
            orientationComponent.zRotation += angleDeltaToTarget
//            stateMachine?.enter(PoliceBotPreAttackState.self)
            intelligenceComponent.stateMachine.enter(TaskBotAgentControlledState.self)
            return
        }
        
        // Apply the delta to the `ManBot`'s rotation.
        orientationComponent.zRotation += delta
        
        // The `ManBot` may have rotated into a new `FacingDirection`, so re-request the "walk forward" animation.
//        animationComponent.requestedAnimationState = .idle
        
        
        wallComponent.stateMachine.update(deltaTime: seconds)
        

        

    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
            
        case is TaskBotAgentControlledState.Type, is TaskBotFleeState.Type, is TaskBotInjuredState.Type,  is TaskBotZappedState.Type,
             is PoliceBotHitState.Type:
            return true
            
        default:
            return false
        }
    }
    
    override func willExit(to nextState: GKState)
    {
        super.willExit(to: nextState)
        
//        // `movementComponent` is a computed property. Declare a local version so we don't compute it multiple times.
//        let movementComponent = self.movementComponent
//
//        // Stop the `ManBot`'s movement and restore its standard movement speed.
//        movementComponent.nextRotation = nil
//        movementComponent.nextTranslation = nil
//        movementComponent.movementSpeed /= GameplayConfiguration.TaskBot.movementSpeedMultiplierWhenAttacking
//        movementComponent.angularSpeed /= GameplayConfiguration.TaskBot.angularSpeedMultiplierWhenAttacking
    }
    
    // MARK: Convenience
    
    func shortestAngleDeltaToTargetFromRotation(entityRotation: Float) -> CGFloat
    {
        // Determine the start and end points and the angle the `ManBot` is facing.
        let ManBotPosition = entity.agent.position
        let targetPosition = self.targetPosition
        
        // Create a vector that represents the translation from the `ManBot` to the target position.
        let translationVector = float2(x: targetPosition.x - ManBotPosition.x, y: targetPosition.y - ManBotPosition.y)
        
        // Create a unit vector that represents the angle the `ManBot` is facing.
        let angleVector = float2(x: cos(entityRotation), y: sin(entityRotation))
        
        // Calculate dot and cross products.
        let dotProduct = dot(translationVector, angleVector)
        let crossProduct = cross(translationVector, angleVector)
        
        // Use the dot product and magnitude of the translation vector to determine the shortest angle to face the target.
        let translationVectorMagnitude = hypot(translationVector.x, translationVector.y)
        let angle = acos(dotProduct / translationVectorMagnitude)
        
        // Use the cross product to determine the direction of travel to face the target.
        if crossProduct.z < 0
        {
            return CGFloat(angle)
        }
        else
        {
            return CGFloat(-angle)
        }
    }
    
}


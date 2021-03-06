/*
//
//  HoldTheLineState.swift
//  ECGameFramework
//
//  Created by Spaceman on 17/09/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//
Abstract:

 Police are connected and no more Police can join the line at this time.
 The Police should move into a line forming a wall, facing the target location.
 Police should use the WallComponent targetPosition to orientate themselves towards the target.
*/

import SpriteKit
import GameplayKit

class HoldTheLineState: GKState
{
    // MARK: Properties
    
    unowned var wallComponent: WallComponent
    unowned var entity: PoliceBot
    
    /// The amount of time the beam has been cooling down.
    var elapsedTime: TimeInterval = 0.0


    var intelligenceComponent: IntelligenceComponent
    {
        guard let intelligenceComponent = entity.component(ofType: IntelligenceComponent.self) else { fatalError("A HoldTheLineState entity must have an IntelligenceComponent.") }
        return intelligenceComponent
    }
    
    // The `MovementComponent` associated with the `entity`.
    var movementComponent: MovementComponent
    {
        guard let movementComponent = entity.component(ofType: MovementComponent.self) else { fatalError("A HoldTheLineState entity must have a MovementComponent.") }
        return movementComponent
    }
    
    /// The `OrientationComponent` associated with the `entity`.
    var orientationComponent: OrientationComponent
    {
        guard let orientationComponent = wallComponent.entity!.component(ofType: OrientationComponent.self) else { fatalError("A HoldTheLineState entity must have an OrientationComponent.") }
        return orientationComponent
    }
    
    var renderComponent: RenderComponent
    {
        guard let renderComponent = wallComponent.entity!.component(ofType: RenderComponent.self) else { fatalError("A HoldTheLineState entity must have an RenderComponent.") }
        return renderComponent
    }
    
    
    /// The `targetPosition` from the `entity`.
    var targetPosition: float2
    {
        guard let targetPosition = entity.targetPosition else { fatalError("A HoldTheLineState entity must have a targetLocation set.") }
        return targetPosition
    }
    
    
    // MARK: Initializers
    
    required init(wallComponent: WallComponent, entity: TaskBot)
    {
        self.wallComponent = wallComponent
        self.entity = entity as! PoliceBot
    }
    
    deinit {
        //        print("Deallocating HoldTheLineState")
    }
    
    // MARK: GKState life cycle
    
    override func didEnter(from previousState: GKState?)
    {
        print("HoldTheLineState: entity: \(entity.debugDescription), Current behaviour mandate: \(entity.mandate), isWall: \(entity.isWall), requestWall: \(entity.requestWall), isSupporting: \(entity.isSupporting), wallComponentisTriggered: \(String(describing: entity.component(ofType: WallComponent.self)?.isTriggered))")
        
        
        super.didEnter(from: previousState)
        elapsedTime = 0.0
        
        
        // `movementComponent` is a computed property. Declare a local version so we don't compute it multiple times.
//        let movementComponent = self.movementComponent
//        
//        // Stop the `ProtestorBot`'s movement and restore its standard movement speed.
//        movementComponent.nextRotation = nil
//        movementComponent.nextTranslation = nil
//        movementComponent.movementSpeed = 0
//        movementComponent.angularSpeed = 0
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
//        print("HoldTheLineState update")
  
//        print("HoldTheLineState: entity: \(entity.debugDescription), Current behaviour mandate: \(entity.mandate), isWall: \(entity.isWall), requestWall: \(entity.requestWall), isSupporting: \(entity.isSupporting), wallComponentisTriggered: \(String(describing: entity.component(ofType: WallComponent.self)?.isTriggered))")

//        guard let targetProtestor = state.nearestProtestorTaskBotTarget?.target.agent else { return }
        
        
        super.update(deltaTime: seconds)
        elapsedTime += seconds
        
        //If the WallComponent has been triggered, align towards target location
        if wallComponent.isTriggered
        {
        
            //Check TaskBot is in wall before proceeding
            if entity.isWall
            {
       
                //Orientate the TaskBot to be the same as all others in the Wall
            
            
                // `orientationComponent` is a computed property. Declare a local version so we don't compute it multiple times.
                let orientationComponent = self.orientationComponent

                // Calculate the angle the `ManBot` needs to turn to face the `targetPosition`.
                let angleDeltaToTarget = shortestAngleDeltaToTargetFromRotation(entityRotation: Float(orientationComponent.zRotation))

                // Calculate the amount of rotation that should be applied during this update.
                var delta = CGFloat(seconds * GameplayConfiguration.Wall.wallRotationSpeed)
                if angleDeltaToTarget < 0
                {
                    delta *= -1
                }

                // Check if the `ManBot` would reach the angle required to face the target during this update.
                if abs(delta) >= abs(angleDeltaToTarget)
                {
                    // Finish the rotation and enter `PoliceBotPreAttackState`.
                    orientationComponent.zRotation += angleDeltaToTarget

    //                //Check enough time has elapsed and TaskBot is in wall before moving to next state
    //                if elapsedTime >= 2.0
    //                {
    //                    stateMachine?.enter(MoveForwardState.self)
    //                }

                    return
                }

                // Apply the delta to the `ManBot`'s rotation.
                orientationComponent.zRotation += delta
            
            
                //Check enough time has elapsed and TaskBot is in wall before moving to next state
                if elapsedTime >= 10.0
                {
                    stateMachine?.enter(MoveForwardState.self)
                }
            
    //            intelligenceComponent.stateMachine.enter(TaskBotAgentControlledState.self)
            }
        }

        //If the WallComponent is not triggered, disband from the wall.
        else
        {
            stateMachine?.enter(DisbandState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case /*is MoveBackwardState.Type, is RetreatState.Type,*/ is MoveForwardState.Type, is DisbandState.Type:
            return true
            
        default:
            return false
        }
    }
    
    override func willExit(to nextState: GKState)
    {
        super.willExit(to: nextState)
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

/*
//  ManBotRotateToAttackState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 01/03/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

 Abstract:
 A state that `ManBot`s enter prior to rotate toward the `PlayerBot` or another `TaskBot` prior to attack.
*/

import SpriteKit
import GameplayKit

class ManBotRotateToAttackState: GKState
{
    // MARK: Properties
    
    unowned var entity: ManBot
    
    /// The `AnimationComponent` associated with the `entity`.
    var animationComponent: AnimationComponent
    {
        guard let animationComponent = entity.component(ofType: AnimationComponent.self) else { fatalError("A ManBotRotateToAttackState's entity must have an AnimationComponent.") }
        return animationComponent
    }
    
    /// The `OrientationComponent` associated with the `entity`.
    var orientationComponent: OrientationComponent
    {
        guard let orientationComponent = entity.component(ofType: OrientationComponent.self) else { fatalError("A ManBotRotateToAttackState's entity must have an OrientationComponent.") }
        return orientationComponent
    }
    
    /// The `targetPosition` from the `entity`.
    var targetPosition: float2
    {
        guard let targetPosition = entity.targetPosition else { fatalError("A ManBotRotateToAttackState's entity must have a targetLocation set.") }
        return targetPosition
    }
    
    // MARK: Initializers
    
    required init(entity: ManBot)
    {
        self.entity = entity
    }
    
    deinit {
        print("Deallocating ManBotRotateToAttackState")
    }
    
    // MARK: GPState Life Cycle
    
    override func didEnter(from previousState: GKState?)
    {
        super.didEnter(from: previousState)
        
        // Request the "walk forward" animation for this `ManBot`.
        animationComponent.requestedAnimationState = .idle
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
        // `orientationComponent` is a computed property. Declare a local version so we don't compute it multiple times.
        let orientationComponent = self.orientationComponent
        
        // Calculate the angle the `ManBot` needs to turn to face the `targetPosition`.
        let angleDeltaToTarget = shortestAngleDeltaToTargetFromRotation(entityRotation: Float(orientationComponent.zRotation))
        
        // Calculate the amount of rotation that should be applied during this update.
        var delta = CGFloat(seconds * GameplayConfiguration.ManBot.preAttackRotationSpeed)
        if angleDeltaToTarget < 0
        {
            delta *= -1
        }
        
        // Check if the `ManBot` would reach the angle required to face the target during this update.
        if abs(delta) >= abs(angleDeltaToTarget)
        {
            // Finish the rotation and enter `ManBotPreAttackState`.
            orientationComponent.zRotation += angleDeltaToTarget
            stateMachine?.enter(ManBotPreAttackState.self)
            return
        }
        
        // Apply the delta to the `ManBot`'s rotation.
        orientationComponent.zRotation += delta
        
        // The `ManBot` may have rotated into a new `FacingDirection`, so re-request the "walk forward" animation.
        animationComponent.requestedAnimationState = .idle
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is TaskBotAgentControlledState.Type, is ManBotPreAttackState.Type, is TaskBotZappedState.Type:
            return true
            
        default:
            return false
        }
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

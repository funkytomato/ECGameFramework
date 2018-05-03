/*
//
//  TaskBotFleeState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 19/04/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
The state of a `TaskBot` when actively fleeing from another another `TaskBot`.

*/

import SpriteKit
import GameplayKit

class TaskBotFleeState: GKState
{
    // MARK: Properties
    
    unowned var entity: TaskBot
    
    //The amount of time the 'ManBot' has been in its "Arrested" state
    var elapsedTime: TimeInterval = 0.0
    
    /// The distance to the current target on the previous update loop.
    var lastDistanceToTarget: Float = 0
    
    /// The `MovementComponent` associated with the `entity`.
    var movementComponent: MovementComponent
    {
        guard let movementComponent = entity.component(ofType: MovementComponent.self) else { fatalError("A TaskBot FleeState's entity must have a MovementComponent.") }
        return movementComponent
    }
    
    /// The `PhysicsComponent` associated with the `entity`.
    var physicsComponent: PhysicsComponent
    {
        guard let physicsComponent = entity.component(ofType: PhysicsComponent.self) else { fatalError("A TaskBot FleeState's entity must have a PhysicsComponent.") }
        return physicsComponent
    }
    
    /// The `IntelligenceComponent` associated with the `entity`.
    var intelligenceComponent: IntelligenceComponent
    {
        guard let intelligenceComponent = entity.component(ofType: IntelligenceComponent.self) else { fatalError("An entity's FleeState's must have an IntelligenceComponent.") }
        return intelligenceComponent
    }
    
    
    // MARK: Initializers
    
    required init(entity: TaskBot)
    {
        self.entity = entity
    }
    
    // MARK: GKState Life Cycle
    
    override func didEnter(from previousState: GKState?)
    {
        super.didEnter(from: previousState)
        
        
        //Reset the tracking of how long the 'ManBot' has been in "Scared" state
        elapsedTime = 0.0
        
        //entity.mandate = .fleeAgent(<#T##GKAgent2D#>)   FRY set the mandate here?
        
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
        elapsedTime += seconds
        
        intelligenceComponent.stateMachine.enter(TaskBotAgentControlledState.self)

    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is TaskBotAgentControlledState.Type, is TaskBotZappedState.Type:
            return true
            
        default:
            return false
        }
    }
    
    override func willExit(to nextState: GKState)
    {
        super.willExit(to: nextState)
        
        // `movementComponent` is a computed property. Declare a local version so we don't compute it multiple times.
        let movementComponent = self.movementComponent
        
        // Stop the `ManBot`'s movement and restore its standard movement speed.
        movementComponent.nextRotation = nil
        movementComponent.nextTranslation = nil
        movementComponent.movementSpeed /= GameplayConfiguration.ManBot.movementSpeedMultiplierWhenAttacking
        movementComponent.angularSpeed /= GameplayConfiguration.ManBot.angularSpeedMultiplierWhenAttacking
    }
    
    // MARK: Convenience
    
    
}

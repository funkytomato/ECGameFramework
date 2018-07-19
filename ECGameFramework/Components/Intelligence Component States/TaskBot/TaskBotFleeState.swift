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
        guard let movementComponent = entity.component(ofType: MovementComponent.self) else { fatalError("A TaskBotFleeState entity must have a MovementComponent.") }
        return movementComponent
    }
    
    var temperamentComponent: TemperamentComponent
    {
        guard let temperamentComponent = entity.component(ofType: TemperamentComponent.self) else { fatalError("An entity's FleeState's must have an TemperamentComponent.") }
        return temperamentComponent
    }
    
    var physicsComponent: PhysicsComponent
    {
        guard let physicsComponent = entity.component(ofType: PhysicsComponent.self) else { fatalError("An entity's FleeState's must have an PhysicsComponent.") }
        return physicsComponent
    }
    
    var animationComponent: AnimationComponent
    {
        guard let animationComponent = entity.component(ofType: AnimationComponent.self) else { fatalError("An entity's FleeState's must have an AnimationComponent.") }
        return animationComponent
    }
    
    // MARK: Initializers
    
    required init(entity: TaskBot)
    {
        self.entity = entity
    }
    
    deinit {
//        print("Deallocating TaskBotFleeState")
    }
    
    // MARK: GKState Life Cycle
    
    override func didEnter(from previousState: GKState?)
    {
        super.didEnter(from: previousState)
        
        self.entity.isScared = true  //fry
        self.entity.isDangerous = false

        animationComponent.requestedAnimationState = .idle
        
        
        // `movementComponent` is a computed property. Declare a local version so we don't compute it multiple times.
        let movementComponent = self.movementComponent
        
        // Move the `ManBot` towards the target at an increased speed.
        movementComponent.movementSpeed *= GameplayConfiguration.TaskBot.movementSpeedMultiplierWhenFleeing
        movementComponent.angularSpeed *= GameplayConfiguration.TaskBot.angularSpeedMultiplierWhenFleeing
        
        
        
        //Reset the tracking of how long the 'ManBot' has been in "Scared" state
        elapsedTime = 0.0
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        elapsedTime += seconds
        
        stateMachine?.enter(TaskBotAgentControlledState.self)
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is TaskBotAgentControlledState.Type, /*is TaskBotFleeState.Type,*/ is TaskBotInjuredState.Type,  is TaskBotZappedState.Type:
            return true
            
        default:
            return false
        }
    }
    
    override func willExit(to nextState: GKState)
    {
        super.willExit(to: nextState)
        
//        physicsComponent.physicsBody.mass = CGFloat(GameplayConfiguration.TaskBot.agentMass)
    }
    
    // MARK: Convenience
    
}

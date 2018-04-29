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
    
    
    // MARK: Initializers
    
    required init(entity: TaskBot)
    {
        self.entity = entity
    }
    
    // MARK: GKState Life Cycle
    
    override func didEnter(from previousState: GKState?)
    {
        super.didEnter(from: previousState)
        
        //Find the nearest dangerous Protestor or Violent Policeman.  They will be the source of the fear
        
        
        //entity.mandate = .flee(<#T##GKAgent2D#>)
     }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
        
        
        
        stateMachine?.enter(TaskBotFleeState.self)
        
        //Only move to taskbotagent after moving far away from dangerous protestors or violent police
        //stateMachine?.enter(TaskBotAgentControlledState.self)
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is TaskBotAgentControlledState.Type, is TaskBotFleeState.Type, is TaskBotZappedState.Type:
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

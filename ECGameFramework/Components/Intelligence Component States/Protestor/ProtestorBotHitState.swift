/*
//
//  ProtestorBotHitState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 24/04/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
A state used to represent the player when hit by a `TaskBot` attack.
*/

import SpriteKit
import GameplayKit

class ProtestorBotHitState: GKState
{
    // MARK: Properties
    
    unowned var entity: ProtestorBot
    
    /// The amount of time the `PlayerBot` has been in the "hit" state.
    var elapsedTime: TimeInterval = 0.0
    
    /// The `AnimationComponent` associated with the `entity`.
    var animationComponent: AnimationComponent
    {
        guard let animationComponent = entity.component(ofType: AnimationComponent.self) else { fatalError("A ProtestorBotHitState's entity must have an AnimationComponent.") }
        return animationComponent
    }
    
    var chargeComponent: ChargeComponent
    {
        guard let chargeComponent = entity.component(ofType: ChargeComponent.self) else { fatalError("A ProtestorBotHitState's entity must have a ChargeComponent")}
        return chargeComponent
    }
    
    var healthComponent: HealthComponent
    {
        guard let healthComponent = entity.component(ofType: HealthComponent.self) else { fatalError("A ProtestorBotHitState's entity must have a HealthComponent")}
        return healthComponent
    }
    
    var temperamentComponent: TemperamentComponent
    {
        guard let temperamentComponent = entity.component(ofType: TemperamentComponent.self) else { fatalError("A ProtestorBotHitState's entity must have a TemperamentComponent") }
        return temperamentComponent
    }
    
    // MARK: Initializers
    
    required init(entity: ProtestorBot)
    {
        self.entity = entity
    }
    
    // MARK: GKState Life Cycle
    
    override func didEnter(from previousState: GKState?)
    {
        super.didEnter(from: previousState)
        
        // Reset the elapsed "hit" duration on entering this state.
        elapsedTime = 0.0
        
        // Request the "hit" animation for this `PlayerBot`.
        animationComponent.requestedAnimationState = .hit
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
        // Update the amount of time the `PlayerBot` has been in the "hit" state.
        elapsedTime += seconds
   
        
        if !healthComponent.hasHealth
        {
            temperamentComponent.stateMachine.enter(SubduedState.self)
            stateMachine?.enter(TaskBotAgentControlledState.self)
        }
        else if healthComponent.health < 40.0
        {
            stateMachine?.enter(ProtestorBeingArrestedState.self)
        }
        
        else
        {
            //temperamentComponent.increaseTemperament()
            temperamentComponent.decreaseTemperament()
            stateMachine?.enter(TaskBotAgentControlledState.self)
            
            /*
            if ((temperamentComponent.stateMachine.currentState as? ScaredState) != nil)
            {
                stateMachine?.enter(TaskBotFleeState.self)
            }
            else
            {
                stateMachine?.enter(TaskBotAgentControlledState.self)
            }
 */
        }

        
        
        
        
        
        
        /*
        // When the `PlayerBot` has been in this state for long enough, transition to the appropriate next state.
        if elapsedTime >= GameplayConfiguration.ProtestorBot.hitStateDuration
        {
            if entity.isPoweredDown
            {
                stateMachine?.enter(ProtestorBotRechargingState.self)
            }
            else
            {
                stateMachine?.enter(TaskBotAgentControlledState.self)
            }
        }
 */
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is TaskBotAgentControlledState.Type, is ProtestorBeingArrestedState.Type, is TaskBotFleeState.Type:
            return true
            
        default:
            return false
        }
    }
}

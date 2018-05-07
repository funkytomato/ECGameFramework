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
    /*
    var chargeComponent: ChargeComponent
    {
        guard let chargeComponent = entity.component(ofType: ChargeComponent.self) else { fatalError("A ProtestorBotHitState's entity must have a ChargeComponent")}
        return chargeComponent
    }
    */
    
    var resistanceComponent: ResistanceComponent
    {
        guard let resistanceComponent = entity.component(ofType: ResistanceComponent.self) else { fatalError("A ProtestorBotHitState's entity must have a ResistanceComponent")}
        return resistanceComponent
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
        
 //       resistanceComponent.isTriggered = true
 //       entity.isResistanceTriggered = true
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
        // Update the amount of time the `PlayerBot` has been in the "hit" state.
        elapsedTime += seconds
   
        //Is the Protestor dead?
        if !healthComponent.hasHealth
        {
            stateMachine?.enter(TaskBotInjuredState.self)
        }
        // Has the Protestor's resistance been broken down?
        else if !resistanceComponent.hasResistance
        {
            //The Protestor is subdued and knackered, arrest them
            temperamentComponent.stateMachine.enter(SubduedState.self)
            //stateMachine?.enter(TaskBotAgentControlledState.self)
            stateMachine?.enter(ProtestorBeingArrestedState.self)
        }
        //Protestor hit, deciding whether to flee or attack
        else
        {
            //temperamentComponent.increaseTemperament()
            temperamentComponent.decreaseTemperament()
            
            
            // Decide what to do on the Protestor's current temperament
            if ((temperamentComponent.stateMachine.currentState as? ScaredState) != nil)
            {
                // Protestor is scared and will attempt to flee from danger
                stateMachine?.enter(TaskBotFleeState.self)
            }
            // Protestor is violent and will fight back
            else if ((temperamentComponent.stateMachine.currentState as? ViolentState) != nil)
            {
                //Protestor will fight back with extreme prejudice
                stateMachine?.enter(ProtestorBotRotateToAttackState.self)
        
            }
            else
            {
                stateMachine?.enter(TaskBotAgentControlledState.self)
            }
 
        }

       /*
        // When the `ProtestorBot` has been in this state for long enough, transition to the appropriate next state.
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
        case is TaskBotAgentControlledState.Type, is ProtestorBeingArrestedState.Type, is TaskBotFleeState.Type, is TaskBotInjuredState.Type:
            return true
            
        default:
            return false
        }
    }
    
    override func willExit(to nextState: GKState)
    {
        super.willExit(to: nextState)
        
        
        //Allow entity to start recharging when not in contact with another entity
        resistanceComponent.isTriggered = false
    }
}

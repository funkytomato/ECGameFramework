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
    
    deinit {
//        print("Deallocating ProtestorBotHitState")
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
        elapsedTime += seconds
   
        // Request the "hit" animation for this `PlayerBot`.
        animationComponent.requestedAnimationState = .hit
        
        //print("hashealth: \(healthComponent.hasHealth) health:\(healthComponent.health)")

        // Protestor has resistance, change their temperament
        if resistanceComponent.hasResistance
        {
            //Create a random number to decide on action
            let changeTemperament = GKMersenneTwisterRandomSource()
            let val = changeTemperament.nextInt(upperBound: 10)
            
            //print("changeTemperament: \(val)")
            
            
            if val < 5
            {
                temperamentComponent.decreaseTemperament()
            }
            else
            {
                temperamentComponent.increaseTemperament()
            }
            
            
            
            // Decide what to do on the Protestor's current temperament
            if ((temperamentComponent.stateMachine.currentState as? ScaredState) != nil)
            {
                // Protestor is scared and will attempt to flee from danger
                stateMachine?.enter(TaskBotFleeState.self)
            }
                // Protestor is violent and will fight back
            else if ((temperamentComponent.stateMachine.currentState as? ViolentState) != nil),
                healthComponent.hasHealth
            {
                //Protestor will fight back with extreme prejudice
                self.entity.isRetaliating = true
            }
            else
            {
                //Protestor is not going to fight back
                self.entity.isRetaliating = false
            }
            
//            stateMachine?.enter(TaskBotAgentControlledState.self)
        }
            

        //Protestor hit, deciding whether to flee or attack
        else
        {
            //Is the Protestor dead?
            if healthComponent.health < 10.0
            {
                //The Protestor is injured or dead and out of the game
                stateMachine?.enter(TaskBotInjuredState.self)
            }
                
            //Protestor is healthy enough to be arrested
            else if healthComponent.hasHealth
            {
                //The Protestor is subdued and knackered, arrest them
                temperamentComponent.stateMachine.enter(SubduedState.self)
                stateMachine?.enter(ProtestorBeingArrestedState.self)
            }

        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is TaskBotAgentControlledState.Type, is TaskBotFleeState.Type, is TaskBotInjuredState.Type,  is TaskBotZappedState.Type,
             is ProtestorBeingArrestedState.Type, is ProtestorBotHitState.Type:
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

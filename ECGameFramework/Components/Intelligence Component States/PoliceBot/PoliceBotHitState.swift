/*
//
//  PoliceBotHitState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 24/04/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
A state used to represent the PoliceBot when hit by a `TaskBot` attack.
*/

import SpriteKit
import GameplayKit

class PoliceBotHitState: GKState
{
    // MARK: Properties
    
    unowned var entity: PoliceBot
    
    /// The amount of time the `PlayerBot` has been in the "hit" state.
    var elapsedTime: TimeInterval = 0.0
    
    /// The `AnimationComponent` associated with the `entity`.
    var animationComponent: AnimationComponent
    {
        guard let animationComponent = entity.component(ofType: AnimationComponent.self) else { fatalError("A PoliceBotHitState's entity must have an AnimationComponent.") }
        return animationComponent
    }
    
    var healthComponent: HealthComponent
    {
        guard let healthComponent = entity.component(ofType: HealthComponent.self) else { fatalError("A PoliceBotHitState's entity must have an HealthComponent.") }
        return healthComponent
    }

    var intelligenceComponent: IntelligenceComponent
    {
        guard let intelligenceComponent = entity.component(ofType: IntelligenceComponent.self) else { fatalError("A PoliceBotHitState's entity must have an IntelligenceComponent.") }
        return intelligenceComponent
    }
    
    var resistanceComponent: ResistanceComponent
    {
        guard let resistanceComponent = entity.component(ofType: ResistanceComponent.self) else { fatalError("A ProtestorBotHitState's entity must have a ResistanceComponent")}
        return resistanceComponent
    }
    
    // MARK: Initializers
    
    required init(entity: PoliceBot)
    {
        self.entity = entity
    }
    
    
    deinit {
        print("Deallocating PoliceBotHitState")
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

        
        // Has the Protestor's resistance been broken down?
        if !resistanceComponent.hasResistance
        {
            //Is the Protestor dead?
            if !healthComponent.hasHealth
            {
                //The Protestor is injured or dead and out of the game
                stateMachine?.enter(TaskBotInjuredState.self)
            }
            else if healthComponent.health < 50.0
            {
                //The Police is scared and will flee
                entity.isScared = true
                stateMachine?.enter(TaskBotFleeState.self)
            }
            else
            {
                //The Protestor is subdued and knackered, arrest them
                //temperamentComponent.stateMachine.enter(SubduedState.self)
                stateMachine?.enter(PoliceArrestState.self)
            }
        }
        
        
        // When the `PlayerBot` has been in this state for long enough, transition to the appropriate next state.
//        if elapsedTime >= GameplayConfiguration.PoliceBot.hitStateDuration
//        {
//            if entity.tazerPoweredDown
//            {
//                stateMachine?.enter(PoliceBotRechargingState.self)
//            }
//            else
//            {
//                stateMachine?.enter(TaskBotAgentControlledState.self)
//            }
//        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is TaskBotAgentControlledState.Type, is PoliceBotRechargingState.Type:
            return true
            
        default:
            return false
        }
    }
}


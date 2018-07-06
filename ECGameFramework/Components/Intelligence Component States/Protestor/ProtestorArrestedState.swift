/*
//
//  ProtestorArrestedState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 10/04/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//
 Abstract:
 The state `ManBot`s are in immediately after being arrested.
 
 Remove all behavour from bot and attach to the arresting entity.
 
*/

import SpriteKit
import GameplayKit

class ProtestorArrestedState: GKState
{
    // MARK:- Properties
    unowned var entity: ProtestorBot
    
    //The amount of time the 'ProtestorBot' has been in its "Arrested" state
    var elapsedTime: TimeInterval = 0.0
    
    
    /// The `AnimationComponent` associated with the `entity`.
    var animationComponent: AnimationComponent
    {
        guard let animationComponent = entity.component(ofType: AnimationComponent.self) else { fatalError("An ProtestorArrestedState's entity must have an AnimationComponent.") }
        return animationComponent
    }
    
    
    //MARK:- Initializers
    required init(entity: ProtestorBot)
    {
        self.entity = entity
    }
    
    
    deinit {
//        print("Deallocating ProtestorArrestedState")
    }
    
    //MARK:- GKState Life Cycle
    override func didEnter(from previousState: GKState?)
    {
        super.didEnter(from: previousState)
        
        //Reset the tracking of how long the 'ManBot' has been in "Arrested" state
        elapsedTime = 0.0
        
        //Request the "beingArrested animation for this state's 'ManBot'
        animationComponent.requestedAnimationState = .arrested
        
        applyCuffsToEntity(entity: self.entity)
        
        self.entity.isActive = false
        
        self.entity.isArrested = true
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        elapsedTime += seconds
        
        //Request the "beingArrested animation for this state's 'ManBot'
        animationComponent.requestedAnimationState = .arrested
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is TaskBotAgentControlledState.Type, is TaskBotInjuredState.Type,  is TaskBotZappedState.Type,
             is ProtestorDetainedState.Type:
            return true
            
        default:
            return false
        }
    }
    
    
    // MARK: Convenience
    
    func applyCuffsToEntity(entity: GKEntity)
    {
        if let playerBot = entity as? PlayerBot, let chargeComponent = playerBot.component(ofType: ChargeComponent.self), !playerBot.isPoweredDown
        {
            // If the other entity is a `PlayerBot` that isn't powered down, reduce its charge.
            chargeComponent.loseCharge(chargeToLose: GameplayConfiguration.ManBot.chargeLossPerContact)
        }
        else if let protestorBot = entity as? ProtestorBot, protestorBot.isGood, let temperamentComponent = entity.component(ofType: TemperamentComponent.self)
        {
            temperamentComponent.stateMachine.enter(SubduedState.self)
        }
    }
}

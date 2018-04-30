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
    
    /// The `PhysicsComponent` associated with the `entity`.
    var physicsComponent: PhysicsComponent
    {
        guard let physicsComponent = entity.component(ofType: PhysicsComponent.self) else { fatalError("An ArrestedState's entity must have a PhysicsComponent.") }
        return physicsComponent
    }
    
    //MARK:- Initializers
    required init(entity: ProtestorBot)
    {
        self.entity = entity
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
        
        /*
        // Apply damage to any entities the `GroundBot` is already in contact with.
        let contactedBodies = physicsComponent.physicsBody.allContactedBodies()
        for contactedBody in contactedBodies
        {
            guard let entity = contactedBody.node?.entity else { continue }
            applyCuffsToEntity(entity: entity)
        }
        */
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
        elapsedTime += seconds
        
        /*
        If the arrested manbot reaches the meatwagon pointer, move to detained state
        */
        if elapsedTime >= GameplayConfiguration.TaskBot.arrestedStateDuration
        {
            stateMachine?.enter(ProtestorDetainedState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is TaskBotAgentControlledState.Type, is ProtestorDetainedState.Type:
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
        /*
        else if let taskBot = entity as? TaskBot, taskBot.isGood
        {
            temperamentComponent.stateMachine.enter(SubduedState.self)
            
            
            // If the other entity is a good `TaskBot`, turn it bad.
            //taskBot.isGood = false
        }
        */
        else if let protestorBot = entity as? ProtestorBot, protestorBot.isProtestor, let temperamentComponent = entity.component(ofType: TemperamentComponent.self)
        {
            temperamentComponent.stateMachine.enter(SubduedState.self)
            //protestorBot.isActive = false
            //temperamentComponent.stateMachine.enter(AngryState.self)
            
            //Stop Police chasing this protestor
            //protestorBot.isGood = false
            
            // If the other entity is a good `TaskBot`, turn it bad.
            //taskBot.isGood = false
        }
    }
}

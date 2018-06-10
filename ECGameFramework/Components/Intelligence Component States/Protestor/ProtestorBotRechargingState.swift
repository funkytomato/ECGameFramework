/*
//
//  ProtestorBotRechargingState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 23/04/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
A state used to represent the player when immobilized by `TaskBot` attacks.
*/

import SpriteKit
import GameplayKit

class ProtestorBotRechargingState: GKState
{
    // MARK: Properties
    
    unowned var entity: ProtestorBot
    
    /// The amount of time the `PlayerBot` has been in the "recharging" state.
    var elapsedTime: TimeInterval = 0.0
    
    /// The `AnimationComponent` associated with the `entity`.
    var animationComponent: AnimationComponent
    {
        guard let animationComponent = entity.component(ofType: AnimationComponent.self) else { fatalError("A ProtestorBotRechargingState's entity must have an AnimationComponent.") }
        return animationComponent
    }
    
    /// The `ResistanceComponent` associated with the `entity`.
    var resistanceComponent: ResistanceComponent
    {
        guard let resistanceComponent = entity.component(ofType: ResistanceComponent.self) else { fatalError("A ProtestorBotRechargingState's entity must have a ResistanceComponent.") }
        return resistanceComponent
    }

    /// The `ObeisanceComponent` associated with the `entity`.
    var obeisanceComponent: ObeisanceComponent
    {
        guard let obeisanceComponent = entity.component(ofType: ObeisanceComponent.self) else { fatalError("A ProtestorBotRechargingState's entity must have a ObeisanceComponent.") }
        return obeisanceComponent
    }
    
    // MARK: Initializers
    
    required init(entity: ProtestorBot)
    {
        self.entity = entity
    }
    
    deinit {
        print("Deallocating ProtestorBotRechargingState")
    }
    
    // MARK: GKState life cycle
    
    override func didEnter(from previousState: GKState?)
    {
        super.didEnter(from: previousState)
        
        // Reset the recharge duration when entering this state.
        elapsedTime = 0.0
        
        // Request the "inactive" animation for the `ProtestorBot`.
        animationComponent.requestedAnimationState = .inactive
        
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
        // Update the elapsed recharge duration.
        elapsedTime += seconds
        
        /**
         There is a delay from when the `TaskBot` enters this state to when it begins to recharge.
         Do nothing if the `TaskBot` hasn't been in this state long enough.
         */
        if elapsedTime < GameplayConfiguration.ProtestorBot.rechargeDelayWhenInactive { return }
      
        
        // `ObeisanceComponent` is a computed property. Declare a local version so we don't compute it multiple times.
        let obeisanceComponent = self.obeisanceComponent
        
        // Add resistance to the `ProtestorBot`.
        var amountToRecharge = GameplayConfiguration.ProtestorBot.rechargeAmountPerSecond * seconds
        obeisanceComponent.addObeisance(obeisanceToAdd: amountToRecharge)
        
        // If the `ProtestorBot` is fully charged it can become agent controlled again.
        if obeisanceComponent.hasFullObeisance
        {
            //entity.isPoweredDown = false
            stateMachine?.enter(TaskBotAgentControlledState.self)
        }
        
        
        // `resistanceComponent` is a computed property. Declare a local version so we don't compute it multiple times.
        let resistanceComponent = self.resistanceComponent
        
        // Add resistance to the `ProtestorBot`.
        amountToRecharge = GameplayConfiguration.ProtestorBot.rechargeAmountPerSecond * seconds
        resistanceComponent.addResistance(resistanceToAdd: amountToRecharge)
        
        // If the `ProtestorBot` is fully charged it can become agent controlled again.
        if resistanceComponent.isFullyResistanced
        {
            //entity.isPoweredDown = false
            stateMachine?.enter(TaskBotAgentControlledState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        return stateClass is TaskBotAgentControlledState.Type
    }
}

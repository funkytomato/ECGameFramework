/*
//
//  BuyWaresLookingState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 30/06/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
The state representing the `TaskBot' while actively inciting others.
*/

import SpriteKit
import GameplayKit

class BuyingWaresLookingState: GKState
{
    // MARK: Properties
    unowned var buyWaresComponent: BuyingWaresComponent
    
    
    
    /// The amount of time the beam has been in its "firing" state.
    var elapsedTime: TimeInterval = 0.0
    
    
    // MARK: Initializers
    
    required init(buyWaresComponent: BuyingWaresComponent)
    {
        self.buyWaresComponent = buyWaresComponent
    }
    
    deinit {
//        print("Deallocating BuyWaresLookingState")
    }
    
    // MARK: GKState life cycle
    
    override func didEnter(from previousState: GKState?)
    {
//        print("BuyWaresLookingState entered: \(buyWaresComponent.entity.debugDescription)")
        
        super.didEnter(from: previousState)
        elapsedTime = 0.0
        
        //Protestor is hungry
        guard let protestorBot = buyWaresComponent.entity as? ProtestorBot else { return }
        protestorBot.isHungry = true
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        elapsedTime += seconds
        
//        print("BuyWaresActiveState updating")
    
        if elapsedTime >= GameplayConfiguration.Wares.maximumLookingDuration
        {
            stateMachine?.enter(BuyingWaresTimeOutState.self)
        }
        
        else if buyWaresComponent.hasWares
        {
            stateMachine?.enter(BuyingWaresBuyingState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is BuyingWaresBuyingState.Type, is BuyingWaresTimeOutState.Type:
            return true
            
        default:
            return false
        }
    }
    
    override func willExit(to nextState: GKState)
    {
        buyWaresComponent.isTriggered = false
        
        //Protestor is hungry
        guard let protestorBot = buyWaresComponent.entity as? ProtestorBot else { return }
        protestorBot.isHungry = false
        
        
        super.willExit(to: nextState)
    }
    
    // MARK: Convenience
    func buyProductFromSeller(entity: GKEntity)
    {
        //        print("entity: \(self.entity.debugDescription) target: \(entity.debugDescription)")
        
        if let playerBot = entity as? PlayerBot,/* let chargeComponent = playerBot.component(ofType: ChargeComponent.self),*/ !playerBot.isPoweredDown
        {
            // If the other entity is a `PlayerBot` that isn't powered down, reduce its charge.
            //chargeComponent.loseCharge(chargeToLose: GameplayConfiguration.ManBot.chargeLossPerContact)
        }
        else if let targetBot = entity as? TaskBot, targetBot.isCriminal, targetBot.isActive,
            let sellingWaresComponent = targetBot.component(ofType: SellingWaresComponent.self)
        {
            
            //Buy product
            sellingWaresComponent.loseWares(waresToLose: 10.0)
            
            //Add product to protestor, trigger consumption
            buyWaresComponent.gainProduct(waresToAdd: 10.0)
            
        }
    }
}

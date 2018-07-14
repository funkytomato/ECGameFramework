/*
//
//  BuyWaresTimeOut.swift
//  ECGameFramework
//
//  Created by Jason Fry on 09/07/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//
    Abstract:
    The state of the `PlayerBot`'s beam when not in use.
*/

import SpriteKit
import GameplayKit

class BuyingWaresTimeOutState: GKState
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
        //        print("Deallocating BuyWaresIdleState")
    }
    
    // MARK: GKState life cycle
    
    override func didEnter(from previousState: GKState?)
    {
        //        print("BuyWaresIdleState entered: \(buyWaresComponent.entity.debugDescription)")
        
        super.didEnter(from: previousState)
        elapsedTime = 0.0
        
        buyWaresComponent.isTriggered = false
        
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        elapsedTime += seconds
        
        //        print("BuyWaresIdleState update: \(buyWaresComponent.entity.debugDescription)")
        

        if elapsedTime >= 15.0
        {
            stateMachine?.enter(BuyingWaresIdleState.self)
//            buyWaresComponent.isTriggered = true
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        return stateClass is BuyingWaresIdleState.Type
    }
}

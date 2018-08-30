/*
//
//  BuyingWaresReturningHomeState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 01/08/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
The state of the `PlayerBot`'s beam when not in use.
*/

import SpriteKit
import GameplayKit

class BuyingWaresReturningHomeState: GKState
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
        //        print("Deallocating BuyingWaresReturningHomeState")
    }
    
    // MARK: GKState life cycle
    
    override func didEnter(from previousState: GKState?)
    {
        //        print("BuyingWaresReturningHomeState entered: \(buyWaresComponent.entity.debugDescription)")
        
        super.didEnter(from: previousState)
        elapsedTime = 0.0
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        elapsedTime += seconds
        
        //        print("BuyingWaresReturningHomeState update: \(buyWaresComponent.entity.debugDescription)")
        
        // If Protestor has reached their home position (where they started before looking for product) move to BuyingWaresIdleState
        guard let protestorBot = buyWaresComponent.entity as? ProtestorBot else { return }
        if protestorBot.isHome
        {
            stateMachine?.enter(BuyingWaresIdleState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        return stateClass is BuyingWaresIdleState.Type
    }
}

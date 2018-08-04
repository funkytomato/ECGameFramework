/*
//
//  BuyWaresIdleState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 30/06/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
The state of the `PlayerBot`'s beam when not in use.
*/

import SpriteKit
import GameplayKit

class BuyingWaresIdleState: GKState
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
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        elapsedTime += seconds
        
//        print("BuyWaresIdleState update: \(buyWaresComponent.entity.debugDescription)")
        
        // If buy a product has been triggered, and has been idle for some time, start searching for a seller
        if buyWaresComponent.isTriggered && elapsedTime >= 20.0
        {
            stateMachine?.enter(BuyingWaresLookingState.self)
            
            //Get the current position and save so that Protestor can return to starting position before looking to buy.
            guard let renderComponent = buyWaresComponent.entity?.component(ofType: RenderComponent.self) else { return }
            buyWaresComponent.returnPosition = float2(renderComponent.node.position)
            
            //Reset the isHome to false
            
            guard let protestorBot = buyWaresComponent.entity as? ProtestorBot else { return }
            protestorBot.isHome = false
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        return stateClass is BuyingWaresLookingState.Type
    }
}

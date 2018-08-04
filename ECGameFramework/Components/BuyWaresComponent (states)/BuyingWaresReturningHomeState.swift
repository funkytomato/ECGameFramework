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
    
        
//        buyWaresComponent.entity.mandate = .returnToPositionOnPath(float2(buyWaresComponent.returnPosition))
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        elapsedTime += seconds
        
        //        print("BuyingWaresReturningHomeState update: \(buyWaresComponent.entity.debugDescription)")
        
        guard let protestor = buyWaresComponent.entity as? ProtestorBot else { return }
        guard let physicsComponent = protestor.component(ofType: PhysicsComponent.self) else { return }
        
        // If Protestor has reached their home position (where they started before looking for product) move to BuyingWaresIdleState
        if buyWaresComponent.isTriggered && elapsedTime >= 20.0
        {
            stateMachine?.enter(BuyingWaresIdleState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        return stateClass is BuyingWaresIdleState.Type
    }
}
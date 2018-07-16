/*
//
//  SellingWaresIdleState.swift
//  ECGameFramework
//
//  Created by Spaceman on 28/06/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
The state of the `PlayerBot`'s beam when not in use.
*/

import SpriteKit
import GameplayKit

class SellingWaresIdleState: GKState
{
    // MARK: Properties
    
    unowned var sellingWaresComponent: SellingWaresComponent
    
    
    
    /// The amount of time the beam has been in its "firing" state.
    var elapsedTime: TimeInterval = 0.0
    
    
    
    // MARK: Initializers
    
    required init(sellingWaresComponent: SellingWaresComponent)
    {
        self.sellingWaresComponent = sellingWaresComponent
    }
    
    deinit {
//        print("Deallocating SellingWaresIdleState")
    }
    
    // MARK: GKState life cycle
    
    override func didEnter(from previousState: GKState?)
    {
//        print("SellingWaresIdleState entered: \(sellingWaresComponent.entity.debugDescription)")
        
        super.didEnter(from: previousState)
        elapsedTime = 0.0
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
//        print("SellingWaresIdleState update: \(sellingWaresComponent.entity.debugDescription)")
        
        // If selling has been triggered, move to SellingWaresActiveState and find somebody who wants to buy
        if sellingWaresComponent.isTriggered
        {
            stateMachine?.enter(SellingWaresActiveState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        return stateClass is SellingWaresActiveState.Type
    }
}

/*
//
//  SellingWaresActiveState.swift
//  ECGameFramework
//
//  Created by Spaceman on 28/06/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
The state representing the `TaskBot' while actively inciting others.
*/

import SpriteKit
import GameplayKit

class SellingWaresActiveState: GKState
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
        print("Deallocating SellingWaresActiveState")
    }
    
    // MARK: GKState life cycle
    
    override func didEnter(from previousState: GKState?)
    {
        print("SellingWaresActiveState entered: \(sellingWaresComponent.entity.debugDescription)")
        
        super.didEnter(from: previousState)
        
        // Reset the "amount of time firing" tracker when we enter the "firing" state.
        elapsedTime = 0.0
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
        print("SellingWaresActiveState updating")
        
        // Update the "amount of time firing" tracker.
        elapsedTime += seconds
        
        if elapsedTime >= GameplayConfiguration.SellingWares.maximumSellingWaresDuration
        {
            /**
             The player has been firing the beam for too long. Enter the `SellingWaresCoolingState`
             to disable firing until the beam has had time to cool down.
             */
            stateMachine?.enter(SellingWaresCoolingState.self)
        }
        else if !sellingWaresComponent.isTriggered
        {
            // The beam is no longer being fired. Enter the `SellingWaresIdleState`.
            stateMachine?.enter(SellingWaresIdleState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is SellingWaresIdleState.Type, is SellingWaresCoolingState.Type:
            return true
            
        default:
            return false
        }
    }
    
    override func willExit(to nextState: GKState)
    {
        super.willExit(to: nextState)
    }
}


/*
//
//  ObserveIdleState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 23/06/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

 Abstract:
 The state of the `PlayerBot`'s beam when not in use.
 */

import SpriteKit
import GameplayKit

class ObserveIdleState: GKState
{
    // MARK: Properties
    
    unowned var observeComponent: ObserveComponent
    
    
    
    /// The amount of time the beam has been in its "firing" state.
    var elapsedTime: TimeInterval = 0.0
    
    
    
    // MARK: Initializers
    
    required init(observeComponent: ObserveComponent)
    {
        self.observeComponent = observeComponent
    }
    
    deinit {
//        print("Deallocating ObserveIdleState")
    }
    
    // MARK: GKState life cycle
    
    override func didEnter(from previousState: GKState?)
    {
//        print("ObserveIdleState entered: \(observeComponent.entity.debugDescription)")
        
        super.didEnter(from: previousState)
        
        // Reset the "amount of time firing" tracker when we enter the "firing" state.
        elapsedTime = 0.0
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
//        print("ObserveIdleState update: \(observeComponent.entity.debugDescription)")
        
        // If the beam has been triggered, enter `ObserveActiveState`.
        if observeComponent.isTriggered
        {
            stateMachine?.enter(ObserveActiveState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        return stateClass is ObserveActiveState.Type
    }
}

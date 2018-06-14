/*
//
//  InciteIdleState.swift
//  ECGameFramework
//
//  Created by Spaceman on 09/06/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
The state of the `PlayerBot`'s beam when not in use.
*/

import SpriteKit
import GameplayKit

class InciteIdleState: GKState
{
    // MARK: Properties
    
    unowned var inciteComponent: InciteComponent
    
    
    
    /// The amount of time the beam has been in its "firing" state.
    var elapsedTime: TimeInterval = 0.0

    
    
    // MARK: Initializers
    
    required init(inciteComponent: InciteComponent)
    {
        self.inciteComponent = inciteComponent
    }
    
    deinit {
        print("Deallocating InciteIdleState")
    }
    
    // MARK: GKState life cycle
    
    override func didEnter(from previousState: GKState?)
    {
        print("InciteIdleState entered: \(inciteComponent.entity.debugDescription)")
        
        super.didEnter(from: previousState)
        
        // Reset the "amount of time firing" tracker when we enter the "firing" state.
        elapsedTime = 0.0 
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
        
        // If the beam has been triggered, enter `InciteActiveState`.
        if inciteComponent.isTriggered
        {
            stateMachine?.enter(InciteActiveState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        return stateClass is InciteActiveState.Type
    }
}

/*
//
//  AppetiteIdleState.swift
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

class AppetiteIdleState: GKState
{
    // MARK: Properties
    
    unowned var appetiteComponent: AppetiteComponent
    
    
    
    /// The amount of time the beam has been in its "firing" state.
    var elapsedTime: TimeInterval = 0.0
    
    
    
    // MARK: Initializers
    
    required init(appetiteComponent: AppetiteComponent)
    {
        self.appetiteComponent = appetiteComponent
    }
    
    deinit {
        print("Deallocating AppetiteIdleState")
    }
    
    // MARK: GKState life cycle
    
    override func didEnter(from previousState: GKState?)
    {
        print("AppetiteIdleState entered: \(appetiteComponent.entity.debugDescription)")
        
        super.didEnter(from: previousState)
        
        // Reset the "amount of time firing" tracker when we enter the "firing" state.
        elapsedTime = 0.0
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
        print("AppetiteIdleState update: \(appetiteComponent.entity.debugDescription)")
        
        // If the beam has been triggered, enter `AppetiteActiveState`.
        if appetiteComponent.isTriggered
        {
            stateMachine?.enter(AppetiteActiveState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        return stateClass is AppetiteActiveState.Type
    }
}

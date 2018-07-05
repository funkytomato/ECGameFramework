/*
//
//  WeaponIdleState.swift
//  ECGameFramework
//
//  Created by Spaceman on 25/04/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

import Foundation   Abstract:
The state of the `TaskBot`'s weapon when not in use.
*/

import SpriteKit
import GameplayKit

class TazerIdleState: GKState
{
    // MARK: Properties
    
    unowned var tazerComponent: TazerComponent
    
    // MARK: Initializers
    
    required init(tazerComponent: TazerComponent)
    {
        self.tazerComponent = tazerComponent
    }
    
    deinit {
//        print("Deallocating TazerIdleState")
    }
    
    // MARK: GKState life cycle
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
        // If the beam has been triggered, enter `TazorFiringState`.
        if tazerComponent.isTriggered
        {
            stateMachine?.enter(TazerFiringState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        return stateClass is TazerFiringState.Type
    }
}

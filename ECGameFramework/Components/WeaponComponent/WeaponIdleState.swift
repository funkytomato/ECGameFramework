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

class WeaponIdleState: GKState
{
    // MARK: Properties
    
    unowned var weaponComponent: WeaponComponent
    
    // MARK: Initializers
    
    required init(weaponComponent: WeaponComponent)
    {
        self.weaponComponent = weaponComponent
    }
    
    // MARK: GKState life cycle
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
        // If the beam has been triggered, enter `WeaponFiringState`.
        if weaponComponent.isTriggered
        {
            stateMachine?.enter(WeaponFiringState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        return stateClass is WeaponFiringState.Type
    }
}

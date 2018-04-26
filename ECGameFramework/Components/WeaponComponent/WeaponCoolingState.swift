/*
//
//  WeaponCoolingState.swift
//  ECGameFramework
//
//  Created by Spaceman on 25/04/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
The state the beam enters when it overheats from being used for too long.
*/

import SpriteKit
import GameplayKit

class WeaponCoolingState: GKState
{
    // MARK: Properties
    
    unowned var weaponComponent: WeaponComponent
    
    /// The amount of time the beam has been cooling down.
    var elapsedTime: TimeInterval = 0.0
    
    // MARK: Initializers
    
    required init(weaponComponent: WeaponComponent)
    {
        self.weaponComponent = weaponComponent
    }
    
    // MARK: GKState life cycle
    
    override func didEnter(from previousState: GKState?)
    {
        super.didEnter(from: previousState)
        
        elapsedTime = 0.0
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
        elapsedTime += seconds
        
        // If the beam has spent long enough cooling down, enter `BeamIdleState`.
        if elapsedTime >= GameplayConfiguration.Beam.coolDownDuration
        {
            stateMachine?.enter(WeaponIdleState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is WeaponIdleState.Type, is WeaponFiringState.Type:
            return true
            
        default:
            return false
        }
    }
    
    override func willExit(to nextState: GKState)
    {
        super.willExit(to: nextState)
        
        if let taskBot = weaponComponent.entity as? TaskBot
        {
            weaponComponent.weaponNode.update(withWeaponState: nextState, source: taskBot)
        }
    }
}

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

class TazerCoolingState: GKState
{
    // MARK: Properties
    
    unowned var tazerComponent: TazerComponent
    
    /// The amount of time the beam has been cooling down.
    var elapsedTime: TimeInterval = 0.0
    
    // MARK: Initializers
    
    required init(tazerComponent: TazerComponent)
    {
        self.tazerComponent = tazerComponent
    }
    
    deinit {
        print("Deallocating TazerCoolingState")
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
        if elapsedTime >= GameplayConfiguration.Tazer.coolDownDuration
        {
            stateMachine?.enter(TazerIdleState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is TazerIdleState.Type, is TazerFiringState.Type:
            return true
            
        default:
            return false
        }
    }
    
    override func willExit(to nextState: GKState)
    {
        super.willExit(to: nextState)
        
        if let taskBot = tazerComponent.entity as? TaskBot
        {
            tazerComponent.tazerNode.update(withWeaponState: nextState, source: taskBot)
        }
    }
}

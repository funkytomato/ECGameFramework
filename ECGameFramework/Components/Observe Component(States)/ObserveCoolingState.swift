/*
//
//  ObserveCoolingState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 23/06/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
The state the beam enters when it overheats from being used for too long.
*/

import SpriteKit
import GameplayKit

class ObserveCoolingState: GKState
{
    // MARK: Properties
    
    unowned var observeComponent: ObserveComponent

    
    /// The amount of time the beam has been cooling down.
    var elapsedTime: TimeInterval = 0.0
    
    // MARK: Initializers
    
    required init(observeComponent: ObserveComponent)
    {
        self.observeComponent = observeComponent
    }
    
    deinit {
//        print("Deallocating ObserveCoolingSate")
    }
    
    // MARK: GKState life cycle
    
    override func didEnter(from previousState: GKState?)
    {
//        print("ObserveCoolingState entered")
        
        super.didEnter(from: previousState)
        
        elapsedTime = 0.0
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
//        print("ObserveCoolingState update")
        
        elapsedTime += seconds
        
        // If the beam has spent long enough cooling down, enter `BeamIdleState`.
        if elapsedTime >= GameplayConfiguration.Observe.coolDownDuration
        {
            stateMachine?.enter(ObserveIdleState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is ObserveIdleState.Type, is ObserveActiveState.Type:
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


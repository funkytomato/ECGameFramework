/*
//
//  ResistanceHitState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 06/05/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
The state representing the `PlayerBot`'s beam when it is being fired at a `TaskBot`.
*/

import SpriteKit
import GameplayKit

class ResistanceHitState: GKState
{
    // MARK: Properties
    
    unowned var resistanceComponent: ResistanceComponent
    
    /// The `TaskBot` currently being targeted by the beam.
    var target: TaskBot?
    
    /// The amount of time the beam has been in its "firing" state.
    var elapsedTime: TimeInterval = 0.0

    // MARK: Initializers
    
    required init(resistanceComponent: ResistanceComponent)
    {
        self.resistanceComponent = resistanceComponent
    }
    
    deinit {
        print("Deallocating ResistanceHitState")
    }
    
    // MARK: GKState life cycle
    
    override func didEnter(from previousState: GKState?)
    {
        super.didEnter(from: previousState)
        
        // Reset the "amount of time firing" tracker when we enter the "firing" state.
        elapsedTime = 0.0

    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
        // Update the "amount of time firing" tracker.
        elapsedTime += seconds
        
        if elapsedTime >= 3
        {
            /**
             The player has been firing the beam for too long. Enter the `BeamCoolingState`
             to disable firing until the beam has had time to cool down.
             */
            stateMachine?.enter(ResistanceCoolingState.self)
        }
        
        if !resistanceComponent.isTriggered
        {
            // The beam is no longer being fired. Enter the `ResistanceIdleState`.
            stateMachine?.enter(ResistanceIdleState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is ResistanceIdleState.Type, is ResistanceCoolingState.Type:
            return true
            
        default:
            return false
        }
    }
    
    override func willExit(to nextState: GKState)
    {
        super.willExit(to: nextState)
    }
    
    // MARK: Convenience
    
}

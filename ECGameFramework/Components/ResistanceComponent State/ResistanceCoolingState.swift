/*
//
//  ResistanceCoolingState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 06/05/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
The state the beam enters when it overheats from being used for too long.
*/

import SpriteKit
import GameplayKit

class ResistanceCoolingState: GKState
{
    // MARK: Properties
    
    unowned var resistanceComponent: ResistanceComponent
    
    /// The amount of time the beam has been cooling down.
    var elapsedTime: TimeInterval = 0.0
    
    // MARK: Initializers
    
    required init(resistanceComponent: ResistanceComponent)
    {
        self.resistanceComponent = resistanceComponent
    }
    
    deinit {
//        print("Deallocating ResistanceCoolingState")
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
        if elapsedTime >= GameplayConfiguration.TaskBot.resistanceCooldownDuration
        {
            stateMachine?.enter(ResistanceIdleState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is ResistanceIdleState.Type, is ResistanceHitState.Type:
            return true
            
        default:
            return false
        }
    }
    
    override func willExit(to nextState: GKState)
    {
        super.willExit(to: nextState)
        
/*        if let protestorBot = resistanceComponent.entity as? PlayerBot
        {
            resistanceComponent.beamNode.update(withBeamState: nextState, source: playerBot)
        }
 */
    }
}

/*
//
//  PoliceSupportState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 26/06/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
The Criminal is currently inciting trouble in the crowd.
The Crim wanders around the scene, and periodically becomes active and whoever they become in contact with during this time becomes influenced.
*/

import SpriteKit
import GameplayKit

class PoliceBotSupportState: GKState
{
    // MARK:- Properties
    unowned var entity: PoliceBot
    
    // The amount of time the 'ManBot' has been in its "Detained" state
    var elapsedTime: TimeInterval = 0.0
    
    
    /// The `TemperamentComponent` associated with the `entity`.
    var intelligenceComponent: IntelligenceComponent
    {
        guard let intelligenceComponent = entity.component(ofType: IntelligenceComponent.self) else { fatalError("A PoliceSupportState entity must have an IntelligenceComponent.") }
        return intelligenceComponent
    }
    
    
    
    //MARK:- Initializers
    required init(entity: PoliceBot)
    {
        self.entity = entity
    }
    
    
    deinit {
//        print("Deallocating PoliceSupportState")
    }
    
    //MARK:- GKState Life Cycle
    override func didEnter(from previousState: GKState?)
    {
        
        //print("PoliceSupportState entered")
        
        super.didEnter(from: previousState)
        
        //Reset the tracking of how long the 'ManBot' has been in "Detained" state
        elapsedTime = 0.0
        
        //Set the InciteComponent to on
        //inciteComponent.stateMachine.enter(InciteActiveState.self)
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
//        print("PoliceSupportState updating")
        
        
        intelligenceComponent.stateMachine.enter(TaskBotAgentControlledState.self)
        
        elapsedTime += seconds
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
            
        case is TaskBotAgentControlledState.Type, is TaskBotFleeState.Type, is TaskBotInjuredState.Type,  is TaskBotZappedState.Type,
             is ProtestorBotHitState.Type:
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


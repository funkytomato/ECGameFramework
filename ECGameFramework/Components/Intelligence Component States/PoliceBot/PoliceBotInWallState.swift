/*
//
//  PoliceBotInWallState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 19/09/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//
Abstract:

Police form wall

*/

import SpriteKit
import GameplayKit

class PoliceBotInWallState: GKState
{
    // MARK:- Properties
    unowned var entity: PoliceBot
    
    // The amount of time the 'ManBot' has been in its "Detained" state
    var elapsedTime: TimeInterval = 0.0
    
    
    /// The `TemperamentComponent` associated with the `entity`.
    var intelligenceComponent: IntelligenceComponent
    {
        guard let intelligenceComponent = entity.component(ofType: IntelligenceComponent.self) else { fatalError("A PoliceBotInWallState entity must have an IntelligenceComponent.") }
        return intelligenceComponent
    }
    
    
    
    //MARK:- Initializers
    required init(entity: PoliceBot)
    {
        self.entity = entity
    }
    
    
    deinit {
        //        print("Deallocating PoliceBotInWallState")
    }
    
    //MARK:- GKState Life Cycle
    override func didEnter(from previousState: GKState?)
    {
        
//        print("PoliceBotInWallState entered")
        
        super.didEnter(from: previousState)
        elapsedTime = 0.0
        
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        elapsedTime += seconds
        
//        print("PoliceBotInWallState updating")

        intelligenceComponent.stateMachine.enter(TaskBotAgentControlledState.self)
        
        
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
            
        case is TaskBotAgentControlledState.Type, is TaskBotFleeState.Type, is TaskBotInjuredState.Type,  is TaskBotZappedState.Type,
             is PoliceBotHitState.Type:
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


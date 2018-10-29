/*
//
//  PoliceBotFormWallState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 01/09/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

 Abstract:

    Police form wall
 
*/

import SpriteKit
import GameplayKit

class PoliceBotFormWallState: GKState
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
        //        print("Deallocating PoliceBotFormWallState")
    }
    
    //MARK:- GKState Life Cycle
    override func didEnter(from previousState: GKState?)
    {
        
        print("PoliceBotFormWallState entered")
        
        super.didEnter(from: previousState)
        elapsedTime = 0.0
        
        //Trigger WallComponent to form a wall with entities in PoliceBotFormWallState
//        entity.component(ofType: WallComponent.self)?.isTriggered = true
        
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        elapsedTime += seconds
        
        print("PoliceBotFormWallState: entity: \(entity.debugDescription), Current behaviour mandate: \(entity.mandate), isWall: \(entity.isWall), requestWall: \(entity.requestWall), isSupporting: \(entity.isSupporting), wallComponentisTriggered: \(String(describing: entity.component(ofType: WallComponent.self)?.isTriggered))")
        
//        print("PoliceBotFormWallState updating")
        
//        guard let wallComponent = entity.component(ofType: WallComponent.self) else { return }
        guard let policeBot = entity as? PoliceBot else { return }
        
        //Should only move into this state when Taskbots are connected
        if policeBot.isWall
        {
            intelligenceComponent.stateMachine.enter(PoliceBotInWallState.self)
        }
        else
        {
            intelligenceComponent.stateMachine.enter(TaskBotAgentControlledState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
            
        case is TaskBotAgentControlledState.Type, is TaskBotFleeState.Type, is TaskBotInjuredState.Type,  is TaskBotZappedState.Type,
             is PoliceBotHitState.Type, is PoliceBotInWallState.Type:
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


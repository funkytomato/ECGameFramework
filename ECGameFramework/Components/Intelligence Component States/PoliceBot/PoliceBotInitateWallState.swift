/*
//
//  PoliceBotInitateWallState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 26/10/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:

Police form wall

*/

import SpriteKit
import GameplayKit

class PoliceBotInitateWallState: GKState
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
    
    /// The `WallComponent` associated with the `entity`.
    var wallComponent: WallComponent
    {
        guard let wallComponent = entity.component(ofType: WallComponent.self) else { fatalError("A PoliceBotInWallState entity must have an WallComponent.") }
        return wallComponent
    }
    
    //MARK:- Initializers
    required init(entity: PoliceBot)
    {
        self.entity = entity
    }
    
    
    deinit {
        //        print("Deallocating PoliceBotInitateWallState")
    }
    
    //MARK:- GKState Life Cycle
    override func didEnter(from previousState: GKState?)
    {
        
        super.didEnter(from: previousState)
        elapsedTime = 0.0
        
        guard let policeBot = entity as? PoliceBot else { return }
        print("PoliceBotInitateWallState entered :\(policeBot.debugDescription)")
        
        entity.isRingLeader = true
        entity.requestWall = true
        entity.isSupporting = false     //Police can not be supporting and be the ringleader
        
        //Trigger WallComponent to form a wall with entities in PoliceBotInitateWallState
        wallComponent.isTriggered = true  //fry
        
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        elapsedTime += seconds
        
        //        guard let wallComponent = entity.component(ofType: WallComponent.self) else { return }
        guard let policeBot = entity as? PoliceBot else { return }
        
        print("PoliceBotInitateWallState: \(elapsedTime.description), entity: \(policeBot.debugDescription), Current behaviour mandate: \(entity.mandate), isWall: \(policeBot.isWall), requestWall: \(policeBot.requestWall), isSupporting: \(policeBot.isSupporting), wallComponentisTriggered: \(String(describing: policeBot.component(ofType: WallComponent.self)?.isTriggered))")
        
        
        //PoliceBot has joined a wall, if not stand and wait
//        if entity.isWall
//        {
            intelligenceComponent.stateMachine.enter(TaskBotAgentControlledState.self)
//        }
        
        
        //Ensure the WallComponent statemachine is started and updated.
        wallComponent.stateMachine.update(deltaTime: seconds)
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
            
        case is TaskBotAgentControlledState.Type, is TaskBotFleeState.Type, is TaskBotInjuredState.Type,  is TaskBotZappedState.Type,
             is PoliceBotHitState.Type/*, is PoliceBotInWallState.Type*/:
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


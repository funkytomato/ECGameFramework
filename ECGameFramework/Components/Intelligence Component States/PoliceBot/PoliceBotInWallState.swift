/*
//
//  PoliceBotInWallState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 19/09/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//
Abstract:

Police are in wall state

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
        //        print("Deallocating PoliceBotInWallState")
    }
    
    //MARK:- GKState Life Cycle
    override func didEnter(from previousState: GKState?)
    {
        
        print("PoliceBotInWallState entered")
        
        super.didEnter(from: previousState)
        elapsedTime = 0.0
        
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        elapsedTime += seconds
        
//        print("PoliceBotInWallState updating")
//        print("PoliceBotInWallState: entity: \(entity.debugDescription), Current behaviour mandate: \(entity.mandate), isWall: \(entity.isWall), requestWall: \(entity.requestWall), isSupporting: \(entity.isSupporting), wallComponentisTriggered: \(String(describing: entity.component(ofType: WallComponent.self)?.isTriggered))")
        
        
//        if !self.entity.requestWall && elapsedTime > 30.0
        if elapsedTime > 30.0
        {
            wallComponent.stateMachine.enter(DisbandState.self)
        }
        
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


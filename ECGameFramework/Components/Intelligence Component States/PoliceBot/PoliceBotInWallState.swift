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
        
        //If Police is in RegroupState, connect to wall
        let currentWallComponentState = wallComponent.stateMachine.currentState
        if (currentWallComponentState as? RegroupState) != nil
        {
            guard let physicsComponent = entity.component(ofType: PhysicsComponent.self) else { return }
            let contactedBodies = physicsComponent.physicsBody.allContactedBodies()
            for contactedBody in contactedBodies
            {
                guard let entity = contactedBody.node?.entity else { continue }
                guard let targetBot = entity as? PoliceBot else { break }
                if self.entity.isPolice && self.entity.connections < 2 /*&& self.entity.requestWall*/ &&
                    targetBot.isPolice && targetBot.connections < 2
                {
                    //Check other PoliceBot is not in wall.
                    
                    let policeBotB = entity as? PoliceBot
                    if /*!policeBotB!.isWall && */policeBotB!.connections < 2
                    {
                        
//                        let policeBotBPhysicsComponent = policeBotB?.component(ofType: PhysicsComponent.self)
//                        let policeBRenderComponent = policeBotB?.component(ofType: RenderComponent.self)
//                        let entityB = policeBRenderComponent?.entity
                        
                        // Get the Physics Component for each entity
//                        let policeBotA = entity as? PoliceBot
//                        let policeBotAPhysicsComponent = policeBotA?.component(ofType: PhysicsComponent.self)
//                        let policeARenderComponent = policeBotA?.component(ofType: RenderComponent.self)
//                        let entityA = policeARenderComponent?.entity
                        
                        
                        //Connect the two Taskbots together like a rope if forming a wall
                        guard let intelligenceComponent = self.entity.component(ofType: IntelligenceComponent.self) else { return }
                        guard ((intelligenceComponent.stateMachine.currentState as? PoliceBotFormWallState) == nil) else { return }
                        guard let jointComponent = self.entity.component(ofType: JointComponent.self) else { return }
                        
                        guard let policeBot = entity as? PoliceBot else { return }
                        if !jointComponent.isTriggered && policeBot.isPolice
                        {
                            jointComponent.setEntityB(targetEntity: policeBotB!)
                        }
                        
                    }
                }
            }
        }
        
        
//        intelligenceComponent.stateMachine.enter(TaskBotAgentControlledState.self)
        
        if !self.entity.requestWall && elapsedTime > 30.0
        {
            wallComponent.isTriggered = false
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


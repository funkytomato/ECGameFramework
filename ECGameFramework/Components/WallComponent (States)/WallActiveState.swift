/*
//
//  WallActiveState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 19/11/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
The state of the `PlayerBot`'s beam when not in use.
*/

import SpriteKit
import GameplayKit

class WallActiveState: GKState
{
    // MARK: Properties
    
    unowned var wallComponent: WallComponent
    unowned var entity: PoliceBot
    
    
    
    /// The amount of time the beam has been in its "firing" state.
    var elapsedTime: TimeInterval = 0.0
    
    
    
    // MARK: Initializers
    
    required init(wallComponent: WallComponent, entity: TaskBot)
    {
        self.wallComponent = wallComponent
        self.entity = entity as! PoliceBot
    }
    
    deinit {
        //        print("Deallocating WallIdleState")
    }
    
    // MARK: GKState life cycle
    
    override func didEnter(from previousState: GKState?)
    {
//        print("WallActiveState didEnter: entity: \(entity.debugDescription), Current behaviour mandate: \(entity.mandate), isWall: \(entity.isWall), requestWall: \(entity.requestWall), isSupporting: \(entity.isSupporting), wallComponentisTriggered: \(String(describing: entity.component(ofType: WallComponent.self)?.isTriggered))")
        
        super.didEnter(from: previousState)
        elapsedTime = 0.0
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
//        print("WallActiveState update: entity: \(entity.debugDescription), Current behaviour mandate: \(entity.mandate), isWall: \(entity.isWall), requestWall: \(entity.requestWall), isSupporting: \(entity.isSupporting), wallComponentisTriggered: \(String(describing: entity.component(ofType: WallComponent.self)?.isTriggered))")

        
        super.update(deltaTime: seconds)
        elapsedTime += seconds
        
        
        guard let physicsComponent = entity.component(ofType: PhysicsComponent.self) else { return }
        let contactedBodies = physicsComponent.physicsBody.allContactedBodies()
        for contactedBody in contactedBodies
        {
            guard let entity = contactedBody.node?.entity else { continue }
            guard let targetBot = entity as? PoliceBot else { break }
            
            //Police must have less than 2 connections, be the wall initator, and touching another PoliceBot that has available connections
            if self.entity.isPolice && self.entity.connections < 2 /*&& self.entity.requestWall*/ &&
                targetBot.isPolice && targetBot.connections < 2
            {
                //Check other PoliceBot is not in wall.
                
                let policeBotB = entity as? PoliceBot
                if policeBotB!.connections < 2
                {
                    
                    //Connect the two Taskbots together like a rope if forming a wall
                    guard let intelligenceComponent = self.entity.component(ofType: IntelligenceComponent.self) else { return }
                    //                    guard ((intelligenceComponent.stateMachine.currentState as? PoliceBotFormWallState) == nil) else { return }
                    guard let jointComponent = self.entity.component(ofType: JointComponent.self) else { return }
                    
                    wallComponent.isTriggered = true    //fry
                    targetBot.component(ofType: WallComponent.self)?.isTriggered = true
                    
                    guard let policeBot = entity as? PoliceBot else { return }
                    if !jointComponent.isTriggered && policeBot.isPolice
                    {
                        jointComponent.makeJointWith(targetEntity: policeBotB!)
                    }
                }
            }
        }
        
        
        if !wallComponent.isTriggered
        {
            stateMachine?.enter(WallCooldownState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is WallCooldownState.Type:
            return true
        default:
            return false
        }
    }
}



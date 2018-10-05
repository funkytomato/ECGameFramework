/*
//
//  RegroupState.swift
//  ECGameFramework
//
//  Created by Spaceman on 17/09/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
 TaskBots who are in proximity to the target Policeman will connect and allows additional PoliceBots to join the line.
 When the total number of Police has been reached or times out, move to HoldTheLineState.
*/

import SpriteKit
import GameplayKit

class RegroupState: GKState
{
    // MARK: Properties
    
    unowned var wallComponent: WallComponent
    unowned var entity: PoliceBot
    
    
    /// The amount of time the beam has been cooling down.
    var elapsedTime: TimeInterval = 0.0
    var consumptionSpeed: Double = 0.0
    
    
    /// The `MovementComponent` associated with the `entity`.
    var movementComponent: MovementComponent
    {
        guard let movementComponent = entity.component(ofType: MovementComponent.self) else { fatalError("A TaskBot FleeState's entity must have a MovementComponent.") }
        return movementComponent
    }
    
    
    // MARK: Initializers
    
    required init(wallComponent: WallComponent, entity: TaskBot)
    {
        self.wallComponent = wallComponent
        self.entity = entity as! PoliceBot
    }
    
    deinit {
        //        print("Deallocating WallCoolingSate")
    }
    
    // MARK: GKState life cycle
    
    override func didEnter(from previousState: GKState?)
    {
        print("RegroupState: entity: \(entity.debugDescription), Current behaviour mandate: \(entity.mandate), isWall: \(entity.isWall), requestWall: \(entity.requestWall), isSupporting: \(entity.isSupporting), wallComponentisTriggered: \(String(describing: entity.component(ofType: WallComponent.self)?.isTriggered))")

        super.didEnter(from: previousState)
        elapsedTime = 0.0
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
//        print("RegroupState update")

//        print("RegroupState: entity: \(entity.debugDescription), Current behaviour mandate: \(entity.mandate), isWall: \(entity.isWall), requestWall: \(entity.requestWall), isSupporting: \(entity.isSupporting), wallComponentisTriggered: \(String(describing: entity.component(ofType: WallComponent.self)?.isTriggered))")

        
        super.update(deltaTime: seconds)
        elapsedTime += seconds
        

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
      
        
        //If regroup time has expired and the wall size is greater than the minimum wall size move to the next state
        if self.entity.isWall && elapsedTime >= GameplayConfiguration.Wall.regroupStateDuration
        {
            stateMachine?.enter(HoldTheLineState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
            case is HoldTheLineState.Type, is DisbandState.Type:
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

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
        print("RegroupState entered")
        
        super.didEnter(from: previousState)
        elapsedTime = 0.0
        
//        entity.agent.maxSpeed = 100.0
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
//        print("RegroupState update")

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
                    
                    let policeBotBPhysicsComponent = policeBotB?.component(ofType: PhysicsComponent.self)
                    let policeBRenderComponent = policeBotB?.component(ofType: RenderComponent.self)
                    let entityB = policeBRenderComponent?.entity
                    
                    // Get the Physics Component for each entity
                    let policeBotA = entity as? PoliceBot
                    let policeBotAPhysicsComponent = policeBotA?.component(ofType: PhysicsComponent.self)
                    let policeARenderComponent = policeBotA?.component(ofType: RenderComponent.self)
                    let entityA = policeARenderComponent?.entity
                    
                    
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

        
        
//        // Check entity is Police, has less than 2 connections and is connecting with a PoliceBot who has less than 2 connections and has requested to build a wall
//        if self.isPolice && self.connections < 2 /*&& !self.isWall*/ &&
//            targetBot.isPolice && targetBot.connections < 2 && self.requestWall /* && !targetBot.isWall */
//        {
//            //Check other PoliceBot is not in wall.
//
//            let policeBotB = entity as? PoliceBot
//            if !policeBotB!.isWall && policeBotB!.connections < 2
//            {
//
//                let policeBotBPhysicsComponent = policeBotB?.component(ofType: PhysicsComponent.self)
//                let policeBRenderComponent = policeBotB?.component(ofType: RenderComponent.self)
//                let entityB = policeBRenderComponent?.entity
//
//                // Get the Physics Component for each entity
//                let policeBotA = agent.entity as? PoliceBot
//                let policeBotAPhysicsComponent = policeBotA?.component(ofType: PhysicsComponent.self)
//                let policeARenderComponent = policeBotA?.component(ofType: RenderComponent.self)
//                let entityA = policeARenderComponent?.entity
//
//
//                //Connect the two Taskbots together like a rope if forming a wall
//                guard let intelligenceComponent = self.component(ofType: IntelligenceComponent.self) else { return }
//                guard ((intelligenceComponent.stateMachine.currentState as? PoliceBotFormWallState) == nil) else { return }
//                guard let jointComponent = self.component(ofType: JointComponent.self) else { return }
//
//                guard let policeBot = entity as? PoliceBot else { return }
//                if !jointComponent.isTriggered && policeBot.isPolice
//                {
//                    jointComponent.setEntityB(targetEntity: policeBotB!)
//                }
//
//                policeBotA!.component(ofType: WallComponent.self)?.isTriggered = true
//                policeBotB!.component(ofType: WallComponent.self)?.isTriggered = true
//            }
//        }
        
        
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
        
        // `movementComponent` is a computed property. Declare a local version so we don't compute it multiple times.
//        let movementComponent = self.movementComponent
        
        // Stop the `ProtestorBot`'s movement and restore its standard movement speed.
//        movementComponent.nextRotation = nil
//        movementComponent.nextTranslation = nil
//        movementComponent.movementSpeed = 0
//        movementComponent.angularSpeed = 0
    }
}

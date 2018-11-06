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
    
    
    /// The `IntelligenceComponent` associated with the `entity`.
    var intelligenceComponent: IntelligenceComponent
    {
        guard let intelligenceComponent = entity.component(ofType: IntelligenceComponent.self) else { fatalError("A TaskBot RegroupState entity must have a IntelligenceComponent.") }
        return intelligenceComponent
    }
    
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
        print("RegroupState: didEnter - entity: \(entity.debugDescription), Current behaviour mandate: \(entity.mandate), isWall: \(entity.isWall), requestWall: \(entity.requestWall), isSupporting: \(entity.isSupporting), wallComponentisTriggered: \(String(describing: entity.component(ofType: WallComponent.self)?.isTriggered))")

        super.didEnter(from: previousState)
        elapsedTime = 0.0
        
        // `movementComponent` is a computed property. Declare a local version so we don't compute it multiple times.
//        let movementComponent = self.movementComponent
//        
//        // Stop the `ProtestorBot`'s movement and restore its standard movement speed.
//        movementComponent.nextRotation = nil
//        movementComponent.nextTranslation = nil
//        movementComponent.movementSpeed = 0
//        movementComponent.angularSpeed = 0
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {

        print("RegroupState: update - entity: \(entity.debugDescription), Current behaviour mandate: \(entity.mandate), isWall: \(entity.isWall), requestWall: \(entity.requestWall), isSupporting: \(entity.isSupporting), wallComponentisTriggered: \(String(describing: entity.component(ofType: WallComponent.self)?.isTriggered))")

        
        super.update(deltaTime: seconds)
        
        
        
        //Check PoliceBot is in PoliceBotFormWallState before trying to connect with them
//        guard let intelligenceComponent = self.entity.component(ofType: IntelligenceComponent.self) else { return }
//        guard ((intelligenceComponent.stateMachine.currentState as? PoliceBotFormWallState) != nil) else { return }

        
        
        //If the WallComponent is triggered, make joints with touching PoliceBots
        if wallComponent.isTriggered
        {

            guard let physicsComponent = entity.component(ofType: PhysicsComponent.self) else { return }
            let contactedBodies = physicsComponent.physicsBody.allContactedBodies()
            for contactedBody in contactedBodies
            {
                
                guard let entity = contactedBody.node?.entity else { continue }
                guard let targetBot = entity as? PoliceBot else { break }

                
                print("entityB: \(self.entity.component(ofType: JointComponent.self)?.entityB?.description), targetBot: \(targetBot.description)")
                
                //Gotta check TaskBot is not trying to create another joint with existing connection
                if self.entity.component(ofType: JointComponent.self)?.entityB != targetBot
                {
                
                
                    //This PoliceBot and the touching PoliceBot should have available connections before continuing
                    if self.entity.isPolice && self.entity.connectionAvailable && targetBot.isPolice && targetBot.connectionAvailable
                    {
                        
                        //Check touching entity has available connections
                        if targetBot.connectionAvailable
                        {
                           
                            //Connect the two Taskbots together like a rope if forming a wall
                             guard let jointComponent = self.entity.component(ofType: JointComponent.self) else { return }
                            
                            guard let policeBot = entity as? PoliceBot else { return }
                            if !jointComponent.isTriggered && policeBot.isPolice
                            {
                                jointComponent.makeJointWith(targetEntity: targetBot)
                            }
                            
                            elapsedTime += seconds
                        }
                    }
                }
            }
        
            //Check PoliceBot is in PoliceBotInWallState before continuing, ensuring their is a valid target
            guard (intelligenceComponent.stateMachine.currentState as? PoliceBotInWallState) != nil else { return }
            
            //If regroup time has expired and the wall size is greater than the minimum wall size move to the next state
            if self.entity.isWall && elapsedTime >= GameplayConfiguration.Wall.regroupStateDuration
            {
                stateMachine?.enter(HoldTheLineState.self)
            }
        }
            
        //If the WallComponent is not triggered, disband from the wall.
        else
        {
            print("Disbanding TaskBot from Regroup State because wall component is no longer triggered.")
            stateMachine?.enter(DisbandState.self)
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

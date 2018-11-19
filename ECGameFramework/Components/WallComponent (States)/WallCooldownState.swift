/*
//
//  WallCooldownState.swift
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

class WallCooldownState: GKState
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
        //        print("Deallocating WallCooldownState")
    }
    
    // MARK: GKState life cycle
    
    override func didEnter(from previousState: GKState?)
    {
        print("WallCooldownState didEnter: entity: \(entity.debugDescription), Current behaviour mandate: \(entity.mandate), isWall: \(entity.isWall), requestWall: \(entity.requestWall), isSupporting: \(entity.isSupporting), wallComponentisTriggered: \(String(describing: entity.component(ofType: WallComponent.self)?.isTriggered))")
        
        super.didEnter(from: previousState)
        elapsedTime = 0.0
        
        guard let jointComponent = entity.component(ofType: JointComponent.self) else { return }
        jointComponent.removeJoint()
        jointComponent.isTriggered = false
        
        self.entity.isRingLeader = false
        self.entity.requestWall = false
        self.entity.isSupporting = false
        self.entity.isWall = false
        
        self.entity.connections = 0
        
        print("WallCooldownState didEnter: entity: \(entity.debugDescription), Current behaviour mandate: \(entity.mandate), isWall: \(entity.isWall), requestWall: \(entity.requestWall), isSupporting: \(entity.isSupporting), wallComponentisTriggered: \(String(describing: entity.component(ofType: WallComponent.self)?.isTriggered))")

    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        print("WallCooldownState update: entity: \(entity.debugDescription), Current behaviour mandate: \(entity.mandate), isWall: \(entity.isWall), requestWall: \(entity.requestWall), isSupporting: \(entity.isSupporting), wallComponentisTriggered: \(String(describing: entity.component(ofType: WallComponent.self)?.isTriggered))")
        
        
        super.update(deltaTime: seconds)
        elapsedTime += seconds
        
        
        //Wait 1 second before moving into next state
        if elapsedTime > 1.0
        {
            stateMachine?.enter(WallIdleState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is WallIdleState.Type:
            return true
        default:
            return false
        }
    }
}


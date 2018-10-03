/*
//
//  DisbandState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 25/09/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
The state of the `PlayerBot`'s beam when not in use.
*/

import SpriteKit
import GameplayKit

class DisbandState: GKState
{
    // MARK: Properties
    
    unowned var wallComponent: WallComponent
    unowned var entity: PoliceBot
    
    
    
    /// The amount of time the beam has been in its "firing" state.
    var elapsedTime: TimeInterval = 0.0
    
    
    /// The `MovementComponent` associated with the `entity`.
    var movementComponent: MovementComponent
    {
        guard let movementComponent = entity.component(ofType: MovementComponent.self) else { fatalError("A DisbandState's entity must have a MovementComponent.") }
        return movementComponent
    }
    
    
    // MARK: Initializers
    
    required init(wallComponent: WallComponent, entity: TaskBot)
    {
        self.wallComponent = wallComponent
        self.entity = entity as! PoliceBot
    }
    
    deinit {
        //        print("Deallocating DisbandState")
    }
    
    // MARK: GKState life cycle
    
    override func didEnter(from previousState: GKState?)
    {
//        print("DisbandState didEnter: \(wallComponent.debugDescription) entity: \(entity.debugDescription)")
//        print("DisbandState: entity: \(entity.debugDescription), Current behaviour mandate: \(entity.mandate), isWall: \(entity.isWall), requestWall: \(entity.requestWall), isSupporting: \(entity.isSupporting), wallComponentisTriggered: \(String(describing: entity.component(ofType: WallComponent.self)?.isTriggered))")

        
        super.didEnter(from: previousState)
        elapsedTime = 0.0
        
        guard let jointComponent = entity.component(ofType: JointComponent.self) else { return }
        jointComponent.removeJoint()
        
        self.entity.requestWall = false
        self.entity.isSupporting = false
        self.entity.isWall = false
        wallComponent.isTriggered = false
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        print("DisbandState update: \(wallComponent.debugDescription)")
        
        super.update(deltaTime: seconds)
        
        if !wallComponent.isTriggered
        {
            stateMachine?.enter(WallIdleState.self)
            guard let intelligenceComponent = entity.component(ofType: IntelligenceComponent.self) else { return }
            intelligenceComponent.stateMachine.enter(TaskBotAgentControlledState.self)
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
    
    override func willExit(to nextState: GKState)
    {
        super.willExit(to: nextState)
    }
}



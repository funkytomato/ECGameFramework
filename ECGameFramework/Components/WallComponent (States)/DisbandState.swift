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
        print("DisbandState didEnter: \(wallComponent.debugDescription)")
        
        super.didEnter(from: previousState)
        elapsedTime = 0.0
        
        guard let jointComponent = entity.component(ofType: JointComponent.self) else { return }
        jointComponent.removeJoint()
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
//        print("DisbandState update: \(wallComponent.debugDescription)")
        
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
}



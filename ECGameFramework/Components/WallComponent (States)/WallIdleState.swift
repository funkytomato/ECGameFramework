/*
//
//  WallIdleState.swift
//  ECGameFramework
//
//  Created by Spaceman on 23/09/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
The state of the `PlayerBot`'s beam when not in use.
*/

import SpriteKit
import GameplayKit

class WallIdleState: GKState
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
        //        print("Deallocating SellingWaresIdleState")
    }
    
    // MARK: GKState life cycle
    
    override func didEnter(from previousState: GKState?)
    {
        //        print("SellingWaresIdleState entered: \(sellingWaresComponent.entity.debugDescription)")
        
        super.didEnter(from: previousState)
        elapsedTime = 0.0
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
        if wallComponent.isTriggered
        {
            stateMachine?.enter(RegroupState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is RegroupState.Type:
            return true
        default:
            return false
        }
    }
}


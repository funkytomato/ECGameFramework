/*
//
//  HoldTheLineState.swift
//  ECGameFramework
//
//  Created by Spaceman on 17/09/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//
Abstract:
TaskBots create a wall
*/

import SpriteKit
import GameplayKit

class HoldTheLineState: GKState
{
    // MARK: Properties
    
    unowned var wallComponent: WallComponent
    
    
    /// The amount of time the beam has been cooling down.
    var elapsedTime: TimeInterval = 0.0
    var consumptionSpeed: Double = 0.0
    
    
    // MARK: Initializers
    
    required init(wallComponent: WallComponent)
    {
        self.wallComponent = wallComponent
    }
    
    deinit {
        //        print("Deallocating HoldTheLineState")
    }
    
    // MARK: GKState life cycle
    
    override func didEnter(from previousState: GKState?)
    {
        //        print("HoldTheLineState entered")
        
        super.didEnter(from: previousState)
        elapsedTime = 0.0
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        //        print("RegroupState update")
        
        super.update(deltaTime: seconds)
        elapsedTime += seconds
        
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is MoveBackwardState.Type, is RetreatState.Type, is MoveForwardState.Type:
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

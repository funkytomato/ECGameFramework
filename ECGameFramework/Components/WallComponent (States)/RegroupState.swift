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
        //        print("WallCoolingState entered")
        
        super.didEnter(from: previousState)
        elapsedTime = 0.0
        
        entity.agent.maxSpeed = 100.0
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        //        print("RegroupState update")

        super.update(deltaTime: seconds)
        elapsedTime += seconds

//        print("wallComponent: \(wallComponent.debugDescription), currentSize: \(wallComponent.currentWallSize), minimum: \(wallComponent.minimumWallSize), maximum: \(wallComponent.maximumWallSize)")
        
        //If regroup time has expired and the wall size is greater than the minimum wall size move to the next state
        if elapsedTime >= GameplayConfiguration.Wall.regroupStateDuration
        {
                stateMachine?.enter(HoldTheLineState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
            case is HoldTheLineState.Type:
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

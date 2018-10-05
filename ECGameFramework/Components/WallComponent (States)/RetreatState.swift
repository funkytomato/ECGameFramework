/*
//
//  RetreatState.swift
//  ECGameFramework
//
//  Created by Spaceman on 17/09/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//


Abstract:
 Police are in a wall and are retreating away from the targetPosition with loose connections.
 Police should already be facing the correct direction and so should start to move quickly away from the targetPosition.
 
*/

import SpriteKit
import GameplayKit

class RetreatState: GKState
{
    // MARK: Properties
    
    unowned var wallComponent: WallComponent
    unowned var entity: TaskBot
    
    
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
        //        print("Deallocating RetreatState")
    }
    
    // MARK: GKState life cycle
    
    override func didEnter(from previousState: GKState?)
    {
//        print("RetreatState entered")
        print("RetreatState: entity: \(entity.debugDescription), Current behaviour mandate: \(entity.mandate), isWall: \(entity.isWall), requestWall: \(entity.requestWall), isSupporting: \(entity.isSupporting), wallComponentisTriggered: \(String(describing: entity.component(ofType: WallComponent.self)?.isTriggered))")

        
        super.didEnter(from: previousState)
        elapsedTime = 0.0
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
//        print("RetreatState update")
        
        super.update(deltaTime: seconds)
        elapsedTime += seconds
        
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is RegroupState.Type, is DisbandState.Type:
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

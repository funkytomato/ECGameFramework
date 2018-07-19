/*
//
//  SellingWaresCoolingState.swift
//  ECGameFramework
//
//  Created by Spaceman on 28/06/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
The state the beam enters when it overheats from being used for too long.
*/

import SpriteKit
import GameplayKit

class SellingWaresCoolingState: GKState
{
    // MARK: Properties
    
    unowned var sellingWaresComponent: SellingWaresComponent
    
    /// The amount of time the beam has been cooling down.
    var elapsedTime: TimeInterval = 0.0
    
    // MARK: Initializers
    
    required init(sellingWaresComponent: SellingWaresComponent)
    {
        self.sellingWaresComponent = sellingWaresComponent
    }
    
    deinit {
//        print("Deallocating SellingWaresCoolingState")
    }
    
    // MARK: GKState life cycle
    
    override func didEnter(from previousState: GKState?)
    {
//        print("SellingWaresCoolingState entered")
        
        super.didEnter(from: previousState)
        elapsedTime = 0.0
        
        //Criminal is chilling out from selling
        guard let taskBot = sellingWaresComponent.entity as? TaskBot else { return }
        taskBot.isSelling = false
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        
        //        print("SellingWaresComponent update")
        
        super.update(deltaTime: seconds)
        elapsedTime += seconds
        
        // If the beam has spent long enough cooling down, enter `BeamIdleState`.
        if elapsedTime >= GameplayConfiguration.Wares.timeOutPeriod
        {
            stateMachine?.enter(SellingWaresIdleState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is SellingWaresIdleState.Type:
            return true
            
        default:
            return false
        }
    }
    
    override func willExit(to nextState: GKState)
    {
        super.willExit(to: nextState)
        
        //Criminal has finished chilling out, start selling again
        guard let taskBot = sellingWaresComponent.entity as? TaskBot else { return }
        taskBot.isSelling = true
    }
}


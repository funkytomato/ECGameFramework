/*
//
//  AppetiteActiveState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 23/06/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
The state representing the `TaskBot' while actively inciting others.
*/

import SpriteKit
import GameplayKit

class AppetiteGettingHungryState: GKState
{
    // MARK: Properties
    unowned var appetiteComponent: AppetiteComponent
    
    
    /// The amount of time the beam has been in its "firing" state.
    var elapsedTime: TimeInterval = 0.0
    
    
    // MARK: Initializers
    
    required init(appetiteComponent: AppetiteComponent)
    {
        self.appetiteComponent = appetiteComponent
    }
    
    deinit {
//        print("Deallocating AppetiteActiveState")
    }
    
    // MARK: GKState life cycle
    
    override func didEnter(from previousState: GKState?)
    {
//        print("AppetiteActiveState entered: \(appetiteComponent.entity.debugDescription)")
        
        super.didEnter(from: previousState)
        
        // Reset the "amount of time firing" tracker when we enter the "firing" state.
        elapsedTime = 0.0
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
//        print("AppetiteActiveState updating")

        // Update the "amount of time firing" tracker.
        elapsedTime += seconds
        
        //Increase the appetite as product has been consumed
        appetiteComponent.gainAppetite(appetiteToAdd: GameplayConfiguration.ProtestorBot.appetiteGainPerCycle)
        
        
        if appetiteComponent.isConsumingProduct
        {
            // Protestor is now consuming product
            stateMachine?.enter(AppetiteConsumingState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is AppetiteIdleState.Type, is AppetiteConsumingState.Type:
            return true
            
        default:
//            print("current state: \(stateClass.debugDescription())")
            return false
        }
    }
    
    override func willExit(to nextState: GKState)
    {
        super.willExit(to: nextState)
    }
}

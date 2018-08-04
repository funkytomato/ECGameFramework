/*
//
//  AppetiteCoolingState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 23/06/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
Reduce the appetite as product is consumed
*/

import SpriteKit
import GameplayKit

class AppetiteConsumingState: GKState
{
    // MARK: Properties
    
    unowned var appetiteComponent: AppetiteComponent
    
    
    /// The amount of time the beam has been cooling down.
    var elapsedTime: TimeInterval = 0.0
    var consumptionSpeed: Double = 0.0
    
    
    // MARK: Initializers
    
    required init(appetiteComponent: AppetiteComponent)
    {
        self.appetiteComponent = appetiteComponent
    }
    
    deinit {
//        print("Deallocating AppetiteCoolingSate")
    }
    
    // MARK: GKState life cycle
    
    override func didEnter(from previousState: GKState?)
    {
//        print("AppetiteCoolingState entered")
        
        super.didEnter(from: previousState)
        elapsedTime = 0.0
        
        // Create a random consumption speed
        let randomSource = GKRandomSource.sharedRandom()
        let diff = randomSource.nextUniform() // returns random Float between 0.0 and 1.0
        let speed = diff * GameplayConfiguration.Appetite.consumptionLossPerSecond
        
        
//        self.consumptionSpeed = Double(speed)
        self.consumptionSpeed = 0.1
        print("consumption speed :\(speed.debugDescription)")
        
        guard let protestorBot = appetiteComponent.entity as? ProtestorBot else { return }
        protestorBot.isHungry = false
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
//        print("AppetiteCoolingState update")
        
        elapsedTime += seconds
        
        //Start losing appetite
//        appetiteComponent.loseAppetite(appetiteToLose: GameplayConfiguration.ProtestorBot.appetiteLossPerCycle)
        appetiteComponent.loseAppetite(appetiteToLose: self.consumptionSpeed)
        
        //Protestor has consumed the product and should go into idle state
        if !appetiteComponent.hasAppetite
        {
            stateMachine?.enter(AppetiteIdleState.self)
            
            guard let protestorBot = appetiteComponent.entity as? ProtestorBot else { return }
            guard let buyWaresComponent = protestorBot.component(ofType: BuyingWaresComponent.self) else { return }
            
            //Remove wares from Protestor's pockethas
            buyWaresComponent.loseProduct(waresToLose: GameplayConfiguration.CriminalBot.sellingWaresLossPerCycle)
            
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is AppetiteIdleState.Type, is AppetiteHungryState.Type:
            return true
            
        default:
            return false
        }
    }
    
    override func willExit(to nextState: GKState)
    {
        super.willExit(to: nextState)
        
        appetiteComponent.isConsumingProduct = false
        
    }
}



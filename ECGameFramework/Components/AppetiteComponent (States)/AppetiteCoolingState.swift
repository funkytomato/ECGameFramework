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

class AppetiteCoolingState: GKState
{
    // MARK: Properties
    
    unowned var appetiteComponent: AppetiteComponent
    
    /// The `RenderComponent' for this component's 'entity'.
    var animationComponent: AnimationComponent
    {
        guard let animationComponent = appetiteComponent.entity?.component(ofType: AnimationComponent.self) else { fatalError("A AppetiteComponent's entity must have a AnimationComponent") }
        return animationComponent
    }
    
    /// The amount of time the beam has been cooling down.
    var elapsedTime: TimeInterval = 0.0
    
    // MARK: Initializers
    
    required init(appetiteComponent: AppetiteComponent)
    {
        self.appetiteComponent = appetiteComponent
    }
    
    deinit {
        print("Deallocating AppetiteCoolingSate")
    }
    
    // MARK: GKState life cycle
    
    override func didEnter(from previousState: GKState?)
    {
        print("AppetiteCoolingState entered")
        
        super.didEnter(from: previousState)
        
        elapsedTime = 0.0
        
        animationComponent.requestedAnimationState = .idle
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
        print("AppetiteCoolingState update")
        
        elapsedTime += seconds
        
        //Start losing appetite
        appetiteComponent.loseAppetite(appetiteToLose: GameplayConfiguration.CriminalBot.appetiteLossPerCycle)
        
        //Protestor has consumed the product and should go into idle state
        if !appetiteComponent.hasAppetite
        {
            stateMachine?.enter(AppetiteIdleState.self)
        }
        
        // If the beam has spent long enough cooling down, enter `BeamIdleState`.
//        if elapsedTime >= GameplayConfiguration.Appetite.coolDownDuration
//        {
//            stateMachine?.enter(AppetiteIdleState.self)
//
//        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is AppetiteIdleState.Type, is AppetiteActiveState.Type:
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



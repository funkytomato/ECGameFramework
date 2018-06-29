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

class AppetiteActiveState: GKState
{
    // MARK: Properties
    unowned var appetiteComponent: AppetiteComponent
    
    
    /// The `RenderComponent' for this component's 'entity'.
    var animationComponent: AnimationComponent
    {
        guard let animationComponent = appetiteComponent.entity?.component(ofType: AnimationComponent.self) else { fatalError("A AppetiteComponent's entity must have a AnimationComponent") }
        return animationComponent
    }
    
    
    /// The amount of time the beam has been in its "firing" state.
    var elapsedTime: TimeInterval = 0.0
    
    
    // MARK: Initializers
    
    required init(appetiteComponent: AppetiteComponent)
    {
        self.appetiteComponent = appetiteComponent
    }
    
    deinit {
        print("Deallocating AppetiteActiveState")
    }
    
    // MARK: GKState life cycle
    
    override func didEnter(from previousState: GKState?)
    {
        print("AppetiteActiveState entered: \(appetiteComponent.entity.debugDescription)")
        
        super.didEnter(from: previousState)
        
        // Reset the "amount of time firing" tracker when we enter the "firing" state.
        elapsedTime = 0.0
        
        
        animationComponent.requestedAnimationState = .inciting
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
        print("AppetiteActiveState updating")
        
        //print(animationComponent.requestedAnimationState.debugDescription)
        
        animationComponent.requestedAnimationState = .inciting
        
        // Update the "amount of time firing" tracker.
        elapsedTime += seconds
        
        let appetiteToGain = GameplayConfiguration.ProtestorBot.appetiteGainPerCycle
        
        if appetiteComponent.isConsumingProduct
        {
            //Decrease the appetite as product is being consumed
            appetiteComponent.loseAppetite(appetiteToLose: appetiteToGain)
        }
        else
        {
            //Increase the appetite as product has been consumed
            appetiteComponent.gainAppetite(appetiteToAdd: appetiteToGain)
        }
        
//        if let appetiteComponent = appetiteComponent.entity?.component(ofType: AppetiteComponent.self), appetiteComponent.hasAppetite
//        {
//            let appetiteToGain = GameplayConfiguration.ProtestorBot.appetiteGainPerCycle
//
//            //print("ObeisanceToLose: \(obeisanceToLose.debugDescription)")
//
//
//        }
        
        if !appetiteComponent.isTriggered
        {
            // The beam is no longer being fired. Enter the `AppetiteIdleState`.
            stateMachine?.enter(AppetiteCoolingState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is AppetiteIdleState.Type, is AppetiteCoolingState.Type:
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

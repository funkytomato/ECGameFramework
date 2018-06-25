/*
//
//  InciteActiveState.swift
//  ECGameFramework
//
//  Created by Spaceman on 09/06/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
The state representing the `TaskBot' while actively inciting others.
*/

import SpriteKit
import GameplayKit

class InciteActiveState: GKState
{
    // MARK: Properties
    unowned var inciteComponent: InciteComponent
    
    
    /// The `RenderComponent' for this component's 'entity'.
    var animationComponent: AnimationComponent
    {
        guard let animationComponent = inciteComponent.entity?.component(ofType: AnimationComponent.self) else { fatalError("A InciteComponent's entity must have a AnimationComponent") }
        return animationComponent
    }
    
    
    /// The amount of time the beam has been in its "firing" state.
    var elapsedTime: TimeInterval = 0.0
    
    
    // MARK: Initializers
    
    required init(inciteComponent: InciteComponent)
    {
        self.inciteComponent = inciteComponent
    }
    
    deinit {
        print("Deallocating InciteActiveState")
    }
    
    // MARK: GKState life cycle
    
    override func didEnter(from previousState: GKState?)
    {
        print("InciteActiveState entered: \(inciteComponent.entity.debugDescription)")
        
        super.didEnter(from: previousState)
        
        // Reset the "amount of time firing" tracker when we enter the "firing" state.
        elapsedTime = 0.0
        
        
        animationComponent.requestedAnimationState = .inciting
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
        print("InciteActiveState updating")
        
        //print(animationComponent.requestedAnimationState.debugDescription)
        
        // Update the "amount of time firing" tracker.
        elapsedTime += seconds
        
        if elapsedTime >= GameplayConfiguration.Incite.maximumIncitingDuration
        {
            /**
             The player has been firing the beam for too long. Enter the `InciteCoolingState`
             to disable firing until the beam has had time to cool down.
             */
            stateMachine?.enter(InciteCoolingState.self)
        }
        else if !inciteComponent.isTriggered
        {
            // The beam is no longer being fired. Enter the `InciteIdleState`.
            stateMachine?.enter(InciteIdleState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is InciteIdleState.Type, is InciteCoolingState.Type:
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

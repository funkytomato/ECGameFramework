/*
//
//  ObserveActiveState.swift
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

class ObserveActiveState: GKState
{
    // MARK: Properties
    unowned var observeComponent: ObserveComponent
    
    
    /// The `RenderComponent' for this component's 'entity'.
    var animationComponent: AnimationComponent
    {
        guard let animationComponent = observeComponent.entity?.component(ofType: AnimationComponent.self) else { fatalError("A ObserveComponent's entity must have a AnimationComponent") }
        return animationComponent
    }
    
    
    /// The amount of time the beam has been in its "firing" state.
    var elapsedTime: TimeInterval = 0.0
    
    
    // MARK: Initializers
    
    required init(observeComponent: ObserveComponent)
    {
        self.observeComponent = observeComponent
    }
    
    deinit {
        print("Deallocating ObserveActiveState")
    }
    
    // MARK: GKState life cycle
    
    override func didEnter(from previousState: GKState?)
    {
        print("ObserveActiveState entered: \(observeComponent.entity.debugDescription)")
        
        super.didEnter(from: previousState)
        
        // Reset the "amount of time firing" tracker when we enter the "firing" state.
        elapsedTime = 0.0
        
        
        animationComponent.requestedAnimationState = .inciting
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
        print("ObserveActiveState updating")
        
        //print(animationComponent.requestedAnimationState.debugDescription)
        
        animationComponent.requestedAnimationState = .inciting
        
        // Update the "amount of time firing" tracker.
        elapsedTime += seconds
        
        if elapsedTime >= GameplayConfiguration.Observe.maximumLookDuration
        {
            /**
             The player has been firing the beam for too long. Enter the `ObserveCoolingState`
             to disable firing until the beam has had time to cool down.
             */
            stateMachine?.enter(ObserveCoolingState.self)
        }
        else if !observeComponent.isTriggered
        {
            // The beam is no longer being fired. Enter the `ObserveIdleState`.
            stateMachine?.enter(ObserveIdleState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is ObserveIdleState.Type, is ObserveCoolingState.Type:
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

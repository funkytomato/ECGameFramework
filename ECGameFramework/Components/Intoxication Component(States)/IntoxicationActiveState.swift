/*
//
//  IntoxicationActiveState.swift
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

class IntoxicationActiveState: GKState
{
    // MARK: Properties
    unowned var intoxicationComponent: IntoxicationComponent
    
    
    /// The `RenderComponent' for this component's 'entity'.
    var animationComponent: AnimationComponent
    {
        guard let animationComponent = intoxicationComponent.entity?.component(ofType: AnimationComponent.self) else { fatalError("A IntoxicationComponent's entity must have a AnimationComponent") }
        return animationComponent
    }
    
    
    /// The amount of time the beam has been in its "firing" state.
    var elapsedTime: TimeInterval = 0.0
    
    
    // MARK: Initializers
    
    required init(intoxicationComponent: IntoxicationComponent)
    {
        self.intoxicationComponent = intoxicationComponent
    }
    
    deinit {
        print("Deallocating IntoxicationActiveState")
    }
    
    // MARK: GKState life cycle
    
    override func didEnter(from previousState: GKState?)
    {
        print("IntoxicationActiveState entered: \(intoxicationComponent.entity.debugDescription)")
        
        super.didEnter(from: previousState)
        
        // Reset the "amount of time firing" tracker when we enter the "firing" state.
        elapsedTime = 0.0
        
        
        animationComponent.requestedAnimationState = .inciting
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
        print("IntoxicationActiveState updating")
        
        //print(animationComponent.requestedAnimationState.debugDescription)
        
        animationComponent.requestedAnimationState = .inciting
        
        // Update the "amount of time firing" tracker.
        elapsedTime += seconds
        
        if elapsedTime >= GameplayConfiguration.Intoxication.maximumIntoxicationDuration
        {
            /**
             The protestor has consumed product, and intoxication will rise a predefined rise over a peroid of time.
             And then move to cooling state where intoxication will fall a little bit.
             */
            stateMachine?.enter(IntoxicationCoolingState.self)
        }
        else if intoxicationComponent.intoxication < 40.0
        {
            // The beam is no longer being fired. Enter the `IntoxicationIdleState`.
            stateMachine?.enter(IntoxicationIdleState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is IntoxicationIdleState.Type, is IntoxicationCoolingState.Type:
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

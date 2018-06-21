/*
//
//  InciteCoolingState.swift
//  ECGameFramework
//
//  Created by Spaceman on 09/06/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//
    Abstract:
    The state the beam enters when it overheats from being used for too long.
*/

import SpriteKit
import GameplayKit

class InciteCoolingState: GKState
{
    // MARK: Properties
    
    unowned var inciteComponent: InciteComponent
    
    /// The `RenderComponent' for this component's 'entity'.
    var animationComponent: AnimationComponent
    {
        guard let animationComponent = inciteComponent.entity?.component(ofType: AnimationComponent.self) else { fatalError("A InciteComponent's entity must have a AnimationComponent") }
        return animationComponent
    }
    
    /// The amount of time the beam has been cooling down.
    var elapsedTime: TimeInterval = 0.0
    
    // MARK: Initializers
    
    required init(inciteComponent: InciteComponent)
    {
        self.inciteComponent = inciteComponent
    }
    
    deinit {
        print("Deallocating InciteCoolingSate")
    }
    
    // MARK: GKState life cycle
    
    override func didEnter(from previousState: GKState?)
    {
        print("InciteCoolingState entered")
        
        super.didEnter(from: previousState)
        
        elapsedTime = 0.0
        
        animationComponent.requestedAnimationState = .idle
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
        print("InciteCoolingState update")
        
        elapsedTime += seconds
        
        // If the beam has spent long enough cooling down, enter `BeamIdleState`.
        if elapsedTime >= GameplayConfiguration.Incite.coolDownDuration
        {
            stateMachine?.enter(InciteIdleState.self)
            
            //Should refill the incite bar for next inciting round
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is InciteIdleState.Type, is InciteActiveState.Type:
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


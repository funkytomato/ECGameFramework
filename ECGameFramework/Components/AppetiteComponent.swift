/*
//
//  AppetiteComponent.swift
//  ECGameFramework
//
//  Created by Jason Fry on 23/06/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
A `GKComponent` that supplies and manages the 'TaskBot's inciting others.

A TaskBot can only appetite others periodically and can only influence others nearby.
*/

import SpriteKit
import GameplayKit

class AppetiteComponent: GKComponent
{
    // MARK: Types
    
    
    // MARK: Properties
    
    /// Set to `true` whenever the player is holding down the attack button.
    var isTriggered = false
    
    
    /**
     The state machine for this `BeamComponent`. Defined as an implicitly
     unwrapped optional property, because it is created during initialization,
     but cannot be created until after we have called super.init().
     */
    var stateMachine: GKStateMachine!
    
    
    /// The `RenderComponent' for this component's 'entity'.
    var renderComponent: RenderComponent
    {
        guard let renderComponent = entity?.component(ofType: RenderComponent.self) else { fatalError("A AppetiteComponent's entity must have a RenderComponent") }
        return renderComponent
    }
    
    /// The `RenderComponent' for this component's 'entity'.
    var animationComponent: AnimationComponent
    {
        guard let animationComponent = entity?.component(ofType: AnimationComponent.self) else { fatalError("A AppetiteComponent's entity must have a AnimationComponent") }
        return animationComponent
    }
    
    // MARK: Initializers
    
    override init()
    {
        super.init()
        
        stateMachine = GKStateMachine(states: [
            AppetiteIdleState(appetiteComponent: self),
            AppetiteActiveState(appetiteComponent: self),
            AppetiteCoolingState(appetiteComponent: self)
            ])
        
        stateMachine.enter(AppetiteIdleState.self)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit
    {
        print("Deallocating AppetiteComponent")
    }
    
    // MARK: GKComponent Life Cycle
    
    
    
    override func update(deltaTime seconds: TimeInterval)
    {
        guard (stateMachine.currentState as? AppetiteActiveState) != nil else { return }
        
        animationComponent.requestedAnimationState = .inciting
        
        stateMachine.update(deltaTime: seconds)
    }
    
    // MARK: Convenience
}

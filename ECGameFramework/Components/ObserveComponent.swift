/*
//
//  ObserveComponent.swift
//  ECGameFramework
//
//  Created by Jason Fry on 23/06/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
A `GKComponent` that supplies and manages the 'TaskBot's inciting others.

A TaskBot can only observe others periodically and can only influence others nearby.
*/

import SpriteKit
import GameplayKit

class ObserveComponent: GKComponent
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
        guard let renderComponent = entity?.component(ofType: RenderComponent.self) else { fatalError("A ObserveComponent's entity must have a RenderComponent") }
        return renderComponent
    }
    
    /// The `RenderComponent' for this component's 'entity'.
    var animationComponent: AnimationComponent
    {
        guard let animationComponent = entity?.component(ofType: AnimationComponent.self) else { fatalError("A ObserveComponent's entity must have a AnimationComponent") }
        return animationComponent
    }
    
    // MARK: Initializers
    
    override init()
    {
        super.init()
        
        stateMachine = GKStateMachine(states: [
            ObserveIdleState(observeComponent: self),
            ObserveActiveState(observeComponent: self),
            ObserveCoolingState(observeComponent: self)
            ])
        
        stateMachine.enter(ObserveIdleState.self)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit
    {
//        print("Deallocating ObserveComponent")
    }
    
    // MARK: GKComponent Life Cycle
    
    
    
    override func update(deltaTime seconds: TimeInterval)
    {
        guard (stateMachine.currentState as? ObserveActiveState) != nil else { return }
        
        animationComponent.requestedAnimationState = .looking
        
        stateMachine.update(deltaTime: seconds)
    }
    
    // MARK: Convenience
}

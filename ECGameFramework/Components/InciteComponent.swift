/*
//
//  InciteComponent.swift
//  ECGameFramework
//
//  Created by Spaceman on 09/06/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//
    Abstract:
    A `GKComponent` that supplies and manages the 'TaskBot's inciting others.
 
    A TaskBot can only incite others periodically and can only influence others nearby.
*/

import SpriteKit
import GameplayKit

class InciteComponent: GKComponent
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
        guard let renderComponent = entity?.component(ofType: RenderComponent.self) else { fatalError("A InciteComponent's entity must have a RenderComponent") }
        return renderComponent
    }
    
    /// The `RenderComponent' for this component's 'entity'.
    var animationComponent: AnimationComponent
    {
        guard let animationComponent = entity?.component(ofType: AnimationComponent.self) else { fatalError("A InciteComponent's entity must have a AnimationComponent") }
        return animationComponent
    }
    
    /// The `IntelligenceComponent' for this component's 'entity'.
    var intelligenceComponent: IntelligenceComponent
    {
        guard let intelligenceComponent = entity?.component(ofType: IntelligenceComponent.self) else { fatalError("A InciteComponent's entity must have a IntelligenceComponent") }
        return intelligenceComponent
    }
    
    // MARK: Initializers
    
    override init()
    {
        super.init()
        
        stateMachine = GKStateMachine(states: [
            InciteIdleState(inciteComponent: self),
            InciteActiveState(inciteComponent: self),
            InciteCoolingState(inciteComponent: self)
            ])
        
        stateMachine.enter(InciteIdleState.self)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit
    {
//        print("Deallocating InciteComponent")
    }
    
    // MARK: GKComponent Life Cycle

    
    
    override func update(deltaTime seconds: TimeInterval)
    {

        
        print("current state: \(stateMachine.currentState.debugDescription), intelligenceComponent current state: \(intelligenceComponent.stateMachine.currentState)")
        
        //Check Protestor is not fighting or confrontation with Police

        guard ((intelligenceComponent.stateMachine.currentState as? ProtestorArrestedState) == nil) else { return }
        guard ((intelligenceComponent.stateMachine.currentState as? ProtestorBeingArrestedState) == nil) else { return }
        guard ((intelligenceComponent.stateMachine.currentState as? ProtestorBotRotateToAttackState) == nil) else { return }
        guard ((intelligenceComponent.stateMachine.currentState as? ProtestorBotPreAttackState) == nil) else { return }
        guard ((intelligenceComponent.stateMachine.currentState as? ProtestorBotAttackState) == nil) else { return }
        guard ((intelligenceComponent.stateMachine.currentState as? ProtestorBotHitState) == nil) else { return }
        guard ((intelligenceComponent.stateMachine.currentState as? TaskBotInjuredState) == nil) else { return }
//        guard ((intelligenceComponent.stateMachine.currentState as? TaskBotFleeState) == nil) else { return }
        guard ((intelligenceComponent.stateMachine.currentState as? ProtestorSheepState) == nil) else { return }
        
//
//        guard ((intelligenceComponent.stateMachine.currentState as? ProtestorInciteState) != nil) else { return }
//        guard (stateMachine.currentState as? InciteActiveState) != nil else { return }
        
        guard let target = entity as? ProtestorBot else { return }
        
        if target.isActive
        {
            stateMachine.update(deltaTime: seconds)
            
            guard let currentState = stateMachine.currentState else { return }
            
            switch currentState
            {
                case is InciteActiveState:
                    animationComponent.requestedAnimationState = .inciting
                    break
                
                default:
                    break
            }
        }
    }
    
    // MARK: Convenience
}


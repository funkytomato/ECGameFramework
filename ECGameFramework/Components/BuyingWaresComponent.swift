/*
//
//  BuyWaresComponent.swift
//  ECGameFramework
//
//  Created by Jason Fry on 30/06/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
A `GKComponent` that supplies and manages the 'TaskBot's buying of products

When active will look for a criminal selling and move to them.
*/

import SpriteKit
import GameplayKit

protocol BuyingWaresComponentDelegate: class
{
    // Called whenever a `HealthComponent` loses charge through a call to `loseCharge`
    func buyingWaresComponentDidLoseProduct(buyWaresComponent: BuyingWaresComponent)
    
    // Called whenever a `HealthComponent` loses charge through a call to `gainCharge`
    func buyingWaresComponentDidGainProduct(buyWaresComponent: BuyingWaresComponent)
}

class BuyingWaresComponent: GKComponent
{
    // MARK: Types
    
    /// The `IntelligenceComponent' for this component's 'entity'.
    var intelligenceComponent: IntelligenceComponent
    {
        guard let intelligenceComponent = entity?.component(ofType: IntelligenceComponent.self) else { fatalError("A InciteComponent's entity must have a IntelligenceComponent") }
        return intelligenceComponent
    }
    
    // MARK: Properties
    var wares: Double
    
    let maximumWares: Double
    
    var percentageWares: Double
    {
        if maximumWares == 0
        {
            return 0.0
        }
        
        return wares / maximumWares
    }

    
    var hasWares: Bool
    {
        return (wares > 0.0)
    }
    
    weak var delegate: BuyingWaresComponentDelegate?
    
    /// Whether the Protestor is looking for something to buy
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
        guard let renderComponent = entity?.component(ofType: RenderComponent.self) else { fatalError("A BuyWaresComponent entity must have a RenderComponent") }
        return renderComponent
    }
    
    /// The `RenderComponent' for this component's 'entity'.
    var animationComponent: AnimationComponent
    {
        guard let animationComponent = entity?.component(ofType: AnimationComponent.self) else { fatalError("A BuyWaresComponent entity must have a AnimationComponent") }
        return animationComponent
    }
    
    // MARK: Initializers
    
    init(wares: Double, maximumWares: Double)
    {
        self.wares = wares
        self.maximumWares = maximumWares
        
        super.init()
        
        stateMachine = GKStateMachine(states: [
            BuyingWaresIdleState(buyWaresComponent: self),
            BuyingWaresLookingState(buyWaresComponent: self),
            BuyingWaresBuyingState(buyWaresComponent: self),
            BuyingWaresTimeOutState(buyWaresComponent: self)
            ])
        
        stateMachine.enter(BuyingWaresIdleState.self)
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
//        print("state: \(intelligenceComponent.stateMachine.currentState)")
        
        
        //Check Protestor is not fighting or confrontation with Police
        guard ((intelligenceComponent.stateMachine.currentState as? ProtestorDetainedState) == nil) else { return }
        guard ((intelligenceComponent.stateMachine.currentState as? ProtestorArrestedState) == nil) else { return }
        guard ((intelligenceComponent.stateMachine.currentState as? ProtestorBeingArrestedState) == nil) else { return }
        guard ((intelligenceComponent.stateMachine.currentState as? ProtestorBotRotateToAttackState) == nil) else { return }
        guard ((intelligenceComponent.stateMachine.currentState as? ProtestorBotPreAttackState) == nil) else { return }
        guard ((intelligenceComponent.stateMachine.currentState as? ProtestorBotAttackState) == nil) else { return }
        guard ((intelligenceComponent.stateMachine.currentState as? ProtestorBotHitState) == nil) else { return }
        guard ((intelligenceComponent.stateMachine.currentState as? TaskBotInjuredState) == nil) else { return }
        guard ((intelligenceComponent.stateMachine.currentState as? TaskBotFleeState) == nil) else { return }
        
        guard let target = entity as? ProtestorBot else { return }
        
        
        if target.isActive
        {
            stateMachine.update(deltaTime: seconds)
            
            guard let currentState = stateMachine.currentState else { return }
            
            switch currentState
            {
                
                case is BuyingWaresLookingState:
                    animationComponent.requestedAnimationState = .looking
                
                case is BuyingWaresBuyingState:
                    animationComponent.requestedAnimationState = .buying
                
                case is BuyingWaresTimeOutState:
                    animationComponent.requestedAnimationState = .idle
                    
                    //Protestor has stopped looking for wares and has lost their appetite.
                    //Reset Appetite to idle
                    let appetiteComponent = self.renderComponent.entity?.component(ofType: AppetiteComponent.self)
                    appetiteComponent?.stateMachine.enter(AppetiteIdleState.self)
                    let taskBot = renderComponent.entity as? ProtestorBot
                    taskBot?.isHungry = false
                
                default:
//                    animationComponent.requestedAnimationState = .idle
                    break
            }
        }
        
        if (stateMachine.currentState as? BuyingWaresTimeOutState != nil)
        {

        }
    }
    
    // MARK: Convenience
    func loseProduct(waresToLose: Double)
    {
        var newWares = wares - waresToLose
        
        // Clamp the new value to the valid range.
        newWares = min(maximumWares, newWares)
        newWares = max(0.0, newWares)
        
        // Check if the new resistance is less than the current resistance.
        if newWares < wares
        {
            wares = newWares
            //buyingWaresBar?.level = percentageWares
            delegate?.buyingWaresComponentDidLoseProduct(buyWaresComponent: self)
        }
    }
    
    func gainProduct(waresToAdd: Double)
    {
        var newWares = wares + waresToAdd
        
        // Clamp the new value to the valid range.
        newWares = min(maximumWares, newWares)
        newWares = max(0.0, newWares)
        
        // Check if the new resistance is greater than the current resistance.
        if newWares > wares
        {
            wares = newWares
//            sellingWaresBar?.level = percentageWares
            delegate?.buyingWaresComponentDidGainProduct(buyWaresComponent: self)
        }
    }
}


/*
//
//  AppetiteComponent.swift
//  ECGameFramework
//
//  Created by Jason Fry on 23/06/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
A `GKComponent` that supplies and manages the 'TaskBot's appetite for alcohol and drugs.

A TaskBot's appetite will gradually increase.  When their appetite is at maximum, they will buy more.
*/

import SpriteKit
import GameplayKit

protocol AppetiteComponentDelegate: class
{
    // Called whenever a `HealthComponent` loses charge through a call to `loseCharge`
    func appetiteComponentDidLoseAppetite(appetiteComponent: AppetiteComponent)
    
    // Called whenever a `HealthComponent` loses charge through a call to `gainCharge`
    func appetiteComponentDidGainAppetite(appetiteComponent: AppetiteComponent)
}

class AppetiteComponent: GKComponent
{
    // MARK: Types
    
    
    // MARK: Properties
    
    //A product has been bought, now consuming
    var isConsumingProduct: Bool
    
    var appetite: Double
    
    let maximumAppetite: Double
    
    var percentageAppetite: Double
    {
        if maximumAppetite == 0
        {
            return 0.0
        }
        
        return appetite / maximumAppetite
    }
    
    var hasAppetite: Bool
    {
        return (appetite > 0.0)
    }
    
    var needsConsumable: Bool
    {
        return appetite == maximumAppetite
    }
    
    /**
     A `ColourBar` used to show the current appetite level. The `ColourBar`'s node
     is added to the scene when the component's entity is added to a `LevelScene`
     via `addEntity(_:)`.
     */
    let appetiteBar: ColourBar?
    
    weak var delegate: AppetiteComponentDelegate?
    
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
        guard let renderComponent = entity?.component(ofType: RenderComponent.self) else { fatalError("A AppetiteComponent's entity must have a RenderComponent") }
        return renderComponent
    }
    
    /// The `RenderComponent' for this component's 'entity'.
    var animationComponent: AnimationComponent
    {
        guard let animationComponent = entity?.component(ofType: AnimationComponent.self) else { fatalError("A AppetiteComponent's entity must have a AnimationComponent") }
        return animationComponent
    }
    
    /// The `RenderComponent' for this component's 'entity'.
    var buyWaresComponent: BuyingWaresComponent
    {
        guard let buyWaresComponent = entity?.component(ofType: BuyingWaresComponent.self) else { fatalError("A AppetiteComponent's entity must have a BuyingWaresComponent") }
        return buyWaresComponent
    }
    
    /// The `IntelligenceComponent' for this component's 'entity'.
    var intelligenceComponent: IntelligenceComponent
    {
        guard let intelligenceComponent = entity?.component(ofType: IntelligenceComponent.self) else { fatalError("A InciteComponent's entity must have a IntelligenceComponent") }
        return intelligenceComponent
    }
    
    // MARK: Initializers
    
    init(appetite: Double, maximumAppetite: Double, displaysAppetiteBar: Bool = false)
    {
        self.appetite = appetite
        self.maximumAppetite = maximumAppetite
        self.isConsumingProduct = false
        
        // Create a `ColourBar` if this `AppetiteComponent` should display one.
        if displaysAppetiteBar
        {
            appetiteBar = ColourBar(levelColour: GameplayConfiguration.AppetiteBar.foregroundLevelColour)
        }
        else
        {
            appetiteBar = nil
        }
        
        super.init()
        
        appetiteBar?.level = percentageAppetite
        
        stateMachine = GKStateMachine(states: [
            AppetiteIdleState(appetiteComponent: self),
            AppetiteHungryState(appetiteComponent: self),
            AppetiteConsumingState(appetiteComponent: self)
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
        //Check Protestor is not fighting, confrontation, scared or injured
        guard ((intelligenceComponent.stateMachine.currentState as? ProtestorDetainedState) == nil) else { return }
        guard ((intelligenceComponent.stateMachine.currentState as? ProtestorArrestedState) == nil) else { return }
        guard ((intelligenceComponent.stateMachine.currentState as? ProtestorBeingArrestedState) == nil) else { return }
        guard ((intelligenceComponent.stateMachine.currentState as? ProtestorBotRotateToAttackState) == nil) else { return }
        guard ((intelligenceComponent.stateMachine.currentState as? ProtestorBotPreAttackState) == nil) else { return }
        guard ((intelligenceComponent.stateMachine.currentState as? ProtestorBotAttackState) == nil) else { return }
        guard ((intelligenceComponent.stateMachine.currentState as? ProtestorBotHitState) == nil) else { return }
        guard ((intelligenceComponent.stateMachine.currentState as? TaskBotInjuredState) == nil) else { return }
        guard ((intelligenceComponent.stateMachine.currentState as? TaskBotFleeState) == nil) else { return }

    
        stateMachine.update(deltaTime: seconds)
        
//        print("state: \(intelligenceComponent.stateMachine.currentState)")
        
        guard let currentState = stateMachine.currentState else { return }
        switch currentState
        {
            
            case is AppetiteConsumingState:
                animationComponent.requestedAnimationState = .drinking
            
            default:
//                animationComponent.requestedAnimationState = .idle
                break
        }
        
        //Protestor's is now hungry and will start to look for a source to buy from
        guard (stateMachine.currentState as? AppetiteHungryState) != nil else { return }
        
        //Protestor is hungry, and wants to buy some wares.  Trigger the BuyingComponent into buying wares
        buyWaresComponent.isTriggered = true
    }
    
    // MARK: Convenience
    func loseAppetite(appetiteToLose: Double)
    {
        var newAppetite = appetite - appetiteToLose
        
        // Clamp the new value to the valid range.
        newAppetite = min(maximumAppetite, newAppetite)
        newAppetite = max(0.0, newAppetite)
        
        //print("newObeiscance: \(newObeisance.debugDescription)  obeisance: \(obeisance.debugDescription)")
        
        // Check if the new charge is less than the current charge.
        if newAppetite < appetite
        {
            appetite = newAppetite
            appetiteBar?.level = percentageAppetite
            delegate?.appetiteComponentDidLoseAppetite(appetiteComponent: self)
        }
    }
    
    func gainAppetite(appetiteToAdd: Double)
    {
        var newAppetite = appetite + appetiteToAdd
        
        // Clamp the new value to the valid range.
        newAppetite = min(maximumAppetite, newAppetite)
        newAppetite = max(0.0, newAppetite)
        
        //print("newAppetite: \(newAppetite.debugDescription)  appetite: \(appetite.debugDescription)")
        
        // Check if the new charge is greater than the current charge.
        if newAppetite > appetite
        {
            appetite = newAppetite
            appetiteBar?.level = percentageAppetite
            delegate?.appetiteComponentDidGainAppetite(appetiteComponent: self)
        }
    }
}

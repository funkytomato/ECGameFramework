/*
//
//  SellingWaresComponent.swift
//  ECGameFramework
//
//  Created by Spaceman on 28/06/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//
Abstract:
A `GKComponent` that supplies and manages the 'TaskBot's inciting others.

A TaskBot can only incite others periodically and can only influence others nearby.
*/

import SpriteKit
import GameplayKit

protocol SellingWaresComponentDelegate: class
{
    // Called whenever a `SellingWaresComponent` loses energy through a call to 'loseWares'
    func sellingWaresComponentDidLoseWares(sellingWaresComponent: SellingWaresComponent)
    
    // Called whenever a `SellingWaresComponent` gains energy through a call to `gainWares`
    func sellingWaresComponenttDidGainWares(sellingWaresComponent: SellingWaresComponent)
}

class SellingWaresComponent: GKComponent
{
    
    // MARK: Types
    
    
    // MARK: Properties
    
    /// Set to `true` whenever the player is holding down the attack button.
    var isTriggered = false
    
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
    
    var isFullyStocked: Bool
    {
        return wares == maximumWares
    }

    /**
     A `SellingWaresBar` used to show the current wares level. The `ColourBar`'s node
     is added to the scene when the component's entity is added to a `LevelScene`
     via `addEntity(_:)`.
     */
    let sellingWaresBar: ColourBar?
    
    weak var delegate: SellingWaresComponentDelegate?
    
    /**
     The state machine for this `BeamComponent`. Defined as an implicitly
     unwrapped optional property, because it is created during initialization,
     but cannot be created until after we have called super.init().
     */
    var stateMachine: GKStateMachine!
    
    
    /// The `RenderComponent' for this component's 'entity'.
    var renderComponent: RenderComponent
    {
        guard let renderComponent = entity?.component(ofType: RenderComponent.self) else { fatalError("A SellingWaresComponent's entity must have a RenderComponent") }
        return renderComponent
    }
    
    /// The `RenderComponent' for this component's 'entity'.
    var animationComponent: AnimationComponent
    {
        guard let animationComponent = entity?.component(ofType: AnimationComponent.self) else { fatalError("A SellingWaresComponent's entity must have a AnimationComponent") }
        return animationComponent
    }
    
    // MARK: Initializers
    
    init(wares: Double, maximumWares: Double, displaysWaresBar: Bool = false)
    {
        self.wares = wares
        self.maximumWares = maximumWares
        
        // Create a `ResistanceBar` if this `ResistanceComponent` should display one.
        if displaysWaresBar
        {
            sellingWaresBar = ColourBar(levelColour: GameplayConfiguration.SellingWaresBar.foregroundLevelColour)
        }
        else
        {
            sellingWaresBar = nil
        }
        
        super.init()
        
        stateMachine = GKStateMachine(states: [
            SellingWaresIdleState(sellingWaresComponent: self),
            SellingWaresActiveState(sellingWaresComponent: self),
            SellingWaresCoolingState(sellingWaresComponent: self)
            ])
        
        stateMachine.enter(SellingWaresIdleState.self)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit
    {
        print("Deallocating InciteComponent")
    }
    
    // MARK: GKComponent Life Cycle
    
    override func update(deltaTime seconds: TimeInterval)
    {
        stateMachine.update(deltaTime: seconds)
        
        guard (stateMachine.currentState as? SellingWaresActiveState) != nil else { return }
        
        print("SellingWaresComponent update: Sell some shit")
        animationComponent.requestedAnimationState = .sellingWares
        
        
    }
    
    // MARK: Component actions
    
    func loseWares(waresToLose: Double)
    {
        var newWares = wares - waresToLose
        
        // Clamp the new value to the valid range.
        newWares = min(maximumWares, newWares)
        newWares = max(0.0, newWares)
        
        // Check if the new resistance is less than the current resistance.
        if newWares < wares
        {
            wares = newWares
            sellingWaresBar?.level = percentageWares
            delegate?.sellingWaresComponentDidLoseWares(sellingWaresComponent: self)
        }
    }
    
    func addWares(waresToAdd: Double)
    {
        var newWares = wares + waresToAdd
        
        // Clamp the new value to the valid range.
        newWares = min(maximumWares, newWares)
        newWares = max(0.0, newWares)
        
        // Check if the new resistance is greater than the current resistance.
        if newWares > wares
        {
            wares = newWares
            sellingWaresBar?.level = percentageWares
            delegate?.sellingWaresComponenttDidGainWares(sellingWaresComponent: self)
        }
    }
}



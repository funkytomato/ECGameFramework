/*
//
//  ResistanceComponent.swift
//  ECGameFramework
//
//  Created by Jason Fry on 03/05/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
A `GKComponent` that tracks the "resistance" (or "health") of a `PlayerBot` or `TaskBot`. For a `PlayerBot`, "resistance" indicates how much power the `PlayerBot` has left before it must reresistance (during which time the `PlayerBot` is inactive). For a `TaskBot`, "resistance" indicates whether the `TaskBot` is "good" or "bad".
*/

import SpriteKit
import GameplayKit

protocol ResistanceComponentDelegate: class
{
    // Called whenever a `ResistanceComponent` loses Resistance through a call to `loseResistance`
    func resistanceComponentDidLoseResistance(resistanceComponent: ResistanceComponent)
}

class ResistanceComponent: GKComponent
{
    // MARK: Properties
    
    // Set to true when being attacked
    var isTriggered = false
    
    var resistance: Double
    
    let maximumResistance: Double
    
    var percentageResistance: Double
    {
        if maximumResistance == 0
        {
            return 0.0
        }
        
        return resistance / maximumResistance
    }
    
    var hasResistance: Bool
    {
        return (resistance > 0.0)
    }
    
    var isFullyResistanced: Bool
    {
        return resistance == maximumResistance
    }
    
    /**
     A `ResistanceBar` used to show the current resistance level. The `ResistanceBar`'s node
     is added to the scene when the component's entity is added to a `LevelScene`
     via `addEntity(_:)`.
     */
    let resistanceBar: ColourBar?
    
    weak var delegate: ResistanceComponentDelegate?
    
    /**
     The state machine for this `ResistanceComponent`. Defined as an implicitly
     unwrapped optional property, because it is created during initialization,
     but cannot be created until after we have called super.init().
     */
    var stateMachine: GKStateMachine!
    
    // MARK: Initializers
    
    init(resistance: Double, maximumResistance: Double, displaysResistanceBar: Bool = false)
    {
        self.resistance = resistance
        self.maximumResistance = maximumResistance
        
        // Create a `ResistanceBar` if this `ResistanceComponent` should display one.
        if displaysResistanceBar
        {
            resistanceBar = ColourBar(levelColour: GameplayConfiguration.ResistanceBar.foregroundLevelColour)
        }
        else
        {
            resistanceBar = nil
        }
        
        super.init()
        
        resistanceBar?.level = percentageResistance
        
        stateMachine = GKStateMachine(states : [
            ResistanceIdleState(resistanceComponent: self),
            ResistanceHitState(resistanceComponent: self),
            ResistanceCoolingState(resistanceComponent: self)
            ])
        
        stateMachine.enter(ResistanceIdleState.self)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit
    {
        print("Deallocating ResistanceComponent")
        
        // Remove the beam node from the scene.
        //beamNode.removeFromParent()
    }
    
    // MARK: GKComponent Life Cycle
    
    override func update(deltaTime seconds: TimeInterval)
    {
        stateMachine.update(deltaTime: seconds)
    }
    
    // MARK: Component actions
    
    func loseResistance(resistanceToLose: Double)
    {
        var newResistance = resistance - resistanceToLose
        
        // Clamp the new value to the valid range.
        newResistance = min(maximumResistance, newResistance)
        newResistance = max(0.0, newResistance)
        
        // Check if the new resistance is less than the current resistance.
        if newResistance < resistance
        {
            resistance = newResistance
            resistanceBar?.level = percentageResistance
            delegate?.resistanceComponentDidLoseResistance(resistanceComponent: self)
        }
    }
    
    func addResistance(resistanceToAdd: Double)
    {
        var newResistance = resistance + resistanceToAdd
        
        // Clamp the new value to the valid range.
        newResistance = min(maximumResistance, newResistance)
        newResistance = max(0.0, newResistance)
        
        // Check if the new resistance is greater than the current resistance.
        if newResistance > resistance
        {
            resistance = newResistance
            resistanceBar?.level = percentageResistance
        }
    }
}

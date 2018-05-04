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
    let resistanceBar: ResistanceBar?
    
    weak var delegate: ResistanceComponentDelegate?
    
    // MARK: Initializers
    
    init(resistance: Double, maximumResistance: Double, displaysResistanceBar: Bool = false)
    {
        self.resistance = resistance
        self.maximumResistance = maximumResistance
        
        // Create a `ResistanceBar` if this `ResistanceComponent` should display one.
        if displaysResistanceBar
        {
            resistanceBar = ResistanceBar()
        }
        else
        {
            resistanceBar = nil
        }
        
        super.init()
        
        resistanceBar?.level = percentageResistance
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
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

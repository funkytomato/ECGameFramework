/*
//
//  ObeisanceComponent.swift
//  ECGameFramework
//
//  Created by Jason Fry on 09/06/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//
Abstract:
A `GKComponent` that tracks the "charge" (or "health") of a `PlayerBot` or `TaskBot`. For a `PlayerBot`, "charge" indicates how much power the `PlayerBot` has left before it must recharge (during which time the `PlayerBot` is inactive). For a `TaskBot`, "charge" indicates whether the `TaskBot` is "good" or "bad".
*/

import SpriteKit
import GameplayKit

protocol ObeisanceComponentDelegate: class
{
    // Called whenever a `ObeisanceComponent` loses charge through a call to `loseObeisance`
    func obeisanceComponentDidLoseObeisance(obeisanceComponent: ObeisanceComponent)
    
    // Called whenever a `ObeisanceComponent` gains charge through a call to `gainObeisance`
    func obeisanceComponentDidGainObeisance(obeisanceComponent: ObeisanceComponent)
}

class ObeisanceComponent: GKComponent
{
    /**
     The state machine for this `ObeisanceComponent`. Defined as an implicitly
     unwrapped optional property, because it is created during initialization,
     but cannot be created until after we have called super.init().
     */
    var stateMachine: GKStateMachine!
    
    // MARK: Properties
    
    var obeisance: Double
    
    let maximumObeisance: Double
    
    var percentageObeisance: Double
    {
        if maximumObeisance == 0
        {
            return 0.0
        }
        
        return obeisance / maximumObeisance
    }
    
    var hasObeisance: Bool
    {
        return (obeisance > 0.0)
    }
    
    //var isFullyCharged: Bool
    var hasFullObeisance: Bool
    {
        return obeisance == maximumObeisance
    }
    
    /**
     A `ChargeBar` used to show the current charge level. The `ChargeBar`'s node
     is added to the scene when the component's entity is added to a `LevelScene`
     via `addEntity(_:)`.
     */
    let obeisanceBar: ColourBar?
    
    weak var delegate: ObeisanceComponentDelegate?
    
    // MARK: Initializers
    
    init(obeisance: Double, maximumObeisance: Double, displaysObeisanceBar: Bool = false)
    {
        self.obeisance = obeisance
        self.maximumObeisance = maximumObeisance
        
        // Create a `ObeisanceBar` if this `ObeisanceComponent` should display one.
        if displaysObeisanceBar
        {
            obeisanceBar = ColourBar(levelColour: GameplayConfiguration.ObeisanceBar.foregroundLevelColour)
        }
        else
        {
            obeisanceBar = nil
        }
        
        super.init()

        
        obeisanceBar?.level = percentageObeisance
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
//        print("Deallocating ObeisanceComponent")
    }
    
    // MARK: Component actions
    
    func loseObeisance(obeisanceToLose: Double)
    {
        var newObeisance = obeisance - obeisanceToLose
        
        // Clamp the new value to the valid range.
        newObeisance = min(maximumObeisance, newObeisance)
        newObeisance = max(0.0, newObeisance)
        
        //print("newObeiscance: \(newObeisance.debugDescription)  obeisance: \(obeisance.debugDescription)")
        
        // Check if the new charge is less than the current charge.
        if newObeisance < obeisance
        {
            obeisance = newObeisance
            obeisanceBar?.level = percentageObeisance
            delegate?.obeisanceComponentDidLoseObeisance(obeisanceComponent: self)
        }
    }
    
    func addObeisance(obeisanceToAdd: Double)
    {
        var newObeisance = obeisance + obeisanceToAdd
        
        // Clamp the new value to the valid range.
        newObeisance = min(maximumObeisance, newObeisance)
        newObeisance = max(0.0, newObeisance)
        
//        print("newObeiscance: \(newObeisance.debugDescription)  obeisance: \(obeisance.debugDescription)")
        
        // Check if the new charge is greater than the current charge.
        if newObeisance > obeisance
        {
            obeisance = newObeisance
            obeisanceBar?.level = percentageObeisance
            delegate?.obeisanceComponentDidGainObeisance(obeisanceComponent: self)
        }
    }
}

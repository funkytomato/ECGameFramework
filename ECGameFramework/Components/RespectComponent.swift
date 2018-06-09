/*
//
//  RespectComponent.swift
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

protocol RespectComponentDelegate: class
{
    // Called whenever a `RespectComponent` loses respect through a call to `loseCharge`
    func respectComponentDidLoseRespect(respectComponent: RespectComponent)
    
    // Called whenever a `RespectComponent` gains respect through a call to `gainRespect`
    func respectComponentDidGainRespect(respectComponent: RespectComponent)
}

class RespectComponent: GKComponent
{
    // MARK: Properties
    
    var respect: Double
    
    let maximumRespect: Double
    
    var percentageRespect: Double
    {
        if maximumRespect == 0
        {
            return 0.0
        }
        
        return respect / maximumRespect
    }
    
    var hasRespect: Bool
    {
        return (respect > 0.0)
    }
    
    //var isFullyCharged: Bool
    var hasFullRespect: Bool
    {
        return respect == maximumRespect
    }
    
    /**
     A `RespectBar` used to show the current charge level. The `RespectBar`'s node
     is added to the scene when the component's entity is added to a `LevelScene`
     via `addEntity(_:)`.
     */
    let respectBar: RespectBar?
    
    weak var delegate: RespectComponentDelegate?
    
    // MARK: Initializers
    
    init(respect: Double, maximumRespect: Double, displaysRespectBar: Bool = false)
    {
        self.respect = respect
        self.maximumRespect = maximumRespect
        
        // Create a `RespectBar` if this `RespectComponent` should display one.
        if displaysRespectBar
        {
            respectBar = RespectBar()
        }
        else
        {
            respectBar = nil
        }
        
        super.init()
        
        respectBar?.level = percentageRespect
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("Deallocating RespectComponent")
    }
    
    // MARK: Component actions
    
    func loseRespect(respectToLose: Double)
    {
        var newRespect = respect - respectToLose
        
        // Clamp the new value to the valid range.
        newRespect = min(maximumRespect, newRespect)
        newRespect = max(0.0, newRespect)
        
        // Check if the new charge is less than the current charge.
        if newRespect < respect
        {
            respect = newRespect
            respectBar?.level = percentageRespect
            delegate?.respectComponentDidLoseRespect(respectComponent: self)
        }
    }
    
    func addRespect(respectToAdd: Double)
    {
        var newRespect = respect + respectToAdd
        
        // Clamp the new value to the valid range.
        newRespect = min(maximumRespect, newRespect)
        newRespect = max(0.0, newRespect)
        
        // Check if the new charge is greater than the current charge.
        if newRespect > respect
        {
            respect = newRespect
            respectBar?.level = percentageRespect
        }
    }
}

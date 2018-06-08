/*
//
//  HealthComponent.swift
//  ECGameFramework
//
//  Created by Jason Fry on 17/04/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
A `GKComponent` that tracks the "charge" (or "health") of a `PlayerBot` or `TaskBot`. For a `PlayerBot`, "charge" indicates how much power the `PlayerBot` has left before it must recharge (during which time the `PlayerBot` is inactive). For a `TaskBot`, "charge" indicates whether the `TaskBot` is "good" or "bad".
*/

import SpriteKit
import GameplayKit

protocol HealthComponentDelegate: class
{
    // Called whenever a `ChargeComponent` loses charge through a call to `loseCharge`
    func healthComponentDidLoseHealth(healthComponent: HealthComponent)
}

class HealthComponent: GKComponent
{
    // MARK: Properties
    
    var health: Double
    
    let maximumHealth: Double
    
    var percentageHealth: Double
    {
        if maximumHealth == 0
        {
            return 0.0
        }
        
        return health / maximumHealth
    }
    
    var hasHealth: Bool
    {
        return (health > 0.0)
    }
    
    //var isFullyCharged: Bool
    var hasFullHealth: Bool
    {
        return health == maximumHealth
    }
    
    /**
     A `ChargeBar` used to show the current charge level. The `ChargeBar`'s node
     is added to the scene when the component's entity is added to a `LevelScene`
     via `addEntity(_:)`.
     */
    let healthBar: HealthBar?
    
    weak var delegate: HealthComponentDelegate?
    
    // MARK: Initializers
    
    init(health: Double, maximumHealth: Double, displaysHealthBar: Bool = false)
    {
        self.health = health
        self.maximumHealth = maximumHealth
        
        // Create a `ChargeBar` if this `ChargeComponent` should display one.
        if displaysHealthBar
        {
            healthBar = HealthBar()
        }
        else
        {
            healthBar = nil
        }
        
        super.init()
        
        healthBar?.level = percentageHealth
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("Deallocating HealthComponent")
    }
    
    // MARK: Component actions
    
    func loseHealth(healthToLose: Double)
    {
        var newHealth = health - healthToLose
        
        // Clamp the new value to the valid range.
        newHealth = min(maximumHealth, newHealth)
        newHealth = max(0.0, newHealth)
        
        // Check if the new charge is less than the current charge.
        if newHealth < health
        {
            health = newHealth
            healthBar?.level = percentageHealth
            delegate?.healthComponentDidLoseHealth(healthComponent: self)
        }
    }
    
    func addHealth(healthToAdd: Double)
    {
        var newHealth = health + healthToAdd
        
        // Clamp the new value to the valid range.
        newHealth = min(maximumHealth, newHealth)
        newHealth = max(0.0, newHealth)
        
        // Check if the new charge is greater than the current charge.
        if newHealth > health
        {
            health = newHealth
            healthBar?.level = percentageHealth
        }
    }
}

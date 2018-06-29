/*
//
//  IntoxicationComponent.swift
//  ECGameFramework
//
//  Created by Jason Fry on 23/06/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
A `GKComponent` that tracks the "charge" (or "intoxication") of a `PlayerBot` or `TaskBot`. For a `PlayerBot`, "charge" indicates how much power the `PlayerBot` has left before it must recharge (during which time the `PlayerBot` is inactive). For a `TaskBot`, "charge" indicates whether the `TaskBot` is "good" or "bad".
*/

import SpriteKit
import GameplayKit

protocol IntoxicationComponentDelegate: class
{
    // Called whenever a `IntoxicationComponent` loses charge through a call to `loseCharge`
    func IntoxicationComponentDidLoseintoxication(IntoxicationComponent: IntoxicationComponent)
    
    // Called whenever a `IntoxicationComponent` loses charge through a call to `gainCharge`
    func IntoxicationComponentDidAddintoxication(IntoxicationComponent: IntoxicationComponent)
}

class IntoxicationComponent: GKComponent
{
    // MARK: Properties
    
    var isTriggered: Bool
    
    var intoxication: Double
    
    let maximumIntoxication: Double
    
    var percentageIntoxication: Double
    {
        if maximumIntoxication == 0
        {
            return 0.0
        }
        
        return intoxication / maximumIntoxication
    }
    
    var hasintoxication: Bool
    {
        return (intoxication > 0.0)
    }
    
    //var isFullyCharged: Bool
    var hasFullintoxication: Bool
    {
        return intoxication == maximumIntoxication
    }
    
    /**
     A `ChargeBar` used to show the current charge level. The `ChargeBar`'s node
     is added to the scene when the component's entity is added to a `LevelScene`
     via `addEntity(_:)`.
     */
    let intoxicationBar: ColourBar?
    
    weak var delegate: IntoxicationComponentDelegate?
    
    // MARK: Initializers
    
    init(intoxication: Double, maximumIntoxication: Double, displaysIntoxicationBar: Bool = false)
    {
        self.isTriggered = false
        self.intoxication = intoxication
        self.maximumIntoxication = maximumIntoxication
        
        // Create a `ChargeBar` if this `ChargeComponent` should display one.
        if displaysIntoxicationBar
        {
            intoxicationBar = ColourBar(levelColour: GameplayConfiguration.IntoxicationBar.foregroundLevelColour)
        }
        else
        {
            intoxicationBar = nil
        }
        
        super.init()
        
        intoxicationBar?.level = percentageIntoxication
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("Deallocating IntoxicationComponent")
    }
    
    // MARK: Component actions
    
    func loseintoxication(intoxicationToLose: Double)
    {
        var newintoxication = intoxication - intoxicationToLose
        
        // Clamp the new value to the valid range.
        newintoxication = min(maximumIntoxication, newintoxication)
        newintoxication = max(0.0, newintoxication)
        
        // Check if the new charge is less than the current charge.
        if newintoxication < intoxication
        {
            intoxication = newintoxication
            intoxicationBar?.level = percentageIntoxication
            delegate?.IntoxicationComponentDidLoseintoxication(IntoxicationComponent: self)
        }
    }
    
    func addintoxication(intoxicationToAdd: Double)
    {
        var newintoxication = intoxication + intoxicationToAdd
        
        // Clamp the new value to the valid range.
        newintoxication = min(maximumIntoxication, newintoxication)
        newintoxication = max(0.0, newintoxication)
        
        // Check if the new charge is greater than the current charge.
        if newintoxication > intoxication
        {
            intoxication = newintoxication
            intoxicationBar?.level = percentageIntoxication
            delegate?.IntoxicationComponentDidAddintoxication(IntoxicationComponent: self)
        }
    }
}

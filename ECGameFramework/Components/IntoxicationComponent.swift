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
    func intoxicationComponentDidLoseintoxication(intoxicationComponent: IntoxicationComponent)
    
    // Called whenever a `IntoxicationComponent` loses charge through a call to `gainCharge`
    func intoxicationComponentDidAddintoxication(intoxicationComponent: IntoxicationComponent)
}

class IntoxicationComponent: GKComponent
{
    
    /// The `RenderComponent' for this component's 'entity'.
    var animationComponent: AnimationComponent
    {
        guard let animationComponent = entity?.component(ofType: AnimationComponent.self) else { fatalError("A ObserveComponent's entity must have a AnimationComponent") }
        return animationComponent
    }
    
    // MARK: Properties
    
    /**
     The state machine for this `BeamComponent`. Defined as an implicitly
     unwrapped optional property, because it is created during initialization,
     but cannot be created until after we have called super.init().
     */
    var stateMachine: GKStateMachine!
    
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
        
        stateMachine = GKStateMachine(states: [
            IntoxicationIdleState(intoxicationComponent: self),
            IntoxicationActiveState(intoxicationComponent: self),
            IntoxicationCoolingState(intoxicationComponent: self)
            ])
        
        stateMachine.enter(IntoxicationIdleState.self)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("Deallocating IntoxicationComponent")
    }
    
    
    override func update(deltaTime seconds: TimeInterval)
    {
        stateMachine.update(deltaTime: seconds)
        
 //       guard (stateMachine.currentState as? IntoxicationActiveState) != nil else { return }
        
        if hasFullintoxication
        {
            animationComponent.requestedAnimationState = .drunk
        }

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
            delegate?.intoxicationComponentDidLoseintoxication(intoxicationComponent: self)
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
            delegate?.intoxicationComponentDidAddintoxication(intoxicationComponent: self)
        }
    }
}

/*
//
//  IntoxicationIdleState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 23/06/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
The state of the `PlayerBot`'s beam when not in use.
*/

import SpriteKit
import GameplayKit

class IntoxicationIdleState: GKState
{
    // MARK: Properties
    
    unowned var intoxicationComponent: IntoxicationComponent
    
    
    
    /// The amount of time the beam has been in its "firing" state.
    var elapsedTime: TimeInterval = 0.0
    
    
    
    // MARK: Initializers
    
    required init(intoxicationComponent: IntoxicationComponent)
    {
        self.intoxicationComponent = intoxicationComponent
    }
    
    deinit {
//        print("Deallocating IntoxicationIdleState")
    }
    
    // MARK: GKState life cycle
    
    override func didEnter(from previousState: GKState?)
    {
//        print("IntoxicationIdleState entered: \(intoxicationComponent.entity.debugDescription)")
        
        super.didEnter(from: previousState)
        
        // Reset the "amount of time firing" tracker when we enter the "firing" state.
        elapsedTime = 0.0
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
//        print("IntoxicationIdleState update: \(intoxicationComponent.entity.debugDescription)")

        if intoxicationComponent.isTriggered
        {
             stateMachine?.enter(IntoxicationActiveState.self)
        }
//        if intoxicationComponent.hasFullintoxication
//        {
//            stateMachine?.enter(IntoxicationActiveState.self)
//        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        return stateClass is IntoxicationActiveState.Type
    }
}

/*
//
//  ResistanceIdleState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 06/05/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
The state of the `PlayerBot`'s beam when not in use.
*/

import SpriteKit
import GameplayKit

class ResistanceIdleState: GKState
{
    // MARK: Properties
    
    unowned var resistanceComponent: ResistanceComponent
      
    
    // MARK: Initializers
    
    required init(resistanceComponent: ResistanceComponent)
    {
        self.resistanceComponent = resistanceComponent
    }
    

    
    // MARK: GKState life cycle
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
        // If the resistance has been triggered, enter `ResistanceHitState`.
        if resistanceComponent.isTriggered
        {
            stateMachine?.enter(ResistanceHitState.self)
        }
        else
        {
            if !resistanceComponent.isFullyResistanced
            {
            
                // Add resistance to the `ProtestorBot`.
                let amountToRecharge = GameplayConfiguration.ProtestorBot.rechargeAmountPerSecond * seconds
                resistanceComponent.addResistance(resistanceToAdd: amountToRecharge)
            }
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is ResistanceHitState.Type:
            return true
            
        default:
            return false
        }
    }
}

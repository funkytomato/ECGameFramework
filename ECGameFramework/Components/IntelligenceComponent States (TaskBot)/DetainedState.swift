/*
//
//  DetainedState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 10/04/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//
Abstract:
The state `ManBot`s are in immediately after reaching the meatwagon destination
*/

import SpriteKit
import GameplayKit

class DetainedState: GKState
{
    // MARK:- Properties
    unowned var entity: ManBot
    
    // The amount of time the 'ManBot' has been in its "Detained" state
    var elapsedTime: TimeInterval = 0.0
    
    
    /// The `AnimationComponent` associated with the `entity`.
    var animationComponent: AnimationComponent
    {
        guard let animationComponent = entity.component(ofType: AnimationComponent.self) else { fatalError("A BeingArrestedState's entity must have an AnimationComponent.") }
        return animationComponent
    }
    
    //MARK:- Initializers
    required init(entity: ManBot)
    {
        self.entity = entity
    }
    
    
    //MARK:- GKState Life Cycle
    override func didEnter(from previousState: GKState?)
    {
        super.didEnter(from: previousState)
        
        //Reset the tracking of how long the 'ManBot' has been in "Detained" state
        elapsedTime = 0.0
        
        //Request the "beingArrested animation for this state's 'ManBot'
        animationComponent.requestedAnimationState = .idle
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
        elapsedTime += seconds
        
        /*
         If the arrested manbot reaches the meatwagon pointer, move to detained state
         */
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is TaskBotAgentControlledState.Type, is DetainedState.Type:
            return true
            
        default:
            return false
        }
    }
}

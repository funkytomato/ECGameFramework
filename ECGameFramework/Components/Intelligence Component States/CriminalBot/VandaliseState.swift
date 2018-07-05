/*
//
//  VandaliseState.swift
//  ECGameFramework
//
//  Created by Spaceman on 23/05/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//
Abstract:
The state `ProtestorBot`s are in immediately after reaching the meatwagon destination
*/

import SpriteKit
import GameplayKit

class VandaliseState: GKState
{
    // MARK:- Properties
    unowned var entity: ProtestorBot
    
    // The amount of time the 'ManBot' has been in its "Detained" state
    var elapsedTime: TimeInterval = 0.0
    
    
    /// The `AnimationComponent` associated with the `entity`.
    var animationComponent: AnimationComponent
    {
        guard let animationComponent = entity.component(ofType: AnimationComponent.self) else { fatalError("A VandaliseState's entity must have an AnimationComponent.") }
        return animationComponent
    }
    
    /// The `TemperamentComponent` associated with the `entity`.
    var temperamentComponent: TemperamentComponent
    {
        guard let temperamentComponent = entity.component(ofType: TemperamentComponent.self) else { fatalError("A VandaliseState's entity must have an TemperamentComponent.") }
        return temperamentComponent
    }
    
    //MARK:- Initializers
    required init(entity: ProtestorBot)
    {
        self.entity = entity
    }
    
    deinit {
//        print("Deallocating VandaliseState")
    }
    
    
    //MARK:- GKState Life Cycle
    override func didEnter(from previousState: GKState?)
    {
        super.didEnter(from: previousState)
        
        //Reset the tracking of how long the 'ManBot' has been in "Detained" state
        elapsedTime = 0.0
        
        //Request the "detained animation for this state's 'ProtestorBot'
        //animationComponent.requestedAnimationState = .vandalising
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        elapsedTime += seconds
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
            case is TaskBotAgentControlledState.Type:
                return true
            
        default:
            return false
        }
    }
}

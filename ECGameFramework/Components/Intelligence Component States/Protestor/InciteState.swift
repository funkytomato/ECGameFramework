/*
//
//  InciteState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 24/05/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
 The Criminal is currently inciting trouble in the crowd.
 The Crim wanders around the scene, and periodically becomes active and whoever they become in contact with during this time becomes influenced.
*/

import SpriteKit
import GameplayKit

class InciteState: GKState
{
    // MARK:- Properties
    unowned var entity: ProtestorBot
    
    // The amount of time the 'ManBot' has been in its "Detained" state
    var elapsedTime: TimeInterval = 0.0
    
    
    /// The `AnimationComponent` associated with the `entity`.
    var animationComponent: AnimationComponent
    {
        guard let animationComponent = entity.component(ofType: AnimationComponent.self) else { fatalError("A InciteState's entity must have an AnimationComponent.") }
        return animationComponent
    }
    
    /// The `TemperamentComponent` associated with the `entity`.
    var temperamentComponent: TemperamentComponent
    {
        guard let temperamentComponent = entity.component(ofType: TemperamentComponent.self) else { fatalError("A InciteState's entity must have an TemperamentComponent.") }
        return temperamentComponent
    }
 
    /// The `TemperamentComponent` associated with the `entity`.
    var intelligenceComponent: IntelligenceComponent
    {
        guard let intelligenceComponent = entity.component(ofType: IntelligenceComponent.self) else { fatalError("A InciteState's entity must have an IntelligenceComponent.") }
        return intelligenceComponent
    }
    
    /// The `TemperamentComponent` associated with the `entity`.
    var inciteComponent: InciteComponent
    {
        guard let inciteComponent = entity.component(ofType: InciteComponent.self) else { fatalError("A InciteState's entity must have an InciteComponent.") }
        return inciteComponent
    }
    
    
    //MARK:- Initializers
    required init(entity: ProtestorBot)
    {
        self.entity = entity
    }
    
    
    deinit {
        print("Deallocating InciteState")
    }
    
    //MARK:- GKState Life Cycle
    override func didEnter(from previousState: GKState?)
    {
        
        //print("InciteState entered")
        
        super.didEnter(from: previousState)
        
        //Reset the tracking of how long the 'ManBot' has been in "Detained" state
        elapsedTime = 0.0
        
        //Request the "detained animation for this state's 'ProtestorBot'
        //animationComponent.requestedAnimationState = .inciting
        
        
        //Set the InciteComponent to on
        inciteComponent.isTriggered = true
        inciteComponent.stateMachine.enter(InciteActiveState.self)
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
        print("InciteState updating")
        
        
        intelligenceComponent.stateMachine.enter(TaskBotAgentControlledState.self)
        
        elapsedTime += seconds
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
            
            case is TaskBotAgentControlledState.Type/*, is InciteState.Type, is ProtestorBotRotateToAttackState.Type*/:
                return true
            
            default:
                return false
        }
    }
    
    override func willExit(to nextState: GKState)
    {
        super.willExit(to: nextState)
    }
}


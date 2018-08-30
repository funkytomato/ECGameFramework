/*
//
//  ProtestorSheepState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 17/08/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

 
 Abstract:
 The Criminal is currently inciting trouble in the crowd.
 The Crim wanders around the scene, and periodically becomes active and whoever they become in contact with during this time becomes influenced.
 */

import SpriteKit
import GameplayKit

class ProtestorSheepState: GKState
{
    // MARK:- Properties
    unowned var entity: ProtestorBot
    
    // The amount of time the 'ManBot' has been in its "Detained" state
    var elapsedTime: TimeInterval = 0.0
    
    
    /// The `TemperamentComponent` associated with the `entity`.
    var spriteComponent: SpriteComponent
    {
        guard let spriteComponent = entity.component(ofType: SpriteComponent.self) else { fatalError("A ProtestorSheepState entity must have an SpriteComponent.") }
        return spriteComponent
    }
    
    /// The `TemperamentComponent` associated with the `entity`.
    var intelligenceComponent: IntelligenceComponent
    {
        guard let intelligenceComponent = entity.component(ofType: IntelligenceComponent.self) else { fatalError("A ProtestorSheepState entity must have an IntelligenceComponent.") }
        return intelligenceComponent
    }
    
    /// The `TemperamentComponent` associated with the `entity`.
    var inciteComponent: InciteComponent
    {
        guard let inciteComponent = entity.component(ofType: InciteComponent.self) else { fatalError("A ProtestorSheepState entity must have an InciteComponent.") }
        return inciteComponent
    }
    
    /// The `TemperamentComponent` associated with the `entity`.
    var animationComponent: AnimationComponent
    {
        guard let animationComponent = entity.component(ofType: AnimationComponent.self) else { fatalError("A ProtestorSheepState entity must have an InciteComponent.") }
        return animationComponent
    }
    
    //MARK:- Initializers
    required init(entity: ProtestorBot)
    {
        self.entity = entity
    }
    
    
    deinit {
        //        print("Deallocating ProtestorSheepState")
    }
    
    //MARK:- GKState Life Cycle
    override func didEnter(from previousState: GKState?)
    {
        
//        print("ProtestorSheepState entered")
        
        super.didEnter(from: previousState)
        elapsedTime = 0.0
        
        entity.isSheep = true
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
//        print("ProtestorSheepState updating")
        
        super.update(deltaTime: seconds)
        elapsedTime += seconds
        
        intelligenceComponent.stateMachine.enter(TaskBotAgentControlledState.self)
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
            
        case is TaskBotAgentControlledState.Type, is TaskBotFleeState.Type, is TaskBotInjuredState.Type,  is TaskBotZappedState.Type,
             is ProtestorBotHitState.Type, is ProtestorBuyWaresState.Type, is ProtestorSheepState.Type:
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



/*
//
//  ProtestorInciteState.swift
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

class ProtestorInciteState: GKState
{
    // MARK:- Properties
    unowned var entity: ProtestorBot
    
    // The amount of time the 'ManBot' has been in its "Detained" state
    var elapsedTime: TimeInterval = 0.0
    
 
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
    
    /// The `TemperamentComponent` associated with the `entity`.
    var animationComponent: AnimationComponent
    {
        guard let animationComponent = entity.component(ofType: AnimationComponent.self) else { fatalError("A InciteState's entity must have an InciteComponent.") }
        return animationComponent
    }
    
    //MARK:- Initializers
    required init(entity: ProtestorBot)
    {
        self.entity = entity
    }
    
    
    deinit {
//        print("Deallocating InciteState")
    }
    
    //MARK:- GKState Life Cycle
    override func didEnter(from previousState: GKState?)
    {
        
        //print("InciteState entered")
        
        super.didEnter(from: previousState)
        elapsedTime = 0.0
        
        //Set the InciteComponent to on
        inciteComponent.isTriggered = true
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        // print("currentState: \(inciteComponent.stateMachine?.currentState.debugDescription)")
        
        // THE TIME IS WRONG HERE.  BECAUSE IT IS NOT STAYING IN THIS STATE, THE ELAPSED TIME IS NOT CORRECTLY UPDATED.
        // THIS COULD EXPLAIN WHY TASKBOTS GET STUCK, AND NOT TIMING CORRECTLY
        // HOW DO WE STAY IN PROTESTORINCITESTATE WHILST CONTINUING TO MOVE???
        
        super.update(deltaTime: seconds)
        elapsedTime += seconds
        
        inciteComponent.stateMachine.update(deltaTime: seconds)
        intelligenceComponent.stateMachine.enter(TaskBotAgentControlledState.self)

        //Show the inciting animation
        guard (inciteComponent.stateMachine?.currentState as? InciteActiveState) != nil else { return }
        animationComponent.requestedAnimationState = .inciting
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
            
            case is TaskBotAgentControlledState.Type, is TaskBotFleeState.Type, is TaskBotInjuredState.Type,  is TaskBotZappedState.Type,
                is ProtestorBotHitState.Type, is ProtestorBuyWaresState.Type, is ProtestorInciteState.Type:
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


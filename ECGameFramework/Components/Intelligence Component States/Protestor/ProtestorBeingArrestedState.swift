/*
//
//  ProtestorBeingArrestedState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 10/04/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//
Abstract:
The state `ManBot`s are in immediately prior to being arrested.
This state has been created to allow for a struggle and resisting arrest

*/

import SpriteKit
import GameplayKit

class ProtestorBeingArrestedState: GKState
{
    // MARK:- Properties
    unowned var entity: ProtestorBot
    
    //The amount of time the 'ManBot' has been in its "BeingArrested" state
    var elapsedTime: TimeInterval = 0.0
    
    
    /// The `AnimationComponent` associated with the `entity`.
    var animationComponent: AnimationComponent
    {
        guard let animationComponent = entity.component(ofType: AnimationComponent.self) else { fatalError("A ProtestorBeingArrestedState's entity must have an AnimationComponent.") }
        return animationComponent
    }
    
    var resistanceComponent: ResistanceComponent
    {
        guard let resistanceComponent = entity.component(ofType: ResistanceComponent.self) else { fatalError("A ResistanceComponent entity must have an AnimationComponent.") }
        return resistanceComponent
    }

    var temperamentComponent: TemperamentComponent
    {
        guard let temperamentComponent = entity.component(ofType: TemperamentComponent.self) else { fatalError("A ResistanceComponent entity must have an TemperamentComponent.") }
        return temperamentComponent
    }
    
    //MARK:- Initializers
    required init(entity: ProtestorBot)
    {
        self.entity = entity
    }
    
    
    //MARK:- GKState Life Cycle
    override func didEnter(from previousState: GKState?)
    {
        super.didEnter(from: previousState)
        
        //Reset the tracking of how long the 'ManBot' has been in a "BeingArrested" state
        elapsedTime = 0.0
        
        
        //Request the "beingArrested animation for this state's 'ProtestorBot'
        animationComponent.requestedAnimationState = .beingArrested
        
        if ((temperamentComponent.stateMachine.currentState as? ViolentState) != nil)
        {
            self.entity.isRetaliating = true
            self.entity.isDangerous = true
        }

    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
        elapsedTime += seconds
        
        /*
         If the `ManBot` has been in its "beingArrested" state for long enough,
         move to the arrested state.
         */
        //if elapsedTime >= GameplayConfiguration.TaskBot.preAttackStateDuration
        if elapsedTime >= GameplayConfiguration.TaskBot.arrestingStateDuration
        {
            stateMachine?.enter(ProtestorArrestedState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is TaskBotAgentControlledState.Type, is ProtestorArrestedState.Type, is TaskBotFleeState.Type:
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

/*
//  ManBotPreAttackState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 01/03/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
The state `ManBot`s are in immediately prior to starting their ramming attack.

 */

import SpriteKit
import GameplayKit

class ManBotPreAttackState: GKState
{
    // MARK: Properties
    
    unowned var entity: ManBot
    
    /// The amount of time the `ManBot` has been in its "pre-attack" state.
    var elapsedTime: TimeInterval = 0.0
    
    /// The `AnimationComponent` associated with the `entity`.
    var animationComponent: AnimationComponent
    {
        guard let animationComponent = entity.component(ofType: AnimationComponent.self) else { fatalError("A ManBotPreAttackState's entity must have an AnimationComponent.") }
        return animationComponent
    }
    
    // MARK: Initializers
    
    required init(entity: ManBot)
    {
        self.entity = entity
    }
    
    deinit {
        print("Deallocating ManBotPreAttackState")
    }
    
    // MARK: GPState Life Cycle
    
    override func didEnter(from previousState: GKState?)
    {
        super.didEnter(from: previousState)
        
        // Reset the tracking of how long the `ManBot` has been in a "pre-attack" state.
        elapsedTime = 0.0
        
        // Request the "attack" animation for this state's `ManBot`.
        animationComponent.requestedAnimationState = .attack
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
        elapsedTime += seconds
        
        /*
         If the `ManBot` has been in its "pre-attack" state for long enough,
         move to the attack state.
         */
        if elapsedTime >= GameplayConfiguration.TaskBot.preAttackStateDuration
        {
            stateMachine?.enter(ManBotAttackState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is TaskBotAgentControlledState.Type, is ManBotAttackState.Type, is TaskBotZappedState.Type:
            return true
            
        default:
            return false
        }
    }
}




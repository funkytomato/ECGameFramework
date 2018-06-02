/*
//
//  ProtestorBotPreAttackState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 20/04/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
The state `ProtestorBot`s are in immediately prior to starting their ramming attack.

*/

import SpriteKit
import GameplayKit

class ProtestorBotPreAttackState: GKState
{
    // MARK: Properties
    
    unowned var entity: ProtestorBot
    
    /// The amount of time the `ProtestorBot` has been in its "pre-attack" state.
    var elapsedTime: TimeInterval = 0.0
    
    /// The `AnimationComponent` associated with the `entity`.
    var animationComponent: AnimationComponent
    {
        guard let animationComponent = entity.component(ofType: AnimationComponent.self) else { fatalError("A ProtestorBotPreAttackState's entity must have an AnimationComponent.") }
        return animationComponent
    }
    
    // MARK: Initializers
    
    required init(entity: ProtestorBot)
    {
        self.entity = entity
    }
    
    
    deinit {
        print("Deallocating ProtestorBotPreAttackState")
    }
    // MARK: GPState Life Cycle
    
    override func didEnter(from previousState: GKState?)
    {
        super.didEnter(from: previousState)
        
        // Reset the tracking of how long the `ProtestorBot` has been in a "pre-attack" state.
        elapsedTime = 0.0
        
        // Request the "attack" animation for this state's `ProtestorBot`.
        animationComponent.requestedAnimationState = .attack
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
        elapsedTime += seconds
        
        /*
         If the `ProtestorBot` has been in its "pre-attack" state for long enough,
         move to the attack state.
         */
        if elapsedTime >= GameplayConfiguration.TaskBot.preAttackStateDuration
        {
            stateMachine?.enter(ProtestorBotAttackState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is TaskBotAgentControlledState.Type, is ProtestorBotAttackState.Type, is TaskBotZappedState.Type:
            return true
            
        default:
            return false
        }
    }
}

/*
//  PoliceBotPreAttackState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 19/04/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
The state `ManBot`s are in immediately prior to starting their ramming attack.

*/

import SpriteKit
import GameplayKit

class PoliceBotPreAttackState: GKState
{
    // MARK: Properties
    
    unowned var entity: PoliceBot
    
    /// The amount of time the `PoliceBot` has been in its "pre-attack" state.
    var elapsedTime: TimeInterval = 0.0
    
    /// The `AnimationComponent` associated with the `entity`.
    var animationComponent: AnimationComponent
    {
        guard let animationComponent = entity.component(ofType: AnimationComponent.self) else { fatalError("A PoliceBotPreAttackState's entity must have an AnimationComponent.") }
        return animationComponent
    }
    
    // MARK: Initializers
    
    required init(entity: PoliceBot)
    {
        self.entity = entity
    }
    
    deinit {
//        print("Deallocating PoliceBotPreAttackState")
    }
    
    // MARK: GPState Life Cycle
    
    override func didEnter(from previousState: GKState?)
    {
        super.didEnter(from: previousState)
        elapsedTime = 0.0
        
        // Request the "attack" animation for this state's `PoliceBot`.
        animationComponent.requestedAnimationState = .attack
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
        elapsedTime += seconds
        
        /*
         If the `PoliceBot` has been in its "pre-attack" state for long enough,
         move to the attack state.
         */
        if elapsedTime >= GameplayConfiguration.TaskBot.preAttackStateDuration
        {
            stateMachine?.enter(PoliceBotAttackState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is TaskBotAgentControlledState.Type, is TaskBotFleeState.Type, is TaskBotInjuredState.Type, is TaskBotZappedState.Type,
             is PoliceBotAttackState.Type:
            return true
            
        default:
            return false
        }
    }
}

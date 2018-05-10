/*
//
//  ScaredState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 17/04/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//
Abstract:
The state `ManBot`s are in immediately after being arrested.

Remove all behavour from bot and attach to the arresting entity.
*/

import SpriteKit
import GameplayKit

class ScaredState: GKState
{
    // MARK:- Properties
    unowned var entity: TaskBot
    
    //The amount of time the 'ManBot' has been in its "Arrested" state
    var elapsedTime: TimeInterval = 0.0

    
    
    /// The `SpriteComponent` associated with the `entity`.
    var spriteComponent: SpriteComponent
    {
        guard let spriteComponent = entity.component(ofType: SpriteComponent.self) else { fatalError("An entity's AngryState must have an AnimationComponent.") }
        return spriteComponent
    }
    
    /// The `AnimationComponent` associated with the `entity`.
    var animationComponent: AnimationComponent
    {
        guard let animationComponent = entity.component(ofType: AnimationComponent.self) else { fatalError("An entity's ScaredState must have an AnimationComponent.") }
        return animationComponent
    }

    
    //MARK:- Initializers
    required init(entity: TaskBot)
    {
        self.entity = entity
    }
    
    
    //MARK:- GKState Life Cycle
    override func didEnter(from previousState: GKState?)
    {
        super.didEnter(from: previousState)
        
        //Reset the tracking of how long the 'ManBot' has been in "Scared" state
        elapsedTime = 0.0
        
        //Request the ScaredState animation for this state's 'ProtestorBot'
        animationComponent.requestedAnimationState = .scared
        
        //Change the colour of the sprite to show calmness
        spriteComponent.changeColour(colour: SKColor.purple)
        
        
        //Set the entity is scared for pathfinding
        entity.isScared = true
        
        entity.isViolent = false
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
        elapsedTime += seconds
        

        // If the entity has spent long enough cooling down, enter `CalmState`.
        if elapsedTime >= GameplayConfiguration.TaskBot.scaredStateDuration
        {
            stateMachine?.enter(CalmState.self)
            entity.isScared = false
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is CalmState.Type, is AngryState.Type:
            return true
            
        default:
            return false
        }
    }
    
    
    // MARK: Convenience
    
}

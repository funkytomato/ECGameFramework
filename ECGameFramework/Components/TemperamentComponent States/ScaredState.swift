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
    
    /// The `PhysicsComponent` associated with the `entity`.
    var physicsComponent: PhysicsComponent
    {
        guard let physicsComponent = entity.component(ofType: PhysicsComponent.self) else { fatalError("An entity's ScaredState must have a PhysicsComponent.") }
        return physicsComponent
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
        
        //Reset the tracking of how long the 'ManBot' has been in "Arrested" state
        elapsedTime = 0.0
        
        //Request the ScaredState animation for this state's 'ManBot'
        //animationComponent.requestedAnimationState = .idle
        
        //Change the colour of the sprite to show calmness
        spriteComponent.changeColour(colour: SKColor.purple)
        
        
        
        /*
        // Apply damage to any entities the `GroundBot` is already in contact with.
        let contactedBodies = physicsComponent.physicsBody.allContactedBodies()
        for contactedBody in contactedBodies
        {
            guard let entity = contactedBody.node?.entity else { continue }
            
            spriteComponent.changeColour(colour: SKColor.cyan)
        }
        */
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
        elapsedTime += seconds
        
        /*
        if entity has moved far away from angry people, then move back into CalmState
         */
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is CalmState.Type, is ScaredState.Type, is AngryState.Type, is SubduedState.Type, is ViolentState.Type:
            return true
            
        default:
            return false
        }
    }
    
    
    // MARK: Convenience
    
}

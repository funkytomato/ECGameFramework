/*
//
//  CalmState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 17/04/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

 Abstract:
 The state of `ManBot`s temperament
 
 
 */

import SpriteKit
import GameplayKit

class CalmState: GKState
{
    // MARK:- Properties
    unowned var entity: ManBot
    
    //The amount of time the 'ManBot' has been in its "Arrested" state
    var elapsedTime: TimeInterval = 0.0
    
    
    /// The `AnimationComponent` associated with the `entity`.
    var animationComponent: AnimationComponent
    {
        guard let animationComponent = entity.component(ofType: AnimationComponent.self) else { fatalError("An entity's CalmState must have an AnimationComponent.") }
        return animationComponent
    }
    
    /// The `PhysicsComponent` associated with the `entity`.
    var physicsComponent: PhysicsComponent
    {
        guard let physicsComponent = entity.component(ofType: PhysicsComponent.self) else { fatalError("An entity's CalmState must have a PhysicsComponent.") }
        return physicsComponent
    }
    
    //MARK:- Initializers
    required init(entity: ManBot)
    {
        self.entity = entity
    }
    
    
    //MARK:- GKState Life Cycle
    override func didEnter(from previousState: GKState?)
    {
        super.didEnter(from: previousState)
        
        //Reset the tracking of how long the 'ManBot' has been in "Arrested" state
        elapsedTime = 0.0
        
        //Request the "CalmState animation for this state's 'ManBot'
        animationComponent.requestedAnimationState = .idle
        
        // Apply damage to any entities the `GroundBot` is already in contact with.
        let contactedBodies = physicsComponent.physicsBody.allContactedBodies()
        for contactedBody in contactedBodies
        {
            guard let entity = contactedBody.node?.entity else { continue }
            
            //If entities bump into each over, increase their temperament
            
        }
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
        case is CalmState.Type, is ScaredState.Type, is AngryState.Type:
            return true
            
        default:
            return false
        }
    }
    
    
    // MARK: Convenience
    
}

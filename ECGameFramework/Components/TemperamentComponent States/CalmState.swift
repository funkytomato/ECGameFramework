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
    unowned var temperamentComponent: TemperamentComponent
    
    //The amount of time the 'ManBot' has been in its "Arrested" state
    var elapsedTime: TimeInterval = 0.0
    
    
    /// The `AnimationComponent` associated with the `entity`.
    var animationComponent: AnimationComponent
    {
        guard let animationComponent = temperamentComponent.entity?.component(ofType: AnimationComponent.self) else { fatalError("TemperamentComponent must have an AnimationComponent.") }
        return animationComponent
    }
    
    required init(temperamentComponent: TemperamentComponent)
    {
        self.temperamentComponent = temperamentComponent
    }
    
    deinit {
//        print("Deallocating CalmState")
    }
    
    //MARK:- GKState Life Cycle
    override func didEnter(from previousState: GKState?)
    {
        super.didEnter(from: previousState)
        elapsedTime = 0.0
        
        //Set the entity is scared for pathfinding
        guard let taskBot = temperamentComponent.entity as? TaskBot else { return }
        taskBot.isViolent = false
        taskBot.isScared = false
        
        //Change the colour of the sprite to show calmness
        animationComponent.changeColour(color: .green)
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        elapsedTime += seconds
        
//        print("temperament: \(temperamentComponent.temperament), calmStateMaximum: \(GameplayConfiguration.Temperament.calmStateMaximumValue)")
        
        // If temperament rises enough move to Aggitated state
        if elapsedTime >= GameplayConfiguration.Temperament.minimumDurationInStateValue &&
            temperamentComponent.temperament > GameplayConfiguration.Temperament.calmStateMaximumValue
        {
            stateMachine?.enter(AggitatedState.self)
        }
        
        // temperament has dropped, move to Calm state
        else if elapsedTime >= GameplayConfiguration.Temperament.minimumDurationInStateValue &&
            temperamentComponent.temperament < GameplayConfiguration.Temperament.calmStateMinimumValue
        {
            stateMachine?.enter(CalmState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is FearfulState.Type, is AggitatedState.Type, is SubduedState.Type, is ScaredState.Type:
            return true
            
        default:
            return false
        }
    }
    
    
    // MARK: Convenience
    
}

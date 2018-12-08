/*
//
//  AngryState.swift
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

class AngryState: GKState
{
    // MARK:- Properties
//    unowned var entity: TaskBot
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
//        print("Deallocating AngryState")
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
        
        //Change the colour of the sprite to show anger
        animationComponent.changeColour(color: .orange)
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        elapsedTime += seconds
        
        
        //If temperament rises move to Violent state
        if elapsedTime >= GameplayConfiguration.Temperament.minimumDurationInStateValue &&
            temperamentComponent.temperament > GameplayConfiguration.Temperament.angryStateMaximumValue
        {
            stateMachine?.enter(ViolentState.self)
        }
        
        // temperament has dropped, move to Aggitated state
        else if elapsedTime >= GameplayConfiguration.Temperament.minimumDurationInStateValue &&
            temperamentComponent.temperament < GameplayConfiguration.Temperament.angryStateMinimumValue
        {
            stateMachine?.enter(AggitatedState.self)
        }
        
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is AggitatedState.Type, is ViolentState.Type, is SubduedState.Type, is ScaredState.Type:
            return true
            
        default:
            return false
        }
    }
    
    
    // MARK: Convenience
    
}


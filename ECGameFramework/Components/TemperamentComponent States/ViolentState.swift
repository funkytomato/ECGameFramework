/*
//
//  ViolentState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 17/04/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
The state `ProtestorBot`s are in immediately after being arrested.

Remove all behavour from bot and attach to the arresting entity.
*/

import SpriteKit
import GameplayKit

class ViolentState: GKState
{
    // MARK:- Properties
    unowned var temperamentComponent: TemperamentComponent
    
    //The amount of time the 'ProtestorBot' has been in its "Violent" state
    var elapsedTime: TimeInterval = 0.0
    
    //The MeatWagon location
    let meatWagonCoordinate = float2(x: 0.0, y: 0.0)
    
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
//        print("Deallocating ViolentState")
    }
    
    
    //MARK:- GKState Life Cycle
    override func didEnter(from previousState: GKState?)
    {
        super.didEnter(from: previousState)
        elapsedTime = 0.0

        //Set the entity is scared for pathfinding
        guard let taskBot = temperamentComponent.entity as? TaskBot else { return }
        taskBot.isViolent = true
        taskBot.isScared = false
        
        //Change the colour of the sprite to show violent
        animationComponent.changeColour(color: .red)
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        elapsedTime += seconds
        
        
        //If temperament rises move to Rage state
        if elapsedTime >= GameplayConfiguration.Temperament.minimumDurationInStateValue &&
            temperamentComponent.temperament > GameplayConfiguration.Temperament.violentStateMaximumValue
        {
            stateMachine?.enter(RageState.self)
        }
        
        // temperament has dropped move to Angry state
        else if elapsedTime >= GameplayConfiguration.Temperament.minimumDurationInStateValue &&
            temperamentComponent.temperament < GameplayConfiguration.Temperament.violentStateMinimumValue
        {
            stateMachine?.enter(AngryState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is RageState.Type, is AngryState.Type, is ScaredState.Type, is SubduedState.Type:
            return true
            
        default:
            return false
        }
    }
    
    
    // MARK: Convenience
    
}

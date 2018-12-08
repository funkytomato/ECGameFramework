/*
//
//  FearfulState.swift
//  ECGameFramework
//
//  Created by Spaceman on 20/07/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
The state `ProtestorBot`s are in immediately after being arrested.

Remove all behavour from bot and attach to the arresting entity.
*/

import SpriteKit
import GameplayKit

class FearfulState: GKState
{
    // MARK:- Properties
//    unowned var entity: TaskBot
    unowned var temperamentComponent: TemperamentComponent
    
    
    //The amount of time the 'ProtestorBot' has been in its "FearfulState" state
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
        //        print("Deallocating FearfulState")
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
        
        //Change the colour of the sprite to show fear
        animationComponent.changeColour(color: .gray)
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        elapsedTime += seconds
        
        
        //If temperament rises enough move to Calm State
        if elapsedTime >= GameplayConfiguration.Temperament.minimumDurationInStateValue &&
            temperamentComponent.temperament > GameplayConfiguration.Temperament.fearfulStateMaximumValue
        {
            stateMachine?.enter(CalmState.self)
        }
            
        //Temperament has dropped, move to Fearful state
        else if elapsedTime >= GameplayConfiguration.Temperament.minimumDurationInStateValue &&
            temperamentComponent.temperament < GameplayConfiguration.Temperament.fearfulStateMinimumValue
        {
            stateMachine?.enter(ScaredState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is ScaredState.Type, is CalmState.Type, is SubduedState.Type:
            return true
            
        default:
            return false
        }
    }
    
    // MARK: Convenience
    
}

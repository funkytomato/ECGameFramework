/*
//
//  RageState.swift
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

class RageState: GKState
{
    // MARK:- Properties
//    unowned var entity: TaskBot
    unowned var temperamentComponent: TemperamentComponent
    
    //The amount of time the 'ProtestorBot' has been in its "Violent" state
    var elapsedTime: TimeInterval = 0.0
    
    //The MeatWagon location
    let meatWagonCoordinate = float2(x: 0.0, y: 0.0)
    
    /// The `SpriteComponent` associated with the `entity`.
//    var spriteComponent: SpriteComponent
//    {
//        guard let spriteComponent = temperamentComponent.entity?.component(ofType: SpriteComponent.self) else { fatalError("An entity's RageState must have an AnimationComponent.") }
//        return spriteComponent
//    }
    
    //MARK:- Initializers
//    required init(entity: TaskBot)
//    {
//        self.entity = entity
//    }
    
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
        
        //Change the colour of the sprite to show violent
//        spriteComponent.changeColour(colour: SKColor.red)
        
        //Set the entity is scared for pathfinding
        guard let taskBot = temperamentComponent.entity as? TaskBot else { return }
        taskBot.isViolent = true
        taskBot.isScared = false
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        elapsedTime += seconds
        
        
        //If temperament drops move to Violent state
        if elapsedTime >= GameplayConfiguration.Temperament.minimumDurationInStateValue &&
            temperamentComponent.temperament < GameplayConfiguration.Temperament.rageStateMinimumValue
        {
            stateMachine?.enter(ViolentState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is ViolentState.Type, is ScaredState.Type, is SubduedState.Type:
            return true
            
        default:
            return false
        }
    }

    // MARK: Convenience
    
}

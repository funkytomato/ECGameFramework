/*
//
//  SubduedState.swift
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

class SubduedState: GKState
{
    // MARK:- Properties
//    unowned var entity: TaskBot
    unowned var temperamentComponent: TemperamentComponent
    
    //The amount of time the 'ManBot' has been in its "Arrested" state
    var elapsedTime: TimeInterval = 0.0

    
    /// The `SpriteComponent` associated with the `entity`.
//    var spriteComponent: SpriteComponent
//    {
//        guard let spriteComponent = temperamentComponent.entity?.component(ofType: SpriteComponent.self) else { fatalError("An entity's AngryState must have an AnimationComponent.") }
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
//        print("Deallocating SubduedState")
    }
    
    //MARK:- GKState Life Cycle
    override func didEnter(from previousState: GKState?)
    {
        super.didEnter(from: previousState)
        elapsedTime = 0.0
        
        //Change the colour of the sprite to show subdued
//        spriteComponent.changeColour(colour: SKColor.darkGray)
        
        //Set the entity to incapacitated for pathfinding
        guard let taskBot = temperamentComponent.entity as? TaskBot else { return }
        taskBot.isViolent = false
        taskBot.isScared = false
        taskBot.isActive = false 
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        elapsedTime += seconds
        
        //Move to a Calmm state after 5 seconds
        if elapsedTime >= 30.0
        {
            stateMachine?.canEnterState(CalmState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is CalmState.Type:
            return true
            
        default:
            return false
        }
    }
    
    
    // MARK: Convenience
    
}

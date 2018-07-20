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
//    unowned var entity: TaskBot
    unowned var temperamentComponent: TemperamentComponent
    
    //The amount of time the 'ManBot' has been in its "Arrested" state
    var elapsedTime: TimeInterval = 0.0
    
    /// The `SpriteComponent` associated with the `entity`.
    var spriteComponent: SpriteComponent
    {
        guard let spriteComponent = temperamentComponent.entity?.component(ofType: SpriteComponent.self) else { fatalError("An entity's AngryState must have an AnimationComponent.") }
        return spriteComponent
    }
    
    
    //MARK:- Initializers
//    required init(e/Users/spaceman/Development/Game Development/Games/ECGameFramework/ECGameFramework/Components/TemperamentComponent States/RageState.swiftntity: TaskBot)
//    {
//        self.entity = entity
//    }
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
        
        //Reset the tracking of how long the 'ProtestorBot' has been in "Calm" state
        elapsedTime = 0.0
        
        //Change the colour of the sprite to show calmness
        spriteComponent.changeColour(colour: SKColor.green)
        
//        self.entity.isScared = false
//        
//        entity.isViolent = false
        
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
        case is ScaredState.Type, is AngryState.Type, is SubduedState.Type:
            return true
            
        default:
            return false
        }
    }
    
    
    // MARK: Convenience
    
}

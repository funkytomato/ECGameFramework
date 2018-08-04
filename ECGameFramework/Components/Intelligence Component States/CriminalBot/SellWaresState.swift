/*
//
//  SellWaresState.swift
//  ECGameFramework
//
//  Created by Spaceman on 23/05/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//
Abstract:
The state `ProtestorBot`s are criminal and selling states
*/

import SpriteKit
import GameplayKit

class SellWaresState: GKState
{
    // MARK:- Properties
    unowned var entity: CriminalBot
    
    // The amount of time the 'ManBot' has been in its "Detained" state
    var elapsedTime: TimeInterval = 0.0

    
    /// The `AnimationComponent` associated with the `entity`.
    var animationComponent: AnimationComponent
    {
        guard let animationComponent = entity.component(ofType: AnimationComponent.self) else { fatalError("A SellWaresState entity must have an AnimationComponent.") }
        return animationComponent
    }
    
    /// The `TemperamentComponent` associated with the `entity`.
    var temperamentComponent: TemperamentComponent
    {
        guard let temperamentComponent = entity.component(ofType: TemperamentComponent.self) else { fatalError("A SellWaresState entity must have an TemperamentComponent.") }
        return temperamentComponent
    }
    
    /// The `Intelligenceomponent` associated with the `entity`.
    var intelligenceComponent: IntelligenceComponent
    {
        guard let intelligenceComponent = entity.component(ofType: IntelligenceComponent.self) else { fatalError("A SellWaresState entity must have an IntelligenceComponent.") }
        return intelligenceComponent
    }
    
    /// The `SellingWaresComponent` associated with the `entity`.
    var sellingWaresComponent: SellingWaresComponent
    {
        guard let sellingWaresComponent = entity.component(ofType: SellingWaresComponent.self) else { fatalError("A SellWaresState entity must have an SellingWaresComponent.") }
        return sellingWaresComponent
    }
    
    
    //MARK:- Initializers
    required init(entity: CriminalBot)
    {
        self.entity = entity

    }
    
    deinit {
//        print("Deallocating SellWareState")
    }
    
    //MARK:- GKState Life Cycle
    override func didEnter(from previousState: GKState?)
    {
        super.didEnter(from: previousState)
        elapsedTime = 0.0
        
        //Tell SellingaresComponent we are selling, and set the TaskBot isSelling flag for pathfinding
        sellingWaresComponent.isTriggered = true
 
        //Request the "detained animation for this state's 'ProtestorBot'
        animationComponent.requestedAnimationState = .selling
        
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        elapsedTime += seconds
        
        //Update the SellingWaresComponent StateMachine
        sellingWaresComponent.stateMachine.update(deltaTime: seconds)
        
        
        //If criminal is not actively selling, they should be moving
        guard sellingWaresComponent.stateMachine?.currentState as? SellingWaresActiveState == nil else { return }
        
        //Ensure the taskbot continues to move around the scene
        intelligenceComponent.stateMachine.enter(TaskBotAgentControlledState.self)
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
            case is TaskBotAgentControlledState.Type:
                return true
            
        default:
            return false
        }
    }
    
    override func willExit(to nextState: GKState)
    {
    }
}

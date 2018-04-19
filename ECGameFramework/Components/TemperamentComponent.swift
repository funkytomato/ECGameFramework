//
//  TemperamentComponent.swift
//  ECGameFramework
//
//  Created by Jason Fry on 16/04/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//
//     Abstract:
//  A `GKComponent` that provides a `GKStateMachine` for entities to use in determining their temperament.

import SpriteKit
import GameplayKit

class TemperamentComponent: GKComponent
{
    
    // MARK: Properties
    
    let stateMachine: GKStateMachine
    
    let initialStateClass: AnyClass
    
    // MARK: Initializers
    
    init(states: [GKState], initialState: GKState)
    {
        print("Initialising TemperamentComponent")
        stateMachine = GKStateMachine(states: states)
        //let firstState = states.first!
        //initialStateClass = type(of: firstState)
        
        initialStateClass = type(of: initialState)
        
        print("initialStateClass :\(initialStateClass.description())")
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: GKComponent Life Cycle
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
        stateMachine.update(deltaTime: seconds)
    }
    
    // MARK: Actions
    
    func enterInitialState()
    {
        stateMachine.enter(initialStateClass)
    }
    
    /*
     Convenience functions
    */
    
    func setState(newState: String)
    {
        switch newState
        {
        case "Scared":
            stateMachine.enter(ScaredState.self)
            
        case "Calm":
            stateMachine.enter(CalmState.self)
            
        case "AngryState":
            stateMachine.enter(AngryState.self)
            
        case "ViolentState":
            stateMachine.enter(ViolentState.self)
            
        default:
            stateMachine.enter(CalmState.self)
        }
        print("Setting the temperamentComponent to :\(newState)")
    }
    
    /*
    Increase the temperament of the entity
    */
    func increaseTemperament()
    {
        let currentTemperament = stateMachine.currentState
        print("currentTemperament:\(currentTemperament.debugDescription)")
        
        switch currentTemperament
        {
        case is ScaredState:
            stateMachine.enter(CalmState.self)
            
        case is CalmState:
            stateMachine.enter(AngryState.self)
            
        case is AngryState:
            stateMachine.enter(ViolentState.self)
            
        case is ViolentState:
            stateMachine.enter(ViolentState.self)
            
        default:
            stateMachine.enter(CalmState.self)
        }
    }
    
    //Decrease the temperament of the entity
    func decreaseTemperament()
    {
        let currentTemperament = stateMachine.currentState
        
        switch currentTemperament
        {
        case is ScaredState:
            stateMachine.enter(ScaredState.self)
            
        case is CalmState:
            stateMachine.enter(ScaredState.self)
            
        case is AngryState:
            stateMachine.enter(CalmState.self)
            
        case is ViolentState:
            stateMachine.enter(AngryState.self)
            
        default:
            stateMachine.enter(CalmState.self)
        }
    }
    
    
    
}

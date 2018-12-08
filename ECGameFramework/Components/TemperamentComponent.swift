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


protocol TemperamentComponentDelegate: class
{
    // Called whenever a `TemperamentComponent` reduces temperament through a call to `reduceTemperament`
    func temperamentComponentDidReduceTemperament(temperamentComponent: TemperamentComponent)
    
    // Called whenever a `TemperamentComponent` increases temperament through a call to `increaseTemperament`
    func temperamentComponentDidIncreaseTemperament(temperamentComponent: TemperamentComponent)
}


class TemperamentComponent: GKComponent
{
    
    // MARK: Properties
    
    var temperament: Double
    let maximumTemperament: Double
    var percentageTemperament: Double
    {
        if maximumTemperament == 0
        {
            return 0.0
        }
        
        return temperament / maximumTemperament
    }
    
    var hasTemperament: Bool
    {
        return (temperament > 0.0)
    }
    
    
    var hasFullTemperament: Bool
    {
        return temperament == maximumTemperament
    }
    
    /**
     A `ColourBar` used to show the current temperament level. The `ColourBar`'s node
     is added to the scene when the component's entity is added to a `LevelScene`
     via `addEntity(_:)`.
     */
    let temperamentBar: ColourBar?
    weak var delegate: TemperamentComponentDelegate?
    
    
    
    var stateMachine: GKStateMachine!
//    var initialStateClass: AnyClass
    
    // MARK: Initializers
    
    init(initialState: String, temperament: Double, maximumTemperament: Double, displaysTemperamentBar: Bool = false)

    {
        //print("Initialising TemperamentComponent")
        self.temperament = temperament
        self.maximumTemperament = maximumTemperament
        
        // Create a `ColourBar` if this `TemperamentComponent` should display one.
        if displaysTemperamentBar
        {
            temperamentBar = ColourBar(levelColour: GameplayConfiguration.TemperamentBar.foregroundLevelColour)
        }
        else
        {
            temperamentBar = nil
        }

        
        super.init()

        temperamentBar?.level = Double(percentageTemperament)
        
        stateMachine = GKStateMachine(states: [
            ScaredState(temperamentComponent: self),
            FearfulState(temperamentComponent: self),
            CalmState(temperamentComponent: self),
            AggitatedState(temperamentComponent: self),
            AngryState(temperamentComponent: self),
            ViolentState(temperamentComponent: self),
            RageState(temperamentComponent: self),
            SubduedState(temperamentComponent: self)
            ])
        
        stateMachine.enter(CalmState.self)
        
        
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
//        print("Deallocating TemperamentComponent")
    }
    
    // MARK: GKComponent Life Cycle
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
    
        
        //Update the temperament state machine
        stateMachine?.update(deltaTime: seconds)
        
        //TEST - PoliceBots turn blue and Criminals turn grey
        guard (self.entity as? ProtestorBot) != nil else { return }
        
        //Set the colour for the current temperament
        guard let currentState = stateMachine.currentState else { return }
        switch currentState
        {
            case is ScaredState:
                    break
            case is FearfulState:
                    break
            case is CalmState:
                    break
            case is AggitatedState:
                    break
            case is AngryState:
                    break
            case is ViolentState:
                    break
            case is RageState:
                    break
            case is SubduedState:
                    break
            default:
                    break
        }
    }
    
    
    
    /*
     Convenience functions
    */

    func setTemperament(newState: String)
    {
//        print("newState: \(newState.debugDescription)")
        

        var stateValue = 0.0
        switch newState
        {
            case "Scared":
                stateValue = GameplayConfiguration.Temperament.scaredStateInitialValue
            
            case "Fearful":
                stateValue = GameplayConfiguration.Temperament.fearfulStateInitialValue
            
            case "Calm":
                stateValue = GameplayConfiguration.Temperament.calmStateInitialValue
            
            case "Aggitated":
                stateValue = GameplayConfiguration.Temperament.aggitatedStateInitialValue
            
            case "Angry":
                stateValue = GameplayConfiguration.Temperament.angryStateInitialValue
            
            case "Violent":
                stateValue = GameplayConfiguration.Temperament.violentStateInitialValue
            
            case "Rage":
                stateValue = GameplayConfiguration.Temperament.rageStateInitialValue
            
            default:
                stateMachine?.enter(CalmState.self)
        }
        
        //Set the temperament value
        increaseTemperament(temperamentToAdd: stateValue)
    }
    
    
    func setState(newState: String)
    {
        print("newState: \(newState.debugDescription)")
        switch newState
        {
            case "Scared":
                stateMachine?.enter(ScaredState.self)
            
            case "Fearful":
                stateMachine?.enter(FearfulState.self)
            
            case "Calm":
                stateMachine?.enter(CalmState.self)
           
            case "Aggitated":
                stateMachine?.enter(AggitatedState.self)
            
            case "Angry":
                stateMachine?.enter(AngryState.self)
            
            case "Violent":
                stateMachine?.enter(ViolentState.self)
            
            case "Rage":
                stateMachine?.enter(RageState.self)
            
            default:
                stateMachine?.enter(CalmState.self)
        }
        //print("Setting the temperamentComponent to :\(newState)")
    }
    
    /*
    Increase the temperament of the entity
    */
    func increaseTemperament()
    {
        let currentTemperament = stateMachine?.currentState
        //print("currentTemperament:\(currentTemperament.debugDescription)")
        
        switch currentTemperament
        {
            case is ScaredState:
                stateMachine?.enter(FearfulState.self)
            
            case is FearfulState:
                stateMachine?.enter(CalmState.self)
            
            case is CalmState:
                stateMachine?.enter(AggitatedState.self)
            
            case is AggitatedState:
                stateMachine?.enter(AngryState.self)
            
            case is AngryState:
                stateMachine?.enter(ViolentState.self)
            
            case is ViolentState:
                stateMachine?.enter(RageState.self)
            
            case is RageState:
                stateMachine?.enter(RageState.self)
            
            default:
                stateMachine?.enter(CalmState.self)
        }
    }
    
    //Decrease the temperament of the entity
    func decreaseTemperament()
    {
        let currentTemperament = stateMachine?.currentState
        
        switch currentTemperament
        {
            case is ScaredState:
                stateMachine?.enter(ScaredState.self)
            
            case is FearfulState:
                stateMachine?.enter(ScaredState.self)
            
            case is CalmState:
                stateMachine?.enter(FearfulState.self)
            
            case is AggitatedState:
                stateMachine?.enter(CalmState.self)
            
            case is AngryState:
                stateMachine?.enter(AggitatedState.self)
            
            case is ViolentState:
                stateMachine?.enter(AngryState.self)
            
            case is RageState:
                stateMachine?.enter(ViolentState.self)
            
            default:
                stateMachine?.enter(CalmState.self)
        }
    }
    
    // MARK: Component actions
    
    func reduceTemperament(temperamentToLose: Double)
    {
        var newTemperament = temperament - temperamentToLose
        
        // Clamp the new value to the valid range.
        newTemperament = min(maximumTemperament, newTemperament)
        newTemperament = max(0.0, Double(newTemperament))
        
        // Check if the new charge is less than the current charge.
        if newTemperament < temperament
        {
            temperament = newTemperament
            temperamentBar?.level = Double(percentageTemperament)
            delegate?.temperamentComponentDidReduceTemperament(temperamentComponent: self)
        }
    }
    
    func increaseTemperament(temperamentToAdd: Double)
    {
        var newTemperament = temperament + temperamentToAdd
        
        // Clamp the new value to the valid range.
        newTemperament = min(maximumTemperament, newTemperament)
        newTemperament = max(0.0, Double(newTemperament))
        
        // Check if the new charge is greater than the current charge.
        if newTemperament > temperament
        {
            temperament = newTemperament
            temperamentBar?.level = Double(percentageTemperament)
            delegate?.temperamentComponentDidIncreaseTemperament(temperamentComponent: self)
        }
    }
}

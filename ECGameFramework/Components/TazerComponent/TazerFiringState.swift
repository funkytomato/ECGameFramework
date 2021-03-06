/*
//
//  WeaponFiringState.swift
//  ECGameFramework
//
//  Created by Spaceman on 25/04/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
The state representing the `TaskBot`'s weapon when it is being fired at a `TaskBot`.
*/

import SpriteKit
import GameplayKit

class TazerFiringState: GKState
{
    // MARK: Properties
    
    unowned var tazerComponent: TazerComponent
    
    /// The `TaskBot` currently being targeted by the weapon.
    var target: TaskBot?
    
    /// The amount of time the weapon has been in its "firing" state.
    var elapsedTime: TimeInterval = 0.0
    
    /// The `PlayerBot` associated with the `weaponComponent`'s `entity`.
    var taskBot: TaskBot
    {
        guard let taskBot = tazerComponent.entity as? TaskBot else { fatalError("A WeaponFiringState's weaponComponent must be associated with a TaskBot.") }
        return taskBot
    }
    
    /// The `RenderComponent` associated with the `weaponComponent`'s `entity`.
    var renderComponent: RenderComponent
    {
        guard let renderComponent = tazerComponent.entity?.component(ofType: RenderComponent.self) else { fatalError("A WeaponFiringState's entity must have a RenderComponent.") }
        return renderComponent
    }
    
    // MARK: Initializers
    
    required init(tazerComponent: TazerComponent)
    {
        self.tazerComponent = tazerComponent
    }
    
    
    deinit {
//        print("Deallocating TazerFiringState")
    }
    
    // MARK: GKState life cycle
    
    override func didEnter(from previousState: GKState?)
    {
        super.didEnter(from: previousState)
        
        // Reset the "amount of time firing" tracker when we enter the "firing" state.
        elapsedTime = 0.0
        
        // Add the `weaponNode` to the scene if it hasn't already been added.
        if tazerComponent.tazerNode.parent == nil
        {
            // `playerBot` is a computed property. Declare a local version so we don't compute it multiple times.
            let taskBot = self.taskBot
            
            /*
             The `weaponComponent`'s `weaponNode` is added to the scene at the `.AboveCharacter` level.
             This ensures it appears above the `PlayerBot` and all `TaskBot`s in the scene.
             */
            guard let scene = renderComponent.node.scene as? LevelScene else { fatalError("The RenderComponent's node must be in a scene.") }
            
            /*
             Subtract 1 from the weapon node's `zPosition` to make sure the weapon appears above all
             characters, but below other elements added to the `AboveCharacters` node.
             */
            tazerComponent.tazerNode.zPosition = -1.0
            
            let aboveCharactersNode = scene.worldLayerNodes[.aboveCharacters]
            aboveCharactersNode?.addChild(tazerComponent.tazerNode)
            
            // Constrain the `weaponNode` to the antenna position on the `PlayerBot`'s node.
            let xRange = SKRange(constantValue: taskBot.weaponTargetOffset.x)
            let yRange = SKRange(constantValue: taskBot.weaponTargetOffset.y)
            
            let constraint = SKConstraint.positionX(xRange, y: yRange)
            constraint.referenceNode = renderComponent.node
            
            tazerComponent.tazerNode.constraints = [constraint]
        }
        
        updateweaponNode(withDeltaTime: 0.0)
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
        // Update the "amount of time firing" tracker.
        elapsedTime += seconds
        
        if elapsedTime >= GameplayConfiguration.Tazer.maximumFireDuration
        {
            /**
             The taskBot has been firing the weapon for too long. Enter the `WeaponCoolingState`
             to disable firing until the weapon has had time to cool down.
             */
            stateMachine?.enter(TazerCoolingState.self)
        }
        else if !tazerComponent.isTriggered
        {
            // The weapon is no longer being fired. Enter the `weaponIdleState`.
            stateMachine?.enter(TazerIdleState.self)
        }
        else
        {
            updateweaponNode(withDeltaTime: seconds)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is TazerIdleState.Type, is TazerCoolingState.Type:
            return true
            
        default:
            return false
        }
    }
    
    override func willExit(to nextState: GKState)
    {
        super.willExit(to: nextState)
        
        // Clear the current target.
        target = nil
        
        // Update the weapon component with the next state.
        tazerComponent.tazerNode.update(withWeaponState: nextState, source: tazerComponent.taskBot)
    }
    
    // MARK: Convenience
    
    func updateweaponNode(withDeltaTime seconds: TimeInterval)
    {
        // Find an appropriate target for the weapon.
        target = tazerComponent.findTargetInWeaponArc(withCurrentTarget: target)
        
        // If the weapon has a target with a charge component, drain charge from it.
        if let healthComponent = target?.component(ofType: HealthComponent.self)
        {
            let healthToLose = GameplayConfiguration.Tazer.damageLossPerSecond * seconds
            healthComponent.loseHealth(healthToLose: healthToLose)
        }
        
        // Update the appearance, position, size and orientation of the `weaponNode`.
        tazerComponent.tazerNode.update(withWeaponState: self, source: taskBot, target: target)
        
        // If the current target has been turned good, deactivate the weapon and move to the idle state.
        if let currentTarget = target, currentTarget.isGood
        {
            tazerComponent.isTriggered = false
            stateMachine?.enter(TazerIdleState.self)
        }
    }
    
}

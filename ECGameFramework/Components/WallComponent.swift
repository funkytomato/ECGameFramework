/*
//
//  WallComponent.swift
//  ECGameFramework
//
//  Created by Spaceman on 17/09/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
A `GKComponent` that manages the 'TaskBot's Wall formation

 WallComponent States:
 
    Regroup, Hold the line, move forward and charge, move backwards and retreat.
*/

import SpriteKit
import GameplayKit

protocol WallComponentDelegate: class
{
    // Called whenever a `HealthComponent` loses charge through a call to `loseCharge`
    func wallComponentDidLoseWall(wallComponent: WallComponent)
    
    // Called whenever a `HealthComponent` loses charge through a call to `gainCharge`
    func wallComponentDidGainWall(wallComponent: WallComponent)
}

class WallComponent: GKComponent
{
    // MARK: Types
    
    
    // MARK: Properties
    
    // The minimum number of Police required to create a wall
    var minimumWallSize: Int
    
    // The maximum number of Police required to create a wall
    var maximumWallSize: Int
    
    
    // The position in the scene that the `PoliceBot` should target when performing Wall manonevres
    var targetPosition: float2?
    
    weak var delegate: WallComponentDelegate?
    
    /// Whether the wall formation has been initated
    var isTriggered = false
    
    
    /**
     The state machine for this `WallComponent`. Defined as an implicitly
     unwrapped optional property, because it is created during initialization,
     but cannot be created until after we have called super.init().
     */
    var stateMachine: GKStateMachine!
    
    
    /// The `RenderComponent' for this component's 'entity'.
    var renderComponent: RenderComponent
    {
        guard let renderComponent = entity?.component(ofType: RenderComponent.self) else { fatalError("A WallComponent's entity must have a RenderComponent") }
        return renderComponent
    }
    
    /// The `RenderComponent' for this component's 'entity'.
    var animationComponent: AnimationComponent
    {
        guard let animationComponent = entity?.component(ofType: AnimationComponent.self) else { fatalError("A WallComponent's entity must have a AnimationComponent") }
        return animationComponent
    }
    
    /// The `IntelligenceComponent' for this component's 'entity'.
    var intelligenceComponent: IntelligenceComponent
    {
        guard let intelligenceComponent = entity?.component(ofType: IntelligenceComponent.self) else { fatalError("A WallComponent's entity must have a IntelligenceComponent") }
        return intelligenceComponent
    }
    
    // MARK: Initializers
    
    init(entity: GKEntity, minimum: Int, maximum: Int)
    {
        //Set the Wall size properties
        self.minimumWallSize = minimum
        self.maximumWallSize = maximum
        
        super.init()
        
        stateMachine = GKStateMachine(states: [
            RegroupState(wallComponent: self),
            HoldTheLineState(wallComponent: self),
            MoveBackwardState(wallComponent: self),
            RetreatState(wallComponent: self),
            MoveForwardState(wallComponent: self),
            ChargeState(wallComponent: self)
            ])
        
        stateMachine.enter(RegroupState.self)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit
    {
        print("Deallocating WallComponent")
    }
    
    // MARK: GKComponent Life Cycle
    
    
    
    override func update(deltaTime seconds: TimeInterval)
    {
        //Check Protestor is not fighting, confrontation, scared or injured
        
        stateMachine.update(deltaTime: seconds)
        
        //        print("state: \(intelligenceComponent.stateMachine.currentState)")
        
        guard let currentState = stateMachine.currentState else { return }
        switch currentState
        {
            
            case is HoldTheLineState:
                animationComponent.requestedAnimationState = .drinking
            
            default:
                //                animationComponent.requestedAnimationState = .idle
                break
        }
        
    }
    
    // MARK: Convenience
    func loseWall(wallToLose: Double)
    {

    }
    
    func gainWall(wallToAdd: Double)
    {

    }
}

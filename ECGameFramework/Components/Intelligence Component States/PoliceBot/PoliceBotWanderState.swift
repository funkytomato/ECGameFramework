/*
//
//  PoliceBotWanderState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 26/10/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
The Protestor is wandering the scene.
The Protestor should sit at bench if free.

*/

import SpriteKit
import GameplayKit

class PoliceBotWanderState: GKState
{
    // MARK:- Properties
    unowned var entity: PoliceBot
    
    // The amount of time the 'ManBot' has been in its "Detained" state
    var elapsedTime: TimeInterval = 0.0
    
    
    /// The `TemperamentComponent` associated with the `entity`.
    var intelligenceComponent: IntelligenceComponent
    {
        guard let intelligenceComponent = entity.component(ofType: IntelligenceComponent.self) else { fatalError("A PoliceBotWanderState.swift entity must have an IntelligenceComponent.") }
        return intelligenceComponent
    }
    
    /// The `TemperamentComponent` associated with the `entity`.
    var animationComponent: AnimationComponent
    {
        guard let animationComponent = entity.component(ofType: AnimationComponent.self) else { fatalError("A PoliceBotWanderState.swift entity must have an InciteComponent.") }
        return animationComponent
    }
    
    //MARK:- Initializers
    required init(entity: PoliceBot)
    {
        self.entity = entity
    }
    
    
    deinit {
        //        print("Deallocating InciteState")
    }
    
    //MARK:- GKState Life Cycle
    override func didEnter(from previousState: GKState?)
    {
        
        print("PoliceBotWanderState.swift entered")
        
        super.didEnter(from: previousState)
        elapsedTime = 0.0
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        elapsedTime += seconds
        
        
        guard let renderComponent = entity.component(ofType: RenderComponent.self) else { return }
        let scene = renderComponent.node.scene as? LevelScene
        let destination = (scene?.createWallLocation())!
        
        // If PoliceBot nears CreateWall location, and has not already requested a wall, and is not already supporting another PoliceBot, then initiate wall formation
        if self.entity.isPolice && !self.entity.requestWall && !self.entity.isSupporting &&
            entity.distanceToPoint(otherPoint: destination) <= 150.0/* && elapsedTime > 30.0*/
        {
            print("PoliceBot close proximity to CreateWall node, entity: \(entity.debugDescription)")
//            self.entity.requestWall = true
//            self.entity.component(ofType: SpriteComponent.self)?.node.color = SKColor.brown
            
            intelligenceComponent.stateMachine.enter(PoliceBotInitateWallState.self)
        }
        else
        {
            intelligenceComponent.stateMachine.enter(TaskBotAgentControlledState.self)
        }
        
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
            
        case is TaskBotAgentControlledState.Type, is TaskBotFleeState.Type, is TaskBotInjuredState.Type,  is TaskBotZappedState.Type,
             is PoliceBotHitState.Type, is PoliceBotInitateWallState.Type, is PoliceBotFormWallState.Type, is PoliceBotInWallState.Type:
            return true
            
        default:
            return false
        }
    }
    
    override func willExit(to nextState: GKState)
    {
        super.willExit(to: nextState)
    }
}

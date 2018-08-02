/*
//
//  BuyWaresCoolingState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 30/06/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
The state the beam enters when it overheats from being used for too long.
*/

import SpriteKit
import GameplayKit

class BuyingWaresBuyingState: GKState
{
    // MARK: Properties
    
    unowned var buyWaresComponent: BuyingWaresComponent
    

    var intelligenceComponent: IntelligenceComponent
    {
        guard let intelligenceComponent = buyWaresComponent.entity?.component(ofType: IntelligenceComponent.self) else { fatalError("A BuyingState entity must have a IntelligenceComponent") }
        return intelligenceComponent
    }
    
    /// The amount of time the beam has been cooling down.
    var elapsedTime: TimeInterval = 0.0
    
    // MARK: Initializers
    
    required init(buyWaresComponent: BuyingWaresComponent)
    {
        self.buyWaresComponent = buyWaresComponent
    }
    
    deinit {
//        print("Deallocating BuyWaresBuyingState")
    }
    
    // MARK: GKState life cycle
    
    override func didEnter(from previousState: GKState?)
    {
//        print("BuyWaresBuyingState entered")
        
        super.didEnter(from: previousState)
        
        elapsedTime = 0.0
        

    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        elapsedTime += seconds
        
//        print("BuyWaresBuyingState update: \(seconds.description)")
    
        

        if buyWaresComponent.hasWares
        {
            stateMachine?.enter(BuyingWaresReturningHomeState.self)
            intelligenceComponent.stateMachine.enter(TaskBotAgentControlledState.self)
            
            //Move Protestor back to their initial position (returnPosition)
            guard let protestor = buyWaresComponent.entity as? ProtestorBot else { return }
            protestor.targetPosition = buyWaresComponent.returnPosition
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is BuyingWaresReturningHomeState.Type:
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

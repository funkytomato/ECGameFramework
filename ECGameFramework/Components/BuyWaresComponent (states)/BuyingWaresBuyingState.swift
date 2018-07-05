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
    
    
    /// The `PhysicsComponent' for this component's 'entity'.
    var physicsComponent: PhysicsComponent
    {
        guard let physicsComponent = buyWaresComponent.entity?.component(ofType: PhysicsComponent.self) else { fatalError("A SellingWaresActiveState entity must have a PhysicsComponent") }
        return physicsComponent
    }
    
    
    /// The `RenderComponent' for this component's 'entity'.
//    var animationComponent: AnimationComponent
//    {
//        guard let animationComponent = buyWaresComponent.entity?.component(ofType: AnimationComponent.self) else { fatalError("A BuyingState entity must have a AnimationComponent") }
//        return animationComponent
//    }

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
        print("Deallocating BuyWaresBuyingState")
    }
    
    // MARK: GKState life cycle
    
    override func didEnter(from previousState: GKState?)
    {
        print("BuyWaresBuyingState entered")
        
        super.didEnter(from: previousState)
        
        elapsedTime = 0.0
        

    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
        print("BuyWaresBuyingState update: \(seconds.description)")
        
 //       animationComponent.requestedAnimationState = .buying
        
        // Check if Protestor is in contact with criminal seller.
        let contactedBodies = physicsComponent.physicsBody.allContactedBodies()
        for contactedBody in contactedBodies
        {
            //Check touching entity is Criminal and wants to sell something
            guard let entity = contactedBody.node?.entity else { continue }
            if let seller = entity as? CriminalBot, seller.isCriminal, seller.isActive, seller.isSelling
            {
                guard let criminalSellingWaresComponent = seller.component(ofType: SellingWaresComponent.self) else { return }
                guard (criminalSellingWaresComponent.stateMachine.currentState as? SellingWaresActiveState) != nil else { return }
                
                stateMachine?.enter(BuyingWaresBuyingState.self)
                //buyProductFromSeller(entity: entity)
            }
        }
        
        elapsedTime += seconds
        if buyWaresComponent.hasWares
        {
            stateMachine?.enter(BuyingWaresIdleState.self)
            intelligenceComponent.stateMachine.enter(TaskBotAgentControlledState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is BuyingWaresIdleState.Type:
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

/*
//
//  ProtestorBuyWaresState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 28/06/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

 Abstract:
 The state `ProtestorBot`s is when buying product to consume.
 States:
    ProtestorBuyWareIdleState = protestor does not need a product
    ProtestorBuyWareLookingState = protestor needs a product and is looking for nearest product seller
    ProtestorBuyWaresBuyingState = protestor is touching seller and is buying product
 */

import SpriteKit
import GameplayKit

class ProtestorBuyWaresState: GKState
{
    // MARK:- Properties
    unowned var entity: ProtestorBot
    
    // The amount of time the 'ManBot' has been in its "Detained" state
    var elapsedTime: TimeInterval = 0.0
    
    
    /// The `AnimationComponent` associated with the `entity`.
    var animationComponent: AnimationComponent
    {
        guard let animationComponent = entity.component(ofType: AnimationComponent.self) else { fatalError("A ProtestorBuyWaresState entity must have an AnimationComponent.") }
        return animationComponent
    }
    
    /// The `TemperamentComponent` associated with the `entity`.
    var temperamentComponent: TemperamentComponent
    {
        guard let temperamentComponent = entity.component(ofType: TemperamentComponent.self) else { fatalError("A ProtestorBuyWaresState entity must have an TemperamentComponent.") }
        return temperamentComponent
    }
    
    /// The `Intelligenceomponent` associated with the `entity`.
    var intelligenceComponent: IntelligenceComponent
    {
        guard let intelligenceComponent = entity.component(ofType: IntelligenceComponent.self) else { fatalError("A ProtestorBuyWaresState entity must have an IntelligenceComponent.") }
        return intelligenceComponent
    }
    
    /// The `SellingWaresComponent` associated with the `entity`.
    var sellingWaresComponent: SellingWaresComponent
    {
        guard let sellingWaresComponent = entity.component(ofType: SellingWaresComponent.self) else { fatalError("A ProtestorBuyWaresState entity must have an SellingWaresComponent.") }
        return sellingWaresComponent
    }
    
    /// The `SellingWaresComponent` associated with the `entity`.
    var buyWaresComponent: BuyingWaresComponent
    {
        guard let buyWaresComponent = entity.component(ofType: BuyingWaresComponent.self) else { fatalError("A ProtestorBuyWaresState entity must have an BuyWaresComponent.") }
        return buyWaresComponent
    }
    
    
    //MARK:- Initializers
    required init(entity: ProtestorBot)
    {
        self.entity = entity
        
    }
    
    deinit {
//        print("Deallocating ProtestorBuyWaresState")
    }
    
    //MARK:- GKState Life Cycle
    override func didEnter(from previousState: GKState?)
    {
        super.didEnter(from: previousState)
        
        //Reset the tracking of how long the 'ManBot' has been in "Detained" state
        elapsedTime = 0.0
        
        buyWaresComponent.stateMachine.enter(BuyingWaresIdleState.self)
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        elapsedTime += seconds
        
        buyWaresComponent.stateMachine.update(deltaTime: seconds)
        
        intelligenceComponent.stateMachine.enter(TaskBotAgentControlledState.self)
        

        //Show buying animation if in buying state
        guard (stateMachine?.currentState as? BuyingWaresBuyingState) != nil else { return }
        animationComponent.requestedAnimationState = .buying
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is TaskBotAgentControlledState.Type, is TaskBotFleeState.Type, is TaskBotInjuredState.Type,  is TaskBotZappedState.Type,
             is ProtestorBotHitState.Type, is ProtestorInciteState.Type:
            return true
            
        default:
            return false
        }
    }
}

/*
//  PoliceBotAttackState.swift
//  ECGameFramework
//
//  Created by Jason Fry on 19/04/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
The state of a `ManBot` when actively charging toward the `PlayerBot` or another `TaskBot`.

*/

import SpriteKit
import GameplayKit

class PoliceBotAttackState: GKState
{
    // MARK: Properties
    
    unowned var entity: PoliceBot
    
    /// The distance to the current target on the previous update loop.
    var lastDistanceToTarget: Float = 0
    
    /// The `MovementComponent` associated with the `entity`.
    var movementComponent: MovementComponent
    {
        guard let movementComponent = entity.component(ofType: MovementComponent.self) else { fatalError("A ManBotAttackState's entity must have a MovementComponent.") }
        return movementComponent
    }
    
    /// The `PhysicsComponent` associated with the `entity`.
    var physicsComponent: PhysicsComponent
    {
        guard let physicsComponent = entity.component(ofType: PhysicsComponent.self) else { fatalError("A ManBotAttackState's entity must have a PhysicsComponent.") }
        return physicsComponent
    }
    
    /// The `targetPosition` from the `entity`.
    var targetPosition: float2
    {
        guard let targetPosition = entity.targetPosition else { fatalError("A ManBotRotateToAttackState's entity must have a targetPosition set.") }
        return targetPosition
    }
    
    // MARK: Initializers
    
    required init(entity: PoliceBot)
    {
        self.entity = entity
    }
    
    // MARK: GKState Life Cycle
    
    override func didEnter(from previousState: GKState?)
    {
        super.didEnter(from: previousState)
        
        // Apply damage to any entities the `ManBot` is already in contact with.
        let contactedBodies = physicsComponent.physicsBody.allContactedBodies()
        for contactedBody in contactedBodies
        {
            guard let entity = contactedBody.node?.entity else { continue }
            applyDamageToEntity(entity: entity)
        }
        
        // `targetPosition` is a computed property. Declare a local version so we don't compute it multiple times.
        let targetPosition = self.targetPosition
        
        // Calculate the distance and vector to the target.
        let dx = targetPosition.x - entity.agent.position.x
        let dy = targetPosition.y - entity.agent.position.y
        
        lastDistanceToTarget = hypot(dx, dy)
        let targetVector = float2(x: Float(dx), y: Float(dy))
        
        // `movementComponent` is a computed property. Declare a local version so we don't compute it multiple times.
        let movementComponent = self.movementComponent
        
        // Move the `ManBot` towards the target at an increased speed.
        movementComponent.movementSpeed *= GameplayConfiguration.PoliceBot.movementSpeedMultiplierWhenAttacking
        movementComponent.angularSpeed *= GameplayConfiguration.PoliceBot.angularSpeedMultiplierWhenAttacking
        
        movementComponent.nextTranslation = MovementKind(displacement: targetVector)
        movementComponent.nextRotation = nil
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
        // `targetPosition` is a computed property. Declare a local version so we don't compute it multiple times.
        let targetPosition = self.targetPosition
        
        // Leave the attack state if the `ManBot` is close to its target.
        let dx = targetPosition.x - entity.agent.position.x
        let dy = targetPosition.y - entity.agent.position.y
        
        let currentDistanceToTarget = hypot(dx, dy)
        if currentDistanceToTarget < GameplayConfiguration.PoliceBot.attackEndProximity
        {
            stateMachine?.enter(TaskBotAgentControlledState.self)
            return
        }
        
        /*
         Leave the attack state if the `PoliceBot` has moved further away from
         its target because it has been knocked off course.
         */
        if currentDistanceToTarget > lastDistanceToTarget
        {
            stateMachine?.enter(TaskBotAgentControlledState.self)
            return
        }
        
        // Otherwise, remember the current distance for the next time we update this state.
        lastDistanceToTarget = currentDistanceToTarget
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        switch stateClass
        {
        case is TaskBotAgentControlledState.Type, is TaskBotZappedState.Type:
            return true
            
        default:
            return false
        }
    }
    
    override func willExit(to nextState: GKState)
    {
        super.willExit(to: nextState)
        
        // `movementComponent` is a computed property. Declare a local version so we don't compute it multiple times.
        let movementComponent = self.movementComponent
        
        // Stop the `ManBot`'s movement and restore its standard movement speed.
        movementComponent.nextRotation = nil
        movementComponent.nextTranslation = nil
        movementComponent.movementSpeed /= GameplayConfiguration.PoliceBot.movementSpeedMultiplierWhenAttacking
        movementComponent.angularSpeed /= GameplayConfiguration.PoliceBot.angularSpeedMultiplierWhenAttacking
    }
    
    // MARK: Convenience
    
    func applyDamageToEntity(entity: GKEntity)
    {
        print("entity: \(entity.debugDescription)")
        
        if let playerBot = entity as? PlayerBot, let chargeComponent = playerBot.component(ofType: ChargeComponent.self), !playerBot.isPoweredDown
        {
            // If the other entity is a `PlayerBot` that isn't powered down, reduce its charge.
            chargeComponent.loseCharge(chargeToLose: GameplayConfiguration.PoliceBot.chargeLossPerContact)
        }
        //else if let taskBot = entity as? TaskBot, taskBot.isGood
            
      //  HERE IS THE PROBLEM.  IT IS A MANBOT AND NOT A PROTESTORBOT!   WHAT THE FUCK IS GOING ON
            
        else if let protestorBot = entity as? ProtestorBot, protestorBot.isGood
        {
            //Move state to next
            guard let intelligenceComponent = entity.component(ofType: IntelligenceComponent.self) else { return }
           // guard let temperamentComponent = entity.component(ofType: TemperamentComponent.self) else { return }
            
            switch intelligenceComponent.stateMachine.currentState
            {

                
                //Protestor is being arrested by the police, and is now arrested
                case is BeingArrestedState:
                    intelligenceComponent.stateMachine.enter(ArrestedState.self)
                
                //Protestor has been moved to the MeatWagon and is now detained
                case is ArrestedState:
                    intelligenceComponent.stateMachine.enter(ArrestedState.self)

//                    temperamentComponent.stateMachine.enter(AngryState.self)
                
                //Protestor is freely moving around the scene when Police move in to arrest protestor
                case is TaskBotAgentControlledState:
                    intelligenceComponent.stateMachine.enter(BeingArrestedState.self)
                
                default:
                    break
            }
            
            
            
            
            // If the other entity is a good `TaskBot`, turn it bad.
            //taskBot.isGood = false
        }
    }
    
}

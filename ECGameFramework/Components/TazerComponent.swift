/*
//
//  TazerComponent.swift
//  ECGameFramework
//
//  Created by Spaceman on 25/04/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
A `GKComponent` that supplies and manages the `TaskBot`'s weapon. The beam is used to tazering...
*/

import SpriteKit
import GameplayKit

class TazerComponent: GKComponent
{
    // MARK: Types
    
    struct TazerInfo
    {
        /// The position of the antenna.
        let position: CGPoint
        
        /// The direction the weapon is facing.
        let rotation: Float
        
        init(entity: GKEntity, weaponOffset: CGPoint)
        {
            guard let renderComponent = entity.component(ofType: RenderComponent.self) else { fatalError("TazerInfo must be created with an entity that has a RenderComponent") }
            guard let orientationComponent = entity.component(ofType: OrientationComponent.self) else { fatalError("TazerInfo must be created with an entity that has an OrientationComponent") }
            
            position = CGPoint(x: renderComponent.node.position.x + weaponOffset.x, y: renderComponent.node.position.y + weaponOffset.y)
            rotation = Float(orientationComponent.zRotation)
        }
        
        func angleTo(target: TazerInfo) -> Float
        {
            // Create a vector that represents the translation to the target position.
            let translationVector = float2(x: Float(target.position.x - position.x), y: Float(target.position.y - position.y))
            
            // Create a unit vector that represents the rotation.
            let angleVector = float2(x: cos(rotation), y: sin(rotation))
            
            // Calculate the dot product.
            let dotProduct = dot(translationVector, angleVector)
            
            // Use the dot product and magnitude of the translation vector to determine the angle to the target.
            let translationVectorMagnitude = hypot(translationVector.x, translationVector.y)
            let angle = acos(dotProduct / translationVectorMagnitude)
            
            return angle
        }
    }
    
    // MARK: Properties
    
    /// Set to `true` whenever the player is holding down the attack button.
    var isTriggered = false
    
    let tazerNode = TazerNode()
    
    var taskBotWeapon: TazerInfo
    {
        return TazerInfo(entity: taskBot, weaponOffset: taskBot.weaponTargetOffset)
    }
    
    /**
     The state machine for this `WeaponComponent`. Defined as an implicitly
     unwrapped optional property, because it is created during initialization,
     but cannot be created until after we have called super.init().
     */
    var stateMachine: GKStateMachine!
    
    /// The 'TaskBot' this component is associated with.
    var taskBot: TaskBot
    {
        guard let taskBot = entity as? TaskBot else { fatalError("WeaponComponents must be associated with a TaskBot") }
        return taskBot
    }
    
    /// The `RenderComponent' for this component's 'entity'.
    var renderComponent: RenderComponent
    {
        guard let renderComponent = entity?.component(ofType: RenderComponent.self) else { fatalError("A WeaponComponent's entity must have a RenderComponent") }
        return renderComponent
    }
    
    // MARK: Initializers
    
    override init()
    {
        super.init()
        
        stateMachine = GKStateMachine(states: [
            TazerIdleState(tazerComponent: self),
            TazerFiringState(tazerComponent: self),
            TazerCoolingState(tazerComponent: self)
            ])
        
        stateMachine.enter(TazerIdleState.self)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit
    {
        print("Dealocating TazerComponent")
        
        // Remove the beam node from the scene.
        tazerNode.removeFromParent()
    }
    
    // MARK: GKComponent Life Cycle
    
    override func update(deltaTime seconds: TimeInterval)
    {
        stateMachine.update(deltaTime: seconds)
    }
    
    // MARK: Convenience
    
    /**
     Finds the nearest "bad" `TaskBot` that lies within the beam's arc.
     Returns `nil` if no `TaskBot`s are within targeting range.
     */
    func findTargetInWeaponArc(withCurrentTarget currentTarget: TaskBot?) -> TaskBot?
    {
        let thisBotNode = renderComponent.node
        
        // Use the player's `EntitySnapshot` to build an array of targetable `TaskBot`s who's antennas are within the beam's arc.
        guard let level = thisBotNode.scene as? LevelScene else { return nil }
        guard let snapshot = level.entitySnapshotForEntity(entity: taskBot) else { return nil }
        
        let botsInArc = snapshot.entityDistances.filter { entityDistance in
            guard let taskBot = entityDistance.target as? TaskBot else { return false }
            
            // Filter out entities that aren't "bad" `TaskBot`s with a `RenderComponent`.
            guard let taskBotNode = taskBot.component(ofType: RenderComponent.self)?.node else { return false }
            if taskBot.isGood
            {
                return false
            }
            
            // Filter out `TaskBot`s that are too far away.
            if entityDistance.distance > Float(GameplayConfiguration.Tazer.arcLength)
            {
                return false
            }
            
            // Filter out any `TaskBot` who's antenna is not within the beam's arc.
            let taskBotWeapon = TazerInfo(entity: taskBot, weaponOffset: taskBot.weaponTargetOffset)
            
            let targetDistanceRatio = entityDistance.distance / Float(GameplayConfiguration.Tazer.arcLength)
            
            /*
             Determine the angle between the `taskBotAntenna` and the `taskBotAntenna`
             adjusting for the distance between the two entities.
             
             This adjustment allows for easier aiming as the `TaskBot` and `target TaskBot`
             get closer together.
             */
            let arcAngle = taskBotWeapon.angleTo(target: taskBotWeapon) * targetDistanceRatio
            if arcAngle > Float(GameplayConfiguration.Tazer.maxArcAngle)
            {
                return false
            }
            
            // Filter out `TaskBot`s where there is scenery between their antenna and the `TaskBot`'s weapon.
            var hasLineOfSite = true
            level.physicsWorld.enumerateBodies(alongRayStart: taskBotWeapon.position, end: taskBotWeapon.position) { obstacleBody, _, _, stop in
                // Ignore nodes that have an entity as they are not scenery.
                if obstacleBody.node?.entity != nil
                {
                    return
                }
                
                // Calculate the lowest y-position for the obstacle's node.
                guard let obstacleNode = obstacleBody.node else { return }
                let obstacleLowestY = obstacleNode.calculateAccumulatedFrame().origin.y
                
                /*
                 If the obstacle's lowest y-position is less than the `TaskBot`'s y-position or
                 the 'PlayerBot'`s y-position, then it blocks the line of sight.
                 */
                if obstacleLowestY < taskBotNode.position.y || obstacleLowestY < thisBotNode.position.y
                {
                    hasLineOfSite = false
                    stop.pointee = true
                }
            }
            
            return hasLineOfSite
            }.map {
                return $0.target as! TaskBot
        }
        
        let target: TaskBot?
        
        // If the current target is still targetable, continue to target it.
        if let currentTarget = currentTarget, botsInArc.contains(currentTarget)
        {
            target = currentTarget
        }
        else
        {
            // Else, return the closest target in the beam's arc.
            target = botsInArc.first
        }
        
        return target
    }
}

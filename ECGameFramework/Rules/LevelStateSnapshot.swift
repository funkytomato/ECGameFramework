/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    These types are used by the game's AI to capture and evaluate a snapshot of the game's state. `EntityDistance` encapsulates the distance between two entities. `LevelStateSnapshot` stores an `EntitySnapshot` for every entity in the level. `EntitySnapshot` stores the distances from an entity to every other entity in the level.
*/

import GameplayKit

/// Encapsulates two entities and their distance apart.
struct EntityDistance
{
    let source: GKEntity
    let target: GKEntity
    let distance: Float
}
    
/**
    Stores a snapshot of the state of a level and all of its entities
    (`PlayerBot`s and `TaskBot`s) at a certain point in time.
*/
class LevelStateSnapshot
{
    // MARK: Properties
    
    // A dictionary whose keys are entities, and whose values are entity snapshots for those entities.
    var entitySnapshots: [GKEntity: EntitySnapshot] = [:]
    
    // MARK: Initialization

    // Initializes a new `LevelStateSnapshot` representing all of the entities in a `LevelScene`.
    init(scene: LevelScene)
    {
        
        /// Returns the `GKAgent2D` for a `PlayerBot` or `TaskBot`.
        func agentForEntity(entity: GKEntity) -> GKAgent2D
        {
            if let agent = entity.component(ofType: TaskBotAgent.self)
            {
                return agent
            }
            else if let playerBot = entity as? PlayerBot
            {
                return playerBot.agent
            }
            
            fatalError("All entities in a level must have an accessible associated GKEntity")
        }

        // A dictionary that will contain a temporary array of `EntityDistance` instances for each entity.
        var entityDistances: [GKEntity: [EntityDistance]] = [:]

        // Add an empty array to the dictionary for each entity, ready for population below.
        for entity in scene.entities
        {
            entityDistances[entity] = []
        }

        /*
            Iterate over all entities in the scene to calculate their distance from other entities.
            `scene.entities` is a `Set`, which does not have integer indexing.
            Because we want to use the current index value from the outer loop as the seed for the inner loop,
            we work with the `Set` index values directly.
        */
        for sourceEntity in scene.entities
        {
            let sourceIndex = scene.entities.index(of: sourceEntity)!

            // Retrieve the `GKAgent` for the source entity.
            let sourceAgent = agentForEntity(entity: sourceEntity)
            
            // Iterate over the remaining entities to calculate their distance from the source agent.
            for targetEntity in scene.entities[scene.entities.index(after: sourceIndex) ..< scene.entities.endIndex]
            {
                // Retrieve the `GKAgent` for the target entity.
                let targetAgent = agentForEntity(entity: targetEntity)
                
                // Calculate the distance between the two agents.
                let dx = targetAgent.position.x - sourceAgent.position.x
                let dy = targetAgent.position.y - sourceAgent.position.y
                let distance = hypotf(dx, dy)

                // Save this distance to both the source and target entity distance arrays.
                entityDistances[sourceEntity]!.append(EntityDistance(source: sourceEntity, target: targetEntity, distance: distance))
                entityDistances[targetEntity]!.append(EntityDistance(source: targetEntity, target: sourceEntity, distance: distance))

            }
        }
        
        // Determine the number of "good" `TaskBot`s and "bad" `TaskBot`s in the scene.
        let (dangerousProtestorTaskBots, protestorTaskBots, policeTaskBots) = scene.entities.reduce(([], [], []))
        {

            (workingArrays: (dangerousProtestorTaskBots: [TaskBot], protestorBots: [TaskBot], policeBots: [TaskBot]), thisEntity: GKEntity) -> ([TaskBot], [TaskBot], [TaskBot]) in
            
            // Try to cast this entity as a `TaskBot`, and skip this entity if the cast fails.
            guard let thisTaskbot = thisEntity as? TaskBot else { return workingArrays }
                
            // Add this `TaskBot` to the appropriate working array based on whether it is violent, "good" or not AND active
            if thisTaskbot.isProtestor && thisTaskbot.isActive && thisTaskbot.isDangerous
            {
                return (workingArrays.dangerousProtestorTaskBots + [thisTaskbot], workingArrays.protestorBots, workingArrays.policeBots)
            }
            else if thisTaskbot.isProtestor && thisTaskbot.isActive
            {
                return (workingArrays.dangerousProtestorTaskBots, workingArrays.protestorBots + [thisTaskbot], workingArrays.policeBots)
            }
            else
            {
                return (workingArrays.dangerousProtestorTaskBots, workingArrays.protestorBots, workingArrays.policeBots + [thisTaskbot])
            }

        }
        
        let policeBotPercentage = Float(policeTaskBots.count) / Float(dangerousProtestorTaskBots.count) + Float(protestorTaskBots.count + policeTaskBots.count)
        
        // Create and store an entity snapshot in the `entitySnapshots` dictionary for each entity.
        for entity in scene.entities
        {
            let entitySnapshot = EntitySnapshot(policeBotPercentage: policeBotPercentage, proximityFactor: scene.levelConfiguration.proximityFactor, entityDistances: entityDistances[entity]!)
            entitySnapshots[entity] = entitySnapshot
        }

    }
    
}

class EntitySnapshot
{
    // MARK: Properties
    
    /// Percentage of `TaskBot`s in the level that are bad.
    let policeBotPercentage: Float
    
    /// The factor used to normalize distances between characters for 'fuzzy' logic.
    let proximityFactor: Float
    
    /// Distance to the `PlayerBot` if it is targetable.
    let playerBotTarget: (target: PlayerBot, distance: Float)?
    
    /// The nearest "good" `TaskBot`.
    let nearestProtestorTaskBotTarget: (target: TaskBot, distance: Float)?
 
    /// The nearest "Violent Protestor" `TaskBot`.
    let nearestDangerousProtestorTaskBotTarget: (target: TaskBot, distance: Float)?
    
    /// A sorted array of distances from this entity to every other entity in the level.
    let entityDistances: [EntityDistance]
    
    // MARK: Initialization
    
    init(policeBotPercentage: Float, proximityFactor: Float, entityDistances: [EntityDistance])
    {
        self.policeBotPercentage = policeBotPercentage
        self.proximityFactor = proximityFactor

        // Sort the `entityDistances` array by distance (nearest first), and store the sorted version.
        self.entityDistances = entityDistances.sorted {
            return $0.distance < $1.distance
        }
        
        var playerBotTarget: (target: PlayerBot, distance: Float)?
        var nearestProtestorTaskBotTarget: (target: TaskBot, distance: Float)?
        var nearestDangerousProtestorTaskBotTarget: (target: TaskBot, distance: Float)?
        
        /*
            Iterate over the sorted `entityDistances` array to find the `PlayerBot`
            (if it is targetable) and the nearest "Protestor" `TaskBot`.
        */
        for entityDistance in self.entityDistances
        {
            if let target = entityDistance.target as? PlayerBot, playerBotTarget == nil && target.isTargetable
            {
                playerBotTarget = (target: target, distance: entityDistance.distance)
            }
            else if let target = entityDistance.target as? TaskBot, nearestDangerousProtestorTaskBotTarget == nil && target.isDangerous
            {
                nearestDangerousProtestorTaskBotTarget = (target: target, distance: entityDistance.distance)
            }
            else if let target = entityDistance.target as? TaskBot, nearestProtestorTaskBotTarget == nil && target.isProtestor
            {
                nearestProtestorTaskBotTarget = (target: target, distance: entityDistance.distance)
            }
            
            // Stop iterating over the array once we have found both the `PlayerBot` and the nearest good `TaskBot` and the nearest dangerous 'TaskBot'
            if playerBotTarget != nil && nearestProtestorTaskBotTarget != nil && nearestDangerousProtestorTaskBotTarget != nil
            {
                break
            }
        }
        
        self.playerBotTarget = playerBotTarget
        self.nearestProtestorTaskBotTarget = nearestProtestorTaskBotTarget
        self.nearestDangerousProtestorTaskBotTarget = nearestDangerousProtestorTaskBotTarget
    }
}

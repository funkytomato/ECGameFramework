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
        
        // Determine the number of "criminal", "scared", "dangerous, "protestor", "Police" and "Injured" `TaskBot`s in the scene.
        let (criminalTaskBots, sellerTaskBots, scaredTaskBots, dangerousTaskBots, protestorTaskBots, subservientTaskBots, policeTaskBots, policeInTroubleTaskBots, injuredTaskBots) = scene.entities.reduce(([],[],[],[],[],[],[],[],[]))
        {

            (workingArrays: (criminalTaskBots: [TaskBot],
                            sellerTaskBots: [TaskBot],
                             scaredTaskBots: [TaskBot],
                              dangerousTaskBots: [TaskBot],
                              protestorBots: [TaskBot],
                              subservientTaskBots: [TaskBot],
                              policeBots: [TaskBot],
                              policeInTroubleTaskBots: [TaskBot],
                              injuredBots: [TaskBot]), thisEntity: GKEntity) -> ([TaskBot], [TaskBot], [TaskBot], [TaskBot], [TaskBot], [TaskBot], [TaskBot], [TaskBot], [TaskBot]) in
            
            // Try to cast this entity as a `TaskBot`, and skip this entity if the cast fails.
            guard let thisTaskbot = thisEntity as? TaskBot else { return workingArrays }
                
            // Add this `TaskBot` to the appropriate working array based on whether it is dangerous, scared, protestor or Police AND active
            
            // The taskbot is active and scared
            if thisTaskbot.isActive && thisTaskbot.isScared
            {
                return (workingArrays.criminalTaskBots, workingArrays.sellerTaskBots, workingArrays.scaredTaskBots + [thisTaskbot], workingArrays.dangerousTaskBots, workingArrays.protestorBots, workingArrays.subservientTaskBots, workingArrays.policeBots, workingArrays.policeInTroubleTaskBots, workingArrays.injuredBots)
            }
            
            // The taskbot is active and dangerous
            else if thisTaskbot.isActive && thisTaskbot.isDangerous
            {
                return (workingArrays.criminalTaskBots, workingArrays.sellerTaskBots, workingArrays.scaredTaskBots, workingArrays.dangerousTaskBots + [thisTaskbot], workingArrays.protestorBots, workingArrays.subservientTaskBots,
                        workingArrays.policeBots, workingArrays.policeInTroubleTaskBots, workingArrays.injuredBots)
            }
            
            // The taskbot is active and subervient
            else if thisTaskbot.isActive && thisTaskbot.isSubservient
            {
                return (workingArrays.criminalTaskBots, workingArrays.sellerTaskBots, workingArrays.scaredTaskBots, workingArrays.dangerousTaskBots, workingArrays.protestorBots + [thisTaskbot],
                    workingArrays.subservientTaskBots + [thisTaskbot],
                        workingArrays.policeBots, workingArrays.policeInTroubleTaskBots, workingArrays.injuredBots)
            }
                
            // The taskbot is an active protestor
            else if thisTaskbot.isProtestor && thisTaskbot.isActive
            {
                return (workingArrays.criminalTaskBots, workingArrays.sellerTaskBots, workingArrays.scaredTaskBots, workingArrays.dangerousTaskBots, workingArrays.protestorBots + [thisTaskbot], workingArrays.subservientTaskBots, workingArrays.policeBots, workingArrays.policeInTroubleTaskBots, workingArrays.injuredBots)
            }
                
            // The taskbot has become incapacitated or injured
            else if thisTaskbot.isInjured && !thisTaskbot.isActive
            {
                return (workingArrays.criminalTaskBots, workingArrays.sellerTaskBots, workingArrays.scaredTaskBots, workingArrays.dangerousTaskBots, workingArrays.protestorBots, workingArrays.subservientTaskBots, workingArrays.policeBots, workingArrays.policeInTroubleTaskBots,
                        workingArrays.injuredBots + [thisTaskbot])
            }
                
            // The taskbot is a policeman
            else if thisTaskbot.isPolice // && isPolice
            {
                return (workingArrays.criminalTaskBots, workingArrays.sellerTaskBots, workingArrays.scaredTaskBots, workingArrays.dangerousTaskBots, workingArrays.protestorBots, workingArrays.subservientTaskBots, workingArrays.policeBots + [thisTaskbot], workingArrays.policeInTroubleTaskBots, workingArrays.injuredBots)
            }

            // The taskbot is a policeman and in trouble
            else if thisTaskbot.isPolice && thisTaskbot.needsHelp
            {
                return (workingArrays.criminalTaskBots, workingArrays.sellerTaskBots, workingArrays.scaredTaskBots, workingArrays.dangerousTaskBots, workingArrays.protestorBots, workingArrays.subservientTaskBots, workingArrays.policeBots + [thisTaskbot], workingArrays.policeInTroubleTaskBots + [thisTaskbot], workingArrays.injuredBots)
            }
             
            // The taskbot is a Criminal and seller
            else if thisTaskbot.isCriminal && thisTaskbot.isSelling // && isCriminal
            {
                return (workingArrays.criminalTaskBots + [thisTaskbot], workingArrays.sellerTaskBots + [thisTaskbot], workingArrays.scaredTaskBots, workingArrays.dangerousTaskBots, workingArrays.protestorBots, workingArrays.subservientTaskBots, workingArrays.policeBots, workingArrays.policeInTroubleTaskBots, workingArrays.injuredBots)
            }
                
            // The taskbot is a Criminal
            else if thisTaskbot.isCriminal // && isCriminal
            {
                return (workingArrays.criminalTaskBots  + [thisTaskbot], workingArrays.sellerTaskBots, workingArrays.scaredTaskBots, workingArrays.dangerousTaskBots, workingArrays.protestorBots, workingArrays.subservientTaskBots, workingArrays.policeBots, workingArrays.policeInTroubleTaskBots, workingArrays.injuredBots)
            }
                
            else
            {
                return (workingArrays.criminalTaskBots, workingArrays.sellerTaskBots, workingArrays.scaredTaskBots, workingArrays.dangerousTaskBots, workingArrays.protestorBots, workingArrays.subservientTaskBots, workingArrays.policeBots, workingArrays.policeInTroubleTaskBots, workingArrays.injuredBots)
            }

        }
        
        let totalTaskBotCount = Float(subservientTaskBots.count) + Float(protestorTaskBots.count) + Float(dangerousTaskBots.count) + Float(injuredTaskBots.count) + Float(policeTaskBots.count) + Float(criminalTaskBots.count) + Float(sellerTaskBots.count)
        
        let policeBotPercentage = Float(policeTaskBots.count) / totalTaskBotCount
//                                    Float(subservientTaskBots.count) + Float(protestorTaskBots.count) + Float(dangerousTaskBots.count) + Float(injuredTaskBots.count) + Float(policeTaskBots.count) + Float(criminalTaskBots.count)
        
        let protestorBotPercentage = Float(protestorTaskBots.count) / totalTaskBotCount
//                                    Float(subservientTaskBots.count) + Float(protestorTaskBots.count) + Float(dangerousTaskBots.count) + Float(injuredTaskBots.count) + Float(policeTaskBots.count) + Float(criminalTaskBots.count)
        
        let subservientBotPercentage = Float(subservientTaskBots.count) / totalTaskBotCount
//                                    Float(subservientTaskBots.count) + Float(protestorTaskBots.count) + Float(dangerousTaskBots.count) + Float(injuredTaskBots.count) + Float(policeTaskBots.count) + Float(criminalTaskBots.count)
        
        let criminalBotPercentage = Float(criminalTaskBots.count) / totalTaskBotCount
//                                      Float(subservientTaskBots.count) + Float(protestorTaskBots.count) + Float(dangerousTaskBots.count) + Float(injuredTaskBots.count) + Float(policeTaskBots.count) + Float(criminalTaskBots.count)
        
        let dangerousBotPercentage = Float(dangerousTaskBots.count) / totalTaskBotCount
//                                    Float(subservientTaskBots.count) + Float(protestorTaskBots.count) + Float(dangerousTaskBots.count) + Float(injuredTaskBots.count) + Float(policeTaskBots.count) + Float(criminalTaskBots.count)
        
        let injuredBotPercentage = Float(injuredTaskBots.count) / totalTaskBotCount
//                                    Float(subservientTaskBots.count) + Float(protestorTaskBots.count) + Float(dangerousTaskBots.count) + Float(injuredTaskBots.count) + Float(policeTaskBots.count) + Float(criminalTaskBots.count)
        

        print("policeBotPercentage:\(policeBotPercentage.description), protestorBotPercentage: \(protestorBotPercentage.description), criminalBotPercentage: \(criminalBotPercentage.description), dangerousBotPercentage: \(dangerousBotPercentage.description), injuredBotPercentage: \(injuredBotPercentage.description), policeTaskBots: \(policeTaskBots.count), policeInTroubleTaskBots: \(policeInTroubleTaskBots.count), protestorTaskBots: \(protestorTaskBots.count), dangerousTaskBots: \(dangerousTaskBots.count), scaredBots: \(scaredTaskBots.count), injuredTaskBots: \(injuredTaskBots.count), sellerTaskBots: \(sellerTaskBots.count)")
        
        
        
        
        // Create and store an entity snapshot in the `entitySnapshots` dictionary for each entity.
        for entity in scene.entities
        {
            let entitySnapshot = EntitySnapshot(policeBotPercentage: policeBotPercentage, protestorBotPercentage: protestorBotPercentage, subservientBotPercentage: subservientBotPercentage, criminalBotPercentage: criminalBotPercentage, dangerousBotPercentage: dangerousBotPercentage, injuredBotPercentage: injuredBotPercentage,  proximityFactor: scene.levelConfiguration.proximityFactor, entityDistances: entityDistances[entity]!)
            entitySnapshots[entity] = entitySnapshot
        }

    }
    
    deinit {
        //print("Deallocating LevelStateSnapShot")
    }
    
}

class EntitySnapshot
{
    // MARK: Properties
    
    /// Percentage of `TaskBot`s in the level that are bad.
    let policeBotPercentage: Float
    
    /// Percentage of `TaskBot`s in the level that are Dangerous.
    let dangerousBotPercentage: Float
    
    /// Percentage of `TaskBot`s in the level that are Protestor.
    let protestorBotPercentage: Float

    /// Percentage of `TaskBot`s in the level that are Subservient.
    let subservientBotPercentage: Float
    
    /// Percentage of `TaskBot`s in the level that are Criminal.
    let criminalBotPercentage: Float

    /// Percentage of `TaskBot`s in the level that are injured.
    let injuredBotPercentage: Float
    
    /// The factor used to normalize distances between characters for 'fuzzy' logic.
    let proximityFactor: Float
    
    /// Distance to the `PlayerBot` if it is targetable.
    let playerBotTarget: (target: PlayerBot, distance: Float)?
    
    /// The nearest "Police" `TaskBot`.
    let nearestPoliceTaskBotTarget: (target: TaskBot, distance: Float)?
    
    /// The nearest "Police" `TaskBot`.
    let nearestPoliceTaskBotInTroubleTarget: (target: TaskBot, distance: Float)?
    
    /// The nearest "good" `TaskBot`.
    let nearestProtestorTaskBotTarget: (target: TaskBot, distance: Float)?
 
    /// The nearest "Subservient" `TaskBot`.
    let nearestSubservientTaskBotTarget: (target: TaskBot, distance: Float)?
    
    /// The nearest "Violent Protestor" `TaskBot`.
    let nearestDangerousTaskBotTarget: (target: TaskBot, distance: Float)?
    
    /// The nearest "Scared" `TaskBot`.
    let nearestScaredTaskBotTarget: (target: TaskBot, distance: Float)?
    
    /// The nearest "Criminal" `TaskBot`.
    let nearestCriminalTaskBotTarget: (target: TaskBot, distance: Float)?
    
    /// The nearest "Seller" `TaskBot`.
    let nearestSellerTaskBotTarget: (target: TaskBot, distance: Float)?
    
    /// The nearest "Injured" `TaskBot`.
    let nearestInjuredTaskBotTarget: (target: TaskBot, distance: Float)?
    
    
    /// A sorted array of distances from this entity to every other entity in the level.
    let entityDistances: [EntityDistance]
    
    // MARK: Initialization
    init(policeBotPercentage: Float, protestorBotPercentage: Float, subservientBotPercentage: Float, criminalBotPercentage: Float, dangerousBotPercentage: Float, injuredBotPercentage: Float,
         proximityFactor: Float, entityDistances: [EntityDistance])
    {
        self.policeBotPercentage = policeBotPercentage
        self.protestorBotPercentage = protestorBotPercentage
        self.subservientBotPercentage = subservientBotPercentage
        self.criminalBotPercentage = criminalBotPercentage
        self.dangerousBotPercentage = dangerousBotPercentage
        self.injuredBotPercentage = injuredBotPercentage
        self.proximityFactor = proximityFactor

        // Sort the `entityDistances` array by distance (nearest first), and store the sorted version.
        self.entityDistances = entityDistances.sorted {
            return $0.distance < $1.distance
        }
        
        var playerBotTarget: (target: PlayerBot, distance: Float)?
        var nearestPoliceTaskBotTarget: (target: TaskBot, distance: Float)?
        var nearestPoliceTaskBotInTroubleTarget: (target: TaskBot, distance: Float)?
        var nearestProtestorTaskBotTarget: (target: TaskBot, distance: Float)?
        var nearestSubservientTaskBotTarget: (target: TaskBot, distance: Float)?
        var nearestDangerousTaskBotTarget: (target: TaskBot, distance: Float)?
        var nearestScaredTaskBotTarget: (target: TaskBot, distance: Float)?
        var nearestCriminalTaskBotTarget: (target: TaskBot, distance: Float)?
        var nearestSellerTaskBotTarget: (target: TaskBot, distance: Float)?
        var nearestInjuredTaskBotTarget: (target: TaskBot, distance: Float)?
        
        
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
            else if let target = entityDistance.target as? TaskBot, nearestDangerousTaskBotTarget == nil && target.isDangerous && target.isActive
            {
                nearestDangerousTaskBotTarget = (target: target, distance: entityDistance.distance)
            }
            else if let target = entityDistance.target as? TaskBot, nearestProtestorTaskBotTarget == nil && target.isProtestor && target.isActive
            {
                nearestProtestorTaskBotTarget = (target: target, distance: entityDistance.distance)
            }
            else if let target = entityDistance.target as? TaskBot, nearestSubservientTaskBotTarget == nil && target.isProtestor && target.isActive && target.isSubservient
            {
                nearestSubservientTaskBotTarget = (target: target, distance: entityDistance.distance)
            }
            else if let target = entityDistance.target as? TaskBot, nearestScaredTaskBotTarget == nil && target.isProtestor && target.isScared && target.isActive
            {
                nearestScaredTaskBotTarget = (target: target, distance: entityDistance.distance)
            }
            else if let target = entityDistance.target as? TaskBot, nearestPoliceTaskBotTarget == nil && target.isPolice && target.isActive
            {
                nearestPoliceTaskBotTarget = (target: target, distance: entityDistance.distance)
            }
            else if let target = entityDistance.target as? TaskBot, nearestPoliceTaskBotInTroubleTarget == nil && target.isPolice && target.isActive && target.needsHelp
            {
                nearestPoliceTaskBotInTroubleTarget = (target: target, distance: entityDistance.distance)
            }
            else if let target = entityDistance.target as? TaskBot, nearestCriminalTaskBotTarget == nil && target.isCriminal && target.isActive // && isCriminal (isBad gets confused with PoliceBot
            {
                nearestCriminalTaskBotTarget = (target: target, distance: entityDistance.distance)
            }
            else if let target = entityDistance.target as? TaskBot, nearestSellerTaskBotTarget == nil && target.isCriminal && target.isActive && target.isSelling // && isCriminal (isBad gets confused with PoliceBot
            {
                nearestSellerTaskBotTarget = (target: target, distance: entityDistance.distance)
            }
            else if let target = entityDistance.target as? TaskBot, nearestInjuredTaskBotTarget == nil && target.isInjured && !target.isActive // && isCriminal (isBad gets confused with PoliceBot
            {
                nearestInjuredTaskBotTarget = (target: target, distance: entityDistance.distance)
            }
            
            // Stop iterating over the array once we have found both the `PlayerBot` and the nearest good `TaskBot` and the nearest dangerous 'TaskBot'
            if playerBotTarget != nil && nearestProtestorTaskBotTarget != nil && nearestSubservientTaskBotTarget != nil && nearestDangerousTaskBotTarget != nil && nearestScaredTaskBotTarget != nil && nearestPoliceTaskBotTarget != nil && nearestPoliceTaskBotInTroubleTarget != nil && nearestCriminalTaskBotTarget != nil && nearestSellerTaskBotTarget != nil && nearestInjuredTaskBotTarget != nil
            {
                break
            }
        }
        
        self.playerBotTarget = playerBotTarget
        self.nearestPoliceTaskBotTarget = nearestPoliceTaskBotTarget
        self.nearestPoliceTaskBotInTroubleTarget = nearestPoliceTaskBotInTroubleTarget
        self.nearestProtestorTaskBotTarget = nearestProtestorTaskBotTarget
        self.nearestSubservientTaskBotTarget = nearestSubservientTaskBotTarget
        self.nearestDangerousTaskBotTarget = nearestDangerousTaskBotTarget
        self.nearestScaredTaskBotTarget = nearestScaredTaskBotTarget
        self.nearestCriminalTaskBotTarget = nearestCriminalTaskBotTarget
        self.nearestSellerTaskBotTarget = nearestSellerTaskBotTarget
        self.nearestInjuredTaskBotTarget = nearestInjuredTaskBotTarget
    }
}

/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    `TaskBotBehavior` is a `GKBehavior` subclass that provides convenience class methods to construct the appropriate goals and behaviors for different `TaskBot` mandates.
*/

import SpriteKit
import GameplayKit

/// Provides factory methods to create `TaskBot`-specific goals and behaviors.
class TaskBotBehavior: GKBehavior
{
    
    // MARK: Behavior factory methods
    
    // MARK:- Arrested Behaviour
    // Arrested behaviour, return the arrested protestor to the meatwagon in the custody of the arresting policeman
    static func arrestedBehaviour(forAgent agent: GKAgent2D, huntingAgent target: GKAgent2D, pathRadius: Float, inScene scene: LevelScene) -> (behaviour: GKBehavior, pathPoints: [CGPoint])
    {
        //print("behaviorAndPathPoints \(agent.description) hunting: \(target.description) scene: \(scene.description)")
        
        let behavior = TaskBotBehavior()
        
        // Add basic goals to reach the `TaskBot`'s maximum speed and avoid obstacles.
        behavior.addTargetSpeedGoal(speed: agent.maxSpeed)
        behavior.addAvoidObstaclesGoal(forScene: scene)
        
        
        // Add goals to follow a calculated path from the `TaskBot` to its target.
        let pathPoints = behavior.addGoalsToFollowPath(from: agent.position, to: scene.meatWagonLocation(), pathRadius: pathRadius, inScene: scene)
        
        
        // Return a tuple containing the new behavior, and the found path points for debug drawing.
        return (behavior, pathPoints)
    }
    
    
    //MARK: Sheep Behaviour
    // Sheep behaviour
    static func sheepBehaviour(forAgent agent: GKAgent2D, targetAgent: GKAgent2D, pathRadius: Float, inScene scene: LevelScene) -> (GKBehavior)
    {
        //print("behaviorAndPathPoints \(agent.description),  scene: \(scene.description)")
        
        let behavior = TaskBotBehavior()
        
        // Add basic goals to reach the `TaskBot`'s maximum speed and avoid obstacles.
//        behavior.addTargetSpeedGoal(speed: agent.maxSpeed)
        behavior.addSeekGoal(forScene: scene, agent: targetAgent, weight: 0.1)
        behavior.addAvoidObstaclesGoal(forScene: scene)
        behavior.addWanderGoal(forScene: scene)
        
        
        // Find nearby Subservient Protestors and group together
        let agentsToFlockWith: [GKAgent2D] = scene.entities.compactMap { entity in
            if let taskBot = entity as? ProtestorBot,
                taskBot.agent !== agent && taskBot.distanceToAgent(otherAgent: agent) <= GameplayConfiguration.Flocking.agentSearchDistanceForFlocking
            {

                //Crowd all subservient Protestors but not if Ringleader
//                if taskBot.isSubservient && !taskBot.isRingLeader
                if taskBot.isSheep
                {
                    return taskBot.agent
                }
            }
            
            return nil
        }
        
        if !agentsToFlockWith.isEmpty
        {
            //            print("crowdBehaviour - agents are flocking \(agentsToFlockWith.debugDescription)")
            
            
            // Add flocking goals for any nearby "bad" `TaskBot`s.
//            let separationGoal = GKGoal(toSeparateFrom: agentsToFlockWith, maxDistance: GameplayConfiguration.Flocking.separationRadius, maxAngle: GameplayConfiguration.Flocking.separationAngle)
//            behavior.setWeight(GameplayConfiguration.Flocking.separationWeight, for: separationGoal)
            let separationGoal = GKGoal(toSeparateFrom: agentsToFlockWith, maxDistance: 300.0, maxAngle: GameplayConfiguration.Flocking.separationAngle)
            behavior.setWeight(8.0, for: separationGoal)
            
//            let alignmentGoal = GKGoal(toAlignWith: agentsToFlockWith, maxDistance: GameplayConfiguration.Flocking.alignmentRadius, maxAngle: GameplayConfiguration.Flocking.alignmentAngle)
            let alignmentGoal = GKGoal(toAlignWith: agentsToFlockWith, maxDistance: 300.0, maxAngle: GameplayConfiguration.Flocking.alignmentAngle)
            behavior.setWeight(GameplayConfiguration.Flocking.alignmentWeight, for: alignmentGoal)
            
//            let cohesionGoal = GKGoal(toCohereWith: agentsToFlockWith, maxDistance: GameplayConfiguration.Flocking.cohesionRadius, maxAngle: GameplayConfiguration.Flocking.cohesionAngle)
//            behavior.setWeight(GameplayConfiguration.Flocking.cohesionWeight, for: cohesionGoal)
            let cohesionGoal = GKGoal(toCohereWith: agentsToFlockWith, maxDistance: 300.0, maxAngle: GameplayConfiguration.Flocking.cohesionAngle)
            behavior.setWeight(10.0, for: cohesionGoal)
        }
        
        // Return a tuple containing the new behavior, and the found path points for debug drawing.
        return (behavior)
    }
    
    
    // Crowd behaviour
    static func crowdBehaviour(forAgent agent: GKAgent2D, pathRadius: Float, temperament: String, inScene scene: LevelScene) -> (GKBehavior)
    {
        //print("behaviorAndPathPoints \(agent.description) hunting: \(target.description) scene: \(scene.description)")
        
        let behavior = TaskBotBehavior()
        
        // Add basic goals to reach the `TaskBot`'s maximum speed and avoid obstacles.
        behavior.addTargetSpeedGoal(speed: 30.0)
        behavior.addSeekGoal(forScene: scene, agent: agent, weight: 0.1)
        behavior.addAvoidObstaclesGoal(forScene: scene)
        behavior.addWanderGoal(forScene: scene)
        
        
        //Get a pointer to this Taskbot's Temperament Component
        let myTemperamentComponent = agent.entity?.component(ofType: TemperamentComponent.self)
        
        
        // Find any nearby "protestor" TaskBots to flock with.
        let agentsToFlockWith: [GKAgent2D] = scene.entities.compactMap { entity in
            if let taskBot = entity as? ProtestorBot,
                /*taskBot.isConsuming &&*/ taskBot.agent !== agent && taskBot.distanceToAgent(otherAgent: agent) <= GameplayConfiguration.Flocking.agentSearchDistanceForFlocking
            {
                
                //Get the Protestor's current temperament state
                let entityTemperamentComponent = taskBot.component(ofType: TemperamentComponent.self)
                let myCurrentTemperament = myTemperamentComponent?.stateMachine.currentState
                
//                print("myCurrentTemperament \(myCurrentTemperament.debugDescription), entityTemperamentComponent \(entityTemperamentComponent.debugDescription) ")
                
                //If the TaskBot's temperament match, return agent to flock with
                switch myCurrentTemperament
                {
                    case is ScaredState:
                        guard (entityTemperamentComponent?.stateMachine.currentState is ScaredState) else { return nil }
                        return taskBot.agent
                    case is FearfulState:
                        guard (entityTemperamentComponent?.stateMachine.currentState is FearfulState) else { return nil }
                        return taskBot.agent
                    case is CalmState:
                        guard (entityTemperamentComponent?.stateMachine.currentState is CalmState) else { return nil }
                        return taskBot.agent
                    case is AggitatedState:
                        guard (entityTemperamentComponent?.stateMachine.currentState is AggitatedState) else { return nil }
                        return taskBot.agent
                    case is AngryState:
                        guard (entityTemperamentComponent?.stateMachine.currentState is AngryState) else { return nil }
                        return taskBot.agent
                    case is ViolentState:
                        guard (entityTemperamentComponent?.stateMachine.currentState is ViolentState) else { return nil }
                        return taskBot.agent
                    case is RageState:
                        guard (entityTemperamentComponent?.stateMachine.currentState is RageState) else { return nil }
                        return taskBot.agent
                    default:
                        break
                }
                
            }
            
            return nil
        }
        
        if !agentsToFlockWith.isEmpty
        {
//            print("crowdBehaviour - agents are flocking \(agentsToFlockWith.debugDescription)")
            
            
            // Add flocking goals for any nearby "bad" `TaskBot`s.
            let separationGoal = GKGoal(toSeparateFrom: agentsToFlockWith, maxDistance: GameplayConfiguration.Flocking.separationRadius, maxAngle: GameplayConfiguration.Flocking.separationAngle)
            behavior.setWeight(GameplayConfiguration.Flocking.separationWeight, for: separationGoal)
            
            let alignmentGoal = GKGoal(toAlignWith: agentsToFlockWith, maxDistance: GameplayConfiguration.Flocking.alignmentRadius, maxAngle: GameplayConfiguration.Flocking.alignmentAngle)
            behavior.setWeight(GameplayConfiguration.Flocking.alignmentWeight, for: alignmentGoal)
            
            let cohesionGoal = GKGoal(toCohereWith: agentsToFlockWith, maxDistance: GameplayConfiguration.Flocking.cohesionRadius, maxAngle: GameplayConfiguration.Flocking.cohesionAngle)
            behavior.setWeight(GameplayConfiguration.Flocking.cohesionWeight, for: cohesionGoal)
        }
        
        // Return a tuple containing the new behavior, and the found path points for debug drawing.
        return (behavior)
    }
    
    
    // Police Support behaviour
    static func supportBehaviour(forAgent agent: GKAgent2D, huntingAgent target: GKAgent2D, pathRadius: Float, inScene scene: LevelScene) -> (behaviour: GKBehavior, pathPoints: [CGPoint])
    {
//        print("supportBehaviour \(agent.description) hunting: \(target.description) scene: \(scene.description)")
        
        let behavior = TaskBotBehavior()
        
        // Add basic goals to reach the `TaskBot`'s maximum speed and avoid obstacles.
        behavior.addTargetSpeedGoal(speed: agent.maxSpeed)
        behavior.addAvoidObstaclesGoal(forScene: scene)
        
        // Find any nearby "police" TaskBots to flock with.
        let agentsToFlockWith: [GKAgent2D] = scene.entities.compactMap { entity in
            if let taskBot = entity as? PoliceBot, taskBot.needsHelp && taskBot.agent !== agent && taskBot.distanceToAgent(otherAgent: agent) <= GameplayConfiguration.Flocking.agentSupportSearchDistanceForArrest
            {
                return taskBot.agent
            }
            
            return nil
        }
        
        if !agentsToFlockWith.isEmpty
        {
            //print("arrestedBehaviour - agents are flocking \(agentsToFlockWith.description)")
            
            
            // Add flocking goals for any nearby "bad" `TaskBot`s.
            let separationGoal = GKGoal(toSeparateFrom: agentsToFlockWith, maxDistance: GameplayConfiguration.PoliceBot.supportSeparationRadius, maxAngle: GameplayConfiguration.PoliceBot.supportSeparationAngle)
            behavior.setWeight(GameplayConfiguration.PoliceBot.supportSeparationWeight, for: separationGoal)
            
            let alignmentGoal = GKGoal(toAlignWith: agentsToFlockWith, maxDistance: GameplayConfiguration.PoliceBot.supportAlignmentRadius, maxAngle: GameplayConfiguration.PoliceBot.supportAlignmentAngle)
            behavior.setWeight(GameplayConfiguration.PoliceBot.supportAlignmentWeight, for: alignmentGoal)
            
            let cohesionGoal = GKGoal(toCohereWith: agentsToFlockWith, maxDistance: GameplayConfiguration.PoliceBot.supportCohesionRadius, maxAngle: GameplayConfiguration.PoliceBot.supportCohesionAngle)
            behavior.setWeight(GameplayConfiguration.PoliceBot.supportCohesionWeight, for: cohesionGoal)
        }
        
        // Add goals to follow a calculated path from the `TaskBot` to its target.
        let pathPoints = behavior.addGoalsToFollowPath(from: agent.position, to: target.position, pathRadius: pathRadius, inScene: scene)
        
        
        //print("targetPosition: \(target.position)")
        
        // Return a tuple containing the new behavior, and the found path points for debug drawing.
        return (behavior, pathPoints)
    }
    
    // PoliceBot initates building a wall and moves the Police leader to the createWallLocation
    static func initiateWallBehaviour(forAgent agent: GKAgent2D, startLocation: float2, pathRadius: Float, inScene scene: LevelScene) -> (behaviour: GKBehavior, pathPoints: [CGPoint])
    {
//        print("initiateWallBehaviour \(agent.description) scene: \(scene.description)")
        
        let behavior = TaskBotBehavior()
        
        // Add basic goals to reach the `TaskBot`'s maximum speed, avoid obstacles and seek the target Police.
        behavior.addTargetSpeedGoal(speed: 25.0)
        behavior.addAvoidObstaclesGoal(forScene: scene)
        
        
        // Add goals to follow a calculated path from the `TaskBot` to its target.
        let pathPoints = behavior.addGoalsToFollowPath(from: agent.position, to: startLocation, pathRadius: pathRadius, inScene: scene)
        
        // Return a tuple containing the new behavior, and the found path points for debug drawing.
        return (behavior, pathPoints)
    }
  
    // Police will come to support target officer and create a wall
    static func formWallBehaviour(forAgent agent: GKAgent2D, huntingAgent target: GKAgent2D, pathRadius: Float, inScene scene: LevelScene) -> (behaviour: GKBehavior, pathPoints: [CGPoint])
    {
//        print("formWallBehaviour \(agent.description) hunting: \(target.description) scene: \(scene.description)")
        
        let behavior = TaskBotBehavior()
        
        // Add basic goals to reach the `TaskBot`'s maximum speed, avoid obstacles and seek the target Police.
        behavior.addTargetSpeedGoal(speed: agent.maxSpeed)
        behavior.addAvoidObstaclesGoal(forScene: scene)
        behavior.addSeekGoal(forScene: scene, agent: target, weight: 1.0)
      
        
        // Find any nearby "police" creating wall TaskBots to flock with.
        let agentsToFlockWith: [GKAgent2D] = scene.entities.compactMap { entity in
            if let taskBot = entity as? PoliceBot, taskBot.isSupporting && taskBot.agent !== agent && taskBot.distanceToAgent(otherAgent: agent) <= GameplayConfiguration.PoliceBot.agentSearchDistanceForWall
            {
                return taskBot.agent
            }
            
            return nil
        }
        
        if !agentsToFlockWith.isEmpty
        {
            let cohesionGoal = GKGoal(toCohereWith: agentsToFlockWith, maxDistance: GameplayConfiguration.PoliceBot.wallCohesionRadius, maxAngle: GameplayConfiguration.PoliceBot.wallCohesionAngle)
            behavior.setWeight(GameplayConfiguration.Flocking.cohesionWeight, for: cohesionGoal)
        }
        
        
        // Add goals to follow a calculated path from the `TaskBot` to its target.
        let pathPoints = behavior.addGoalsToFollowPath(from: agent.position, to: target.position, pathRadius: pathRadius, inScene: scene)
        
        
        // Return a tuple containing the new behavior, and the found path points for debug drawing.
        return (behavior, pathPoints)
    }
    
    
    // Police Support Hold the Line Behaviour
    // Police will come to support target officer and create a wall
//    static func inWallBehaviour(forAgent agent: GKAgent2D, huntingAgent target: GKAgent2D, pathRadius: Float, inScene scene: LevelScene) -> (behaviour: GKBehavior, pathPoints: [CGPoint])
    static func inWallBehaviour(forAgent agent: GKAgent2D, huntingAgent target: float2, pathRadius: Float, inScene scene: LevelScene) -> (behaviour: GKBehavior, pathPoints: [CGPoint])
    {
        
        let policeBot = agent.entity as? PoliceBot
        
//        print("TaskBotBehaviour inWallbehaviour:- entity: \(policeBot.debugDescription), Current behaviour mandate: \(policeBot?.mandate), isWall: \(policeBot?.isWall), requestWall: \(policeBot?.requestWall), isSupporting: \(policeBot?.isSupporting), wallComponentisTriggered: \(String(describing: policeBot?.component(ofType: WallComponent.self)?.isTriggered))")

        
        
        let behavior = TaskBotBehavior()
        
        // Add basic goals to reach the `TaskBot`'s maximum speed, avoid obstacles and seek the target Police.
        behavior.addTargetSpeedGoal(speed: 100.0)
        behavior.addAvoidObstaclesGoal(forScene: scene)

        
        // Find any nearby "police" in wall TaskBots to flock with.
        let agentsToFlockWith: [GKAgent2D] = scene.entities.compactMap { entity in
            if let taskBot = entity as? PoliceBot, taskBot.isWall && taskBot.agent !== agent && taskBot.distanceToAgent(otherAgent: agent) <= GameplayConfiguration.PoliceBot.agentSearchDistanceForWall
            {
                return taskBot.agent
            }
            
            return nil
        }
        
        if !agentsToFlockWith.isEmpty
        {
            //print("arrestedBehaviour - agents are flocking \(agentsToFlockWith.description)")
            
            //Make the Taskbots align with each other (resemble a wall)
            let alignmentGoal = GKGoal(toAlignWith: agentsToFlockWith, maxDistance: GameplayConfiguration.PoliceBot.wallAlignmentRadius, maxAngle: GameplayConfiguration.PoliceBot.wallAlignmentAngle)
            behavior.setWeight(GameplayConfiguration.PoliceBot.wallAlignmentWeight, for: alignmentGoal)
            
        }

        
        // Add goals to follow a calculated path from the `TaskBot` to its target.
        let pathPoints = behavior.addGoalsToFollowPath(from: agent.position, to: target, pathRadius: 1000.0, inScene: scene)

        
        // Return a tuple containing the new behavior, and the found path points for debug drawing.
        return (behavior, pathPoints)
    }
    
    
    /// Constructs a behavior to hunt a `TaskBot` or `PlayerBot` via a computed path.
    static func huntBehaviour(forAgent agent: GKAgent2D, huntingAgent target: GKAgent2D, pathRadius: Float, inScene scene: LevelScene) -> (behavior: GKBehavior, pathPoints: [CGPoint])
    {
        //print("behaviorAndPathPoints \(agent.description) hunting: \(target.description) scene: \(scene.description)")
        
        let behavior = TaskBotBehavior()
        
        // Add basic goals to reach the `TaskBot`'s maximum speed and avoid obstacles.
        behavior.addTargetSpeedGoal(speed: agent.maxSpeed)
        behavior.addAvoidObstaclesGoal(forScene: scene)

//        // Find any nearby "bad" TaskBots to flock with.
//        let agentsToFlockWith: [GKAgent2D] = scene.entities.compactMap { entity in
//            if let taskBot = entity as? TaskBot, !taskBot.isGood && taskBot.agent !== agent && taskBot.distanceToAgent(otherAgent: agent) <= GameplayConfiguration.Flocking.agentSearchDistanceForFlocking
//            {
//                return taskBot.agent
//            }
//
//            return nil
//        }
//
//        if !agentsToFlockWith.isEmpty
//        {
//            //print("behaviorAndPathPoints - agents are flocking \(agentsToFlockWith.description)")
//
//
//            // Add flocking goals for any nearby "bad" `TaskBot`s.
//            let separationGoal = GKGoal(toSeparateFrom: agentsToFlockWith, maxDistance: GameplayConfiguration.Flocking.separationRadius, maxAngle: GameplayConfiguration.Flocking.separationAngle)
//            behavior.setWeight(GameplayConfiguration.Flocking.separationWeight, for: separationGoal)
//
//            let alignmentGoal = GKGoal(toAlignWith: agentsToFlockWith, maxDistance: GameplayConfiguration.Flocking.alignmentRadius, maxAngle: GameplayConfiguration.Flocking.alignmentAngle)
//            behavior.setWeight(GameplayConfiguration.Flocking.alignmentWeight, for: alignmentGoal)
//
//            let cohesionGoal = GKGoal(toCohereWith: agentsToFlockWith, maxDistance: GameplayConfiguration.Flocking.cohesionRadius, maxAngle: GameplayConfiguration.Flocking.cohesionAngle)
//            behavior.setWeight(GameplayConfiguration.Flocking.cohesionWeight, for: cohesionGoal)
//        }

        // Add goals to follow a calculated path from the `TaskBot` to its target.
        let pathPoints = behavior.addGoalsToFollowPath(from: agent.position, to: target.position, pathRadius: pathRadius, inScene: scene)
        
        
        //print("targetPosition: \(target.position)")
        
        // Return a tuple containing the new behavior, and the found path points for debug drawing.
        return (behavior, pathPoints)
    }
    
    /// Constructs a behavior to return to the start of a `TaskBot` patrol path.
    static func returnToPathBehaviour(forAgent agent: GKAgent2D, returningToPoint endPoint: float2, pathRadius: Float, inScene scene: LevelScene) -> (behavior: GKBehavior, pathPoints: [CGPoint])
    {
        //print("behaviorAndPathPoints agent:\(agent.description) returning to: \(endPoint)  scene: \(scene.description)")
        
        let behavior = TaskBotBehavior()
        
        // Add basic goals to reach the `TaskBot`'s maximum speed and avoid obstacles.
        behavior.addTargetSpeedGoal(speed: agent.maxSpeed)
        behavior.addAvoidObstaclesGoal(forScene: scene)
        
        // Add goals to follow a calculated path from the `TaskBot` to the start of its patrol path.
        let pathPoints = behavior.addGoalsToFollowPath(from: agent.position, to: endPoint, pathRadius: pathRadius, inScene: scene)
        
        // Return a tuple containing the new behavior, and the found path points for debug drawing.
        return (behavior, pathPoints)
    }
    
    /// Constructs a behavior to patrol a path of points, avoiding obstacles along the way.
    static func patrolBehaviour(forAgent agent: GKAgent2D, patrollingPathWithPoints patrolPathPoints: [CGPoint], pathRadius: Float, inScene scene: LevelScene, cyclical: Bool) -> GKBehavior
    {
        //print("behavior agent:\(agent.description) patrolling: \(patrolPathPoints.description)  scene: \(scene.description)")
        
        let behavior = TaskBotBehavior()
        
        // Add basic goals to reach the `TaskBot`'s maximum speed and avoid obstacles.
        behavior.addTargetSpeedGoal(speed: agent.maxSpeed)
        behavior.addAvoidObstaclesGoal(forScene: scene)
        
        // Convert the patrol path to an array of `float2`s.
        let pathVectorPoints = patrolPathPoints.map { float2($0) }
        
        // Create a cyclical (closed) `GKPath` from the provided path points with the requested path radius.
        let path = GKPath(points: pathVectorPoints, radius: pathRadius, cyclical: cyclical)

        // Add "follow path" and "stay on path" goals for this path.
        behavior.addFollowAndStayOnPathGoals(for: path)

        return behavior
    }
    
    
    //Construct a behaviour to wander, avoiding obstacles along the way
    static func wanderBehaviour(forAgent agent: GKAgent2D, inScene scene: LevelScene) -> (behavior: GKBehavior, pathPoints: [CGPoint])
    {
        //print("behaviorAndWander agent:\(agent.description)  scene: \(scene.description)")
        
        let behavior = TaskBotBehavior()
        
        
        //Add basic goals to reach the TaskBot's maximum speed, avoid obstacles and wander
        behavior.addTargetSpeedGoal(speed: agent.maxSpeed)
        behavior.addSeekGoal(forScene: scene, agent: agent, weight: 0.8)
        behavior.addWanderGoal(forScene: scene)
        behavior.addAvoidObstaclesGoal(forScene: scene)
        
        
        let pathPoints = behavior.addPointsToWander(from: agent.position, pathRadius: GameplayConfiguration.TaskBot.wanderPathRadius, inScene: scene)
        
        
        // Return a tuple containing the new behavior, and the found path points for debug drawing.
        return (behavior, pathPoints)
    }
    

    //Construct a behaviour to flee from an agent, avoiding obstacles along the way
    static func fleeBehaviour(forAgent agent: GKAgent2D, fromAgent fearSource: GKAgent2D, inScene scene: LevelScene) -> (behavior: GKBehavior, pathPoints: [CGPoint])
    {
        //print("behaviorFlee agent:\(agent.description)  scene: \(scene.description)")
        
        let behavior = TaskBotBehavior()
        
        
        //Add basic goals to reach the TaskBot's maximum speed, avoid obstacles and wander
        behavior.addTargetSpeedGoal(speed: agent.maxSpeed + 500.0)
        behavior.addAvoidObstaclesGoal(forScene: scene)
        behavior.addFleeGoal(forScene: scene, forAgent: fearSource)
        
        let pathPoints = behavior.addPointsToWander(from: agent.position, pathRadius: GameplayConfiguration.TaskBot.fleePathRadius, inScene: scene)
        
        
        // Return a tuple containing the new behavior, and the found path points for debug drawing.
        return (behavior, pathPoints)
    }
    
    
    // Constructs a behaviour to move the agent along a path
    static func moveBehaviour(forAgent agent: GKAgent2D, pathPoints: [CGPoint], pathRadius: Float, inScene scene: LevelScene) -> (behavior: GKBehavior, pathPoints: [CGPoint])
    {
        //print("moveBehaviour \(agent.description), pathPoints: \(pathPoints)")
        
        let behavior = TaskBotBehavior()


        // Convert the patrol path to an array of `float2`s.
        let pathVectorPoints = pathPoints.map { float2($0) }
        
        // Create a cyclical (closed) `GKPath` from the provided path points with the requested path radius.
        let path = GKPath(points: pathVectorPoints, radius: pathRadius, cyclical: false)
        
        
        // Add basic goals to reach the TaskBot's maximum speed, avoid obstacles, etc...
        // Add "follow path" and "stay on path" goals for this path.
        behavior.addTargetSpeedGoal(speed: agent.maxSpeed)
        behavior.addAvoidObstaclesGoal(forScene: scene)
        behavior.addFollowAndStayOnPathGoals(for: path)


        // Return a tuple containing the new behavior, and the found path points for debug drawing.
        return (behavior, pathPoints)
    }
    
    
    /// Constructs a behavior to retaliate a `TaskBot` attack
    static func retaliateBehaviour(forAgent agent: GKAgent2D, huntingAgent target: GKAgent2D, pathRadius: Float, inScene scene: LevelScene) -> (behavior: GKBehavior, pathPoints: [CGPoint])
    {
        //print("retaliateBehaviour \(agent.description) target: \(target.description) scene: \(scene.description)")
        
        let behavior = TaskBotBehavior()
        
        // Add basic goals to reach the `TaskBot`'s maximum speed and avoid obstacles.
        behavior.addTargetSpeedGoal(speed: agent.maxSpeed)
        behavior.addAvoidObstaclesGoal(forScene: scene)
        
        // Find any nearby "dangerous" protestor TaskBots to flock with.
        let agentsToFlockWith: [GKAgent2D] = scene.entities.compactMap { entity in
            if let taskBot = entity as? TaskBot, taskBot.isGood && taskBot.isDangerous && taskBot.agent !== agent && taskBot.distanceToAgent(otherAgent: agent) <= GameplayConfiguration.Flocking.agentSearchDistanceForFlocking
            {
                return taskBot.agent
            }
            
            return nil
        }
        
        if !agentsToFlockWith.isEmpty
        {
            //print("behaviorAndPathPoints - agents are flocking \(agentsToFlockWith.description)")
            
            
            // Add flocking goals for any nearby "bad" `TaskBot`s.
            let separationGoal = GKGoal(toSeparateFrom: agentsToFlockWith, maxDistance: GameplayConfiguration.Flocking.separationRadius, maxAngle: GameplayConfiguration.Flocking.separationAngle)
            behavior.setWeight(GameplayConfiguration.Flocking.separationWeight, for: separationGoal)
            
            let alignmentGoal = GKGoal(toAlignWith: agentsToFlockWith, maxDistance: GameplayConfiguration.Flocking.alignmentRadius, maxAngle: GameplayConfiguration.Flocking.alignmentAngle)
            behavior.setWeight(GameplayConfiguration.Flocking.alignmentWeight, for: alignmentGoal)
            
            let cohesionGoal = GKGoal(toCohereWith: agentsToFlockWith, maxDistance: GameplayConfiguration.Flocking.cohesionRadius, maxAngle: GameplayConfiguration.Flocking.cohesionAngle)
            behavior.setWeight(GameplayConfiguration.Flocking.cohesionWeight, for: cohesionGoal)
        }
        
        // Add goals to follow a calculated path from the `TaskBot` to its target.
        let pathPoints = behavior.addGoalsToFollowPath(from: agent.position, to: target.position, pathRadius: pathRadius, inScene: scene)
        
        
        //print("targetPosition: \(target.position)")
        
        // Return a tuple containing the new behavior, and the found path points for debug drawing.
        return (behavior, pathPoints)
    }
    
    
    // MARK: Pathfinding Methods
    
    /**
        Calculates all of the extruded obstacles that the provided point resides near.
        The extrusion is based on the buffer radius of the pathfinding graph.
    */
    private func extrudedObstaclesContaining(point: float2, inScene scene: LevelScene) -> [GKPolygonObstacle]
    {
        //print("extrudedObstaclesContaining point:\(point) scene: \(scene.description)")
        
        /*
            Add a small fudge factor (+5) to the extrusion radius to make sure 
            we're including all obstacles.
        */
        let extrusionRadius = Float(GameplayConfiguration.TaskBot.pathfindingGraphBufferRadius) + 5

        /*
            Return only the polygon obstacles which contain the specified point.
            
            Note: This creates a bounding box around the polygon obstacle to check
            for intersection. This is appropriate for DemoBots, but in your game a
            more specific check may be necessary.
        */
        return scene.polygonObstacles.filter { obstacle in
            // Retrieve all vertices for the polygon obstacle.
            let range = 0..<obstacle.vertexCount
            
            let polygonVertices = range.map { obstacle.vertex(at: $0) }
            guard !polygonVertices.isEmpty else { return false }
            
            let maxX = polygonVertices.max { $0.x < $1.x }!.x + extrusionRadius
            let maxY = polygonVertices.max { $0.y < $1.y }!.y + extrusionRadius
            
            let minX = polygonVertices.min { $0.x < $1.x }!.x - extrusionRadius
            let minY = polygonVertices.min { $0.y < $1.y }!.y - extrusionRadius
            
            return (point.x > minX && point.x < maxX) && (point.y > minY && point.y < maxY)
        }
    }
    
    /**
        Creates a node on the obstacle graph for the provided point by ignoring
        the buffer radius of the contacted obstacles. 
    
        Returns `nil` if a valid connection could not be made.
    */
    private func connectedNode(forPoint point: float2, onObstacleGraphInScene scene: LevelScene) -> GKGraphNode2D?
    {
        //print("connectedNode point:\(point) scene:\(scene.description)")
        
        // Create a graph node for this point.
        let pointNode = GKGraphNode2D(point: point)
        
        // Try to connect this node to the graph.
        scene.graph.connectUsingObstacles(node: pointNode)

        /*
            Check to see if we were able to connect the node to the graph.
            If not, this means that the point is inside the buffer zone of an obstacle
            somewhere in the level. We can't pathfind to a point that is off-graph,
            so we try to find the nearest point that is on the graph, and pathfind
            to there instead.
        */
        if pointNode.connectedNodes.isEmpty
        {
            // The previous connection attempt failed, so remove the node from the graph.
            scene.graph.remove([pointNode])
        
            // Search the graph for all intersecting obstacles.
            let intersectingObstacles = extrudedObstaclesContaining(point: point, inScene: scene)
        
            /*
                Connect this node to the graph ignoring the buffer radius of any
                obstacles that the point is currently intersecting.
            */
            scene.graph.connectUsingObstacles(node: pointNode, ignoringBufferRadiusOf: intersectingObstacles)
            //scene.graph.connectUsingObstacles(node: pointNode)
        
            // If still no connection could be made, return `nil`.
            if pointNode.connectedNodes.isEmpty
            {
                scene.graph.remove([pointNode])
                return nil
            }
        }
        
        return pointNode
    }
    
    
    private func addPointsToWander(from startPoint: float2, pathRadius: Float, inScene scene: LevelScene) -> [CGPoint]
    {

        //let endPoint = float2(140.0,45.0)
       // guard let endNode = connectedNode(forPoint: endPoint, onObstacleGraphInScene: scene) else { return []  }
        
        //scene.graph.connectUsingObstacles(node: endNode)
        
        //print("addGoalsToWander startPoint: \(startPoint) endPoint: \(endNode.position)  scene: \(scene.description)")
        
        
        //Convert the provided 'CGpoint' into nodes for the 'GKGraph'
        guard let startNode = connectedNode(forPoint: startPoint, onObstacleGraphInScene: scene) else { return []  }
       
        // Remove the "start" and "end" nodes when exiting this scope.
        defer { scene.graph.remove([startNode/*, endNode*/]) }
        
        //let pathNodes = scene.graph.findPath(from: startNode, to: endNode) as! [GKGraphNode2D]
        let pathNodes = [CGPoint()]
        
        // Convert the `GKGraphNode2D` nodes into `CGPoint`s for debug drawing.
        //let pathPoints = pathNodes.map { CGPoint($0.position) }
        //return pathPoints
        return pathNodes
    }
    
    
    /// Pathfinds around obstacles to create a path between two points, and adds goals to follow that path.
    private func addGoalsToFollowPath(from startPoint: float2, to endPoint: float2, pathRadius: Float, inScene scene: LevelScene) -> [CGPoint]
    {
        //print("addGoalsToFollowPath startPoint: \(startPoint) endPoint: \(endPoint) scene: \(scene.description)")
        
        // Convert the provided `CGPoint`s into nodes for the `GPGraph`.
        guard let startNode = connectedNode(forPoint: startPoint, onObstacleGraphInScene: scene),
             let endNode = connectedNode(forPoint: endPoint, onObstacleGraphInScene: scene) else { return [] }
        
        // Remove the "start" and "end" nodes when exiting this scope.
        defer { scene.graph.remove([startNode, endNode]) }
        
        // Find a path between these two nodes.
        let pathNodes = scene.graph.findPath(from: startNode, to: endNode) as! [GKGraphNode2D]
        
        // A valid `GKPath` can not be created if fewer than 2 path nodes were found, return.
        guard pathNodes.count > 1 else { return [] }
        
        // Create a new `GKPath` from the found nodes with the requested path radius.
        let path = GKPath(graphNodes: pathNodes, radius: pathRadius)
        
        // Add "follow path" and "stay on path" goals for this path.
        addFollowAndStayOnPathGoals(for: path)
        
        // Convert the `GKGraphNode2D` nodes into `CGPoint`s for debug drawing.
        let pathPoints = pathNodes.map { CGPoint($0.position) }
        return pathPoints
    }
    
    
    // MARK:- Behaviour Goals
    // Adds a goal to wander around thhe scene
    private func addWanderGoal(forScene scene: LevelScene)
    {
        setWeight(0.9, for: GKGoal(toWander: 500))
        //print("addWanderGoal  scene: \(scene.description)")
    }

    
    
    // Adds a goal to flee around thhe scene
    private func addFleeGoal(forScene scene: LevelScene, forAgent agent: GKAgent2D)
    {
        setWeight(1.0, for: GKGoal(toFleeAgent: agent))
        //print("addWanderGoal  scene: \(scene.description)")
    }
    
    //Add a goal to seek
    private func addSeekGoal(forScene scene: LevelScene, agent: GKAgent, weight: Float)
    {
        setWeight(weight, for: GKGoal(toSeekAgent: agent))
        //print("addSeekGoal \(agent.description)  scene: \(scene.description)")
    }
    
    
    // Adds a goal to avoid all polygon obstacles in the scene.
    private func addAvoidObstaclesGoal(forScene scene: LevelScene)
    {
        setWeight(1.0, for: GKGoal(toAvoid: scene.polygonObstacles, maxPredictionTime: GameplayConfiguration.TaskBot.maxPredictionTimeForObstacleAvoidance))
        //print("addAvoidObstaclesGoal  scene: \(scene.description)")
    }
    
    
    // Adds a goal to attain a target speed.
    private func addTargetSpeedGoal(speed: Float)
    {
        setWeight(0.5, for: GKGoal(toReachTargetSpeed: speed))
        //print("addTargetSpeedGoal  speed: \(speed.description)")
    }
    
    
    // Adds goals to follow and stay on a path.
    private func addFollowAndStayOnPathGoals(for path: GKPath)
    {
        // The "follow path" goal tries to keep the agent facing in a forward direction when it is on this path.
        setWeight(1.0, for: GKGoal(toFollow: path, maxPredictionTime: GameplayConfiguration.TaskBot.maxPredictionTimeWhenFollowingPath, forward: true))

        // The "stay on path" goal tries to keep the agent on the path within the path's radius.
        setWeight(1.0, for: GKGoal(toStayOn: path, maxPredictionTime: GameplayConfiguration.TaskBot.maxPredictionTimeWhenFollowingPath))
        
        //print("addFollowAndStayOnPathGoals \(path.description)")
    }
    
    deinit
    {
        //print("Deallocating TaskBotBehavior")
    }
}

/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    A `GKEntity` subclass that provides a base class for `GroundBot` and `FlyingBot`. This subclass allows for convenient construction of the common AI-related components shared by the game's antagonists.
*/

import SpriteKit
import GameplayKit

class TaskBot: GKEntity, ContactNotifiableType, GKAgentDelegate, RulesComponentDelegate
{

    
    // MARK: Nested types
    
    /// Encapsulates a `TaskBot`'s current mandate, i.e. the aim that the `TaskBot` is setting out to achieve.
    enum TaskBotMandate
    {
        // Hunt another agent (either a `PlayerBot` or a "good" `TaskBot`).
        case huntAgent(GKAgent2D)

        //Crowd behaviour
        case crowd()
        
        // Follow the `TaskBot`'s "good" patrol path.
        case followGoodPatrolPath

        
        // Follow the `TaskBot`'s "bad" patrol path.
        case followBadPatrolPath

        
        // Return to a given position on a patrol path.
        case returnToPositionOnPath(float2)
        
        
        // Wander the 'TaskBot' around the scene
        case wander
        
        
        // Arrested behaviour, protestor in Police custody
        case arrested(GKAgent2D)
        
        
        // Take arrested prisoner to meatwagon
        case lockupPrisoner
        
        // Move away from the DangerousBot area quickly
        case fleeAgent(GKAgent2D)

        
        // Retaliate from attack
        case retaliate(GKAgent2D)
    }

    // MARK: Properties
    
    /// Indicates whether or not the `TaskBot` is currently in a "good" (benevolent) or "bad" (adversarial) state.
    var isProtestor: Bool
    {
        didSet
        {
            // Do nothing if the value hasn't changed.
            guard isProtestor != oldValue else { return }
            
            // Get the components we will need to access in response to the value changing.
            guard let intelligenceComponent = component(ofType: IntelligenceComponent.self) else { fatalError("TaskBots must have an intelligence component.") }
            guard let animationComponent = component(ofType: AnimationComponent.self) else { fatalError("TaskBots must have an animation component.") }
            guard let resistanceComponent = component(ofType: ResistanceComponent.self) else { fatalError("TaskBots must have a resistance component.") }
            guard let healthComponent = component(ofType: HealthComponent.self) else { fatalError("TaskBots must have a health component.") }

            
            // Update the `TaskBot`'s speed and acceleration to suit the new value of `isGood`.
            agent.maxSpeed = GameplayConfiguration.TaskBot.maximumSpeedForIsGood(isGood: isProtestor)
            agent.maxAcceleration = GameplayConfiguration.TaskBot.maximumAcceleration

            if isProtestor
            {
                /*
                    The `TaskBot` just turned from "bad" to "good".
                    Set its mandate to `.ReturnToPositionOnPath` for the closest point on its "good" patrol path.
                */
                let closestPointOnGoodPath = closestPointOnPath(path: goodPathPoints)
                mandate = .returnToPositionOnPath(float2(closestPointOnGoodPath))
                
                if self is FlyingBot
                {
                    // Enter the `FlyingBotBlastState` so it performs a curing blast.
                    intelligenceComponent.stateMachine.enter(FlyingBotBlastState.self)
                }
                else
                {
                    // Make sure the `TaskBot`s state is `TaskBotAgentControlledState` so that it follows its mandate.
                    intelligenceComponent.stateMachine.enter(TaskBotAgentControlledState.self)
                }
                
                // Update the animation component to use the "good" animations.
                animationComponent.animations = goodAnimations
                
                // Set the appropriate amount of charge.
                //chargeComponent.charge = 0.0
                resistanceComponent.resistance = 100.0
                healthComponent.health = 100.0
            }
            else
            {
                
                /*
                    The `TaskBot` just turned from "good" to "bad".
                    Default to a `.ReturnToPositionOnPath` mandate for the closest point on its "bad" patrol path.
                    This may be overridden by a `.HuntAgent` mandate when the `TaskBot`'s rules are next evaluated.
                */
                let closestPointOnBadPath = closestPointOnPath(path: badPathPoints)
                mandate = .returnToPositionOnPath(float2(closestPointOnBadPath))
                
                // Update the animation component to use the "bad" animations.
                animationComponent.animations = badAnimations
                
                // Set the appropriate amount of charge.
                //chargeComponent.charge = chargeComponent.maximumCharge
                resistanceComponent.resistance = resistanceComponent.maximumResistance
                healthComponent.health = healthComponent.maximumHealth
                
                // Enter the "zapped" state.
                intelligenceComponent.stateMachine.enter(TaskBotZappedState.self)
            }
        }
    }
    
    // Is the taskbot still a playable bot?
    var isActive: Bool
    
    // Is the taskbot violent?  A violent taskbot will attack if provoked or not unprovoked
    var isViolent: Bool
    
    //Is the taskbot dangerous?  a Taskbot is dangerous if it is attacking and is violent
    var isDangerous: Bool
    
    //Is the taskbot scared and likely to flee?
    var isScared: Bool
    
    //Is the taskbot fighting back?
    var isRetaliating: Bool
    
    /// The aim that the `TaskBot` is currently trying to achieve.
    var mandate: TaskBotMandate
    
    /// The points for the path that the `TaskBot` should patrol when "good" and not hunting.
    var goodPathPoints: [CGPoint]

    /// The points for the path that the `TaskBot` should patrol when "bad" and not hunting.
    var badPathPoints: [CGPoint]

    /// The appropriate `GKBehavior` for the `TaskBot`, based on its current `mandate`.
    var behaviorForCurrentMandate: GKBehavior
    {
        // Return an empty behavior if this `TaskBot` is not yet in a `LevelScene`.
        guard let levelScene = component(ofType: RenderComponent.self)?.node.scene as? LevelScene else {
            return GKBehavior()
        }

        let agentBehavior: GKBehavior
        let radius: Float
            
        // `debugPathPoints`, `debugPathShouldCycle`, and `debugColor` are only used when debug drawing is enabled.
        let debugPathPoints: [CGPoint]
        var debugPathShouldCycle = false
        let debugColor: SKColor
        
        
        switch mandate
        {
            
            case .followGoodPatrolPath, .followBadPatrolPath:
                let pathPoints = isProtestor ? goodPathPoints : badPathPoints
                radius = GameplayConfiguration.TaskBot.patrolPathRadius
                agentBehavior = TaskBotBehavior.patrolBehaviour(forAgent: agent, patrollingPathWithPoints: pathPoints, pathRadius: radius, inScene: levelScene)
                debugPathPoints = pathPoints
                
                // Patrol paths are always closed loops, so the debug drawing of the path should cycle back round to the start.
                debugPathShouldCycle = true
                debugColor = isProtestor ? SKColor.green : SKColor.purple
            
            case .crowd:
                radius = GameplayConfiguration.TaskBot.huntPathRadius
                
                let temperament = "Calm"
                
                (agentBehavior, debugPathPoints) = TaskBotBehavior.crowdBehaviour(forAgent: agent, pathRadius: radius, temperament: temperament, inScene: levelScene)
                debugColor = SKColor.orange
            
            case let .huntAgent(taskBot):
                radius = GameplayConfiguration.TaskBot.huntPathRadius
                (agentBehavior, debugPathPoints) = TaskBotBehavior.huntBehaviour(forAgent: agent, huntingAgent: taskBot, pathRadius: radius, inScene: levelScene)
                debugColor = SKColor.red

            case let .returnToPositionOnPath(position):
                radius = GameplayConfiguration.TaskBot.returnToPatrolPathRadius
                (agentBehavior, debugPathPoints) = TaskBotBehavior.returnToPathBehaviour(forAgent: agent, returningToPoint: position, pathRadius: radius, inScene: levelScene)
                debugColor = SKColor.yellow
            
            case .wander:
                radius = GameplayConfiguration.TaskBot.wanderPathRadius
                (agentBehavior, debugPathPoints)  = TaskBotBehavior.wanderBehaviour(forAgent: agent, inScene: levelScene)
                debugColor = SKColor.cyan
            
            //Protestor being moved to LockUp
            case let .arrested(taskBot):
                radius = GameplayConfiguration.TaskBot.wanderPathRadius
                (agentBehavior, debugPathPoints) = TaskBotBehavior.arrestedBehaviour(forAgent: agent, huntingAgent: taskBot, pathRadius: 25.0, inScene: levelScene)
                debugColor = SKColor.white
            
            //PoliceBot taking prisoner to meatwagon
            case .lockupPrisoner:
                radius = GameplayConfiguration.TaskBot.lockupRadius
                (agentBehavior, debugPathPoints) = TaskBotBehavior.returnToPathBehaviour(forAgent: agent, returningToPoint: levelScene.meatWagonLocation(), pathRadius: radius, inScene: levelScene)
                debugColor = SKColor.brown
            
            case let .fleeAgent(taskBot):
                radius = GameplayConfiguration.TaskBot.fleePathRadius
                (agentBehavior, debugPathPoints) = TaskBotBehavior.fleeBehaviour(forAgent: agent, fromAgent: taskBot, inScene: levelScene)
                debugColor = SKColor.purple
            
            case let .retaliate(taskBot):
                radius = GameplayConfiguration.TaskBot.huntPathRadius
                (agentBehavior, debugPathPoints) = TaskBotBehavior.retaliateBehaviour(forAgent: agent, huntingAgent: taskBot, pathRadius: radius, inScene: levelScene)
                debugColor = SKColor.blue
        }

        if levelScene.debugDrawingEnabled
        {
            drawDebugPath(path: debugPathPoints, cycle: debugPathShouldCycle, color: debugColor, radius: radius)
        }
        else
        {
            debugNode.removeAllChildren()
        }

        return agentBehavior
    }
    
    /// The animations to use when a `TaskBot` is in its "good" state.
    var goodAnimations: [AnimationState: Animation]
    {
        fatalError("goodAnimations must be overridden in subclasses")
    }
    
    /// The animations to use when a `TaskBot` is in its "bad" state.
    var badAnimations: [AnimationState: Animation]
    {
        fatalError("badAnimations must be overridden in subclasses")
    }
    
    /// The `GKAgent` associated with this `TaskBot`.
    var agent: TaskBotAgent
    {
        guard let agent = component(ofType: TaskBotAgent.self) else { fatalError("A TaskBot entity must have a GKAgent2D component.") }
        return agent
    }

    /// The `RenderComponent` associated with this `TaskBot`.
    var renderComponent: RenderComponent
    {
        guard let renderComponent = component(ofType: RenderComponent.self) else { fatalError("A TaskBot must have an RenderComponent.") }
        return renderComponent
    }
    
    /// The `RenderComponent` associated with this `TaskBot`.
    var temperamentComponent: TemperamentComponent
    {
        guard let temperamentComponent = component(ofType: TemperamentComponent.self) else { fatalError("A TaskBot must have an TemperamentComponent.") }
        return temperamentComponent
    }
    
    /// Used to determine the location on the `TaskBot` where contact with the debug beam occurs.
    var beamTargetOffset = CGPoint.zero
    
    // uSed to determne the location on the 'TaskBot' where contact with the debug weapon occurs
    var weaponTargetOffset = CGPoint.zero
    
    /// Used to hang shapes representing the current path for the `TaskBot`.
    var debugNode = SKNode()
    
    // MARK: Initializers
    
    required init(isGood: Bool, goodPathPoints: [CGPoint], badPathPoints: [CGPoint])
    {
        // Whether or not the `TaskBot` is "good" when first created.
        self.isProtestor = isGood
        
        // Whether or not the 'TaskBot' is active, = healthy and not arrested or detained
        self.isActive = true
        
        // Whether or not the 'TaskBot' is violent, e.g. will attack if provoked
        self.isViolent = false
        
        // Whether or not the 'TaskBot' is dangerous, e.g. actively fighting with extreme violence
        self.isDangerous = false
        
        // Whether or not the 'TaskBot' is scared
        self.isScared = false
        
        // Whether or not the taskbot is retaliating
        self.isRetaliating = false

        // The locations of the points that define the `TaskBot`'s "good" and "bad" patrol paths.
        self.goodPathPoints = goodPathPoints
        self.badPathPoints = badPathPoints
        
        /*
            A `TaskBot`'s initial mandate is always to patrol.
            Because a `TaskBot` is positioned at the appropriate path's start point when the level is created,
            there is no need for it to pathfind to the start of its path, and it can patrol immediately.
        */
        mandate = isGood ? .followGoodPatrolPath : .followBadPatrolPath
        super.init()

        // Create a `TaskBotAgent` to represent this `TaskBot` in a steering physics simulation.
        let agent = TaskBotAgent()
        agent.delegate = self
        
        // Configure the agent's characteristics for the steering physics simulation.
        agent.maxSpeed = GameplayConfiguration.TaskBot.maximumSpeedForIsGood(isGood: isGood)
        agent.maxAcceleration = GameplayConfiguration.TaskBot.maximumAcceleration
        agent.mass = GameplayConfiguration.TaskBot.agentMass
        agent.radius = GameplayConfiguration.TaskBot.agentRadius
        agent.behavior = GKBehavior()
        
        /*
            `GKAgent2D` is a `GKComponent` subclass.
            Add it to the `TaskBot` entity's list of components so that it will be updated
            on each component update cycle.
        */
        addComponent(agent)

        // Create and add a rules component to encapsulate all of the rules that can affect a `TaskBot`'s behavior.
        let rulesComponent = RulesComponent(rules: [
            PlayerBotNearRule(),
            PlayerBotMediumRule(),
            PlayerBotFarRule(),
            ProtestorTaskBotNearRule(),
            ProtestorTaskBotMediumRule(),
            ProtestorTaskBotFarRule(),
            DangerousProtestorTaskBotNearRule(),
            DangerousProtestorTaskBotMediumRule(),
            DangerousProtestorTaskBotFarRule(),
            ScaredTaskBotNearRule(),
            ScaredTaskBotMediumRule(),
            ScaredTaskBotFarRule(),
            PoliceTaskBotPercentageLowRule(),
            PoliceTaskBotPercentageMediumRule(),
            PoliceTaskBotPercentageHighRule(),
            PoliceBotNearRule(),
            PoliceBotMediumRule(),
            PoliceBotFarRule()
            
        ])
        addComponent(rulesComponent)
        rulesComponent.delegate = self
        
        
        if let emitterComponent = component(ofType: EmitterComponent.self)
        {
            emitterComponent.node.targetNode = renderComponent.node.scene
        }
        else { print("TaskBot does not have an emitter component.") }
        
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: GKAgentDelegate
    
    func agentWillUpdate(_: GKAgent)
    {
        /*
            `GKAgent`s do not operate in the SpriteKit physics world,
            and are not affected by SpriteKit physics collisions.
            Because of this, the agent's position and rotation in the scene
            may have values that are not valid in the SpriteKit physics simulation.
            For example, the agent may have moved into a position that is not allowed
            by interactions between the `TaskBot`'s physics body and the level's scenery.
            To counter this, set the agent's position and rotation to match
            the `TaskBot` position and orientation before the agent calculates
            its steering physics update.
        */
        updateAgentPositionToMatchNodePosition()
        updateAgentRotationToMatchTaskBotOrientation()
    }
    
    func agentDidUpdate(_: GKAgent)
    {
        guard let intelligenceComponent = component(ofType: IntelligenceComponent.self) else { return }
        guard let orientationComponent = component(ofType: OrientationComponent.self) else { return }
        guard let emitterComponent = component(ofType: EmitterComponent.self) else { return }

        
 //       print("intelligenceComponent.stateMachine.currentState:\(intelligenceComponent.stateMachine.currentState?.description)")
        if intelligenceComponent.stateMachine.currentState is TaskBotAgentControlledState
        {
            
            // `TaskBot`s always move in a forward direction when they are agent-controlled.
            component(ofType: AnimationComponent.self)?.requestedAnimationState = .idle    //.walkForward
            
            // When the `TaskBot` is agent-controlled, the node position follows the agent position.
            updateNodePositionToMatchAgentPosition()
            
            // If the agent has a velocity, the `zRotation` should be the arctangent of the agent's velocity. Otherwise use the agent's `rotation` value.
            let newRotation: Float
            if agent.velocity.x > 0.0 || agent.velocity.y > 0.0
            {
                newRotation = atan2(agent.velocity.y, agent.velocity.x)
            }
            else
            {
                newRotation = agent.rotation
            }

            // Ensure we have a valid rotation.
            if newRotation.isNaN { return }

            orientationComponent.zRotation = CGFloat(newRotation)
            //print((renderComponent.node.scene?.description))
            emitterComponent.node.targetNode = renderComponent.node.scene
            
        }
        else
        {
            /*
                When the `TaskBot` is not agent-controlled, the agent position
                and rotation follow the node position and `TaskBot` orientation.
            */
            updateAgentPositionToMatchNodePosition()
            updateAgentRotationToMatchTaskBotOrientation()
        }
    }
    
    // MARK: RulesComponentDelegate
    
    func rulesComponent(rulesComponent: RulesComponent, didFinishEvaluatingRuleSystem ruleSystem: GKRuleSystem)
    {
        let state = ruleSystem.state["snapshot"] as! EntitySnapshot
        
        // Adjust the `TaskBot`'s `mandate` based on the result of evaluating the rules.
        
        // A Series of situation in which we prefer to Flee from a 'TaskBot'
        let fleeTaskBotRaw = [
        
            // A "Dangerous" Taskbot is nearby AND "nearest Protestor is far away"
          /*
            ruleSystem.minimumGrade(forFacts: [
                Fact.dangerousTaskBotNear.rawValue as AnyObject,
                Fact.protestorTaskBotFar.rawValue as AnyObject
                ]),
            
            // A "Dangerous" Taskbot is nearby AND "Police presence is low"
            ruleSystem.minimumGrade(forFacts: [
                Fact.dangerousTaskBotNear.rawValue as AnyObject,
                Fact.policeTaskBotPercentageLow.rawValue as AnyObject
                ]),
            
            // "High percentage of Dangerous Taskbots" AND "High Percentage of Police"
            ruleSystem.minimumGrade(forFacts: [
                Fact.dangerousTaskBotPercentageHigh.rawValue as AnyObject,
                Fact.policeTaskBotPercentageHigh.rawValue as AnyObject
                ]),
            
            // "High percentage of Dangerous Taskbots" AND "Medium Percentage of Police"
            ruleSystem.minimumGrade(forFacts: [
                Fact.dangerousTaskBotPercentageHigh.rawValue as AnyObject,
                Fact.policeTaskBotPercentageMedium.rawValue as AnyObject
            ]),
            */
            
            // "Police nearby" AND "Dangerous Protestors nearby"
            ruleSystem.minimumGrade(forFacts: [
                Fact.policeBotNear.rawValue as AnyObject
                ])/*,
            
            // "Police nearby" AND "Dangerous Protestors nearby"
            ruleSystem.minimumGrade(forFacts: [
                Fact.policeBotMedium.rawValue as AnyObject
                ]),
            
            // "Police far away" AND "Dangerous Protestors nearby"
            ruleSystem.minimumGrade(forFacts: [
                Fact.policeBotFar.rawValue as AnyObject
            ])
 */
        ]
        
        
        let fleeDangerousTaskBot = fleeTaskBotRaw.reduce(0.0, max)
        print("fleeDangerousTaskBot: \(fleeDangerousTaskBot.description), fleeTaskBotRaw: \(fleeTaskBotRaw.description) ")
      
        
        
        // A series of situations in which we prefer this `TaskBot` to hunt the player.
        let huntPlayerBotRaw = [
            // "Number of Police TaskBots is high" AND "Player is nearby".
            ruleSystem.minimumGrade(forFacts: [
                Fact.policeTaskBotPercentageHigh.rawValue as AnyObject,
                Fact.playerBotNear.rawValue as AnyObject
            ])
            
            /*
                There are already a lot of Police `TaskBot`s on the level, and the
                player is nearby, so hunt the player.
            */
/*
            // "Number of Police `TaskBot`s is medium" AND "Player is nearby".
            ruleSystem.minimumGrade(forFacts: [
  //              Fact.policeTaskBotPercentageMedium.rawValue as AnyObject//,
 //               Fact.playerBotNear.rawValue as AnyObject
            ]),
            /*
                There are already a reasonable number of Police `TaskBots` on the level,
                and the player is nearby, so hunt the player.
            */
            
            /*
                "Number of Police TaskBots is high" AND "Player is at medium proximity"
                AND "nearest Protestor `TaskBot` is at medium proximity".
            */
            ruleSystem.minimumGrade(forFacts: [
 //               Fact.policeTaskBotPercentageHigh.rawValue as AnyObject,
 //               Fact.playerBotMedium.rawValue as AnyObject,
 //               Fact.protestorTaskBotMedium.rawValue as AnyObject
            ]),
            /* 
                There are already a lot of Police `TaskBot`s on the level, so even though
                both the player and the nearest Protestor TaskBot are at medium proximity,
                prefer the player for hunting.
            */
 */
        ]

        // Find the maximum of the minima from above.
        let huntPlayerBot = huntPlayerBotRaw.reduce(0.0, max)
        print("huntPlayerBot: \(huntPlayerBot.description), huntPlayerBotRaw: \(huntPlayerBotRaw.description) ")
        
        
        // A series of situations in which we prefer this 'TaskBot' to hunt the nearest "Dangerous Protestor" TaskBot
        // Police will only hunt dangerous if they have enough Police
        let huntDangerousProtestorTaskBotRaw = [
            
            // "Number Police TaskBots is high" AND "Dangerous Protestor 'TaskBot' is nearby"
            ruleSystem.minimumGrade(forFacts: [

                Fact.policeTaskBotPercentageHigh.rawValue as AnyObject,
                Fact.dangerousTaskBotNear.rawValue as AnyObject,
                ]),
            
            // "Number of Police TaskBots is high" AND "Nearest Dangerous Protestor TaskBot is at medium distance"
            ruleSystem.minimumGrade(forFacts: [
                Fact.policeTaskBotPercentageHigh.rawValue as AnyObject,
                Fact.dangerousTaskBotMedium.rawValue as AnyObject
                ]),
            
            // "Number of Police TaskBots is high" AND "Nearest Dangerous Protestor is at far away"
            ruleSystem.minimumGrade(forFacts: [
                Fact.policeTaskBotPercentageHigh.rawValue as AnyObject,
                Fact.dangerousTaskBotMedium.rawValue as AnyObject
                ]),
        ]
        
        // Find the maximum of the minima from above.
        let huntDangerousProtestorBot = huntDangerousProtestorTaskBotRaw.reduce(0.0, max)
        print("huntDangerousTaskBot: \(huntDangerousProtestorBot.description), huntDangerousTaskBotRaw: \(huntDangerousProtestorTaskBotRaw.description) ")
        
        
        // A series of situations in which we prefer this `TaskBot` to hunt the nearest "Protestor" TaskBot.
        let huntTaskBotRaw = [
        
            // "Number of Police TaskBots is low" AND "Nearest Protestor `TaskBot` is nearby" AND "Scared Protestor" is nearby.
            ruleSystem.minimumGrade(forFacts: [
                Fact.policeTaskBotPercentageLow.rawValue as AnyObject,
                Fact.protestorTaskBotNear.rawValue as AnyObject
            ]),
            /*
                There are not many Police `TaskBot`s on the level, and a Protestor `TaskBot`
                is nearby, so hunt the `TaskBot`.
            */

            // "Number of Police TaskBots is medium" AND "Nearest Protestor TaskBot is nearby".
            ruleSystem.minimumGrade(forFacts: [
                Fact.policeTaskBotPercentageMedium.rawValue as AnyObject,
                Fact.protestorTaskBotNear.rawValue as AnyObject
            ]),
            /* 
                There are a reasonable number of `TaskBot`s on the level, but a Protestor
                `TaskBot` is nearby, so hunt the `TaskBot`.
            */

            /*
                "Number of Police TaskBots is low" AND "Player is at medium proximity"
                AND "Nearest Protestor TaskBot is at medium proximity".
            */
            ruleSystem.minimumGrade(forFacts: [
                Fact.policeTaskBotPercentageLow.rawValue as AnyObject,
        //        Fact.playerBotMedium.rawValue as AnyObject,
                Fact.protestorTaskBotMedium.rawValue as AnyObject
            ]),
            /*
                There are not many Police `TaskBot`s on the level, so even though both
                the player and the nearest Protestor `TaskBot` are at medium proximity,
                prefer the nearest Protestor `TaskBot` for hunting.
            */

            /*
                "Number of Police `TaskBot`s is medium" AND "Player is far away" AND
                "Nearest Protestor `TaskBot` is at medium proximity".
            */
            ruleSystem.minimumGrade(forFacts: [
                Fact.policeTaskBotPercentageMedium.rawValue as AnyObject,
       //         Fact.playerBotFar.rawValue as AnyObject,
                Fact.protestorTaskBotMedium.rawValue as AnyObject
            ]),
            /*
                There are a reasonable number of Police `TaskBot`s on the level, the
                player is far away, and the nearest Protestor `TaskBot` is at medium
                proximity, so prefer the nearest Protestor `TaskBot` for hunting.
            */
        ]

        // Find the maximum of the minima from above.
        let huntTaskBot = huntTaskBotRaw.reduce(0.0, max)
        print("huntTaskBot: \(huntTaskBot.description), huntTaskBotRaw: \(huntTaskBotRaw.description) ")
        
        
        // A series of situations in which we prefer this `TaskBot` to hunt the nearest "Police" TaskBot.
        let attackPoliceBotRaw = [
        
            // Police TaskBot is nearby and their are not many Police
            ruleSystem.minimumGrade(forFacts: [
                Fact.policeBotNear.rawValue as AnyObject,
                Fact.policeTaskBotPercentageLow.rawValue as AnyObject
                ]),
            
            // Police TaskBot is nearby and their are some Police
            ruleSystem.minimumGrade(forFacts: [
                Fact.policeBotNear.rawValue as AnyObject,
                Fact.policeTaskBotPercentageMedium.rawValue as AnyObject
                ]),
            
            // Police TaskBot is medium proximity and their are few Police
            ruleSystem.minimumGrade(forFacts: [
                Fact.policeBotMedium.rawValue as AnyObject,
                Fact.policeTaskBotPercentageLow.rawValue as AnyObject
                ])
        ]
        
        //Find the maximum of the minum from above
        let attackPoliceBot = attackPoliceBotRaw.reduce(0.0, max)
        print("attackPoliceBot: \(attackPoliceBot)")
        
        
        // Taskbot is scared and a Dangerous or Police Bot is nearby, leg it
        if self.isScared && fleeDangerousTaskBot > 0
        {
            print("Fleeing from dangerous or police")
            
            // The rules provided greated motivation to flee
            guard let dangerousTaskBot = state.nearestDangerousTaskBotTarget?.target.agent else { return }
            mandate = .fleeAgent(dangerousTaskBot)
        }
        
        // Protestor TaskBot has been attacked and is now retaliating
        else if self.isRetaliating && self.isProtestor
        {
            print("Retaliating")
            guard let targetTaskbot = state.nearestPoliceTaskBotTarget?.target.agent else { return }
            mandate = .retaliate(targetTaskbot)
        }

        //TaskBot is Violent and Police are nearby, go fuck them up
        else if self.isProtestor && self.isViolent && attackPoliceBot > 0
        {
            print("Attacking Police")
            guard let dangerousTaskBot = state.nearestPoliceTaskBotTarget?.target.agent else { return }
            mandate = .huntAgent(dangerousTaskBot)
        }
            
        // TaskBot is Police and active (alive) and a dangerous bot is detected, attack it
        else if !self.isProtestor && isActive && huntDangerousProtestorBot > huntTaskBot
        {
            // The rules provided greater motivation to hunt the nearest Dangerous Protestor TaskBot. Ignore any motivation to hunt the PlayerBot.
            
            print("Hunt the nearest dangerous bot")
            mandate = .huntAgent(state.nearestDangerousTaskBotTarget!.target.agent)
        }
        
        // PROBABLY DELETE THIS LATER
        // An active PoliceBot is near a Protestor, attack them
        else if !isProtestor && isActive && huntTaskBot > huntPlayerBot
        {
            print("Hunt the nearest Protestor: \(state.nearestProtestorTaskBotTarget!.target.agent.debugDescription)")
            
            // The rules provided greater motivation to hunt the nearest good TaskBot. Ignore any motivation to hunt the PlayerBot.
            mandate = .huntAgent(state.nearestProtestorTaskBotTarget!.target.agent)
        }
        else
        {
            // The rules provided no motivation to hunt, so patrol in the "bad" state.
            switch mandate
            {
                case .wander:
                    mandate = .wander
                    break;
                
                case .followGoodPatrolPath:
                    //The taskbot is already on its "good" patrol path, so no update is needed
                    break
                
                case .followBadPatrolPath:
                    // The `TaskBot` is already on its "bad" patrol path, so no update is needed.
                    break
                default:
                    // Send the `TaskBot` to the closest point on its "bad" patrol path.
                    let closestPointOnBadPath = closestPointOnPath(path: badPathPoints)
                    mandate = .returnToPositionOnPath(float2(closestPointOnBadPath))
            }
        }
    }
    
    // MARK: ContactableType
    
    func contactWithEntityDidBegin(_ entity: GKEntity) {}

    func contactWithEntityDidEnd(_ entity: GKEntity) {}

    // MARK: Convenience
    
    /// The direct distance between this `TaskBot`'s agent and another agent in the scene.
    func distanceToAgent(otherAgent: GKAgent2D) -> Float
    {
        let deltaX = agent.position.x - otherAgent.position.x
        let deltaY = agent.position.y - otherAgent.position.y
        
        return hypot(deltaX, deltaY)
    }
    
    func distanceToPoint(otherPoint: float2) -> Float
    {
        let deltaX = agent.position.x - otherPoint.x
        let deltaY = agent.position.y - otherPoint.y
        
        return hypot(deltaX, deltaY)
    }
    
    func closestPointOnPath(path: [CGPoint]) -> CGPoint
    {
        // Find the closest point to the `TaskBot`.
        let taskBotPosition = agent.position
        let closestPoint = path.min {
            return distance_squared(taskBotPosition, float2($0)) < distance_squared(taskBotPosition, float2($1))
        }
    
        return closestPoint!
    }
    
    /// Sets the `TaskBot` `GKAgent` position to match the node position (plus an offset).
    func updateAgentPositionToMatchNodePosition()
    {
        // `renderComponent` is a computed property. Declare a local version so we don't compute it multiple times.
        let renderComponent = self.renderComponent
        
        let agentOffset = GameplayConfiguration.TaskBot.agentOffset
        agent.position = float2(x: Float(renderComponent.node.position.x + agentOffset.x), y: Float(renderComponent.node.position.y + agentOffset.y))
    }
    
    /// Sets the `TaskBot` `GKAgent` rotation to match the `TaskBot`'s orientation.
    func updateAgentRotationToMatchTaskBotOrientation()
    {
        //Ensure the agent's orientation and visible orientation are consistent
        guard let orientationComponent = component(ofType: OrientationComponent.self) else { return }
        agent.rotation = Float(orientationComponent.zRotation)
        
        //Ensure animationComponent and Orientation are consistent
        guard let animationComponent = component(ofType: AnimationComponent.self) else { return }
        animationComponent.node.zRotation = orientationComponent.zRotation
        
        //print("zRotation:\(orientationComponent.zRotation)")
    }
    
    /// Sets the `TaskBot` node position to match the `GKAgent` position (minus an offset).
    func updateNodePositionToMatchAgentPosition()
    {
        // `agent` is a computed property. Declare a local version of its property so we don't compute it multiple times.
        let agentPosition = CGPoint(agent.position)
        
        let agentOffset = GameplayConfiguration.TaskBot.agentOffset
        renderComponent.node.position = CGPoint(x: agentPosition.x - agentOffset.x, y: agentPosition.y - agentOffset.y)
    }
    
    // MARK: Debug Path Drawing
    
    func drawDebugPath(path: [CGPoint], cycle: Bool, color: SKColor, radius: Float)
    {
        guard path.count > 1 else { return }
        
        debugNode.removeAllChildren()
        
        var drawPath = path
        
        if cycle
        {
            drawPath += [drawPath.first!]
        }

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        // Use RGB component accessor common between `UIColor` and `NSColor`.
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let strokeColor = SKColor(red: red, green: green, blue: blue, alpha: 0.4)
        let fillColor = SKColor(red: red, green: green, blue: blue, alpha: 0.2)
        
        for index in 0..<drawPath.count - 1
        {
            let current = CGPoint(x: drawPath[index].x, y: drawPath[index].y)
            let next = CGPoint(x: drawPath[index + 1].x, y: drawPath[index + 1].y)
            
            let circleNode = SKShapeNode(circleOfRadius: CGFloat(radius))
            circleNode.strokeColor = strokeColor
            circleNode.fillColor = fillColor
            circleNode.position = current
            debugNode.addChild(circleNode)

            let deltaX = next.x - current.x
            let deltaY = next.y - current.y
            let rectNode = SKShapeNode(rectOf: CGSize(width: hypot(deltaX, deltaY), height: CGFloat(radius) * 2))
            rectNode.strokeColor = strokeColor
            rectNode.fillColor = fillColor
            rectNode.zRotation = atan(deltaY / deltaX)
            rectNode.position = CGPoint(x: current.x + (deltaX / 2.0), y: current.y + (deltaY / 2.0))
            debugNode.addChild(rectNode)
        }
    }
    
    // MARK: Shared Assets
    
    class func loadSharedAssets()
    {
        ColliderType.definedCollisions[.TaskBot] = [
            .Obstacle,
            .PlayerBot,
            .TaskBot
        ]
        
        ColliderType.requestedContactNotifications[.TaskBot] = [
            .Obstacle,
            .PlayerBot,
            .TaskBot
        ]
    }
    
    func entityTouched (touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        print("TaskBot touched!!!")
    }
}

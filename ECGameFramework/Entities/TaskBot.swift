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
        //Police should go and give support to an officer in need
        case supportPolice(GKAgent2D)
        
        // Player instructed TaskBot to move to a location
        case playerMovedTaskBot
        
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
        
        // Return to the starting position at the time of beginning to look for wares
        case returnHome(float2)
        
        // Wander the 'TaskBot' around the scene
        case wander
        
        
        // Arrested behaviour, protestor in Police custody
        case arrested(GKAgent2D)
        
        
        // Take arrested prisoner to meatwagon
        case lockupPrisoner
        
        // Move away from the DangerousBot area quickly
        case fleeAgent(GKAgent2D)

        // Retaliate against attack
        case retaliate(GKAgent2D)

        // Incite trouble
        case incite
        
        // Buy wares
        case buyWares(GKAgent2D)
        
        // Sell wares
        case sellWares
        
        // Vandalise
        case vandalise(float2)
        
        // Loot
        case loot(float2)
    }

    // MARK: Properties
    
    /// Indicates whether or not the `TaskBot` is currently in a "good" (benevolent) or "bad" (adversarial) state.
    var isGood: Bool
    {
        didSet
        {
            // Do nothing if the value hasn't changed.
            guard isGood != oldValue else { return }
            
            // Get the components we will need to access in response to the value changing.
            guard let intelligenceComponent = component(ofType: IntelligenceComponent.self) else { fatalError("TaskBots must have an intelligence component.") }
            guard let animationComponent = component(ofType: AnimationComponent.self) else { fatalError("TaskBots must have an animation component.") }
            guard let resistanceComponent = component(ofType: ResistanceComponent.self) else { fatalError("TaskBots must have a resistance component.") }
            guard let healthComponent = component(ofType: HealthComponent.self) else { fatalError("TaskBots must have a health component.") }
            guard let chargeComponent = component(ofType: ChargeComponent.self) else { fatalError("TaskBots must have a charge component.") }
            
            
            // Update the `TaskBot`'s speed and acceleration to suit the new value of `isGood`.
            agent.maxSpeed = GameplayConfiguration.TaskBot.maximumSpeedForIsGood(isGood: isGood)
            agent.maxAcceleration = GameplayConfiguration.TaskBot.maximumAcceleration

            if isGood
            {
                /*
                    The `TaskBot` just turned from "bad" to "good".
                    Set its mandate to `.ReturnToPositionOnPath` for the closest point on its "good" patrol path.
                */
                let closestPointOnGoodPath = closestPointOnPath(path: goodPathPoints)
                mandate = .returnToPositionOnPath(float2(closestPointOnGoodPath))
//                mandate = .wander
                
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
                chargeComponent.charge = 100.0
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
                chargeComponent.charge = chargeComponent.maximumCharge
                resistanceComponent.resistance = resistanceComponent.maximumResistance
                healthComponent.health = healthComponent.maximumHealth
                
                // Enter the "zapped" state.
                intelligenceComponent.stateMachine.enter(TaskBotZappedState.self)
            }
        }
    }
    
    
    var oldColour: SKColor
    
    // Is the taskbot still a playable bot?
    var isActive: Bool
    
    // Is the taskBot at it's return position?
    var isHome: Bool
    
    // Is the taskbot violent?  A violent taskbot will attack if provoked or not unprovoked
    var isViolent: Bool
    
    //Is the taskbot dangerous?  a Taskbot is dangerous if it is attacking and is violent
    var isDangerous: Bool
    
    //Is the taskbot scared and likely to flee?
    var isScared: Bool
    
    // Is the taskbot arrested?
    var isArrested: Bool
    
    //Is the taskbot fighting back?
    var isRetaliating: Bool

    //Is the taskbot protestor?
    var isProtestor: Bool
    
    //Is the taskbot hungry for alcohol and drugs
    var isHungry: Bool
    
    //Does the taskbot have wares on them
    var hasWares: Bool
    
    //Is the taskbot consuming a product
    var isConsuming: Bool
    
    //Is the taskbot Subservient?
    var isSubservient: Bool
    
    //Is the taskbot criminal?
    var isCriminal: Bool
    
    //Is the taskbot selling wares?
    var isSelling: Bool
    
    //Is the taskbot buying wares?
    var isBuying: Bool
    
    //Is the taskbot injured?
    var isInjured: Bool
    
    //Is the taskbot police?
    var isPolice: Bool
    
    //Is the taskbot in trouble?
    var needsHelp: Bool
    
    /// The aim that the `TaskBot` is currently trying to achieve.
    var mandate: TaskBotMandate
    
    // The points for the path that the player has created for a TaskBot to follow
    var playerPathPoints: [CGPoint] = []
    
    // The points for the path that the `TaskBot` should patrol when "good" and not hunting.
    var goodPathPoints: [CGPoint]

    // The points for the path that the `TaskBot` should patrol when "bad" and not hunting.
    var badPathPoints: [CGPoint]

    // The appropriate `GKBehavior` for the `TaskBot`, based on its current `mandate`.
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
            // PoliceBots need support
            case let .supportPolice(target):
                
                print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                
                radius = GameplayConfiguration.TaskBot.huntPathRadius
                (agentBehavior, debugPathPoints) = TaskBotBehavior.supportBehaviour(forAgent: agent, huntingAgent: target, pathRadius: radius, inScene: levelScene)
                debugColor = SKColor.orange
            
            
            // Player has created a path for the TaskBot to follow
            case .playerMovedTaskBot:
                
                print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                
                let pathPoints = self.playerPathPoints
                radius = GameplayConfiguration.TaskBot.patrolPathRadius
                (agentBehavior, debugPathPoints) = TaskBotBehavior.moveBehaviour(forAgent: agent, pathPoints: pathPoints, pathRadius: radius, inScene: levelScene)
                
                debugPathShouldCycle = true
                debugColor = SKColor.white
            
                //startAnimation()
            
            // TaskBots will follow either a good or bad patrol path
            case .followGoodPatrolPath, .followBadPatrolPath:
                
                print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                
                let pathPoints = isGood ? goodPathPoints : badPathPoints
                radius = GameplayConfiguration.TaskBot.patrolPathRadius
                agentBehavior = TaskBotBehavior.patrolBehaviour(forAgent: agent, patrollingPathWithPoints: pathPoints, pathRadius: radius, inScene: levelScene, cyclical: true)
                debugPathPoints = pathPoints
                
                // Patrol paths are always closed loops, so the debug drawing of the path should cycle back round to the start.
                debugPathShouldCycle = true
                debugColor = isGood ? SKColor.green : SKColor.purple
            
            // Protestors will crowd together if of the same temperament
            case .crowd:
                
                print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                
                // Who will crowd with who, only calm people for now
                let temperament = "Calm"
                radius = GameplayConfiguration.TaskBot.huntPathRadius
                agentBehavior = TaskBotBehavior.crowdBehaviour(forAgent: agent, pathRadius: radius, temperament: temperament, inScene: levelScene)
                debugColor = SKColor.orange
            
                let pathPoints = isGood ? goodPathPoints : badPathPoints
                debugPathPoints = pathPoints
            
            // TaskBot is hunting another TaskBot
            case let .huntAgent(taskBot):
                
                print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                
                radius = GameplayConfiguration.TaskBot.huntPathRadius
                (agentBehavior, debugPathPoints) = TaskBotBehavior.huntBehaviour(forAgent: agent, huntingAgent: taskBot, pathRadius: radius, inScene: levelScene)
                debugColor = SKColor.red

            // Return TaskBot to a position on a path
            case let .returnToPositionOnPath(position):
                
                print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                
                radius = GameplayConfiguration.TaskBot.returnToPatrolPathRadius
                (agentBehavior, debugPathPoints) = TaskBotBehavior.returnToPathBehaviour(forAgent: agent, returningToPoint: position, pathRadius: radius, inScene: levelScene)
                debugColor = SKColor.yellow
            
            case let .returnHome(position):
                
                print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                
                radius = GameplayConfiguration.TaskBot.returnToPatrolPathRadius
                (agentBehavior, debugPathPoints) = TaskBotBehavior.returnToPathBehaviour(forAgent: agent, returningToPoint: position, pathRadius: radius, inScene: levelScene)
                debugColor = SKColor.brown
            
            // TaskBot is wandering around the scene
            case .wander:
                
                print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                
                radius = GameplayConfiguration.TaskBot.wanderPathRadius
                (agentBehavior, debugPathPoints)  = TaskBotBehavior.wanderBehaviour(forAgent: agent, inScene: levelScene)
                debugColor = SKColor.cyan
            
            // Protestor being moved to LockUp
            case let .arrested(taskBot):
                
                print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                
                radius = GameplayConfiguration.TaskBot.wanderPathRadius
                (agentBehavior, debugPathPoints) = TaskBotBehavior.arrestedBehaviour(forAgent: agent, huntingAgent: taskBot, pathRadius: 25.0, inScene: levelScene)
                debugColor = SKColor.white
            
            // PoliceBot taking prisoner to meatwagon
            case .lockupPrisoner:
                
                print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                
                radius = GameplayConfiguration.TaskBot.lockupRadius
                (agentBehavior, debugPathPoints) = TaskBotBehavior.returnToPathBehaviour(forAgent: agent, returningToPoint: levelScene.meatWagonLocation(), pathRadius: radius, inScene: levelScene)
                debugColor = SKColor.brown
            
            // TaskBot is scared and running away
            case let .fleeAgent(taskBot):
                
                print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                
                radius = GameplayConfiguration.TaskBot.fleePathRadius
                (agentBehavior, debugPathPoints) = TaskBotBehavior.fleeBehaviour(forAgent: agent, fromAgent: taskBot, inScene: levelScene)
                debugColor = SKColor.purple
            
            // TaskBot is violent and being attacked, fight back
            case let .retaliate(taskBot):
                
                print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                
                radius = GameplayConfiguration.TaskBot.huntPathRadius
                (agentBehavior, debugPathPoints) = TaskBotBehavior.retaliateBehaviour(forAgent: agent, huntingAgent: taskBot, pathRadius: radius, inScene: levelScene)
                debugColor = SKColor.blue

            // TaskBot is inciting the crowd
            case .incite:
                
                print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                
                radius = GameplayConfiguration.TaskBot.wanderPathRadius
                (agentBehavior, debugPathPoints)  = TaskBotBehavior.wanderBehaviour(forAgent: agent, inScene: levelScene)
                debugColor = SKColor.gray
  
            // TaskBot is a protestor and is buying their wares
            case let .buyWares(target):
                
                print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                
                radius = GameplayConfiguration.TaskBot.wanderPathRadius
                (agentBehavior, debugPathPoints)  = TaskBotBehavior.huntBehaviour(forAgent: agent, huntingAgent: target, pathRadius: radius, inScene: levelScene)
                debugColor = SKColor.white
            
            // TaskBot is a criminal and is selling their wares
            case let .sellWares(target):
                
                print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                
//                radius = GameplayConfiguration.TaskBot.wanderPathRadius
//                (agentBehavior, debugPathPoints)  = TaskBotBehavior.huntBehaviour(forAgent: agent, huntingAgent: target, pathRadius: radius, inScene: levelScene)
//                (agentBehavior, debugPathPoints)  = TaskBotBehavior.wanderBehaviour(forAgent: agent, inScene: levelScene)
                
                let pathPoints = isGood ? goodPathPoints : badPathPoints
                radius = GameplayConfiguration.TaskBot.patrolPathRadius
                agentBehavior = TaskBotBehavior.patrolBehaviour(forAgent: agent, patrollingPathWithPoints: pathPoints, pathRadius: radius, inScene: levelScene, cyclical: true)
                debugPathPoints = pathPoints
                
                // Patrol paths are always closed loops, so the debug drawing of the path should cycle back round to the start.
                debugPathShouldCycle = true
//                debugColor = isGood ? SKColor.green : SKColor.purple
                
                debugColor = SKColor.yellow
            
            //TaskBot is a criminal and is vandalising
            case let .vandalise(position):
                
                print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                
                radius = GameplayConfiguration.TaskBot.returnToPatrolPathRadius
                (agentBehavior, debugPathPoints) = TaskBotBehavior.returnToPathBehaviour(forAgent: agent, returningToPoint: position, pathRadius: radius, inScene: levelScene)
                debugColor = SKColor.yellow
            
            //TaskBot is a criminal and is looting a building
            case let .loot(position):
                
                print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                
                radius = GameplayConfiguration.TaskBot.returnToPatrolPathRadius
                (agentBehavior, debugPathPoints) = TaskBotBehavior.returnToPathBehaviour(forAgent: agent, returningToPoint: position, pathRadius: radius, inScene: levelScene)
                debugColor = SKColor.yellow
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
        //Initialise for capturing touch movement
        self.gestureStartPoint = CGPoint.init()
        
        self.oldColour = SKColor.clear
        
        //Whether or not the 'TaskBot' is located at it's return position
        self.isHome = false
        
        // Whether or not the `TaskBot` is "good" when first created.
        self.isGood = isGood
        
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
        
        // Whether or not the protestor is arrested
        self.isArrested = false
        
        // Whether or not the protestor is criminal
        self.isCriminal = false

        //Whether or not the criminal is selling wares
        self.isSelling = false

        //Whether or not the protestor is buying wares
        self.isBuying = false
        
        // Whether or not the taskbot is protestor
        self.isProtestor = false
        
        //Whether or not the taskbot is hungry for alcohol and drugs
        self.isHungry = false
        
        //Whether or not the taskbot has wares on them
        self.hasWares = false
        
        // Whether or not the taskbot is consuming a product
        self.isConsuming = false
        
        //Whether or not the taskbot is Subservient to the Player
        self.isSubservient = false
        
        // Whether or not the taskbot is Police
        self.isPolice = false

        //Whether or not the taskbot needs help
        self.needsHelp = false
        
        // Whether or not the taskbot is Injured
        self.isInjured = false
        
        // The locations of the points that define the `TaskBot`'s "good" and "bad" patrol paths.
        self.goodPathPoints = goodPathPoints
        self.badPathPoints = badPathPoints
        
        /*
            A `TaskBot`'s initial mandate is always to patrol.
            Because a `TaskBot` is positioned at the appropriate path's start point when the level is created,
            there is no need for it to pathfind to the start of its path, and it can patrol immediately.
        */
        mandate = isGood ? .followGoodPatrolPath : .followGoodPatrolPath
//        mandate = .wander
        
        super.init()

        // Create a `TaskBotAgent` to represent this `TaskBot` in a steering physics simulation.
        let agent = TaskBotAgent()
        agent.delegate = self
        
        
        // Create a random speed for each taskbot
        let randomSource = GKRandomSource.sharedRandom()
        let diff = randomSource.nextUniform() // returns random Float between 0.0 and 1.0
        let speed = diff * GameplayConfiguration.TaskBot.maximumSpeedForIsGood(isGood: isGood) + GameplayConfiguration.TaskBot.minimumSpeed //Ensure it has some speed
        print("speed :\(speed.debugDescription)")
        
        // Configure the agent's characteristics for the steering physics simulation.
        agent.maxSpeed = speed
        //agent.maxSpeed = GameplayConfiguration.TaskBot.maximumSpeedForIsGood(isGood: isGood)
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
            SubservientTaskBotPercentageLowRule(),
            SubservientTaskBotPercentageMediumRule(),
            SubservientTaskBotPercentageHighRule(),
            SubservientTaskBotNearRule(),
            SubservientTaskBotMediumRule(),
            SubservientTaskBotFarRule(),
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
            PoliceBotFarRule(),
            CriminalTaskBotPercentageLowRule(),
            CriminalTaskBotPercentageMediumRule(),
            CriminalTaskBotPercentageHighRule(),
            CriminalTaskBotNearRule(),
            CriminalTaskBotMediumRule(),
            CriminalTaskBotFarRule(),
            SellerTaskBotNearRule(),
            SellerTaskBotMediumRule(),
            SellerTaskBotFarRule(),
            BuyerTaskBotNearRule(),
            BuyerTaskBotMediumRule(),
            BuyerTaskBotFarRule(),
            InjuredTaskBotPercentageLowRule(),
            InjuredTaskBotPercentageMediumRule(),
            InjuredTaskBotPercentageHighRule(),
            InjuredTaskBotNearRule(),
            InjuredTaskBotMediumRule(),
            InjuredTaskBotFarRule()
        ])
        addComponent(rulesComponent)
        rulesComponent.delegate = self
        
        /*
        if let emitterComponent = component(ofType: EmitterComponent.self)
        {
            emitterComponent.node.targetNode = renderComponent.node.scene
        }
        else { print("TaskBot does not have an emitter component.") }
        */
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("Deallocating TaskBot")
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
        //guard let emitterComponent = component(ofType: EmitterComponent.self) else { return }

        
        //print("entity: \(self.agent.debugDescription)  intelligenceComponent.stateMachine.currentState:\(String(describing: intelligenceComponent.stateMachine.currentState?.description))")
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
            //emitterComponent.node.targetNode = renderComponent.node.scene
            
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
        
        //A series of situation in which we prefer to Incite other Protestors
        let inciteTaskBotRaw = [
        
            //Protestors are nearby
//            ruleSystem.minimumGrade(forFacts: [
//                Fact.protestorTaskBotNear.rawValue as AnyObject
//                ]),
            
            
            ruleSystem.minimumGrade(forFacts: [
                Fact.protestorTaskBotNear.rawValue as AnyObject,
                Fact.policeBotFar.rawValue as AnyObject
                ]),
            
            ruleSystem.minimumGrade(forFacts: [
                Fact.protestorTaskBotMedium.rawValue as AnyObject,
                Fact.policeBotFar.rawValue as AnyObject
                ])
            
        ]
        
        let inciteTaskBot = inciteTaskBotRaw.reduce(0.0, max)
        
        
        // A Series of situation in which we prefer to Flee from a 'TaskBot'
        let fleeDangerousTaskBotRaw = [
        
            // "Police nearby" AND "Dangerous Protestors nearby"
            ruleSystem.minimumGrade(forFacts: [
//                Fact.policeBotNear.rawValue as AnyObject,
                Fact.dangerousTaskBotNear.rawValue as AnyObject
                ]),
            
            ruleSystem.minimumGrade(forFacts: [
//                Fact.policeBotMedium.rawValue as AnyObject,
                Fact.dangerousTaskBotMedium.rawValue as AnyObject
                ]),
            
            ruleSystem.minimumGrade(forFacts: [
    //          Fact.policeBotMedium.rawValue as AnyObject,
                Fact.dangerousTaskBotFar.rawValue as AnyObject
                ])
        ]
        let fleeDangerousTaskBot = fleeDangerousTaskBotRaw.reduce(0.0, max)
        
        
        // A Series of situation in which we prefer to Flee from a 'TaskBot'
        let fleePoliceTaskBotRaw = [
            
            // "Police nearby" AND "Dangerous Protestors nearby"
            ruleSystem.minimumGrade(forFacts: [
                Fact.policeBotNear.rawValue as AnyObject
            ]),
            
            ruleSystem.minimumGrade(forFacts: [
                Fact.policeBotMedium.rawValue as AnyObject
                ]),
            
            ruleSystem.minimumGrade(forFacts: [
                Fact.policeBotMedium.rawValue as AnyObject
                ])
        ]
        let fleePoliceTaskBot = fleePoliceTaskBotRaw.reduce(0.0, max)

        //print("fleeDangerousTaskBot: \(fleeDangerousTaskBot.description), fleeTaskBotRaw: \(fleeTaskBotRaw.description) ")

        
        //A series of situation in which we prefer to Incite other Protestors
        let supportTaskBotRaw = [
            
            //Police are in trouble are nearby
            ruleSystem.minimumGrade(forFacts: [
                Fact.policeBotInTroubleNear.rawValue as AnyObject
                ]),
            
            //Police are in trouble are medium distance
            ruleSystem.minimumGrade(forFacts: [
                Fact.policeBotInTroubleMedium.rawValue as AnyObject
                ]),
            
            //Police are in trouble are far away
            ruleSystem.minimumGrade(forFacts: [
                Fact.policeBotInTroubleFar.rawValue as AnyObject
                ])
        ]
        
        let supportPoliceBot = supportTaskBotRaw.reduce(0.0, max)
//        print("supportPoliceBot: \(supportPoliceBot.description), supportPoliceBotRaw: \(supportTaskBotRaw.description) ")

        
        //A series of situation in which we prefer to hunt the criminal
        let huntCriminalTaskBotRaw = [
            
            //Police are in trouble are nearby
            ruleSystem.minimumGrade(forFacts: [
                Fact.criminalTaskBotNear.rawValue as AnyObject
                ]),
            
            //Police are in trouble are medium distance
            ruleSystem.minimumGrade(forFacts: [
                Fact.criminalTaskBotMedium.rawValue as AnyObject
                ]),
            
            //Police are in trouble are far away
            ruleSystem.minimumGrade(forFacts: [
                Fact.criminalTaskBotFar.rawValue as AnyObject
                ])
        ]
        
        let huntCriminalTaskBot = huntCriminalTaskBotRaw.reduce(0.0, max)
 //       print("huntCriminalTaskBot: \(huntCriminalTaskBot.description), huntCriminalTaskBotRaw: \(huntCriminalTaskBotRaw.description) ")
        
        
        //A series of situation in which we hunt sellers
        let huntSellerTaskBotRaw = [
            
            //Police are in trouble are nearby
            ruleSystem.minimumGrade(forFacts: [
                Fact.sellerTaskBotNear.rawValue as AnyObject
                ]),
            
            //Police are in trouble are medium distance
            ruleSystem.minimumGrade(forFacts: [
                Fact.sellerTaskBotMedium.rawValue as AnyObject
                ]),

            //Police are in trouble are far away
            ruleSystem.minimumGrade(forFacts: [
                Fact.sellerTaskBotFar.rawValue as AnyObject
                ])
        ]
        
        let huntSellerTaskBot = huntSellerTaskBotRaw.reduce(0.0, max)
//        print("huntSellerTaskBot: \(huntSellerTaskBot.description), huntSellerTaskBotRaw: \(huntSellerTaskBotRaw.description) ")

        
        //A series of situation in which we hunt buyers
        let huntBuyerTaskBotRaw = [
            
            //A buyer is nearby and Police are far away
            ruleSystem.minimumGrade(forFacts: [
                Fact.buyerTaskBotNear.rawValue as AnyObject
//                Fact.policeBotFar.rawValue as AnyObject
                ])//,
            
            //A buyer is medium far away and Police are nearby
//            ruleSystem.minimumGrade(forFacts: [
//                Fact.buyerTaskBotMedium.rawValue as AnyObject
////                Fact.policeBotNear.rawValue as AnyObject
//                ]),

            //A buyer is far away and Police are nearby
//            ruleSystem.minimumGrade(forFacts: [
//                Fact.buyerTaskBotFar.rawValue as AnyObject
////                Fact.policeBotNear.rawValue as AnyObject
//                ])
        ]
        
        let huntBuyerTaskBot = huntBuyerTaskBotRaw.reduce(0.0, max)
//        print("huntBuyerTaskBot: \(huntBuyerTaskBot.description), huntBuyerTaskBotRaw: \(huntBuyerTaskBotRaw.description) ")
        
        
      
        
        // A series of situations in which we prefer this `TaskBot` to hunt the player.
        let huntPlayerBotRaw = [
            // "Number of Police TaskBots is high" AND "Player is nearby".
            ruleSystem.minimumGrade(forFacts: [
                Fact.policeTaskBotPercentageHigh.rawValue as AnyObject,
                Fact.playerBotNear.rawValue as AnyObject
            ])
        ]

        // Find the maximum of the minima from above.
        let huntPlayerBot = huntPlayerBotRaw.reduce(0.0, max)
        //print("huntPlayerBot: \(huntPlayerBot.description), huntPlayerBotRaw: \(huntPlayerBotRaw.description) ")
        
        
        // A series of situations in which we prefer this 'TaskBot' to hunt the nearest "Dangerous Protestor" TaskBot
        // Police will only hunt dangerous if they have enough Police
        let huntDangerousProtestorTaskBotRaw = [
            
            // "Number Police TaskBots is high" AND "Dangerous Protestor 'TaskBot' is nearby"
            ruleSystem.minimumGrade(forFacts: [

//                Fact.policeTaskBotPercentageLow.rawValue as AnyObject,
                Fact.dangerousTaskBotNear.rawValue as AnyObject,
                ]),
            
            // "Number of Police TaskBots is medium" AND "Nearest Dangerous Protestor TaskBot is at medium distance"
            ruleSystem.minimumGrade(forFacts: [
                //Fact.policeTaskBotPercentageMedium.rawValue as AnyObject,
//                Fact.policeTaskBotPercentageLow.rawValue as AnyObject,
                Fact.dangerousTaskBotMedium.rawValue as AnyObject
                ]),
            
            // "Number of Police TaskBots is medium" AND "Nearest Dangerous Protestor is at medium away"
//            ruleSystem.minimumGrade(forFacts: [
//                Fact.policeTaskBotPercentageMedium.rawValue as AnyObject,
//                Fact.dangerousTaskBotMedium.rawValue as AnyObject
//                ]),
//
            // "Number of Police TaskBots is high" AND "Nearest Dangerous Protestor is at far away"
            ruleSystem.minimumGrade(forFacts: [
//                Fact.policeTaskBotPercentageHigh.rawValue as AnyObject,
                Fact.dangerousTaskBotFar.rawValue as AnyObject
                ]),
        ]
        
        // Find the maximum of the minima from above.
        let huntDangerousProtestorBot = huntDangerousProtestorTaskBotRaw.reduce(0.0, max)
//        print("huntDangerousTaskBot: \(huntDangerousProtestorBot.description), huntDangerousTaskBotRaw: \(huntDangerousProtestorTaskBotRaw.description) ")
        
        
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
        //print("huntTaskBot: \(huntTaskBot.description), huntTaskBotRaw: \(huntTaskBotRaw.description) ")
        
        
        // A series of situations in which we prefer this `TaskBot` to hunt the nearest "Police" TaskBot.
        let attackPoliceBotRaw = [
        
            // Police TaskBot is nearby and their are not many Police
            ruleSystem.minimumGrade(forFacts: [
                Fact.policeBotNear.rawValue as AnyObject,
                Fact.policeTaskBotPercentageLow.rawValue as AnyObject
                ]),
            
            // Police TaskBot is nearby and their are some Police, but there are dangerous protestors nearby for backup
            ruleSystem.minimumGrade(forFacts: [
                Fact.policeBotNear.rawValue as AnyObject,
                Fact.policeTaskBotPercentageMedium.rawValue as AnyObject,
                Fact.dangerousTaskBotNear.rawValue as AnyObject
                ])
            
            // Police TaskBot is medium proximity and their are few Police
//            ruleSystem.minimumGrade(forFacts: [
//                Fact.policeBotMedium.rawValue as AnyObject,
//                Fact.policeTaskBotPercentageLow.rawValue as AnyObject
//                ])
        ]
        
        //Find the maximum of the minum from above
        let attackPoliceBot = attackPoliceBotRaw.reduce(0.0, max)
        //print("attackPoliceBot: \(attackPoliceBot)")
        
        
        // Protestor is arrested and should be moved to the meatwagaon
        if self.isArrested
        {
            //print("Moving prisoner to meatwagon")
            
            mandate = .lockupPrisoner
            
            print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
        }
        
        //Protestor is scared and wants to run away
        else if self.isScared && self.isProtestor && fleePoliceTaskBot > 0.0
        {
            print("Protestor Fleeing from Police")
            
            // The rules provided greated motivation to flee
            guard let policeTaskBot = state.nearestPoliceTaskBotTarget?.target.agent else { return }

            mandate = .fleeAgent(policeTaskBot)
            
            print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
        }
            
        // Police is scared and a Dangerous or is nearby, leg it
//        else if self.isScared && fleeDangerousTaskBot > 0
        else if self.isScared && self.isPolice && fleeDangerousTaskBot > 0.0
        {
            print("Police Fleeing from dangerous protestor")
            
            // The rules provided greated motivation to flee
            guard let dangerousTaskBot = state.nearestDangerousTaskBotTarget?.target.agent else { return }
            mandate = .fleeAgent(dangerousTaskBot)
            
            print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
        }
        
            
        // Protestor has been attacked and is now retaliating
        else if self.isRetaliating && self.isProtestor
        {
            //print("Retaliating")
            guard let targetTaskbot = state.nearestPoliceTaskBotTarget?.target.agent else { return }
            mandate = .retaliate(targetTaskbot)
            self.isSubservient = false
            
            print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
        }
         
        // Police has been attacked and is now retaliating
        else if self.isRetaliating && self.isPolice
        {
            //print("Retaliating")
            guard let targetTaskbot = state.nearestDangerousTaskBotTarget?.target.agent else { return }
            mandate = .retaliate(targetTaskbot)
            
            print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
        }
            
        //TaskBot is Violent and Police are nearby, go fuck them up
        else if self.isProtestor && self.isViolent && attackPoliceBot > 0.0
        {
            //print("Attacking Police")
            guard let dangerousTaskBot = state.nearestPoliceTaskBotTarget?.target.agent else { return }
            mandate = .huntAgent(dangerousTaskBot)
            
            print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
        }
         
        //TaskBot is Criminal and wants to sell wares
        else if self.isCriminal && self.isSelling// && huntBuyerTaskBot > 0.5
        {
//            guard let protestorBot = state.nearestBuyerTaskBotTarget?.target.agent else { return }
            mandate = .sellWares
            
            print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
        }

        //TaskBot is Protestor and and has bought wares, has not reached home, return to starting position
        else if self.isProtestor && self.hasWares && !self.isHome
        {
            guard let protestorBot = self as? ProtestorBot else { return }
            guard let buyingWaresComponent = protestorBot.component(ofType: BuyingWaresComponent.self) else { return }
            
            mandate = .returnHome(buyingWaresComponent.returnPosition)
        }
            
        //TaskBot is Protestor and wants to buy wares and seller nearby
        else if self.isProtestor && !self.isSubservient && self.isHungry && huntSellerTaskBot > 0.7
        {
            guard let criminalBot = state.nearestSellerTaskBotTarget?.target.agent else { return }
            mandate = .buyWares(criminalBot)
            
            print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
        }
        

            
        //TaskBot is Protestor and drinking, make them crowd together
//        else if self.isProtestor && self.isConsuming
//        {
//            mandate = .crowd()
//            
//            print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
//        }
        
        //TaskBot is Police and another Policeman needs help, go support them
        else if self.isPolice && supportPoliceBot > 0.5
        {
//            print("Support another Police")
            guard let supportPoliceBot = state.nearestPoliceTaskBotTarget?.target.agent else { return }
            mandate = .supportPolice(supportPoliceBot)
            
            print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
        }
            
            
        //Protestor is subvervient and protestors are nearby
        else if self.isSubservient && inciteTaskBot > 0.0
        {
//            print("Inciting others")
            mandate = .incite
            
            print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
        }
            
        // TaskBot is Police and active (alive) and a dangerous bot is detected, attack it
        else if self.isPolice && self.isActive && huntDangerousProtestorBot > 0.0
        {
            // The rules provided greater motivation to hunt the nearest Dangerous Protestor TaskBot. Ignore any motivation to hunt the PlayerBot.
            
            //print("Hunt the nearest dangerous bot")
            guard let dangerousTaskBot = state.nearestDangerousTaskBotTarget?.target.agent else { return }
            mandate = .huntAgent(dangerousTaskBot)
            
            print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
        }
        
        // PROBABLY DELETE THIS LATER
        // An active PoliceBot is near a Protestor, attack them
//        else if self.isPolice && self.isActive && huntTaskBot > huntPlayerBot
//        {
//            //print("Hunt the nearest Protestor: \(state.nearestProtestorTaskBotTarget!.target.agent.debugDescription)")
//
//            // The rules provided greater motivation to hunt the nearest good TaskBot. Ignore any motivation to hunt the PlayerBot.
//            mandate = .huntAgent(state.nearestProtestorTaskBotTarget!.target.agent)
//        }
        else
        {
//            print("mandate :\(mandate)")
            
            // The rules provided no motivation to hunt, retaliate or flee
            switch mandate
            {
                case .crowd:
                    print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
//                    print("Crowding")
                    break
                
//                case .sellWares(state.nearestBuyerTaskBotTarget?.target.agent):
                
                case .incite:
                    print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                    break
                
                case .sellWares:
                    print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
//                    print("selling wares")
                    break
                
                case .buyWares(state.nearestSellerTaskBotTarget?.target.agent):
                    print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
//                    print("buying Wares")
                    break
                
                case .wander:
                    print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
//                    print("wandering")
                    // The taskbot is already wandering, so no update is needed
                    break
                
                case .playerMovedTaskBot:
                    print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
//                    print("playerMovedTaskbot")
                    // The taskbot is already on the player designated path, so no update is needed
                    break
                
                case .followGoodPatrolPath:
                    print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
//                    print("followGoodPatrolPath")
                    //The taskbot is already on its "good" patrol path, so no update is needed
                    break
                
                case .followBadPatrolPath:
//                    print("followBadPatrolPath")
                    print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                    // The `TaskBot` is already on its "bad" patrol path, so no update is needed.
                    break
                
                default:
                    // Send the `TaskBot` to the closest point on its "bad" patrol path.
                    let closestPointOnBadPath = closestPointOnPath(path: badPathPoints)
                    mandate = .returnToPositionOnPath(float2(closestPointOnBadPath))
                    print("TaskBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
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
    
    // Sets the `TaskBot` node position to match the `GKAgent` position (minus an offset).
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
    
    //@property (nonatomic) CGPoint gestureStartPoint;
    var gestureStartPoint: CGPoint
    
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?, scene: LevelScene)
    {
        //print ("touchesBegan")
        
        //Delete the existing path
        playerPathPoints.removeAll()
        
        for touch in touches
        {
            let touchLocation = touch.location(in: scene)
            
            //Getting the position of the touch
            self.gestureStartPoint = touchLocation
        }
    }

    
    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?, scene: LevelScene)
    {
        for touch in touches
        {
            //Get the current position of the user's finger
            let touchLocation = touch.location(in: scene)
            
            //Calculate how far the user’s finger has moved both horizontally and vertically from previous position
            //fabsf returns absolute value of float
            let deltaX = fabsf(Float(self.gestureStartPoint.x - touchLocation.x));
            let deltaY = fabsf(Float(self.gestureStartPoint.y - touchLocation.y));
            
            //check to see if the user has moved far enough in one direction
            //without having moved too far in the other to constitute a swipe.
            
            let kMinimumGestureLength: Float = 10.0
            let kMaximumVariance: Float = 100.0
            
            if (deltaX >= kMinimumGestureLength && deltaY <= kMaximumVariance)
            {
                //Horizontal swipe detected
                
                recordPlayerPath(location: touchLocation)
            }
            else if (deltaY >= kMinimumGestureLength && deltaX <= kMaximumVariance)
            {
                //Vertical swipe detected
                recordPlayerPath(location: touchLocation)
            }
            
            //Set the previous position to current position
            self.gestureStartPoint = touchLocation
        }
    }
    
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?, scene: LevelScene) {}
    
    func recordPlayerPath(location: CGPoint)
    {
        //Reduce the number of recorded path points
        playerPathPoints.append(location)
        
        //print("playerPathPoints: \(playerPathPoints.count)")
    }
    
    func startAnimation()
    {
        let expandAction = SKAction.scale(to: 1.5, duration: 0.33)
        let contractAction = SKAction.scale(to: 0.7, duration: 0.33)
        let pulsateAction = SKAction.repeatForever(
            SKAction.sequence([expandAction, contractAction]))
        
        guard let animationComponent = self.component(ofType: AnimationComponent.self) else { return }
        animationComponent.node.run(pulsateAction)
        
        //guard let spriteComponent = self.component(ofType: SpriteComponent.self) else { return }
        //spriteComponent.node.run(pulsateAction)
    }
    
    func stopAnimation()
    {
        guard let animationComponent = self.component(ofType: AnimationComponent.self) else { return }
        animationComponent.node.removeAllActions()
        
        //guard let spriteComponent = self.component(ofType: SpriteComponent.self) else { return }
        //spriteComponent.node.removeAllActions()
    }
}

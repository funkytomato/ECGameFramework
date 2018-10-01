/*
//
//  PoliceBot.swift
//  ECGameFramework
//
//  Created by Jason Fry on 19/04/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
A ground-based `TaskBot` with a distance attack. This `GKEntity` subclass allows for convenient construction of an entity with appropriate `GKComponent` instances.
*/

import SpriteKit
import GameplayKit


class PoliceBot: TaskBot, ChargeComponentDelegate, ResistanceComponentDelegate, HealthComponentDelegate, ResourceLoadableType
{

    

    // MARK: Resistance Component Delegate
    func resistanceComponentDidGainResistance(resistanceComponent: ResistanceComponent)
    {
        guard let resistanceComponent = component(ofType: ResistanceComponent.self) else { return }
        
        if resistanceComponent.resistance > 40.0
        {
            self.needsHelp = false
        }
    }
    
    

    func resistanceComponentDidLoseResistance(resistanceComponent: ResistanceComponent)
    {
//        guard let intelligenceComponent = component(ofType: IntelligenceComponent.self) else { return }
        guard let resistanceComponent = component(ofType: ResistanceComponent.self) else { return }
        
        resistanceComponent.isTriggered = true
//        intelligenceComponent.stateMachine.enter(PoliceBotHitState.self)
        
        //Policeman is in trouble and needs backup
        if resistanceComponent.resistance < 70.0
        {
            self.needsHelp = true
        }
    }
    
    // MARK: ChargeComponentDelegate
    func chargeComponentDidGainCharge(chargeComponent: ChargeComponent)
    {
        print("Add charge to PoliceBot")
    }
    
    func chargeComponentDidLoseCharge(chargeComponent: ChargeComponent)
    {
        guard let intelligenceComponent = component(ofType: IntelligenceComponent.self) else { return }
        
        isGood = !chargeComponent.hasCharge
        
        if !isGood
        {
            intelligenceComponent.stateMachine.enter(TaskBotZappedState.self)
        }
    }

    // MARK: HealthComponentDelegate
    func healthComponentDidAddHealth(healthComponent: HealthComponent)
    {
//        guard let healthComponent = component(ofType: HealthComponent.self) else { return }
    }
    

    func healthComponentDidLoseHealth(healthComponent: HealthComponent)
    {
        guard let resistanceComponent = component(ofType: ResistanceComponent.self) else { return }
        guard let intelligenceComponent = component(ofType: IntelligenceComponent.self) else { return }
        
        //Police has no more shield, take damage
        if !resistanceComponent.isFullyResistanced
        {
            //if !healthComponent.hasHealth
            if healthComponent.health < 20.0
            {
//                print("current state: \(intelligenceComponent.stateMachine.currentState.debugDescription) isGood: \(self.isGood)")
                
                //intelligenceComponent.stateMachine.enter(PoliceBotRechargingState.self)
                intelligenceComponent.stateMachine.enter(TaskBotInjuredState.self)
            }
            else
            {
                intelligenceComponent.stateMachine.enter(PoliceBotHitState.self)
            }
        }
    }
    
    // MARK: Static Properties
    
    var texture = SKTexture()
    
    /// Used to determine the location on the `PlayerBot` where the beam starts.
    var handOffset = GameplayConfiguration.PoliceBot.handOffset
    
//    var physicsJoint = SKPhysicsJointLimit()
    
    /// The size to use for the `PoliceBot`s animation textures.
    static var textureSize = CGSize(width: 50.0, height: 50.0)
    
    
    /// The size to use for the `PoliceBot`'s shadow texture.
    //static var shadowSize = CGSize(width: 50.0, height: 10.0)
    
    /// The actual texture to use for the `PoliceBot`'s shadow.
    static var shadowTexture: SKTexture = {
        let shadowAtlas = SKTextureAtlas(named: "Shadows")
        return shadowAtlas.textureNamed("GroundBotShadow")
    }()
    
    
    /// The offset of the `PoliceBot`'s shadow from its center position.
    //static var shadowOffset = CGPoint(x: 0.0, y: -40.0)
    
    /// The animations to use when a `PoliceBot` is in its "good" state.
    static var goodAnimations: [AnimationState: Animation]?
    
    /// The animations to use when a `PoliceBot` is in its "bad" state.
    static var badAnimations: [AnimationState: Animation]?
    
    var tazerPoweredDown = false

    
    // MARK: TaskBot Properties
    
    override var goodAnimations: [AnimationState: Animation]
    {
        return PoliceBot.goodAnimations!
    }
    
    override var badAnimations: [AnimationState: Animation]
    {
        return PoliceBot.badAnimations!
    }
    
    
    // MARK: PoliceBot Properties
    
    /// The position in the scene that the `PoliceBot` should target with its attack.
    var targetPosition: float2?
    
    // MARK: Initialization
    
    required init(id: Int, temperamentState: String, isGood: Bool, goodPathPoints: [CGPoint], badPathPoints: [CGPoint])
    {
        super.init(id: id, isGood: isGood, goodPathPoints: goodPathPoints, badPathPoints: badPathPoints)
        
        //TaskBot is Police
        self.isPolice = true
        

        // Configure the agent's characteristics for the steering physics simulation.
        agent.maxSpeed = GameplayConfiguration.TaskBot.maximumSpeedForIsGood(isGood: isGood)
        agent.mass = GameplayConfiguration.PoliceBot.agentMass
        
        //Put PoliceBots on patrol
        mandate = isGood ? .followGoodPatrolPath : .followGoodPatrolPath
        
        
        // Determine initial animations and charge based on the initial state of the bot.
        let initialAnimations: [AnimationState: Animation]
        let initialCharge: Double
        let initialHealth: Double
        let initialResistance: Double
        let initialTemperament: Double
        
        if isGood
        {

            guard let goodAnimations = PoliceBot.goodAnimations else {
                fatalError("Attempt to access PoliceBot.goodAnimations before they have been loaded.")
            }
            initialAnimations = goodAnimations
            initialCharge = 100.0
            initialHealth = 100.0
            initialResistance = 100.0
            initialTemperament = 0.0
            
            texture = SKTexture(imageNamed: "PoliceBot")
        }
        else
        {

            
            guard let badAnimations = PoliceBot.badAnimations else {
                fatalError("Attempt to access PoliceBot.badAnimations before they have been loaded.")
            }
            initialAnimations = badAnimations
            initialCharge = GameplayConfiguration.PoliceBot.maximumCharge
            initialHealth = GameplayConfiguration.PoliceBot.maximumHealth
            initialResistance = GameplayConfiguration.PoliceBot.maximumResistance
            initialTemperament = GameplayConfiguration.PoliceBot.maximumTemperament
            
            texture = SKTexture(imageNamed: "PoliceBotBad")
        }
        
        
        
        // Create components that define how the entity looks and behaves.
        let renderComponent = RenderComponent()
        addComponent(renderComponent)
        
        let orientationComponent = OrientationComponent()
        addComponent(orientationComponent)
        
        let spriteComponent = SpriteComponent(entity: self, texture: texture, textureSize: PoliceBot.textureSize)
        addComponent(spriteComponent)
        
        
        //let shadowComponent = ShadowComponent(texture: PoliceBot.shadowTexture, size: PoliceBot.shadowSize, offset: PoliceBot.shadowOffset)
        //addComponent(shadowComponent)
        
        let animationComponent = AnimationComponent(textureSize: PoliceBot.textureSize, animations: initialAnimations)
        addComponent(animationComponent)
        
        let intelligenceComponent = IntelligenceComponent(states: [
            TaskBotAgentControlledState(entity: self),
            TaskBotFleeState(entity: self),
            TaskBotInjuredState(entity: self),
            TaskBotZappedState(entity: self),
            PoliceBotRotateToAttackState(entity: self),
            PoliceBotPreAttackState(entity: self),
            PoliceBotAttackState(entity: self),
            PoliceArrestState(entity: self),
            PoliceDetainState(entity: self),
            PoliceBotHitState(entity: self),
            PoliceBotSupportState(entity: self),
            PoliceBotFormWallState(entity: self),
            PoliceBotInWallState(entity: self)
            ])
        addComponent(intelligenceComponent)
        
        
        let temperamentComponent = TemperamentComponent(initialState: temperamentState, temperament: initialTemperament, maximumTemperament: Double(GameplayConfiguration.ProtestorBot.maximumTemperament), displaysTemperamentBar: false)
        addComponent(temperamentComponent)
        

        
        let physicsBody = SKPhysicsBody(circleOfRadius: GameplayConfiguration.TaskBot.physicsBodyRadius, center: GameplayConfiguration.TaskBot.physicsBodyOffset)
        physicsBody.restitution = 100.0
        let physicsComponent = PhysicsComponent(physicsBody: physicsBody, colliderType: .TaskBot)
        addComponent(physicsComponent)
        
        
        let jointComponent = JointComponent(entity: self)
        addComponent(jointComponent)
        
        let wallComponent = WallComponent(entity: self, minimum: GameplayConfiguration.Wall.minimumWallSize, maximum: GameplayConfiguration.Wall.maximumWallSize)
        addComponent(wallComponent)
        
        let chargeComponent = ChargeComponent(charge: initialCharge, maximumCharge: GameplayConfiguration.PoliceBot.maximumCharge, displaysChargeBar: false)
        chargeComponent.delegate = self
        addComponent(chargeComponent)
        
        let healthComponent = HealthComponent(health: initialHealth, maximumHealth: GameplayConfiguration.PoliceBot.maximumHealth, displaysHealthBar: false)
        healthComponent.delegate = self
        addComponent(healthComponent)
        
        let resistanceComponent = ResistanceComponent(resistance: initialResistance, maximumResistance: GameplayConfiguration.PoliceBot.maximumResistance, displaysResistanceBar: false)
        resistanceComponent.delegate = self
        addComponent(resistanceComponent)
        
        // `BeamComponent` implements the beam that a `PlayerBot` fires at "bad" `TaskBot`s.
        let tazerComponent = TazerComponent()
        addComponent(tazerComponent)
        
        let movementComponent = MovementComponent()
        addComponent(movementComponent)
        
        // Connect the `PhysicsComponent` and the `RenderComponent`.
        renderComponent.node.physicsBody = physicsComponent.physicsBody
        
        // Connect the 'SpriteComponent' to the 'RenderComponent'
        renderComponent.node.addChild(spriteComponent.node)
        
        //print("scene:\(String(describing: renderComponent.node.scene?.description))")
        
        /*
        let emitterComponent = EmitterComponent(particleName: "Trail.sks")
        addComponent(emitterComponent)
        renderComponent.node.addChild(emitterComponent.node)
 */
 
        // Connect the `RenderComponent` and `ShadowComponent` to the `AnimationComponent`.
        renderComponent.node.addChild(animationComponent.node)
        //animationComponent.shadowNode = shadowComponent.node
        
        // Specify the offset for beam targeting.
        beamTargetOffset = GameplayConfiguration.PoliceBot.beamTargetOffset
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(id: Int, isGood: Bool, goodPathPoints: [CGPoint], badPathPoints: [CGPoint]) {
        fatalError("init(isGood:goodPathPoints:badPathPoints:) has not been implemented")
    }
    
    
    deinit {
//        print("Deallocating PoliceBot")
    }
    
    // MARK: ContactableType
    
    override func contactWithEntityDidBegin(_ entity: GKEntity)
    {
        super.contactWithEntityDidBegin(entity)
        
        // Check if Protestor on form wall trigger node
//        guard let physicsComponent = entity.component(ofType: PhysicsComponent.self) else { return }
//        let contactedBodies = physicsComponent.physicsBody.allContactedBodies()
//        for contactedBody in contactedBodies
//        {
////            guard let entity = contactedBody.node?.entity else { continue }
//            if contactedBody.node?.name == "createWall"
//            {
//                print("creatWall detected")
//                entity.component(ofType: WallComponent.self)?.isTriggered = true
//            }
//        }
        
//        if let targetBot = entity as? PoliceBot,
//            let targetPhysicsComponent = targetBot.component(ofType: PhysicsComponent.self)
//        {
//            if targetPhysicsComponent.physicsBody.node?.name == "createWall"
//            {
//                print("creatWall detected")
//            }
//        }
        
//        guard let targetBot = entity as? TaskBot else { return }
//        
////        if let formWallState = self.component(ofType: IntelligenceComponent.self)?.stateMachine.currentState as? PoliceBotFormWallState
////        {
//        
//        // Check entity is Police, has less than 2 connections and is connecting with a PoliceBot who has less than 2 connections and has requested to build a wall
//            if self.isPolice && self.connections < 2 /*&& !self.isWall*/ &&
//                targetBot.isPolice && targetBot.connections < 2 && self.requestWall /* && !targetBot.isWall */
//            {
//                //Check other PoliceBot is not in wall.
//                
//                let policeBotB = entity as? PoliceBot
//                if !policeBotB!.isWall && policeBotB!.connections < 2
//                {
//                
//                    let policeBotBPhysicsComponent = policeBotB?.component(ofType: PhysicsComponent.self)
//                    let policeBRenderComponent = policeBotB?.component(ofType: RenderComponent.self)
//                    let entityB = policeBRenderComponent?.entity
//                    
//                    // Get the Physics Component for each entity
//                    let policeBotA = agent.entity as? PoliceBot
//                    let policeBotAPhysicsComponent = policeBotA?.component(ofType: PhysicsComponent.self)
//                    let policeARenderComponent = policeBotA?.component(ofType: RenderComponent.self)
//                    let entityA = policeARenderComponent?.entity
//                    
//                  
//                    //Connect the two Taskbots together like a rope if forming a wall
//                    guard let intelligenceComponent = self.component(ofType: IntelligenceComponent.self) else { return }
//                    guard ((intelligenceComponent.stateMachine.currentState as? PoliceBotFormWallState) == nil) else { return }
//                    guard let jointComponent = self.component(ofType: JointComponent.self) else { return }
//                    
//                    guard let policeBot = entity as? PoliceBot else { return }
//                    if !jointComponent.isTriggered && policeBot.isPolice
//                    {
//                        jointComponent.setEntityB(targetEntity: policeBotB!)
//                    }
//                    
//                    policeBotA!.component(ofType: WallComponent.self)?.isTriggered = true
//                    policeBotB!.component(ofType: WallComponent.self)?.isTriggered = true
//                }
//            }
////        }
        
        
        //If touching entity is attacking, start the arresting process
        //print("PoliceBot currentState :\(entity.component(ofType: IntelligenceComponent.self)?.stateMachine.currentState.debugDescription)")
        
        if let attackState = self.component(ofType: IntelligenceComponent.self)?.stateMachine.currentState as? PoliceBotAttackState
        {
            attackState.applyDamageToEntity(entity: entity)
        }
    }
    
    // MARK: RulesComponentDelegate
    
    override func rulesComponent(rulesComponent: RulesComponent, didFinishEvaluatingRuleSystem ruleSystem: GKRuleSystem)
    {
        super.rulesComponent(rulesComponent: rulesComponent, didFinishEvaluatingRuleSystem: ruleSystem)

        guard let scene = component(ofType: RenderComponent.self)?.node.scene else { return }
        guard let intelligenceComponent = component(ofType: IntelligenceComponent.self) else { return }
        guard let agentControlledState = intelligenceComponent.stateMachine.currentState as? TaskBotAgentControlledState else { return }
        
        // 1) Check if enough time has passed since the `PoliceBot`'s last attack.
        guard agentControlledState.elapsedTime >= GameplayConfiguration.TaskBot.delayBetweenAttacks else { return }
        
        print("PoliceBot mandate: \(mandate)")
        
        //Check the current mandate and set the appropriate values
        switch mandate
        {
            /*
             A `PoliceBot` will attack a location in the scene if the following conditions are met:
             1) Enough time has elapsed since the `PoliceBot` last attacked a target.
             2) The `PoliceBot` is hunting a target.
             3) The target is within the `PoliceBot`'s attack range.
             4) There is no scenery between the `PoliceBot` and the target.
             */
            case let .huntAgent(targetAgent):
                
//                print("PoliceBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                
                // 3) Check if the target is within the `PoliceBot`'s attack range.
                guard distanceToAgent(otherAgent: targetAgent) <= GameplayConfiguration.TaskBot.maximumAttackDistance else { return }
                
                // 4) Check if any walls or obstacles are between the `PoliceBot` and its hunt target position.
                var hasLineOfSight = true
                
                scene.physicsWorld.enumerateBodies(alongRayStart: CGPoint(agent.position), end: CGPoint(targetAgent.position)) { body, _, _, stop in
                    if ColliderType(rawValue: body.categoryBitMask).contains(.Obstacle) {
                        hasLineOfSight = false
                        stop.pointee = true
                    }
                }
                
                if !hasLineOfSight { return }
                
                // The `PoliceBot` is ready to attack the `targetAgent`'s current position.
                targetPosition = targetAgent.position
                intelligenceComponent.stateMachine.enter(PoliceBotRotateToAttackState.self)
            
            case let .supportPolice(targetAgent):
                
                print("PoliceBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                intelligenceComponent.stateMachine.enter(PoliceBotSupportState.self)
                targetPosition = targetAgent.position
            
            case .initateWall:
                print("PoliceBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
            
                intelligenceComponent.stateMachine.enter(PoliceBotFormWallState.self)
            
            
            case let .formWall(targetAgent):
                print("PoliceBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                
                intelligenceComponent.stateMachine.enter(PoliceBotFormWallState.self)
                targetPosition = targetAgent.position
                
//                let scene = renderComponent.node.scene as? LevelScene
//                targetPosition = scene?.playerBot.agent.position
                
            
                self.isSupporting = true

            case let .inWall(targetAgent):
                print("PoliceBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")

                intelligenceComponent.stateMachine.enter(PoliceBotInWallState.self)
                targetPosition = targetAgent.position
                
//                let scene = renderComponent.node.scene as? LevelScene
//                targetPosition = scene?.playerBot.agent.position
            
            
            case let .fleeAgent(targetAgent):
                
//                print("PoliceBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                intelligenceComponent.stateMachine.enter(TaskBotFleeState.self)
                targetPosition = targetAgent.position
            
            default:
                print("PoliceBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                break
//                print("Hmm, do something hereE?")
        }
    }
    

    
    
    // MARK: ResourceLoadableType
    
    static var resourcesNeedLoading: Bool
    {
        return goodAnimations == nil || badAnimations == nil
    }
    
    static func loadResources(withCompletionHandler completionHandler: @escaping () -> ())
    {
        // Load `TaskBot`s shared assets.
        super.loadSharedAssets()
        
        let PoliceBotAtlasNames = [
            "Arresting",
            "HoldingPrisoner",
            
            "PoliceAttack",
            "PoliceHit",
            
            "PoliceIdle",
            "PolicePatrol",
            "PoliceInActive",
            "PoliceZapped",
            "PoliceInjured",
            
            
            "AngryPolice",
            "CalmPolice",
            "ScaredPolice",
            "UnhappyPolice",
            "ViolentPolice",
        ]
        
        /*
         Preload all of the texture atlases for `PoliceBot`. This improves
         the overall loading speed of the animation cycles for this character.
         */
        SKTextureAtlas.preloadTextureAtlasesNamed(PoliceBotAtlasNames) { error, PoliceBotAtlases in
            if let error = error {
                fatalError("Police can not load One or more texture atlases could not be found: \(error)")
            }
            
            /*
             This closure sets up all of the `PoliceBot` animations
             after the `PoliceBot` texture atlases have finished preloading.
             */
            
            goodAnimations = [:]
            goodAnimations![.arresting] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[0], withImageIdentifier: "Arresting", forAnimationState: .arresting)
            
            goodAnimations![.holdingPrisoner] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[1], withImageIdentifier: "HoldingPrisoner", forAnimationState: .holdingPrisoner)
            
            goodAnimations![.attack] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[2], withImageIdentifier: "PoliceAttack", forAnimationState: .attack)
            
            goodAnimations![.hit] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[3], withImageIdentifier: "PoliceHit", forAnimationState: .hit)
 
            goodAnimations![.idle] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[4], withImageIdentifier: "PoliceIdle", forAnimationState: .idle)
            
            goodAnimations![.patrol] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[5], withImageIdentifier: "PolicePatrol", forAnimationState: .patrol)
            
            goodAnimations![.walkForward] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[6], withImageIdentifier: "PolicePatrol", forAnimationState: .walkForward)
            
            goodAnimations![.inactive] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[6], withImageIdentifier: "PoliceInActive", forAnimationState: .inactive)
            
            goodAnimations![.zapped] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[7], withImageIdentifier: "PoliceZapped", forAnimationState: .zapped)
            
            goodAnimations![.injured] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[8], withImageIdentifier: "PoliceInjured", forAnimationState: .injured)
         
            
            badAnimations = [:]
            
            badAnimations![.arresting] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[0], withImageIdentifier: "Arresting", forAnimationState: .arresting)
            
            badAnimations![.holdingPrisoner] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[1], withImageIdentifier: "HoldingPrisoner", forAnimationState: .holdingPrisoner)
            
            badAnimations![.attack] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[2], withImageIdentifier: "PoliceAttack", forAnimationState: .attack)
            
            badAnimations![.hit] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[3], withImageIdentifier: "PoliceHit", forAnimationState: .hit)
            
            badAnimations![.idle] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[4], withImageIdentifier: "PoliceIdle", forAnimationState: .idle)
            
            badAnimations![.patrol] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[5], withImageIdentifier: "PolicePatrol", forAnimationState: .patrol)
            
            badAnimations![.walkForward] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[6], withImageIdentifier: "PolicePatrol", forAnimationState: .walkForward)
            
            badAnimations![.inactive] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[6], withImageIdentifier: "PoliceInActive", forAnimationState: .inactive)
            
            badAnimations![.zapped] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[7], withImageIdentifier: "PoliceZapped", forAnimationState: .zapped)
            
            badAnimations![.injured] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[8], withImageIdentifier: "PoliceInjured", forAnimationState: .injured)

            
            // Invoke the passed `completionHandler` to indicate that loading has completed.
            completionHandler()
            
            //print("Police goodAnimations: \(goodAnimations?.description)")
            //print("Police badAnimations: \(badAnimations?.description)")
        }
        
        //print((goodAnimations?.description))
    }
    
    static func purgeResources()
    {
        goodAnimations = nil
        badAnimations = nil
    }
 
    override func entityTouched (touches: Set<UITouch>, withEvent event: UIEvent?)
    {
//        print("PoliceBot touched!!!")
    }
}

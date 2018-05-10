/*
//
//  ProtestorBot.swift
//  ECGameFramework
//
//  Created by Jason Fry on 20/04/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
A ground-based `TaskBot` with a distance attack. This `GKEntity` subclass allows for convenient construction of an entity with appropriate `GKComponent` instances.
*/

import SpriteKit
import GameplayKit

//class ProtestorBot: TaskBot, ChargeComponentDelegate, ResourceLoadableType
class ProtestorBot: TaskBot, HealthComponentDelegate, ResistanceComponentDelegate, ResourceLoadableType
{
    // MARK: Static Properties
    
    var texture = SKTexture()
    
    /// The size to use for the `PoliceBot`s animation textures.
    static var textureSize = CGSize(width: 50.0, height: 50.0)
    
    
    /// The size to use for the `PoliceBot`'s shadow texture.
    //static var shadowSize = CGSize(width: 50.0, height: 10.0)
    
    /// The actual texture to use for the `PoliceBot`'s shadow.
    static var shadowTexture: SKTexture = {
        let shadowAtlas = SKTextureAtlas(named: "Shadows")
        return shadowAtlas.textureNamed("GroundBotShadow")
    }()
    

    var isAlive = true
    
    /// The offset of the `PoliceBot`'s shadow from its center position.
    //static var shadowOffset = CGPoint(x: 0.0, y: -40.0)
    
    /// The animations to use when a `PoliceBot` is in its "good" state.
    static var goodAnimations: [AnimationState: Animation]?
    
    /// The animations to use when a `PoliceBot` is in its "bad" state.
    static var badAnimations: [AnimationState: Animation]?
    
    
    
    // MARK: TaskBot Properties
    override var goodAnimations: [AnimationState: Animation]
    {
        return ProtestorBot.goodAnimations!
    }
    
    override var badAnimations: [AnimationState: Animation]
    {
        return ProtestorBot.badAnimations!
    }
    
    
    // MARK: ProtestorBot Properties
    
    // The position in the scene that the `PoliceBot` should target with its attack.
    var targetPosition: float2?
    
    var isPoweredDown: Bool = false
    
    //Is hit by another
    var isResistanceTriggered: Bool = false
    
    
    // MARK: Initialization
    required init(temperament: String, isGood: Bool, goodPathPoints: [CGPoint], badPathPoints: [CGPoint])
    {
        super.init(isGood: isGood, goodPathPoints: goodPathPoints, badPathPoints: badPathPoints)
        
        // Determine initial animations and charge based on the initial state of the bot.
        let initialAnimations: [AnimationState: Animation]
        let initialResistance: Double
        let initialHealth: Double
        
        if isGood
        {
            
            guard let goodAnimations = ProtestorBot.goodAnimations else {
                fatalError("Attempt to access ProtestorBot.goodAnimations before they have been loaded.")
            }
            initialAnimations = goodAnimations
            initialResistance = 100.0
            initialHealth = 100.0
            
            texture = SKTexture(imageNamed: "ProtestorBot")
        }
        else
        {
            
            guard let badAnimations = ProtestorBot.badAnimations else {
                fatalError("Attempt to access ProtestorBot.badAnimations before they have been loaded.")
            }
            initialAnimations = badAnimations
            initialResistance = GameplayConfiguration.ProtestorBot.maximumResistance
            initialHealth = GameplayConfiguration.ProtestorBot.maximumHealth
            
            texture = SKTexture(imageNamed: "ProtestorBotBad")
        }
    
        
        // Create components that define how the entity looks and behaves.
        
        let renderComponent = RenderComponent()
        addComponent(renderComponent)
        
        let orientationComponent = OrientationComponent()
        addComponent(orientationComponent)
        
        let spriteComponent = SpriteComponent(entity: self, texture: texture, textureSize: ProtestorBot.textureSize)
        addComponent(spriteComponent)
        
        //let shadowComponent = ShadowComponent(texture: PoliceBot.shadowTexture, size: PoliceBot.shadowSize, offset: PoliceBot.shadowOffset)
        //addComponent(shadowComponent)
        
        let animationComponent = AnimationComponent(textureSize: ProtestorBot.textureSize, animations: initialAnimations)
        addComponent(animationComponent)
        
        let intelligenceComponent = IntelligenceComponent(states: [
            TaskBotAgentControlledState(entity: self),
            TaskBotFleeState(entity: self),
            TaskBotInjuredState(entity: self),
            ProtestorBotHitState(entity: self),
            ProtestorBotRotateToAttackState(entity: self),
            ProtestorBotPreAttackState(entity: self),
            ProtestorBotAttackState(entity: self),
            ProtestorBeingArrestedState(entity: self),
            ProtestorArrestedState(entity: self),
            ProtestorDetainedState(entity: self),
            ProtestorBotRechargingState(entity: self),
            TaskBotZappedState(entity: self)
            ])
        addComponent(intelligenceComponent)
        
        var initialState : GKState?
        switch temperament
        {
        case "Scared":
            initialState = ScaredState(entity: self) as? GKState
            
        case "Calm":
            initialState = CalmState(entity: self) as? GKState
            
        case "Angry":
            initialState = AngryState(entity: self) as? GKState
            
        case "Violent":
            initialState = ViolentState(entity: self) as? GKState
            
        default:
            initialState = CalmState(entity: self) as? GKState
        }
        
        //print("initialState :\(initialState.debugDescription)")
        
        let temperamentComponent = TemperamentComponent(states: [
            CalmState(entity: self),
            ScaredState(entity: self),
            AngryState(entity: self),
            ViolentState(entity: self),
            SubduedState(entity: self)
            ], initialState: initialState!)
        addComponent(temperamentComponent)
        
        
        
        let physicsBody = SKPhysicsBody(circleOfRadius: GameplayConfiguration.TaskBot.physicsBodyRadius, center: GameplayConfiguration.TaskBot.physicsBodyOffset)
        let physicsComponent = PhysicsComponent(physicsBody: physicsBody, colliderType: .TaskBot)
        addComponent(physicsComponent)
/*
        let chargeComponent = ChargeComponent(charge: initialCharge, maximumCharge: GameplayConfiguration.ProtestorBot.maximumCharge, displaysChargeBar: true)
        chargeComponent.delegate = self
        addComponent(chargeComponent)
  */
        let healthComponent = HealthComponent(health: initialHealth, maximumHealth: GameplayConfiguration.ProtestorBot.maximumHealth, displaysHealthBar: true)
        healthComponent.delegate = self
        addComponent(healthComponent)

        let resistanceComponent = ResistanceComponent(resistance: initialResistance, maximumResistance: GameplayConfiguration.ProtestorBot.maximumResistance, displaysResistanceBar: true)
        resistanceComponent.delegate = self
        addComponent(resistanceComponent)
        
        
        let movementComponent = MovementComponent()
        addComponent(movementComponent)
        
        // Connect the `PhysicsComponent` and the `RenderComponent`.
        renderComponent.node.physicsBody = physicsComponent.physicsBody
        
        // Connect the 'SpriteComponent' to the 'RenderComponent'
        renderComponent.node.addChild(spriteComponent.node)
        
        //print("scene:\(String(describing: renderComponent.node.scene?.description))")
        
        let emitterComponent = EmitterComponent(particleName: "Trail.sks")
        addComponent(emitterComponent)
        renderComponent.node.addChild(emitterComponent.node)
        
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
    
    required init(isGood: Bool, goodPathPoints: [CGPoint], badPathPoints: [CGPoint]) {
        fatalError("init(isGood:goodPathPoints:badPathPoints:) has not been implemented")
    }
    
    
    // MARK: ContactableType
    
    override func contactWithEntityDidBegin(_ entity: GKEntity)
    {
        super.contactWithEntityDidBegin(entity)
    }
    
    override func contactWithEntityDidEnd(_ entity: GKEntity)
    {
        super.contactWithEntityDidEnd(entity)
    }
    
    // MARK: RulesComponentDelegate
    
    override func rulesComponent(rulesComponent: RulesComponent, didFinishEvaluatingRuleSystem ruleSystem: GKRuleSystem)
    {


        super.rulesComponent(rulesComponent: rulesComponent, didFinishEvaluatingRuleSystem: ruleSystem)
        

        /*
         A Protestor will flee a location if the following conditions are met:
         1) Enough time has elapsed since the Protestor last did something (create delays between actions
         2) The Protestor is scared
         3) A Dangerous Protestor is nearby
         4) Their is a high number of Dangerous Protestors nearby
         5) Their is a high number of Police nearby
        */
        guard let scene = component(ofType: RenderComponent.self)?.node.scene else { return }
        guard let intelligenceComponent = component(ofType: IntelligenceComponent.self) else { return }
        guard let temperamentComponent = component(ofType: TemperamentComponent.self) else { return }
        guard let agentControlledState = intelligenceComponent.stateMachine.currentState as? TaskBotAgentControlledState else { return }
        
        
        // 1) Check enough thinking time has passed
        //guard agentControlledState.elapsedTime >= GameplayConfiguration.ProtestorBot.delayBetweenAttacks else { return }
        
        // 2) Check if the Protestor is Scared
        //guard let scared = temperamentComponent.stateMachine.currentState as? ScaredState else { return }
        
        // 3) Set the Protestor to Flee State
        //guard intelligenceComponent.stateMachine.enter(TaskBotFleeState.self) else { return }
        
        print("mandate \(mandate)")
        
        switch mandate
        {
            case let .fleeAgent(targetAgent):
               intelligenceComponent.stateMachine.enter(TaskBotFleeState.self)
               targetPosition = targetAgent.position
            
            case let .retaliate(targetTaskbot):
                intelligenceComponent.stateMachine.enter(ProtestorBotRotateToAttackState.self)
                targetPosition = targetTaskbot.position
            
            default:
                break
        }
    }
    
    func hunt()
    {
        
        /*
         A `PoliceBot` will attack a location in the scene if the following conditions are met:
         1) Enough time has elapsed since the `PoliceBot` last attacked a target.
         2) The `PoliceBot` is hunting a target.
         3) The target is within the `PoliceBot`'s attack range.
         4) There is no scenery between the `PoliceBot` and the target.
         */
        guard let scene = component(ofType: RenderComponent.self)?.node.scene else { return }
        guard let intelligenceComponent = component(ofType: IntelligenceComponent.self) else { return }
        guard let agentControlledState = intelligenceComponent.stateMachine.currentState as? TaskBotAgentControlledState else { return }
        
        // 1) Check if enough time has passed since the `PoliceBot`'s last attack.
        guard agentControlledState.elapsedTime >= GameplayConfiguration.ProtestorBot.delayBetweenAttacks else { return }
        
        // 2) Check if the current mandate is to hunt an agent.
        guard case let .huntAgent(targetAgent) = mandate else { return }
        
        // 3) Check if the target is within the `PoliceBot`'s attack range.
        guard distanceToAgent(otherAgent: targetAgent) <= GameplayConfiguration.ProtestorBot.maximumAttackDistance else { return }
        
        // 4) Check if any walls or obstacles are between the `ProtestorBot` and its hunt target position.
        var hasLineOfSight = true
        
        scene.physicsWorld.enumerateBodies(alongRayStart: CGPoint(agent.position), end: CGPoint(targetAgent.position)) { body, _, _, stop in
            if ColliderType(rawValue: body.categoryBitMask).contains(.Obstacle) {
                hasLineOfSight = false
                stop.pointee = true
            }
        }
        
        if !hasLineOfSight { return }
        
        // The `ProtestorBot` is ready to attack the `targetAgent`'s current position.
        targetPosition = targetAgent.position
        intelligenceComponent.stateMachine.enter(ProtestorBotRotateToAttackState.self)
    }

    
    // MARK: ResistanceComponentDelegate
    func resistanceComponentDidLoseResistance(resistanceComponent: ResistanceComponent)
    {
        guard let intelligenceComponent = component(ofType: IntelligenceComponent.self) else { return }
        guard let resistanceComponent = component(ofType: ResistanceComponent.self) else { return }
        
        resistanceComponent.isTriggered = true
        
        // Protestor is resisting
        if resistanceComponent.hasResistance
        {
            // Beat them up
            intelligenceComponent.stateMachine.enter(ProtestorBotHitState.self)
        }
        else
        {
            // Attempt to arrest the Protestor
            intelligenceComponent.stateMachine.enter(ProtestorBeingArrestedState.self)
        }
    }

    
    func healthComponentDidLoseHealth(healthComponent: HealthComponent)
    {
        guard let intelligenceComponent = component(ofType: IntelligenceComponent.self) else { return }
        
        //isProtestor = !healthComponent.hasHealth
        //print("health:\(healthComponent.health.description)")
        
        // Check the on the health of the Protestor
        if !healthComponent.hasHealth
        {
            //Protestor is fucked, and no longer playable
            intelligenceComponent.stateMachine.enter(TaskBotInjuredState.self)
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
        
        let ProtestorBotAtlasNames = [
            "ProtestorBeingArrested",
            "ProtestorArrested",
            "ProtestorDetained",
            "ProtestorAttack",
            "ProtestorHit",
            "ProtestorIdle",
            
            "AngryProtestor",
            "CalmProtestor",
            "ScaredProtestor",
            "UnhappyProtestor",
            "ViolentProtestor"
        ]
        
        /*
         Preload all of the texture atlases for `PoliceBot`. This improves
         the overall loading speed of the animation cycles for this character.
         */
        SKTextureAtlas.preloadTextureAtlasesNamed(ProtestorBotAtlasNames) { error, ProtestorBotAtlases in
            if let error = error {
                fatalError("One or more texture atlases could not be found: \(error)")
            }
            
            /*
             This closure sets up all of the `ProtestorBot` animations
             after the `ProtestorBot` texture atlases have finished preloading.
             */
            
            goodAnimations = [:]
            goodAnimations![.beingArrested] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[0], withImageIdentifier: "ProtestorBeingArrested", forAnimationState: .beingArrested)
            goodAnimations![.arrested] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[1], withImageIdentifier: "ProtestorArrested", forAnimationState: .arrested)
            goodAnimations![.detained] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[2], withImageIdentifier: "ProtestorDetained", forAnimationState: .detained)
            goodAnimations![.attack] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[3], withImageIdentifier: "ProtestorAttack", forAnimationState: .attack)
            goodAnimations![.hit] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[4], withImageIdentifier: "ProtestorHit", forAnimationState: .hit)
            goodAnimations![.idle] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[5], withImageIdentifier: "ProtestorIdle", forAnimationState: .idle)
            
            //Temperament
            goodAnimations![.angry] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[6], withImageIdentifier: "AngryProtestor", forAnimationState: .angry)
            goodAnimations![.calm] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[7], withImageIdentifier: "CalmProtestor", forAnimationState: .calm)
            goodAnimations![.scared] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[8], withImageIdentifier: "ScaredProtestor", forAnimationState: .scared)
            goodAnimations![.unhappy] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[9], withImageIdentifier: "UnhappyProtestor", forAnimationState: .unhappy)
            goodAnimations![.violent] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[10], withImageIdentifier: "ViolentProtestor", forAnimationState: .violent)
            
            
            badAnimations = [:]
            badAnimations![.beingArrested] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[0], withImageIdentifier: "ProtestorBeingArrested", forAnimationState: .beingArrested)
            badAnimations![.attack] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[3], withImageIdentifier: "ProtestorAttack", forAnimationState: .attack)
            badAnimations![.hit] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[4], withImageIdentifier: "ProtestorHit", forAnimationState: .hit, bodyActionName: "ZappedShake", shadowActionName: "ZappedShadowShake", repeatTexturesForever: false)
            badAnimations![.arrested] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[1], withImageIdentifier: "ProtestorArrested", forAnimationState: .arrested, bodyActionName: "ZappedShake", shadowActionName: "ZappedShadowShake", repeatTexturesForever: false)
            badAnimations![.idle] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[5], withImageIdentifier: "ProtestorIdle", forAnimationState: .idle)
            badAnimations![.patrol] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[5], withImageIdentifier: "ProtestorPatrol", forAnimationState: .patrol)
            badAnimations![.walkForward] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[5], withImageIdentifier: "ProtestorPatrol", forAnimationState: .walkForward)
            
            
            // Invoke the passed `completionHandler` to indicate that loading has completed.
            completionHandler()
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
        print("ProtestorBot touched!!!")
    }
}

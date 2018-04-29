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

//class PoliceBot: TaskBot, ChargeComponentDelegate, HealthComponentDelegate, ResourceLoadableType
class PoliceBot: TaskBot, HealthComponentDelegate, ResourceLoadableType
{
    // MARK: ChargeComponentDelegate
    /*
    func chargeComponentDidLoseCharge(chargeComponent: ChargeComponent)
    {
        guard let intelligenceComponent = component(ofType: IntelligenceComponent.self) else { return }
        
        isProtestor = !chargeComponent.hasCharge
        
        if !isProtestor
        {
            intelligenceComponent.stateMachine.enter(TaskBotZappedState.self)
        }
    }
    */
    
    // MARK: HealthComponentDelegate
    func healthComponentDidLoseHealth(healthComponent: HealthComponent)
    {
        if let intelligenceComponent = component(ofType: IntelligenceComponent.self)
        {
            if !healthComponent.hasHealth
            {
                isAlive = false
                intelligenceComponent.stateMachine.enter(PoliceBotRechargingState.self)
            }
            else
            {
                intelligenceComponent.stateMachine.enter(PoliceBotHitState.self)
            }
        }
    }
    
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
    
    
    /// The offset of the `PoliceBot`'s shadow from its center position.
    //static var shadowOffset = CGPoint(x: 0.0, y: -40.0)
    
    /// The animations to use when a `PoliceBot` is in its "good" state.
    static var goodAnimations: [AnimationState: Animation]?
    
    /// The animations to use when a `PoliceBot` is in its "bad" state.
    static var badAnimations: [AnimationState: Animation]?
    
//    var isPoweredDown = false
    var tazerPoweredDown = false
    var isAlive = true
    
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
    
    required init(temperament: String, isGood: Bool, goodPathPoints: [CGPoint], badPathPoints: [CGPoint])
    {
        super.init(isGood: isGood, goodPathPoints: goodPathPoints, badPathPoints: badPathPoints)
        
        // Determine initial animations and charge based on the initial state of the bot.
        let initialAnimations: [AnimationState: Animation]
//        let initialCharge: Double
        let initialHealth: Double
        
        if isGood
        {
            
            guard let goodAnimations = PoliceBot.goodAnimations else {
                fatalError("Attempt to access PoliceBot.goodAnimations before they have been loaded.")
            }
            initialAnimations = goodAnimations
//            initialCharge = 0.0
            initialHealth = 0.0
            
            texture = SKTexture(imageNamed: "PoliceBot")
        }
        else
        {
            
            guard let badAnimations = PoliceBot.badAnimations else {
                fatalError("Attempt to access PoliceBot.badAnimations before they have been loaded.")
            }
            initialAnimations = badAnimations
 //           initialCharge = GameplayConfiguration.PoliceBot.maximumCharge
            initialHealth = GameplayConfiguration.PoliceBot.maximumHealth
            
            texture = SKTexture(imageNamed: "PoliceBotBad")
        }
        
        
        
        // Create components that define how the entity looks and behaves.
        
        let renderComponent = RenderComponent()
        addComponent(renderComponent)
        
        let orientationComponent = OrientationComponent()
        addComponent(orientationComponent)
        
        let spriteComponent = SpriteComponent(texture: texture, textureSize: PoliceBot.textureSize)
        //let spriteComponent = SpriteComponent(texture: PoliceBot.texture, textureSize: PoliceBot.textureSize)
        addComponent(spriteComponent)
        
        //let shadowComponent = ShadowComponent(texture: PoliceBot.shadowTexture, size: PoliceBot.shadowSize, offset: PoliceBot.shadowOffset)
        //addComponent(shadowComponent)
        
        let animationComponent = AnimationComponent(textureSize: PoliceBot.textureSize, animations: initialAnimations)
        addComponent(animationComponent)
        
        let intelligenceComponent = IntelligenceComponent(states: [
            TaskBotAgentControlledState(entity: self),
            TaskBotFleeState(entity: self),
            PoliceBotRotateToAttackState(entity: self),
            PoliceBotPreAttackState(entity: self),
            PoliceBotAttackState(entity: self),
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
        
        print("initialState :\(initialState.debugDescription)")
        
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
        let chargeComponent = ChargeComponent(charge: initialCharge, maximumCharge: GameplayConfiguration.PoliceBot.maximumCharge)
        chargeComponent.delegate = self
        addComponent(chargeComponent)
        */
        
        let healthComponent = HealthComponent(health: initialHealth, maximumHealth: GameplayConfiguration.PoliceBot.maximumHealth)
        healthComponent.delegate = self
        addComponent(healthComponent)
        
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
        
        let emitterComponent = EmitterComponent(particleName: "Trail.sks")
        addComponent(emitterComponent)
        renderComponent.node.addChild(emitterComponent.node)
        
        // Connect the `RenderComponent` and `ShadowComponent` to the `AnimationComponent`.
        renderComponent.node.addChild(animationComponent.node)
        //animationComponent.shadowNode = shadowComponent.node
        
        
        /*
         if !isGood
         {
         temperamentComponent.stateMachine.enter(ViolentState.self)
         }
         */
        
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
        
        //If touching entity is attacking, start the arresting process
        print("PoliceBot currentState :\(entity.component(ofType: IntelligenceComponent.self)?.stateMachine.currentState.debugDescription)")
        
        //guard let temperamentState = entity.component(ofType: TemperamentComponent.self)?.stateMachine.currentState as? AngryState else { return }
        
        if let attackState = self.component(ofType: IntelligenceComponent.self)?.stateMachine.currentState as? PoliceBotAttackState
        {
            attackState.applyDamageToEntity(entity: entity)
        }
        /*
        if let intelligenceComponent = entity.component(ofType: IntelligenceComponent.self)?.stateMachine.currentState as? ProtestorBeingArrestedState
        {
            intelligenceComponent.stateMachine?.enter(ProtestorArrestedState.self)
        }
        else { return }
        */
        
        
        /*
        if let attackState = entity.component(ofType: IntelligenceComponent.self)?.stateMachine.currentState as? PoliceBotAttackState
        {
            attackState.applyDamageToEntity(entity: entity)
        }
        else { return }
        
        
        if let arrestingState = entity.component(ofType: IntelligenceComponent.self)?.stateMachine.currentState as? PoliceArrestState
        {
            arrestingState.applyDamageToEntity(entity: entity)
        }
        else { return }
        
        if let detainState = entity.component(ofType: IntelligenceComponent.self)?.stateMachine.currentState as? PoliceDetainState
        {
            detainState.applyDamageToEntity(entity: entity)
        }
        
        if let beingArrestedState = entity.component(ofType: IntelligenceComponent.self)?.stateMachine.currentState as? BeingArrestedState
        {
            print("beingArrestedState :\(beingArrestedState.debugDescription)")
        }
 */
 
        // Use the `PoliceBotAttackState` to apply the appropriate damage to the contacted entity.
        
        
    }
    
    // MARK: RulesComponentDelegate
    
    override func rulesComponent(rulesComponent: RulesComponent, didFinishEvaluatingRuleSystem ruleSystem: GKRuleSystem)
    {
        super.rulesComponent(rulesComponent: rulesComponent, didFinishEvaluatingRuleSystem: ruleSystem)
        
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
        guard agentControlledState.elapsedTime >= GameplayConfiguration.PoliceBot.delayBetweenAttacks else { return }
        
        // 2) Check if the current mandate is to hunt an agent.
        guard case let .huntAgent(targetAgent) = mandate else { return }
        
        // 3) Check if the target is within the `PoliceBot`'s attack range.
        guard distanceToAgent(otherAgent: targetAgent) <= GameplayConfiguration.PoliceBot.maximumAttackDistance else { return }
        
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
            "PoliceAttack",
            "PoliceHit",
            "HoldingPrisoner",
            "PoliceIdle",
            "PolicePatrol",
            "AngryPolice",
            "CalmPolice",
            "ScaredPolice",
            "UnhappyPolice",
            "ViolentPolice"
        ]
        
        /*
         Preload all of the texture atlases for `PoliceBot`. This improves
         the overall loading speed of the animation cycles for this character.
         */
        SKTextureAtlas.preloadTextureAtlasesNamed(PoliceBotAtlasNames) { error, PoliceBotAtlases in
            if let error = error {
                fatalError("One or more texture atlases could not be found: \(error)")
            }
            
            /*
             This closure sets up all of the `PoliceBot` animations
             after the `PoliceBot` texture atlases have finished preloading.
             */
            
            goodAnimations = [:]
            goodAnimations![.arresting] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[0], withImageIdentifier: "Arresting", forAnimationState: .arresting)
            goodAnimations![.attack] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[1], withImageIdentifier: "PoliceAttack", forAnimationState: .attack)
            goodAnimations![.hit] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[2], withImageIdentifier: "PoliceHit", forAnimationState: .hit)
            goodAnimations![.holdingPrisoner] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[3], withImageIdentifier: "HoldingPrisoner", forAnimationState: .holdingPrisoner)
            goodAnimations![.idle] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[4], withImageIdentifier: "PoliceIdle", forAnimationState: .idle)
            goodAnimations![.patrol] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[5], withImageIdentifier: "PolicePatrol", forAnimationState: .patrol)
            goodAnimations![.walkForward] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[5], withImageIdentifier: "PolicePatrol", forAnimationState: .walkForward)
            
            //Temperament
            goodAnimations![.angry] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[6], withImageIdentifier: "PoliceAngry", forAnimationState: .angry)
            goodAnimations![.calm] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[7], withImageIdentifier: "PoliceCalm", forAnimationState: .calm)
            goodAnimations![.scared] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[8], withImageIdentifier: "PoliceScared", forAnimationState: .scared)
            goodAnimations![.unhappy] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[9], withImageIdentifier: "PoliceUnhappy", forAnimationState: .unhappy)
            goodAnimations![.violent] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[10], withImageIdentifier: "PoliceViolent", forAnimationState: .violent)
            
            
            badAnimations = [:]
            badAnimations![.arresting] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[0], withImageIdentifier: "Arresting", forAnimationState: .arresting)
            badAnimations![.attack] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[1], withImageIdentifier: "PoliceAttack", forAnimationState: .attack)
            badAnimations![.hit] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[2], withImageIdentifier: "PoliceHit", forAnimationState: .hit, bodyActionName: "ZappedShake", shadowActionName: "ZappedShadowShake", repeatTexturesForever: false)
            badAnimations![.holdingPrisoner] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[3], withImageIdentifier: "HoldingPrisoner", forAnimationState: .holdingPrisoner, bodyActionName: "ZappedShake", shadowActionName: "ZappedShadowShake", repeatTexturesForever: false)
            badAnimations![.idle] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[4], withImageIdentifier: "PoliceIdle", forAnimationState: .idle)
            badAnimations![.patrol] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[5], withImageIdentifier: "PolicePatrol", forAnimationState: .patrol)
            badAnimations![.walkForward] = AnimationComponent.animationsFromAtlas(atlas: PoliceBotAtlases[5], withImageIdentifier: "PolicePatrol", forAnimationState: .walkForward)
  
            
            // Invoke the passed `completionHandler` to indicate that loading has completed.
            completionHandler()
        }
        
        print((goodAnimations?.description))
    }
    
    static func purgeResources()
    {
        goodAnimations = nil
        badAnimations = nil
    }
}

/*
//  ManBot.swift
//  ECGameFramework
//
//  Created by Jason Fry on 01/03/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

    Abstract:
    A ground-based `TaskBot` with a distance attack. This `GKEntity` subclass allows for convenient construction of an entity with appropriate `GKComponent` instances.
*/

import SpriteKit
import GameplayKit

class ManBot: TaskBot, ChargeComponentDelegate, ResourceLoadableType
{
    // MARK: Static Properties
    
    var texture = SKTexture()
    
    /// The size to use for the `ManBot`s animation textures.
    static var textureSize = CGSize(width: 50.0, height: 50.0)
    
    
    /// The size to use for the `ManBot`'s shadow texture.
    //static var shadowSize = CGSize(width: 50.0, height: 10.0)
    
    /// The actual texture to use for the `ManBot`'s shadow.
    static var shadowTexture: SKTexture = {
        let shadowAtlas = SKTextureAtlas(named: "Shadows")
        return shadowAtlas.textureNamed("GroundBotShadow")
    }()
 
    
    /// The offset of the `ManBot`'s shadow from its center position.
    //static var shadowOffset = CGPoint(x: 0.0, y: -40.0)
    
    /// The animations to use when a `ManBot` is in its "good" state.
    static var goodAnimations: [AnimationState: Animation]?
    
    /// The animations to use when a `ManBot` is in its "bad" state.
    static var badAnimations: [AnimationState: Animation]?
 
 
 
    // MARK: TaskBot Properties
    
    override var goodAnimations: [AnimationState: Animation]
    {
        return ManBot.goodAnimations!
    }
    
    override var badAnimations: [AnimationState: Animation]
    {
        return ManBot.badAnimations!
    }
 
 
    // MARK: ManBot Properties
    
    /// The position in the scene that the `ManBot` should target with its attack.
    var targetPosition: float2?
    
    // MARK: Initialization
    
    required init(temperament: String, isGood: Bool, goodPathPoints: [CGPoint], badPathPoints: [CGPoint])
    {
        super.init(isGood: isGood, goodPathPoints: goodPathPoints, badPathPoints: badPathPoints)
        
        // Determine initial animations and charge based on the initial state of the bot.
        let initialAnimations: [AnimationState: Animation]
        let initialCharge: Double
        
        if isGood
        {
            
            guard let goodAnimations = ManBot.goodAnimations else {
                fatalError("Attempt to access ManBot.goodAnimations before they have been loaded.")
            }
            initialAnimations = goodAnimations
            initialCharge = 0.0
            
            texture = SKTexture(imageNamed: "ManBot")
        }
        else
        {
            
            guard let badAnimations = ManBot.badAnimations else {
                fatalError("Attempt to access ManBot.badAnimations before they have been loaded.")
            }
            initialAnimations = badAnimations
            initialCharge = GameplayConfiguration.ManBot.maximumCharge
            
            texture = SKTexture(imageNamed: "ManBotBad")
        }
        
        
        
        // Create components that define how the entity looks and behaves.
        
        let renderComponent = RenderComponent()
        addComponent(renderComponent)
        
        let orientationComponent = OrientationComponent()
        addComponent(orientationComponent)
        
        let spriteComponent = SpriteComponent(entity: self, texture: texture, textureSize: ManBot.textureSize)
        //let spriteComponent = SpriteComponent(texture: ManBot.texture, textureSize: ManBot.textureSize)
        addComponent(spriteComponent)
    
        //let shadowComponent = ShadowComponent(texture: ManBot.shadowTexture, size: ManBot.shadowSize, offset: ManBot.shadowOffset)
        //addComponent(shadowComponent)
 
        let animationComponent = AnimationComponent(textureSize: ManBot.textureSize, animations: initialAnimations)
        addComponent(animationComponent)

        let intelligenceComponent = IntelligenceComponent(states: [
            TaskBotAgentControlledState(entity: self),
            ManBotRotateToAttackState(entity: self),
            ManBotPreAttackState(entity: self),
            ManBotAttackState(entity: self),
            TaskBotZappedState(entity: self),
//            BeingArrestedState(entity: self),
//            ArrestedState(entity: self),
//            DetainedState(entity: self)
            ])
        addComponent(intelligenceComponent)
        
        var initialState : GKState?
        switch temperament
        {
        case "Scared":
            initialState = ScaredState(entity: self)// as? GKState
            
        case "Calm":
            initialState = CalmState(entity: self)// as? GKState
            
        case "Angry":
            initialState = AngryState(entity: self)// as? GKState
            
        case "Violent":
            initialState = ViolentState(entity: self)// as? GKState
            
        default:
             initialState = CalmState(entity: self)// as? GKState
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
        
        let chargeComponent = ChargeComponent(charge: initialCharge, maximumCharge: GameplayConfiguration.ManBot.maximumCharge)
        chargeComponent.delegate = self
        addComponent(chargeComponent)
        
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
        beamTargetOffset = GameplayConfiguration.ManBot.beamTargetOffset
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(isGood: Bool, goodPathPoints: [CGPoint], badPathPoints: [CGPoint]) {
        fatalError("init(isGood:goodPathPoints:badPathPoints:) has not been implemented")
    }

    
    deinit {
        print("Deallocating ManBot")
    }
    
    // MARK: ContactableType
    
    override func contactWithEntityDidBegin(_ entity: GKEntity)
    {
        super.contactWithEntityDidBegin(entity)
        
        //If touching entity is attacking, start the arresting process
        guard let attackState = entity.component(ofType: IntelligenceComponent.self)?.stateMachine.currentState as? ManBotAttackState else { return }
        
        
        // Use the `ManBotAttackState` to apply the appropriate damage to the contacted entity.
        attackState.applyDamageToEntity(entity: entity)
    }
    
    // MARK: RulesComponentDelegate
    
    override func rulesComponent(rulesComponent: RulesComponent, didFinishEvaluatingRuleSystem ruleSystem: GKRuleSystem)
    {
        super.rulesComponent(rulesComponent: rulesComponent, didFinishEvaluatingRuleSystem: ruleSystem)
        
        /*
         A `ManBot` will attack a location in the scene if the following conditions are met:
         1) Enough time has elapsed since the `ManBot` last attacked a target.
         2) The `ManBot` is hunting a target.
         3) The target is within the `ManBot`'s attack range.
         4) There is no scenery between the `ManBot` and the target.
         */
        guard let scene = component(ofType: RenderComponent.self)?.node.scene else { return }
        guard let intelligenceComponent = component(ofType: IntelligenceComponent.self) else { return }
        guard let agentControlledState = intelligenceComponent.stateMachine.currentState as? TaskBotAgentControlledState else { return }
        
        // 1) Check if enough time has passed since the `ManBot`'s last attack.
        guard agentControlledState.elapsedTime >= GameplayConfiguration.ManBot.delayBetweenAttacks else { return }
        
        // 2) Check if the current mandate is to hunt an agent.
        guard case let .huntAgent(targetAgent) = mandate else { return }
        
        // 3) Check if the target is within the `ManBot`'s attack range.
        guard distanceToAgent(otherAgent: targetAgent) <= GameplayConfiguration.ManBot.maximumAttackDistance else { return }
        
        // 4) Check if any walls or obstacles are between the `ManBot` and its hunt target position.
        var hasLineOfSight = true
        
        scene.physicsWorld.enumerateBodies(alongRayStart: CGPoint(agent.position), end: CGPoint(targetAgent.position)) { body, _, _, stop in
            if ColliderType(rawValue: body.categoryBitMask).contains(.Obstacle) {
                hasLineOfSight = false
                stop.pointee = true
            }
        }
        
        if !hasLineOfSight { return }
        
        // The `ManBot` is ready to attack the `targetAgent`'s current position.
        targetPosition = targetAgent.position
        intelligenceComponent.stateMachine.enter(ManBotRotateToAttackState.self)
    }
    
    // MARK: ChargeComponentDelegate
    
    func chargeComponentDidLoseCharge(chargeComponent: ChargeComponent)
    {
        guard let intelligenceComponent = component(ofType: IntelligenceComponent.self) else { return }
        
        isGood = !chargeComponent.hasCharge
        
        if !isGood
        {
            intelligenceComponent.stateMachine.enter(TaskBotZappedState.self)
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
        
        let manBotAtlasNames = [
            "ManBotGoodWalk",
            "ManBotBadWalk",
            "ManBotAttack",
            "ManBotZapped",
            "ManBotIdle"
        ]
        
        /*
         Preload all of the texture atlases for `ManBot`. This improves
         the overall loading speed of the animation cycles for this character.
         */
        SKTextureAtlas.preloadTextureAtlasesNamed(manBotAtlasNames) { error, manBotAtlases in
            if let error = error {
                fatalError("One or more texture atlases could not be found: \(error)")
            }
            
            /*
             This closure sets up all of the `ManBot` animations
             after the `ManBot` texture atlases have finished preloading.
             */
            
            goodAnimations = [:]
            goodAnimations![.walkForward] = AnimationComponent.animationsFromAtlas(atlas: manBotAtlases[0], withImageIdentifier: "ManBotGoodWalk", forAnimationState: .walkForward)
            goodAnimations![.idle] = AnimationComponent.animationsFromAtlas(atlas: manBotAtlases[4], withImageIdentifier: "ManBotIdle", forAnimationState: .idle)
            
            badAnimations = [:]
            badAnimations![.walkForward] = AnimationComponent.animationsFromAtlas(atlas: manBotAtlases[1], withImageIdentifier: "ManBotBadWalk", forAnimationState: .walkForward)
            badAnimations![.attack] = AnimationComponent.animationsFromAtlas(atlas: manBotAtlases[2], withImageIdentifier: "ManBotAttack", forAnimationState: .attack, bodyActionName: "ZappedShake", shadowActionName: "ZappedShadowShake", repeatTexturesForever: false)
            badAnimations![.zapped] = AnimationComponent.animationsFromAtlas(atlas: manBotAtlases[3], withImageIdentifier: "ManBotZapped", forAnimationState: .zapped, bodyActionName: "ZappedShake", shadowActionName: "ZappedShadowShake")
        
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
}


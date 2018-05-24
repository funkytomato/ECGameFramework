/*
//
//  CriminalBot.swift
//  ECGameFramework
//
//  Created by Spaceman on 23/05/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
A Criminal `TaskBot` with a distance attack. This `GKEntity` subclass allows for convenient construction of an entity with appropriate `GKComponent` instances.
*/

import SpriteKit
import GameplayKit


class CriminalBot: TaskBot, HealthComponentDelegate, ResistanceComponentDelegate, ResourceLoadableType
{
    
    // MARK: Static Properties
    
    var texture = SKTexture()
    
    // The size to use for the `PoliceBot`s animation textures.
    static var textureSize = CGSize(width: 50.0, height: 50.0)
    
    
    // The size to use for the `PoliceBot`'s shadow texture.
    // static var shadowSize = CGSize(width: 50.0, height: 10.0)
    
    // The actual texture to use for the `PoliceBot`'s shadow.
    static var shadowTexture: SKTexture = {
        let shadowAtlas = SKTextureAtlas(named: "Shadows")
        return shadowAtlas.textureNamed("GroundBotShadow")
    }()
    
    
    
    // The offset of the `PoliceBot`'s shadow from its center position.
    // static var shadowOffset = CGPoint(x: 0.0, y: -40.0)
    
    // MARK: TaskBot Animation Properties
    
    // The animations to use when a `ProtestorBot` is in its "good" state.
    static var goodAnimations: [AnimationState: Animation]?
    
    // The animations to use when a `ProtestorBot` is in its "bad" state.
    static var badAnimations: [AnimationState: Animation]?
    
    
    override var goodAnimations: [AnimationState: Animation]
    {
        return CriminalBot.goodAnimations!
    }
    
    override var badAnimations: [AnimationState: Animation]
    {
        return CriminalBot.badAnimations!
    }
    
    
    // MARK: ProtestorBot Properties
    
    // The position in the scene that the `PoliceBot` should target with its attack.
    var targetPosition: float2?
    
    
    // MARK: Initialization
    required init(temperament: String, isGood: Bool, goodPathPoints: [CGPoint], badPathPoints: [CGPoint])
    {
        super.init(isGood: isGood, goodPathPoints: goodPathPoints, badPathPoints: badPathPoints)
        
        // Determine initial animations and charge based on the initial state of the bot.
        let initialAnimations: [AnimationState: Animation]
        let initialResistance: Double
        let initialHealth: Double
        
        self.isCriminal = true
        
        // Good TaskBot
        if isGood
        {
            guard let goodAnimations = CriminalBot.goodAnimations else {
                fatalError("Attempt to access ProtestorBot.goodAnimations before they have been loaded.")
            }
            initialAnimations = goodAnimations
            initialResistance = 100.0
            initialHealth = 100.0
            
            texture = SKTexture(imageNamed: "CriminalBot")
        }
            
        //Bad Taskbot
        else
        {
            guard let badAnimations = CriminalBot.badAnimations else {
                fatalError("Attempt to access ProtestorBot.badAnimations before they have been loaded.")
            }
            initialAnimations = badAnimations
            initialResistance = GameplayConfiguration.ProtestorBot.maximumResistance
            initialHealth = GameplayConfiguration.ProtestorBot.maximumHealth
            
            texture = SKTexture(imageNamed: "CriminalBotBad")
        }
        
        
        // Create components that define how the entity looks and behaves.
        
        let renderComponent = RenderComponent()
        addComponent(renderComponent)
        
        let orientationComponent = OrientationComponent()
        addComponent(orientationComponent)
        
        
        let spriteComponent = SpriteComponent(entity: self, texture: texture, textureSize: CriminalBot.textureSize)
        addComponent(spriteComponent)
        
        
        //let shadowComponent = ShadowComponent(texture: PoliceBot.shadowTexture, size: PoliceBot.shadowSize, offset: PoliceBot.shadowOffset)
        //addComponent(shadowComponent)
        
        let animationComponent = AnimationComponent(textureSize: CriminalBot.textureSize, animations: initialAnimations)
        addComponent(animationComponent)
        
        let intelligenceComponent = IntelligenceComponent(states: [
            TaskBotAgentControlledState(entity: self),
            TaskBotPlayerControlledState(entity: self),
            TaskBotFleeState(entity: self),
            TaskBotInjuredState(entity: self),
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
        let healthComponent = HealthComponent(health: initialHealth, maximumHealth: GameplayConfiguration.CriminalBot.maximumHealth, displaysHealthBar: true)
        healthComponent.delegate = self
        addComponent(healthComponent)
        
        let resistanceComponent = ResistanceComponent(resistance: initialResistance, maximumResistance: GameplayConfiguration.CriminalBot.maximumResistance, displaysResistanceBar: true)
        resistanceComponent.delegate = self
        addComponent(resistanceComponent)
        
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
        
        
        guard let intelligenceComponent = component(ofType: IntelligenceComponent.self) else { return }
        
        //Criminal Rules
        switch mandate
        {
            case .sellWares:
                print("Sell Wares")
                intelligenceComponent.stateMachine.enter(SellWaresState.self)
            
            case let .vandalise(targetPosition):
                print("Vandalise")
                intelligenceComponent.stateMachine.enter(VandaliseState.self)
            
            case let .loot(targetPosition):
                print("Loot")
                intelligenceComponent.stateMachine.enter(LootState.self)
            
            default:
                break
        }
    }
    
    
    // MARK: Resistance Component Delegate
    func resistanceComponentDidLoseResistance(resistanceComponent: ResistanceComponent)
    {
        guard let intelligenceComponent = component(ofType: IntelligenceComponent.self) else { return }
        guard let resistanceComponent = component(ofType: ResistanceComponent.self) else { return }
        
        resistanceComponent.isTriggered = true
        
        // Criminal is resisting
        if resistanceComponent.hasResistance
        {
            // Beat them up
            intelligenceComponent.stateMachine.enter(ProtestorBotHitState.self)
        }
        else
        {
            // Attempt to arrest the Criminal
            intelligenceComponent.stateMachine.enter(ProtestorBeingArrestedState.self)
        }
    }
    
    // MARK: Health Component Delegate
    func healthComponentDidLoseHealth(healthComponent: HealthComponent)
    {
        guard let intelligenceComponent = component(ofType: IntelligenceComponent.self) else { return }
        
        // Check the on the health of the Criminal
        if !healthComponent.hasHealth
        {
            //Criminal is fucked, and no longer playable
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
        
        let CriminalBotAtlasNames = [
            "CriminalIdle",
            "CriminalLooting",
            "CriminalVandalising",
            "CriminalSellingWares",
            "CriminalHit",
            "CriminalAttack",
            
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
        SKTextureAtlas.preloadTextureAtlasesNamed(CriminalBotAtlasNames) { error, CriminalBotAtlases in
            if let error = error {
                fatalError("One or more texture atlases could not be found: \(error)")
            }
            
            /*
             This closure sets up all of the `CriminalBot` animations
             after the `CriminalBot` texture atlases have finished preloading.
             */
            
            goodAnimations = [:]
            goodAnimations![.idle] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[0], withImageIdentifier: "CriminalIdle", forAnimationState: .idle)
            goodAnimations![.looting] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[1], withImageIdentifier: "CriminalLooting", forAnimationState: .looting)
            goodAnimations![.vandalising] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[2], withImageIdentifier: "CriminalVandalising", forAnimationState: .vandalising)
            goodAnimations![.sellingWares] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[3], withImageIdentifier: "CriminalSellingWares", forAnimationState: .sellingWares)
            goodAnimations![.hit] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[4], withImageIdentifier: "CriminalHit", forAnimationState: .hit)
            goodAnimations![.attack] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[5], withImageIdentifier: "CriminalAttack", forAnimationState: .attack)
    
            
            
            badAnimations = [:]
            badAnimations![.idle] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[0], withImageIdentifier: "Idle", forAnimationState: .idle)
            badAnimations![.looting] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[1], withImageIdentifier: "Looting", forAnimationState: .looting)
            badAnimations![.vandalising] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[2], withImageIdentifier: "Vandalising", forAnimationState: .vandalising)
            badAnimations![.sellingWares] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[3], withImageIdentifier: "SellingWares", forAnimationState: .sellingWares)
            badAnimations![.hit] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[4], withImageIdentifier: "Hit", forAnimationState: .hit)
            badAnimations![.attack] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[5], withImageIdentifier: "Attack", forAnimationState: .attack)
            
            
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
    
    func moveTaskbot()
    {
        //Set the mandate to move along path
        mandate = .playerMovedTaskBot
        
        startAnimation()
        
        print("playerpathPoints: \(playerPathPoints.count)")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?, scene: LevelScene)
    {
        super.touchesBegan(touches, with: event, scene: scene)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?, scene: LevelScene)
    {
        super.touchesMoved(touches, with: event, scene: scene)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?, scene: LevelScene)
    {
        moveTaskbot()
    }
}
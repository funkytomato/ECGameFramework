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


class CriminalBot: TaskBot, HealthComponentDelegate, ResistanceComponentDelegate, ChargeComponentDelegate, RespectComponentDelegate, ObeisanceComponentDelegate, SellingWaresComponentDelegate, ResourceLoadableType
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
    required init(id: Int, temperamentState: String, isGood: Bool, goodPathPoints: [CGPoint], badPathPoints: [CGPoint])
    {
        
        super.init(id: id, isGood: isGood, goodPathPoints: goodPathPoints, badPathPoints: badPathPoints)
        
        // Determine initial animations and charge based on the initial state of the bot.
        let initialAnimations: [AnimationState: Animation]
        let initialResistance: Double
        let initialHealth: Double
        let initialCharge: Double
        let initialRespect: Double
        let initialObeisance: Double
        let initialSellingWares: Double
        let initialTemperament: Int
        
        self.isCriminal = true
        self.baseColour = .gray
        
        // Good TaskBot
        if isGood
        {
            guard let goodAnimations = CriminalBot.goodAnimations else {
                fatalError("Attempt to access ProtestorBot.goodAnimations before they have been loaded.")
            }
            initialAnimations = goodAnimations
            initialResistance = 100.0
            initialHealth = 100.0
            initialCharge = 100.0
            initialRespect = 100.0
            initialObeisance = 100.0
            initialSellingWares = 100.0
            initialTemperament = 0
            
            texture = SKTexture(imageNamed: "CriminalBot")
            
//            self.isSelling = true
        }
            
        //Bad Taskbot
        else
        {
            guard let badAnimations = CriminalBot.badAnimations else {
                fatalError("Attempt to access ProtestorBot.badAnimations before they have been loaded.")
            }
            initialAnimations = badAnimations
            initialResistance = GameplayConfiguration.CriminalBot.maximumResistance
            initialHealth = GameplayConfiguration.CriminalBot.maximumHealth
            initialCharge = GameplayConfiguration.CriminalBot.maximumCharge
            initialRespect = GameplayConfiguration.CriminalBot.maximumRespect
            initialObeisance = GameplayConfiguration.CriminalBot.maximumObeisance
            initialSellingWares = GameplayConfiguration.CriminalBot.maximumWares
            initialTemperament = Int(GameplayConfiguration.CriminalBot.maximumTemperament)
            
            texture = SKTexture(imageNamed: "CriminalBotBad")
        }
        
        
        // Create a random speed for each taskbot
        let randomSource = GKRandomSource.sharedRandom()
        let diff = randomSource.nextUniform() // returns random Float between 0.0 and 1.0
        let speed = diff * GameplayConfiguration.TaskBot.maximumSpeedForIsGood(isGood: isGood) + GameplayConfiguration.TaskBot.minimumSpeed //Ensure it has some speed
//        print("speed :\(speed.debugDescription)")
        
        // Configure the agent's characteristics for the steering physics simulation.
        agent.maxSpeed = speed
        agent.mass = GameplayConfiguration.TaskBot.agentMass

        
        
        // Create components that define how the entity looks and behaves.
        
        let renderComponent = RenderComponent()
        addComponent(renderComponent)
        
        let orientationComponent = OrientationComponent()
        addComponent(orientationComponent)
        
        
//        let spriteComponent = SpriteComponent(entity: self, texture: texture, textureSize: CriminalBot.textureSize)
//        addComponent(spriteComponent)
        
        
        //let shadowComponent = ShadowComponent(texture: PoliceBot.shadowTexture, size: PoliceBot.shadowSize, offset: PoliceBot.shadowOffset)
        //addComponent(shadowComponent)
        
        let animationComponent = AnimationComponent(textureSize: CriminalBot.textureSize, animations: initialAnimations)
        addComponent(animationComponent)
        
        let intelligenceComponent = IntelligenceComponent(states: [
            TaskBotAgentControlledState(entity: self),
//            TaskBotPlayerControlledState(entity: self),
            TaskBotFleeState(entity: self),
            TaskBotInjuredState(entity: self),
            TaskBotZappedState(entity: self),
            SellWaresState(entity: self)
            ])
        addComponent(intelligenceComponent)
        
        
        let temperamentComponent = TemperamentComponent(initialState: temperamentState, temperament: Double(initialTemperament), maximumTemperament: Double(GameplayConfiguration.ProtestorBot.maximumTemperament), displaysTemperamentBar: false)
        addComponent(temperamentComponent)
        
        
        let physicsBody = SKPhysicsBody(circleOfRadius: GameplayConfiguration.TaskBot.physicsBodyRadius, center: GameplayConfiguration.TaskBot.physicsBodyOffset)
        let physicsComponent = PhysicsComponent(physicsBody: physicsBody, colliderType: .TaskBot)
        addComponent(physicsComponent)
        
         let chargeComponent = ChargeComponent(charge: initialCharge, maximumCharge: GameplayConfiguration.ProtestorBot.maximumCharge, displaysChargeBar: false)
         chargeComponent.delegate = self
         addComponent(chargeComponent)
        
        let healthComponent = HealthComponent(health: initialHealth, maximumHealth: GameplayConfiguration.CriminalBot.maximumHealth, displaysHealthBar: false)
        healthComponent.delegate = self
        addComponent(healthComponent)
        
        let resistanceComponent = ResistanceComponent(resistance: initialResistance, maximumResistance: GameplayConfiguration.CriminalBot.maximumResistance, displaysResistanceBar: false)
        resistanceComponent.delegate = self
        addComponent(resistanceComponent)
        
        let respectComponent = RespectComponent(respect: initialRespect, maximumRespect: GameplayConfiguration.CriminalBot.maximumRespect, displaysRespectBar: false)
        respectComponent.delegate = self
        addComponent(respectComponent)
        
        let obesianceComponent = ObeisanceComponent(obeisance: initialObeisance, maximumObeisance: GameplayConfiguration.CriminalBot.maximumObeisance, displaysObeisanceBar: false)
        obesianceComponent.delegate = self
        addComponent(obesianceComponent)
        
        let sellingWaresComponent = SellingWaresComponent(wares: initialSellingWares, maximumWares: GameplayConfiguration.CriminalBot.maximumWares, displaysWaresBar: false)
        sellingWaresComponent.delegate = self
        addComponent(sellingWaresComponent)
        
        let movementComponent = MovementComponent()
        addComponent(movementComponent)
        
        // Connect the `PhysicsComponent` and the `RenderComponent`.
        renderComponent.node.physicsBody = physicsComponent.physicsBody
        
        // Connect the 'SpriteComponent' to the 'RenderComponent'
//        renderComponent.node.addChild(spriteComponent.node)
        
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
        
        
        //Set the base colour for the TaskBot
        animationComponent.node.colorBlendFactor = 1.0
        animationComponent.node.color = self.baseColour
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(id: Int, isGood: Bool, goodPathPoints: [CGPoint], badPathPoints: [CGPoint])
    {
        fatalError("init(isGood:goodPathPoints:badPathPoints:) has not been implemented")
    }
    
    
    deinit
    {
//        print("Deallocating CriminalBot")
    }
    
    
    func buyWares(_ entity: GKEntity)
    {
        //If a Criminal is selling wares and a Protestor touches Criminal and wants to buy, sell them a product
        //Check the criminal has a SellingWaresComponent
        guard let sellingWaresComponent = component(ofType: SellingWaresComponent.self) else { return }
        guard (sellingWaresComponent.stateMachine.currentState as? SellingWaresActiveState) != nil else { return }
        
        
        //Check protestor is active, has a buying component, and move into buying state
        guard let protestorBot = entity as? ProtestorBot else { return }
        if protestorBot.isActive
        {
            guard let protestorBuyingWaresComponent = protestorBot.component(ofType: BuyingWaresComponent.self) else { return }
            //            print("state: \(protestorBuyingWaresComponent.stateMachine.currentState.debugDescription)")
            guard (protestorBuyingWaresComponent.stateMachine.currentState as? BuyingWaresLookingState) != nil else { return }
            // protestorBuyingWaresComponent.stateMachine.enter(BuyingState.self)
            
            
            //Reduce the number of wares the Criminal has
            sellingWaresComponent.loseWares(waresToLose: GameplayConfiguration.CriminalBot.sellingWaresLossPerCycle)
            
            //Protestor buys product
            protestorBuyingWaresComponent.gainProduct(waresToAdd: GameplayConfiguration.CriminalBot.sellingWaresLossPerCycle)
            
            //Check protestor has an appetite
            guard let protestorAppetiteComponent = protestorBot.component(ofType: AppetiteComponent.self) else { return }
            
            //Trigger the Protestor isConSuming flag
            //            protestorAppetiteComponent.isConsumingProduct = true
            protestorBot.isConsuming = true
            
            //Protestor has bought product and so does not need to look to buy more
            protestorAppetiteComponent.isTriggered = false
            
            
            //Ensure the Protestor has an IntoxicationComponent
            guard let protestorIntoxicationComponent = protestorBot.component(ofType: IntoxicationComponent.self) else { return }
            
            //Trigger the Protestor's intoxication component
            protestorIntoxicationComponent.isTriggered = true
        }
    }
    
    
    // MARK: ContactableType
    
    override func contactWithEntityDidBegin(_ entity: GKEntity)
    {
        super.contactWithEntityDidBegin(entity)
        
//        buyWares(entity)
    }
    
    
    override func contactWithEntityDidEnd(_ entity: GKEntity)
    {
        super.contactWithEntityDidEnd(entity)
        
//        buyWares(entity)
    }
    
    
    // MARK: RulesComponentDelegate
    override func rulesComponent(rulesComponent: RulesComponent, didFinishEvaluatingRuleSystem ruleSystem: GKRuleSystem)
    {
        super.rulesComponent(rulesComponent: rulesComponent, didFinishEvaluatingRuleSystem: ruleSystem)

        
        guard let intelligenceComponent = component(ofType: IntelligenceComponent.self) else { return }
        
        //Criminal Rules
        switch mandate
        {
            case .incite:
//                print("CriminalBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                intelligenceComponent.stateMachine.enter(ProtestorInciteState.self)
                break
            
            case .sellWares:
//                print("CriminalBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                intelligenceComponent.stateMachine.enter(SellWaresState.self)
                break
            
            case .vandalise:
//                print("CriminalBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                intelligenceComponent.stateMachine.enter(VandaliseState.self)
                break
            
            case .loot:
//                print("CriminalBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                intelligenceComponent.stateMachine.enter(LootState.self)
                break
            
            default:
//                print("CriminalBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                break
        }
    }
    
    // MARK: Charge Component Delegate
    func chargeComponentDidGainCharge(chargeComponent: ChargeComponent)
    {
//        print("Add charge to Criminal")
    }
    
    func chargeComponentDidLoseCharge(chargeComponent: ChargeComponent)
    {
        guard let intelligenceComponent = component(ofType: IntelligenceComponent.self) else { return }
        
//        print("current state: \(intelligenceComponent.stateMachine.currentState.debugDescription) isGood: \(self.isGood)")
        
        isGood = !chargeComponent.hasCharge
        
        if !isGood
        {
            intelligenceComponent.stateMachine.enter(TaskBotZappedState.self)
            self.isSelling = true
        }
    }
    
    // MARK: Resistance Component Delegate
    func resistanceComponentDidGainResistance(resistanceComponent: ResistanceComponent)
    {
//        guard let resistanceComponent = component(ofType: ResistanceComponent.self) else { return }
    }
    

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
    func healthComponentDidAddHealth(healthComponent: HealthComponent)
    
    {
//         guard let healthComponent = component(ofType: HealthComponent.self) else { return }
    }
    
    func healthComponentDidLoseHealth(healthComponent: HealthComponent)
    {
        guard let intelligenceComponent = component(ofType: IntelligenceComponent.self) else { return }
        
        // Check the on the health of the Criminal
        if healthComponent.health < 20.0
        {
            //Criminal is fucked, and no longer playable
            intelligenceComponent.stateMachine.enter(TaskBotInjuredState.self)
        }
    }
    
    // MARK: Respect Component Delegate
    func respectComponentDidLoseRespect(respectComponent: RespectComponent)
    {
//        guard let respectComponent = component(ofType: RespectComponent.self) else { return }
        
        
    }
    
    func respectComponentDidGainRespect(respectComponent: RespectComponent)
    {
//        guard let respectComponent = component(ofType: RespectComponent.self) else { return }
        
    }
    
    // MARK: Obeisance Component Delegate
    func obeisanceComponentDidLoseObeisance(obeisanceComponent: ObeisanceComponent)
    {
        guard let obeisanceComponent = component(ofType: ObeisanceComponent.self) else { return }
        
        if !obeisanceComponent.hasObeisance
        {
            print("Player has lost their obeisance")
        }
    }
    
    func obeisanceComponentDidGainObeisance(obeisanceComponent: ObeisanceComponent)
    {
        guard let obeisanceComponent = component(ofType: ObeisanceComponent.self) else { return }
        
        if obeisanceComponent.hasFullObeisance
        {
            print("Player has full obeisance")
        }
    }
    
    // MARK: SellingWares Component Delegate
    func sellingWaresComponentDidLoseWares(sellingWaresComponent: SellingWaresComponent)
    {
        print("SellingWares lose wares")
    }
    
    func sellingWaresComponenttDidGainWares(sellingWaresComponent: SellingWaresComponent)
    {
        print("SellingWares gain wares")
        
        //If no more products available, can not sell
        if !sellingWaresComponent.hasWares
        {
            self.isSelling = false
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
            "CriminalBeingArrested",        //0
            "CriminalArrested",             //1
            "CriminalDetained",             //2
            
            "CriminalAttack",               //3
            "CriminalHit",                  //4

            "CriminalIdle",                 //5
            "CriminalPatrol",               //6
            "CriminalInActive",             //7
            "CriminalInciting",             //8
            "CriminalZapped",               //9
            "CriminalInjured",              //10
            
            "CriminalLooting",              //11
            "CriminalVandalising",          //12
            "CriminalSellingWares",         //13

            
            "AngryProtestor",               //14
            "CalmProtestor",                //15
            "ScaredProtestor",              //16
            "UnhappyProtestor",             //17
            "ViolentProtestor"              //18
        ]
        
        /*
         Preload all of the texture atlases for `PoliceBot`. This improves
         the overall loading speed of the animation cycles for this character.
         */
        SKTextureAtlas.preloadTextureAtlasesNamed(CriminalBotAtlasNames) { error, CriminalBotAtlases in
            if let error = error {
                fatalError("Criminal could not not load One or more texture atlases could not be found: \(error)")
            }
            
            /*
             This closure sets up all of the `CriminalBot` animations
             after the `CriminalBot` texture atlases have finished preloading.
             */
            
            goodAnimations = [:]
            
            goodAnimations![.beingArrested] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[0], withImageIdentifier: "CriminalBeingArrested", forAnimationState: .beingArrested)
            
            goodAnimations![.arrested] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[1], withImageIdentifier: "CriminalArrested", forAnimationState: .arrested)
            
            goodAnimations![.detained] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[2], withImageIdentifier: "CriminalDetained", forAnimationState: .detained)
            
            
            
            goodAnimations![.attack] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[3], withImageIdentifier: "CriminalAttack", forAnimationState: .attack)
            
            goodAnimations![.hit] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[4], withImageIdentifier: "CriminalHit", forAnimationState: .hit)
            

            
            goodAnimations![.idle] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[5], withImageIdentifier: "CriminalIdle", forAnimationState: .idle)
            
            goodAnimations![.patrol] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[6], withImageIdentifier: "CriminalPatrol", forAnimationState: .patrol)
            
            goodAnimations![.walkForward] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[6], withImageIdentifier: "CriminalPatrol", forAnimationState: .walkForward)
            
            goodAnimations![.inactive] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[7], withImageIdentifier: "CriminalInActive", forAnimationState: .inactive)
            
            goodAnimations![.inciting] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[8], withImageIdentifier: "CriminalInciting", forAnimationState: .inciting)
            
            goodAnimations![.zapped] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[9], withImageIdentifier: "CriminalZapped", forAnimationState: .zapped)
            
            goodAnimations![.injured] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[10], withImageIdentifier: "CriminalInjured", forAnimationState: .injured)
            
            
            
            goodAnimations![.looting] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[11], withImageIdentifier: "CriminalLooting", forAnimationState: .looting)
            
            goodAnimations![.vandalising] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[12], withImageIdentifier: "CriminalVandalising", forAnimationState: .vandalising)
            
            goodAnimations![.sellingWares] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[13], withImageIdentifier: "CriminalSellingWares", forAnimationState: .sellingWares)
            

            

            badAnimations = [:]
            
            
            badAnimations![.beingArrested] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[0], withImageIdentifier: "CriminalBeingArrested", forAnimationState: .beingArrested)
            
            badAnimations![.arrested] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[1], withImageIdentifier: "CriminalArrested", forAnimationState: .arrested)
            
            badAnimations![.detained] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[2], withImageIdentifier: "CriminalDetained", forAnimationState: .detained)
            
            badAnimations![.attack] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[3], withImageIdentifier: "CriminalAttack", forAnimationState: .attack)
            
            badAnimations![.hit] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[4], withImageIdentifier: "CriminalHit", forAnimationState: .hit)
            
            badAnimations![.idle] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[5], withImageIdentifier: "CriminalIdle", forAnimationState: .idle)
            
            badAnimations![.patrol] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[6], withImageIdentifier: "CriminalPatrol", forAnimationState: .patrol)
            
            badAnimations![.walkForward] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[6], withImageIdentifier: "CriminalPatrol", forAnimationState: .walkForward)
            
            badAnimations![.inactive] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[7], withImageIdentifier: "CriminalInActive", forAnimationState: .inactive)
            
            badAnimations![.inciting] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[8], withImageIdentifier: "CriminalInciting", forAnimationState: .inciting)
            
            badAnimations![.zapped] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[9], withImageIdentifier: "CriminalZapped", forAnimationState: .zapped)
            
            badAnimations![.injured] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[10], withImageIdentifier: "CriminalInjured", forAnimationState: .injured)
            
            badAnimations![.looting] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[11], withImageIdentifier: "CriminalLooting", forAnimationState: .looting)
            
            badAnimations![.vandalising] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[12], withImageIdentifier: "CriminalVandalising", forAnimationState: .vandalising)
            
            badAnimations![.sellingWares] = AnimationComponent.animationsFromAtlas(atlas: CriminalBotAtlases[13], withImageIdentifier: "CriminalSellingWares", forAnimationState: .sellingWares)
            
           
            // Invoke the passed `completionHandler` to indicate that loading has completed.
            completionHandler()
            

        }
        
        //print("Police goodAnimations: \(goodAnimations?.description)")
        //print("Police badAnimations: \(badAnimations?.description)")
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
        
        guard let animationComponent = component(ofType: AnimationComponent.self) else { return }
        animationComponent.createHighlightNode()
        
        //print("playerpathPoints: \(playerPathPoints.count)")
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

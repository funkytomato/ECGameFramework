              
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


class ProtestorBot: TaskBot, HealthComponentDelegate, ResistanceComponentDelegate, ChargeComponentDelegate, RespectComponentDelegate, ObeisanceComponentDelegate,
    AppetiteComponentDelegate, IntoxicationComponentDelegate, BuyingWaresComponentDelegate,
    TemperamentComponentDelegate, ResourceLoadableType
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
        return ProtestorBot.goodAnimations!
    }
    
    override var badAnimations: [AnimationState: Animation]
    {
        return ProtestorBot.badAnimations!
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
        let initialAppetite: Double
        let initialIntoxication: Double
        let initialTemperament: Double

        
        //Inform the TaskBot it is a Protestor, and set the base colour for a Protestor (Green)
        self.isProtestor = true
        self.baseColour = .green
        
        
        // Create a random speed for each taskbot
        let randomSource = GKRandomSource.sharedRandom()
        let diff = randomSource.nextUniform() // returns random Float between 0.0 and 1.0
        let speed = diff * GameplayConfiguration.TaskBot.maximumSpeedForIsGood(isGood: isGood) + GameplayConfiguration.TaskBot.minimumSpeed //Ensure it has some speed
//        print("speed :\(speed.debugDescription)")
        
        // Configure the agent's characteristics for the steering physics simulation.
        agent.maxSpeed = speed
        agent.mass = GameplayConfiguration.ProtestorBot.agentMass
        
        mandate = .wander
        
        // TaskBot is Protestor
        if isGood
        {
            guard let goodAnimations = ProtestorBot.goodAnimations else {
                fatalError("Attempt to access ProtestorBot.goodAnimations before they have been loaded.")
            }
            initialAnimations = goodAnimations
            initialResistance = 100.0       //Red bar
            initialHealth = 100.0           //Green bar
            initialCharge = 50.0            //Blue bar
            initialRespect = 0.0           //Yellow bar
            initialObeisance = 100.0        //Brown bar
            initialAppetite = 0.0           //White
            initialIntoxication = 80.0       //Orange
            initialTemperament = 0.0       //Cyan
            
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
            initialCharge = GameplayConfiguration.ProtestorBot.maximumCharge
            initialRespect = GameplayConfiguration.ProtestorBot.maximumRespect
            initialObeisance = GameplayConfiguration.ProtestorBot.maximumObesiance
            initialAppetite = GameplayConfiguration.ProtestorBot.maximumAppetite
            initialIntoxication = GameplayConfiguration.ProtestorBot.maximumIntoxication
            initialTemperament = Double(GameplayConfiguration.ProtestorBot.maximumTemperament)
            
            texture = SKTexture(imageNamed: "ProtestorBotBad")
        }
    
        
        // Create components that define how the entity looks and behaves.
        
        let renderComponent = RenderComponent()
        addComponent(renderComponent)
        
        let orientationComponent = OrientationComponent()
        addComponent(orientationComponent)
        
        
//        let spriteComponent = SpriteComponent(entity: self, texture: texture, textureSize: ProtestorBot.textureSize)
//        addComponent(spriteComponent)

        
        //let shadowComponent = ShadowComponent(texture: PoliceBot.shadowTexture, size: PoliceBot.shadowSize, offset: PoliceBot.shadowOffset)
        //addComponent(shadowComponent)
        
        let animationComponent = AnimationComponent(textureSize: ProtestorBot.textureSize, animations: initialAnimations)
        addComponent(animationComponent)
        
        let inputComponent = InputComponent()
        addComponent(inputComponent)
        inputComponent.isEnabled = false
        
        let intelligenceComponent = IntelligenceComponent(states: [
            TaskBotAgentControlledState(entity: self),
            TaskBotPlayerControlledState(entity: self),
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
            TaskBotZappedState(entity: self),
            ProtestorInciteState(entity: self),
            ProtestorBuyWaresState(entity: self),
            ProtestorSheepState(entity: self)
 //           ProtestorBotWanderState(entity: self)
            ])
        addComponent(intelligenceComponent)
        

        
        //print("initialState :\(initialState.debugDescription)")
        let temperamentComponent = TemperamentComponent(initialState: temperamentState, temperament: initialTemperament, maximumTemperament: Double(GameplayConfiguration.ProtestorBot.maximumTemperament), displaysTemperamentBar: false)
        temperamentComponent.delegate = self
        addComponent(temperamentComponent)
        temperamentComponent.setTemperament(newState: temperamentState)
//        print("temperamentState: \(temperamentState.debugDescription)")
        
        
        let physicsBody = SKPhysicsBody(circleOfRadius: GameplayConfiguration.TaskBot.physicsBodyRadius, center: GameplayConfiguration.TaskBot.physicsBodyOffset)
        let physicsComponent = PhysicsComponent(physicsBody: physicsBody, colliderType: .TaskBot)
        addComponent(physicsComponent)
        
        let chargeComponent = ChargeComponent(charge: initialCharge, maximumCharge: GameplayConfiguration.ProtestorBot.maximumCharge, displaysChargeBar: false)
        chargeComponent.delegate = self
        addComponent(chargeComponent)
  
        let healthComponent = HealthComponent(health: initialHealth, maximumHealth: GameplayConfiguration.ProtestorBot.maximumHealth, displaysHealthBar: false)
        healthComponent.delegate = self
        addComponent(healthComponent)

        let resistanceComponent = ResistanceComponent(resistance: initialResistance, maximumResistance: GameplayConfiguration.ProtestorBot.maximumResistance, displaysResistanceBar: false)
        resistanceComponent.delegate = self
        addComponent(resistanceComponent)
        
        let respectComponent = RespectComponent(respect: initialRespect, maximumRespect: GameplayConfiguration.ProtestorBot.maximumRespect, displaysRespectBar: false)
        respectComponent.delegate = self
        addComponent(respectComponent)
        
        let obesianceComponent = ObeisanceComponent(obeisance: initialObeisance, maximumObeisance: GameplayConfiguration.ProtestorBot.maximumObesiance, displaysObeisanceBar: false)
        obesianceComponent.delegate = self
        addComponent(obesianceComponent)
        
        let inciteComponent = InciteComponent()
        addComponent(inciteComponent)
        
        let buyWaresComponent = BuyingWaresComponent(wares: 0.0, maximumWares: 100.0)
        buyWaresComponent.delegate = self
        addComponent(buyWaresComponent)
        
        let appetiteComponent = AppetiteComponent(appetite: initialAppetite, maximumAppetite: GameplayConfiguration.ProtestorBot.maximumAppetite, displaysAppetiteBar: false)
        appetiteComponent.delegate = self
        addComponent(appetiteComponent)
        
        let intoxicationComponent = IntoxicationComponent(intoxication: initialIntoxication , maximumIntoxication: GameplayConfiguration.ProtestorBot.maximumIntoxication, displaysIntoxicationBar: false)
        intoxicationComponent.delegate = self
        addComponent(intoxicationComponent)
        
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
        
        
        //Create light node
        animationComponent.createHighlightNode()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(id: Int, isGood: Bool, goodPathPoints: [CGPoint], badPathPoints: [CGPoint]) {
        fatalError("init(isGood:goodPathPoints:badPathPoints:) has not been implemented")
    }
    
    
    deinit {
//        print("Deallocating ProtestorBot")
    }
    
    // MARK: ContactableType
    
    override func contactWithEntityDidBegin(_ entity: GKEntity)
    {
        super.contactWithEntityDidBegin(entity)
        
        // If the Protestor is violent or drunk, they may attack who they bump into
        guard let intoxicationComponent = self.component(ofType: IntoxicationComponent.self) else { return }
        guard let temperamentComponent = self.component(ofType: TemperamentComponent.self) else { return }
        
        //Drunk Protestors will attack anybody
        if intoxicationComponent.hasFullintoxication
        {

            //Get the touching TaskBot's position to be used as the attack position
            guard let taskBot = entity as? TaskBot else { return }
            print("taskBot: \(taskBot.debugDescription)")
            targetPosition = taskBot.agent.position
            
            //Move the Protestor into the attack sequence, ProtestorBotRotateToAttackState being the starting state
            guard let intelligenceComponent = self.component(ofType: IntelligenceComponent.self) else { return }
            intelligenceComponent.stateMachine.enter(ProtestorBotRotateToAttackState.self)
        }
        else
        {
            //Protestor is either violent or raging, attack the Taskbot made contact with
            if ((temperamentComponent.stateMachine.currentState as? ViolentState) != nil) || ((temperamentComponent.stateMachine.currentState as? RageState) != nil)
            {
                guard let intelligenceComponent = self.component(ofType: IntelligenceComponent.self) else { return }
                guard let taskBot = entity as? TaskBot else { return }
                print("taskBot: \(taskBot.debugDescription)")
                targetPosition = taskBot.agent.position
                intelligenceComponent.stateMachine.enter(ProtestorBotRotateToAttackState.self)
            }
        }
        
        //Protestor will attempt to buy from the touching Criminal TaskBot
        buyWares(entity)
        
        // If the Protestor is inciting, influence Protestors on contact
        guard let inciteComponent = component(ofType: InciteComponent.self) else { return }
        guard (inciteComponent.stateMachine.currentState as? InciteActiveState) != nil else { return }
        if inciteComponent.isTriggered
        {
            guard let protestorTarget = entity as? ProtestorBot else { return }
            guard let protestorTargetObeisanceComponent = protestorTarget.component(ofType: ObeisanceComponent.self) else { return }
            protestorTargetObeisanceComponent.addObeisance(obeisanceToAdd: GameplayConfiguration.ProtestorBot.obeisanceGainPerCycle)
            
            //If target Protestor's obeisance becomes high enough, set the Protestor's RingLeader Property to this entity
            if protestorTarget.isSubservient
            {
                
                //Make protestor sheep
                guard let intelligenceComponent = protestorTarget.component(ofType: IntelligenceComponent.self) else { return }
                intelligenceComponent.stateMachine.enter(ProtestorSheepState.self)
                
                //Increase the RingLeader's respect with their flock
                guard let respectComponent = self.component(ofType: RespectComponent.self) else { return }
                respectComponent.addRespect(respectToAdd: 25.0)
                
//                print("protestorTarget.ringLeader: \(protestorTarget.ringLeader.debugDescription), respect: \(respectComponent.respect)")
            }
            
            //print("Increased the obeisance of the touching Protestor")
        }
    }
    
    override func contactWithEntityDidEnd(_ entity: GKEntity)
    {
        super.contactWithEntityDidEnd(entity)
        
        // If Protestor is drunk, their temperament will increase slightly, and cause the other protestor be affected too
        guard let intoxicationComponent = component(ofType: IntoxicationComponent.self) else { return }
        if intoxicationComponent.hasFullintoxication
        {
            guard let protestorTarget = entity as? ProtestorBot else { return }
            guard let protestorTargetTemperamentComponent = protestorTarget.component(ofType: TemperamentComponent.self) else { return }
            protestorTargetTemperamentComponent.increaseTemperament(temperamentToAdd: 10.0)
        }
        
        // If the Protestor is inciting, influence Protestors on contact
        // Raise their temperament
        guard let inciteComponent = component(ofType: InciteComponent.self) else { return }
        guard (inciteComponent.stateMachine.currentState as? InciteActiveState) != nil else { return }
        if inciteComponent.isTriggered
        {
            guard let protestorTarget = entity as? ProtestorBot else { return }
            guard let protestorTargetTemperamentComponent = protestorTarget.component(ofType: TemperamentComponent.self) else { return }
            protestorTargetTemperamentComponent.increaseTemperament(temperamentToAdd: Double(GameplayConfiguration.ProtestorBot.temperamentIncreasePerCycle))
            
            //print("Raised temperament of touching Protestor")
        }    
    }
    
    
    func buyWares(_ entity: GKEntity)
    {
        
        //Check touching entity is criminal and actively selling
        guard let criminalBot = entity as? CriminalBot else { return }
        guard let sellingWaresComponent = criminalBot.component(ofType: SellingWaresComponent.self) else { return }
        guard (sellingWaresComponent.stateMachine.currentState as? SellingWaresActiveState) != nil else { return }
        
        
        //Check Protestor is looking to buy wares
        
        guard let buyingWaresComponent = self.component(ofType: BuyingWaresComponent.self) else { return }
//        print("\(buyingWaresComponent.stateMachine.currentState.debugDescription)")
        guard (buyingWaresComponent.stateMachine.currentState as? BuyingWaresLookingState) != nil else { return }
        
        
        //Buy wares
        buyingWaresComponent.gainProduct(waresToAdd: GameplayConfiguration.CriminalBot.sellingWaresLossPerCycle)
        sellingWaresComponent.loseWares(waresToLose: GameplayConfiguration.CriminalBot.sellingWaresLossPerCycle)
        
        
        //Reset appetite
        guard let appetiteComponent = self.component(ofType: AppetiteComponent.self) else { return }
        appetiteComponent.isTriggered = false
        self.isConsuming = true
        
        
        //Trigger intoxication component
        guard let intoxicationComponent = self.component(ofType: IntoxicationComponent.self) else { return }
        intoxicationComponent.isTriggered = true
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
        
//        print("agentControlledState: \(intelligenceComponent.stateMachine.currentState)")

        
        guard let agentControlledState = intelligenceComponent.stateMachine.currentState as? TaskBotAgentControlledState else { return }
        
        
        // Check if enough time has passed since the `ProtestorBot`'s last attack.
        guard agentControlledState.elapsedTime >= GameplayConfiguration.TaskBot.delayBetweenAttacks else { return }

        
        print("ProtestorBot: rulesComponent:- mandate \(mandate), state: \(intelligenceComponent.stateMachine.currentState.debugDescription)")


        switch mandate
        {
//            case .wander:
//                intelligenceComponent.stateMachine.enter(ProtestorBotWanderState.self)
            
            case .playerMovedTaskBot:
//                print("ProtestorBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                break
            
            
            case .returnToPositionOnPath:
//                print("ProtestorBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                break
            
            case let .returnHome(position):
            
//                print("ProtestorBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                
                targetPosition = position
                
                break
            
            case let .buyWares(target):
                
//                print("ProtestorBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                
        
                // Check if the target is within the `ProtestorBot`'s attack range.
                guard distanceToAgent(otherAgent: target) <= 150.0 else { return }
                
                // Check if any walls or obstacles are between the `PoliceBot` and its hunt target position.
                var hasLineOfSight = true
                
                scene.physicsWorld.enumerateBodies(alongRayStart: CGPoint(agent.position), end: CGPoint(target.position)) { body, _, _, stop in
                    if ColliderType(rawValue: body.categoryBitMask).contains(.Obstacle) {
                        hasLineOfSight = false
                        stop.pointee = true
                    }
                }
                
                if !hasLineOfSight { return }
                
                
                intelligenceComponent.stateMachine.enter(ProtestorBuyWaresState.self)
                targetPosition = target.position
                break
            
            case .incite:
                
//                print("ProtestorBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                
                //print("mandate \(mandate)")
                intelligenceComponent.stateMachine.enter(ProtestorInciteState.self)
                break

            case let .huntAgent(targetAgent):
                
//                print("ProtestorBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                
                // Check if the target is within the `ProtestorBot`'s attack range.
                guard distanceToAgent(otherAgent: targetAgent) <= GameplayConfiguration.TaskBot.maximumAttackDistance else { return }
                
                // Check if any walls or obstacles are between the `PoliceBot` and its hunt target position.
                var hasLineOfSight = true
                
                scene.physicsWorld.enumerateBodies(alongRayStart: CGPoint(agent.position), end: CGPoint(targetAgent.position)) { body, _, _, stop in
                    if ColliderType(rawValue: body.categoryBitMask).contains(.Obstacle) {
                        hasLineOfSight = false
                        stop.pointee = true
                    }
                }
                
                if !hasLineOfSight { return }
                
                // The `ProtestorBot` is ready to attack the `targetAgent`'s current position.
                intelligenceComponent.stateMachine.enter(ProtestorBotRotateToAttackState.self)
                targetPosition = targetAgent.position
                break
            
            case .lockupPrisoner:
 
//                print("ProtestorBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
            
//                intelligenceComponent.stateMachine.enter(TaskBotAgentControlledState.self)
                break
            
            case let .fleeAgent(targetAgent):
                
//                print("ProtestorBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                
                intelligenceComponent.stateMachine.enter(TaskBotFleeState.self)
                targetPosition = targetAgent.position
                break
            
            case let .retaliate(targetTaskbot):
                
//                print("ProtestorBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                
                intelligenceComponent.stateMachine.enter(ProtestorBotRotateToAttackState.self)
                targetPosition = targetTaskbot.position
                break
            
            case let .sheep(target):
//                print("ProtestorBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                break
            
            default:
                
//                print("ProtestorBot: rulesComponent:- entity: \(self.debugDescription), mandate: \(mandate)")
                
                break
        }
    }

    // MARK: Appetite Component Delegate
    func appetiteComponentDidLoseAppetite(appetiteComponent: AppetiteComponent)
    {
        //print("Appetite Component Lose Appetite")
        
        if !appetiteComponent.hasAppetite
        {
            appetiteComponent.isTriggered = false
            appetiteComponent.isConsumingProduct = false
            self.isConsuming = false
            
            //Remove product
            guard let buyingWaresComponent = component(ofType: BuyingWaresComponent.self) else { return }
            buyingWaresComponent.loseProduct(waresToLose: 10.0)
        }
    }
    
    func appetiteComponentDidGainAppetite(appetiteComponent: AppetiteComponent)
    {
        //print("Appetite Component Add Appetite")
        
        if appetiteComponent.appetite >= 100.0
        {
            //Protestor wants to buy a product
            appetiteComponent.isTriggered = true
        }
    }
    
    
    // MARK: BuyWares Component Delegate
    func buyingWaresComponentDidLoseProduct(buyWaresComponent: BuyingWaresComponent)
    {
        //Protestor does not have any wares
        self.hasWares = false
    }
    
    func buyingWaresComponentDidGainProduct(buyWaresComponent: BuyingWaresComponent) {
//        print("Buy product and eat/use")
        
        self.hasWares = true
    }
    
    
    // MARK: Intoxication Component Delegate
    func intoxicationComponentDidLoseintoxication(intoxicationComponent: IntoxicationComponent)
    {
//        print("Intoxication Component Lose Appetite")
        
        if !intoxicationComponent.hasintoxication
        {
            print("Protestor has sobered up")
        }
    }
    
    func intoxicationComponentDidAddintoxication(intoxicationComponent: IntoxicationComponent)
    {
//        print("Intoxication Component Lose Appetite")
        
        if intoxicationComponent.hasFullintoxication
        {
            print("Protestor is drunk")
        }
    }
    
    // MARK: Charge Component Delegate
    func chargeComponentDidGainCharge(chargeComponent: ChargeComponent)
    {
//        print("Add charge to Protestor")
    }
    
    
    func chargeComponentDidLoseCharge(chargeComponent: ChargeComponent)
    {
        guard let intelligenceComponent = component(ofType: IntelligenceComponent.self) else { return }

        //The player decides who the RingLeader will be by zapping them
        self.isRingLeader = true
        
        //Freeze Protestor for a bit and then carry on
        isGood = !chargeComponent.hasCharge
        if !isGood
        {
            guard let buyingWaresComponent = self.component(ofType: BuyingWaresComponent.self) else { return }
            buyingWaresComponent.isTriggered = false
            
            intelligenceComponent.stateMachine.enter(TaskBotZappedState.self)
        }
    }
    
    
    // MARK: Resistance Component Delegate
    func resistanceComponentDidGainResistance(resistanceComponent: ResistanceComponent)
    {
//        guard let resistanceComponent = component(ofType: ResistanceComponent.self) else { return }
    }
    

    func resistanceComponentDidLoseResistance(resistanceComponent: ResistanceComponent)
    {
        guard let resistanceComponent = component(ofType: ResistanceComponent.self) else { return }
        
        resistanceComponent.isTriggered = true
    }

    
    // MARK: Health Component Delegate
    func healthComponentDidAddHealth(healthComponent: HealthComponent)
    {
//        guard let healthComponent = component(ofType: HealthComponent.self) else { return }
    }
    
    
    
    func healthComponentDidLoseHealth(healthComponent: HealthComponent)
    {
        guard let intelligenceComponent = component(ofType: IntelligenceComponent.self) else { return }
        
        // Check the on the health of the Protestor
        //if !healthComponent.hasHealth
        if healthComponent.health < 20.0
        {
            //Protestor is fucked, and no longer playable
            intelligenceComponent.stateMachine.enter(TaskBotInjuredState.self)
        }
            
        //If Protestor's health gets below 50, move them to ScaredState, ready to Flee
        else if healthComponent.health < 50.0
        {
            temperamentComponent.stateMachine.enter(ScaredState.self)
        }
    }
    
    // MARK: Respect Component Delegate
    func respectComponentDidLoseRespect(respectComponent: RespectComponent)
    {
        guard let respectComponent = component(ofType: RespectComponent.self) else { return }
        
        //Protestor has lost all respect and is no longer controllable
        if !respectComponent.hasRespect
        {
            guard let inputComponent = self.component(ofType: InputComponent.self) else { return }
            inputComponent.isEnabled = false
            
            guard let animationComponent = component(ofType: AnimationComponent.self) else { return }
            animationComponent.removeHighlightNode()
        }
        
    }
    
    func respectComponentDidGainRespect(respectComponent: RespectComponent)
    {
        guard let respectComponent = component(ofType: RespectComponent.self) else { return }

        if respectComponent.hasFullRespect
        {
//            //RingLeader has gained full respect and should now be movable
            guard let inputComponent = self.component(ofType: InputComponent.self) else { return }
            inputComponent.isEnabled = true
            
            guard let animationComponent = component(ofType: AnimationComponent.self) else { return }
            animationComponent.createHighlightNode()
            
            // Make Ringleader heavier and more forceful through crowds
            self.agent.mass = 2.0
            self.agent.maxSpeed = 100.0
            self.agent.maxAcceleration = 200.0
        }
    }
    
    
    // MARK: Temperament Component Delegate
    func temperamentComponentDidReduceTemperament(temperamentComponent: TemperamentComponent) {
//        guard let temperamentComponent = component(ofType: TemperamentComponent.self) else { return }
    }
    
    func temperamentComponentDidIncreaseTemperament(temperamentComponent: TemperamentComponent) {
//        guard let temperamentComponent = component(ofType: TemperamentComponent.self) else { return }
    }
    
    // MARK: Obeisance Component Delegate
    func obeisanceComponentDidLoseObeisance(obeisanceComponent: ObeisanceComponent)
    {
        guard let obeisanceComponent = component(ofType: ObeisanceComponent.self) else { return }
        
        // When their is no more obeisance the protestor will be free to wander away
        if !obeisanceComponent.hasObeisance
        {
            
            guard let intelligenceComponent = component(ofType: IntelligenceComponent.self) else { return }
            intelligenceComponent.stateMachine.enter(TaskBotAgentControlledState.self)
            
            //Protestor is no longer subservient to the player
            self.isSubservient = false
            
            //Ensure InciteComponent is idle and switched off
            guard let inciteComponent = component(ofType: InciteComponent.self) else { return }
            inciteComponent.isTriggered = false
        }
    }

    func obeisanceComponentDidGainObeisance(obeisanceComponent: ObeisanceComponent)
    {
        guard let obeisanceComponent = component(ofType: ObeisanceComponent.self) else { return }
        
        //print("\(obeisanceComponent.obeisance)")
        
        //Player has gained enough influence (obeisance) over the protestor,
        //and so the protesor should start to incite too
        if obeisanceComponent.obeisance > 50
        {
            self.isSubservient = true
            //print("Protestor has become subservient")
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
            "ProtestorPatrol",
            "ProtestorInActive",
            "ProtestorInciting",
            "ProtestorZapped",
            "ProtestorInjured",

            "ProtestorLooking",
            "ProtestorBuying",
            "ProtestorDrinking",
            "ProtestorDrunk",

            
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
                fatalError("Protestor One or more texture atlases could not be found: \(error)")
            }
            
            /*
             This closure sets up all of the `ProtestorBot` animations
             after the `ProtestorBot` texture atlases have finished preloading.
             */
            
            goodAnimations = [:]
            goodAnimations![.beingArrested] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[0], withImageIdentifier: "ProtestorBeingArrested", forAnimationState: .beingArrested)
            
            goodAnimations![.arrested] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[1], withImageIdentifier: "ProtestorArrested", forAnimationState: .arrested)
            
//            goodAnimations![.arrested] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[1], withImageIdentifier: "ProtestorArrested", forAnimationState: .arrested, bodyActionName: "ZappedShake", shadowActionName: "ZappedShadowShake", repeatTexturesForever: false)
            
            goodAnimations![.detained] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[2], withImageIdentifier: "ProtestorDetained", forAnimationState: .detained)
            
            goodAnimations![.attack] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[3], withImageIdentifier: "ProtestorAttack", forAnimationState: .attack)
            
            goodAnimations![.hit] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[4], withImageIdentifier: "ProtestorHit", forAnimationState: .hit)
            

            
            goodAnimations![.idle] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[5], withImageIdentifier: "ProtestorIdle", forAnimationState: .idle)
            
            goodAnimations![.patrol] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[6], withImageIdentifier: "ProtestorPatrol", forAnimationState: .patrol)

            goodAnimations![.walkForward] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[6], withImageIdentifier: "ProtestorPatrol", forAnimationState: .walkForward)
            
            goodAnimations![.inactive] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[7], withImageIdentifier: "ProtestorInActive", forAnimationState: .inactive)
            
            goodAnimations![.inciting] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[8], withImageIdentifier: "ProtestorInciting", forAnimationState: .inciting)
            
            goodAnimations![.zapped] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[9], withImageIdentifier: "ProtestorZapped", forAnimationState: .zapped)
            
            goodAnimations![.injured] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[10], withImageIdentifier: "ProtestorInjured", forAnimationState: .injured)

            goodAnimations![.looking] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[11], withImageIdentifier: "ProtestorLooking", forAnimationState: .looking)
            
            goodAnimations![.buying] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[12], withImageIdentifier: "ProtestorBuying", forAnimationState: .buying)
            
            goodAnimations![.drinking] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[13], withImageIdentifier: "ProtestorDrinking", forAnimationState: .drinking)
            
            goodAnimations![.drunk] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[14], withImageIdentifier: "ProtestorDrunk", forAnimationState: .drunk)
            
            
            //Temperament
            goodAnimations![.angry] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[11], withImageIdentifier: "AngryProtestor", forAnimationState: .angry)
            goodAnimations![.calm] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[12], withImageIdentifier: "CalmProtestor", forAnimationState: .calm)
            goodAnimations![.scared] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[13], withImageIdentifier: "ScaredProtestor", forAnimationState: .scared)
            goodAnimations![.unhappy] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[14], withImageIdentifier: "UnhappyProtestor", forAnimationState: .unhappy)
            goodAnimations![.violent] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[15], withImageIdentifier: "ViolentProtestor", forAnimationState: .violent)
            

            
            badAnimations = [:]
            badAnimations![.beingArrested] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[0], withImageIdentifier: "ProtestorBeingArrested", forAnimationState: .beingArrested)
            
            badAnimations![.arrested] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[1], withImageIdentifier: "ProtestorArrested", forAnimationState: .arrested, bodyActionName: "ZappedShake", shadowActionName: "ZappedShadowShake", repeatTexturesForever: false)
            
            badAnimations![.attack] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[3], withImageIdentifier: "ProtestorAttack", forAnimationState: .attack)
            
            badAnimations![.hit] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[4], withImageIdentifier: "ProtestorHit", forAnimationState: .hit, bodyActionName: "ZappedShake", shadowActionName: "ZappedShadowShake", repeatTexturesForever: false)
            
            badAnimations![.idle] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[5], withImageIdentifier: "ProtestorIdle", forAnimationState: .idle)
            
            badAnimations![.patrol] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[6], withImageIdentifier: "ProtestorPatrol", forAnimationState: .patrol)
            
            badAnimations![.walkForward] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[6], withImageIdentifier: "ProtestorPatrol", forAnimationState: .walkForward)

            badAnimations![.inactive] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[7], withImageIdentifier: "ProtestorInActive", forAnimationState: .inactive)
            
            badAnimations![.inciting] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[8], withImageIdentifier: "ProtestorInciting", forAnimationState: .inciting)
            
            badAnimations![.zapped] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[9], withImageIdentifier: "ProtestorZapped", forAnimationState: .zapped)
            
            badAnimations![.injured] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[10], withImageIdentifier: "ProtestorInjured", forAnimationState: .injured)
            
            badAnimations![.looking] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[11], withImageIdentifier: "ProtestorLooking", forAnimationState: .looking)
            
            badAnimations![.buying] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[12], withImageIdentifier: "ProtestorBuying", forAnimationState: .buying)
            
            badAnimations![.drinking] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[13], withImageIdentifier: "ProtestorDrinking", forAnimationState: .drinking)
            
            badAnimations![.drunk] = AnimationComponent.animationsFromAtlas(atlas: ProtestorBotAtlases[14], withImageIdentifier: "ProtestorDrunk", forAnimationState: .drunk)


            
            // Invoke the passed `completionHandler` to indicate that loading has completed.
            completionHandler()
        }
        
        //print("Protestor goodAnimations: \(goodAnimations?.description)")
        //print("Protestor badAnimations: \(badAnimations?.description)")
    }
    
    static func purgeResources()
    {
        goodAnimations = nil
        badAnimations = nil
    }
    
    func moveTaskbot()
    {
        
        //Check there is a valid minimum number of path points
        if self.playerPathPoints.count >= 3
        {
        
            //Set the mandate to move along path
            mandate = .playerMovedTaskBot
            
            //Move into Player moved state
            guard let intelligenceComponent = self.component(ofType: IntelligenceComponent.self) else { return }
            intelligenceComponent.stateMachine.enter(TaskBotPlayerControlledState.self)
            
            //print("playerpathPoints: \(playerPathPoints.count)")
        }
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



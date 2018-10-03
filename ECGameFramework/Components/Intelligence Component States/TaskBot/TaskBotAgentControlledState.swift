/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    A state used to represent the `TaskBot` when its movement is being managed by an `GKAgent`.
*/

import SpriteKit
import GameplayKit

class TaskBotAgentControlledState: GKState
{
    // MARK: Properties
    
    unowned var entity: TaskBot
    
    //Used for moving TaskBot's out of corners
    var oldPosition: float2 = [0.0,0.0]
    
    // The amount of time that has passed since the `TaskBot` became agent-controlled.
    var elapsedTime: TimeInterval = 0.0
    
    var destination: float2 = [0.0,0.0]
    
    // The amount of time that has passed since the `TaskBot` last determined an appropriate behavior.
    var timeSinceBehaviorUpdate: TimeInterval = 0.0
    
    // MARK: Initializers
    
    required init(entity: TaskBot)
    {
        self.entity = entity
    }
    
    
    deinit {
//        print("Deallocating TaskBotAgentControlledState")
    }
    
    // MARK: GKState Life Cycle
    
    override func didEnter(from previousState: GKState?)
    {
        super.didEnter(from: previousState)
        
        // Reset the amount of time since the last behavior update.
        timeSinceBehaviorUpdate = 0.0
        elapsedTime = 0.0
        
//        print("entity behaviour: \(entity.behaviorForCurrentMandate.debugDescription)")
        
        // Ensure that the agent's behavior is the appropriate behavior for its current mandate.
        entity.agent.behavior = entity.behaviorForCurrentMandate
        
        /*
            `TaskBot`s recover to a full charge if they're hit with the beam but don't become "good".
            If this `TaskBot` has any charge, restore it to the full amount.
        */
        if let chargeComponent = entity.component(ofType: ChargeComponent.self), chargeComponent.hasCharge
        {
            let chargeToAdd = chargeComponent.maximumCharge - chargeComponent.charge
            chargeComponent.addCharge(chargeToAdd: chargeToAdd)
        }
        
//        guard let renderComponent = entity.component(ofType: RenderComponent.self) else { return }
//        let scene = renderComponent.node.scene as? LevelScene
//        self.destination = (scene?.meatWagonLocation())!
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        super.update(deltaTime: seconds)
        
//        print("entity: \(entity.debugDescription), Current behaviour mandate: \(entity.mandate), isWall: \(entity.isWall), requestWall: \(entity.requestWall), isSupporting: \(entity.isSupporting), wallComponentisTriggered: \(String(describing: entity.component(ofType: WallComponent.self)?.isTriggered))")
        
        // Update the "time since last behavior update" tracker.
        timeSinceBehaviorUpdate += seconds
        elapsedTime += seconds
        
        // Check if enough time has passed since the last behavior update, and update the behavior if so.
        if timeSinceBehaviorUpdate >= GameplayConfiguration.TaskBot.behaviorUpdateWaitDuration
        {
            
            // If PoliceBot nears CreateWall location, and has not already requested a wall, and is not already supporting another PoliceBot, then initiate wall formation
            if self.entity.isPolice && !self.entity.requestWall && !self.entity.isSupporting &&
                entity.distanceToPoint(otherPoint: destination) <= 300.0
            {
                print("PoliceBot close proximity to CreateWall node, entity: \(entity.debugDescription)")
                self.entity.requestWall = true
                self.entity.component(ofType: SpriteComponent.self)?.node.color = SKColor.brown
            }
            
            
            //Gradually increase the Police resistance
            if self.entity.isPolice,
                let resistanceComponent = entity.component(ofType: ResistanceComponent.self)
            {
                resistanceComponent.addResistance(resistanceToAdd: GameplayConfiguration.PoliceBot.resistanceRechargeAmountPerSecond)
            }
            
            //Gradually decrease the obeisance
            if let obeisanceComponent = entity.component(ofType: ObeisanceComponent.self), obeisanceComponent.hasObeisance
            {
                obeisanceComponent.loseObeisance(obeisanceToLose: GameplayConfiguration.ProtestorBot.obeisanceLossPerCycle)
            }

            
            let mandate = entity.mandate
            
            switch mandate
            {
                // When a `TaskBot` is moving along player path
                case .playerMovedTaskBot:
                    // print(entity.playerPathPoints.description)
                    
                    // Ensure we have a last position to check against, else dropout
                    guard let lastPos = entity.playerPathPoints.last else { return }
                    
                    
                    // When a `TaskBot` is nearing path patrol end, and gets near enough, it should start to wander.
                    if case .playerMovedTaskBot = entity.mandate, entity.distanceToPoint(otherPoint: float2(lastPos)) <= GameplayConfiguration.TaskBot.thresholdProximityToPatrolPathStartPoint
                    {
                        entity.mandate = .wander
//                        entity.stopAnimation()
                        entity.isPlayerControlled = false
                    }
                        
                    else
                    {
                        entity.mandate = .playerMovedTaskBot
                    }
                    break
                
                // When a `TaskBot` is close to the meatwagon, it should be removed from game
                case .lockupPrisoner:
 
                    if entity.distanceToPoint(otherPoint: destination) <= GameplayConfiguration.TaskBot.thresholdProximityToMeatwagonPoint
                    {
                        guard let intelligenceComponent = entity.component(ofType: IntelligenceComponent.self) else { return }
                        intelligenceComponent.stateMachine.enter(ProtestorDetainedState.self)
                    }

                    break
                
                case let .returnHome(position):
                    if entity.distanceToPoint(otherPoint: position) <= GameplayConfiguration.TaskBot.thresholdProximityToReturnPoint
                    {
                        
                        //If Protestor start consuming
                        if entity.isProtestor
                        {
                            //Check protestor has an appetite
                            guard let protestorAppetiteComponent = entity.component(ofType: AppetiteComponent.self) else { return }
                            protestorAppetiteComponent.isConsumingProduct = true
                            
                            guard let protestorBot = entity as? ProtestorBot else { return }
                            protestorBot.isConsuming = true
                            protestorBot.isHome = true
                            
                            entity.mandate = .crowd()
                        }
                    }
                    break
                
                // When a `TaskBot` is returning to its path patrol start, and gets near enough, it should start to patrol.
                case let .returnToPositionOnPath(position):
                    if entity.distanceToPoint(otherPoint: position) <= GameplayConfiguration.TaskBot.thresholdProximityToPatrolPathStartPoint
                    {
                        //If Protestor Criminal, wander
                        if entity.isProtestor
                        {
                            entity.mandate = .wander
                        }
                        
                        //If Police or Criminal, Patrol
                        else
                        {
                            entity.mandate = entity.isGood ? .followGoodPatrolPath : .followBadPatrolPath
                        }
                    }
                    break
                
                
                case .wander:
                    
//                    print("TaskBotAgentControlledState: wander")
//                    entity.mandate = .wander
                    
                    break
                
                case .incite:
//                    print("TaskBotAgentControlledState: incite")
                    entity.mandate = .incite
                    break
                
                case .sheep:
//                    print("TaskBotAgentControlledState: sheep")
//                    entity.mandate = .sheep(target)
                    break
                
                case let .formWall(target):
                    
                    //When Police get within proximity of the Police leader, switch on the entities wall component
                    if entity.distanceToPoint(otherPoint: target.position) <= 75.0
                    {
//                        print("Forming wall")
                        entity.component(ofType: WallComponent.self)?.isTriggered = true
//                        entity.mandate = entity.isGood ? .followGoodPatrolPath : .followBadPatrolPath
                        
                    }
                    break
                
                // When a `TaskBot` is in wall, do some shit...
                case .inWall:
                    
                    break
                
                default:
                    break
            }
            
//            print("entity: \(entity.debugDescription), Current behaviour mandate: \(entity.mandate), isArrested: \(entity.isArrested), elapsedTime: \(elapsedTime.debugDescription), distanceToPoint: \(entity.distanceToPoint(otherPoint: oldPosition))")
            
            //Check if taskbot has stayed in same position for long time, e.g. stuck in corner.  Move Taskbot away from current position
            if entity.distanceToPoint(otherPoint: oldPosition) <= 10.0 && elapsedTime >= 15.0 && !entity.isArrested
            {
                entity.mandate = .returnToPositionOnPath(float2(0.0,0.0))
            }
            
            guard let taskBot = entity as? TaskBot else { return }
            oldPosition = taskBot.agent.position
//            print("taskbot oldPosition: \(oldPosition.debugDescription)")
            
            // Ensure the agent's behavior is the appropriate behavior for its current mandate.
            entity.agent.behavior = entity.behaviorForCurrentMandate
            
//            print("entity: \(entity.debugDescription), Current behaviour mandate: \(entity.mandate), entity.behaviorForCurrentMandate: \(entity.behaviorForCurrentMandate)")
            
            // Reset `timeSinceBehaviorUpdate`, to delay when the entity's behavior is next updated.
            timeSinceBehaviorUpdate = 0.0
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool
    {
        //print("is ValidNextState stateClass:\(stateClass.description())")
        
        switch stateClass
        {
        case is TaskBotAgentControlledState.Type, is TaskBotZappedState.Type, is TaskBotPlayerControlledState.Type, is TaskBotFleeState.Type, is TaskBotInjuredState.Type,
              is PoliceBotPreAttackState.Type, is PoliceBotRotateToAttackState.Type, is PoliceBotAttackState.Type, is PoliceArrestState.Type, is PoliceDetainState.Type, is PoliceBotHitState.Type, is PoliceBotSupportState.Type, is PoliceBotFormWallState.Type, is PoliceBotInWallState.Type,
             is ProtestorBotPreAttackState.Type, is ProtestorBotRotateToAttackState.Type, is ProtestorBotAttackState.Type, is ProtestorBeingArrestedState.Type, is ProtestorArrestedState.Type, is ProtestorDetainedState.Type, is ProtestorBotHitState.Type, is ProtestorBotRechargingState.Type, is ProtestorInciteState.Type, is ProtestorBuyWaresState.Type, is ProtestorSheepState.Type, /*is ProtestorBotWanderState.Type,*/
             is SellWaresState.Type:
                return true
                
            default:
                return false
        }
    }
    
    override func willExit(to nextState: GKState)
    {
        super.willExit(to: nextState)
        
        /*
            The `TaskBot` will no longer be controlled by an agent in the steering simulation
            when it leaves the `TaskBotAgentControlledState`.
            Assign an empty behavior to cancel any active agent control.
        */
        entity.agent.behavior = GKBehavior()
    }
}

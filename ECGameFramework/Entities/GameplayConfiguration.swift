/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Configuration information and parameters for the game's gameplay. Adjust these numbers to modify how the game behaves.
*/

import Foundation
import CoreGraphics
import SpriteKit  //need for colour setting

struct GameplayConfiguration
{
    
    /*
        MARK:- Colour Bars for the various properties
    */
    struct ColourBar
    {
        // The size of the complete bar (back and level indicator).
        static let size = CGSize(width: 74.0, height: 10.0)
        
        // The size of the colored level bar.
        static let levelNodeSize = CGSize(width: 70.0, height: 6.0)
        
        /// The duration used for actions to update the level indicator.
        static let levelUpdateDuration = TimeInterval(0.1)
        
        // The background color.
        static let backgroundColour = SKColor.black
        
        // The charge level node color.
        static let foregroundLevelColour = SKColor.green
        
    }
    
    //  MARK:- SellingWaresComponent Bar
    //  Shows the quantity of products available for sale
    struct SellingWaresBar
    {
        // The charge level node color.
        static let foregroundLevelColour = SKColor.darkGray
        
        // The offset of the Entity's charge bar from its position.
        static let sellingWaresBarOffset = CGPoint(x: 0.0, y: 125.0)
    }
    
    
    //  MARK:- IntoxicationComponent Bar
    //  Shows the intoxication level of the Protestor
    struct IntoxicationBar
    {
        // The charge level node color.
        static let foregroundLevelColour = SKColor.orange
        
        // The offset of the Entity's charge bar from its position.
        static let intoxicationBarOffset = CGPoint(x: 0.0, y: 115.0)
    }
    
    
    //  MARK:- AppetiteComponent Bar
    //  Shows the appetite of the Protestor
    struct AppetiteBar
    {
        // The charge level node color.
        static let foregroundLevelColour = SKColor.white
        
        // The offset of the Entity's charge bar from its position.
        static let appetiteBarOffset = CGPoint(x: 0.0, y: 105.0)
    }
    
    
    //  MARK:- ChargeComponent Bar
    //  Shows the level of charge the TaskBot has
    struct ChargeBar
    {
        // The charge level node color.
        static let foregroundLevelColour = SKColor.blue
        
        // The offset of the Entity's charge bar from its position.
        static let chargeBarOffset = CGPoint(x: 0.0, y: 95.0)
    }

    
    //  MARK:- HealthBar Component
    //  Shows the level of health the TaskBot has
    struct HealthBar
    {
        // The charge level node color.
        static let foregroundLevelColour = SKColor.green
        
        // The offset of the Entity's charge bar from its position.
        static let healthBarOffset = CGPoint(x: 0.0, y: 85.0)
    }
    
    
    //  MARK:- ResistanceComponent bar
    //  Shows the level of resistance the TaskBot has (resistance to attacks and arrest)
    struct ResistanceBar
    {
        // The charge level node color.
        static let foregroundLevelColour = SKColor.red
        
        // The offset of the Entity's resistance bar from its position.
        static let resistanceBarOffset = CGPoint(x: 0.0, y: 75.0)
    }
    
    
    
    //  MARK:- RespectComponent bar
    //  Shows the level of respect the TaskBot has (how others percieve them)
    struct RespectBar
    {
        // The charge level node color.
        static let foregroundLevelColour = SKColor.yellow
        
        // The offset of the Entity's respect bar from its position.
        static let respectBarOffset = CGPoint(x: 0.0, y: 65.0)
    }
    
    
    //  MARK:- ObeisanceComponent Bar Properties
    //  Shows the level of obeisance the Protestor has towards the Player (can the player control them)
    struct ObeisanceBar
    {
        // The charge level node color.
        static let foregroundLevelColour = SKColor.lightGray
        
        // The offset of the Entity's respect bar from its position.
        static let obeisanceBarOffset = CGPoint(x: 0.0, y: 55.0)
    }
    
    
    /*
        MARK:- The Beam fired from the Player to other TaskBots
    */
    struct Beam
    {
        /// The distance (in points) over which the beam can be fired.
        static let arcLength: CGFloat = 300.0
        
        /// The arc angle (in radians) within which the beam is effective.
        static let arcAngle = CGFloat(45.0 * (Double.pi / 180.0))
        
        /// The maximum arc angle (in radians) after being adjusted for distance from target.
        static let maxArcAngle = CGFloat(0.35)
        
        /// The maximum number of seconds for which the beam can be fired before recharging.
        static let maximumFireDuration: TimeInterval = 2.0
        
        /// The amount of charge points the beam drains from `TaskBot`s per second.
        static let chargeLossPerSecond = 90.0
        
        /// The length of time that the beam takes to recharge when it is fully depleted.
        static let coolDownDuration: TimeInterval = 1.0
    }

    
    //  MARK:- BuyingWaresComponent & SellingWaresComponent Properties
    struct Wares
    {
        
        // The maximum number of seconds for selling and buying wares
        static let maximumSellingAndBuyingDuration: TimeInterval = 10.0
        
        // The length of time that to chill out between selling and buying wares
        static let timeOutPeriod: TimeInterval = 5.0
    }
    
    
    //  MARK:- InciteComponent Properties
    struct Incite
    {
        /// The distance (in points) over which the beam can be fired.
        static let arcLength: CGFloat = 300.0
        
        /// The arc angle (in radians) within which the beam is effective.
        static let arcAngle = CGFloat(45.0 * (Double.pi / 180.0))
        
        /// The maximum arc angle (in radians) after being adjusted for distance from target.
        static let maxArcAngle = CGFloat(0.35)
        
        /// The maximum number of seconds for which the beam can be fired before recharging.
        static let maximumIncitingDuration: TimeInterval = 10.0
        
        /// The amount of charge points the beam drains from `TaskBot`s per second.
        static let chargeLossPerSecond = 90.0
        
        /// The length of time that the beam takes to recharge when it is fully depleted.
        static let coolDownDuration: TimeInterval = 5.0
    }
    
    
    //  MARK:- Tazer Properties
    struct Tazer
    {
        /// The distance (in points) over which the beam can be fired.
        static let arcLength: CGFloat = 300.0
        
        /// The arc angle (in radians) within which the beam is effective.
        static let arcAngle = CGFloat(45.0 * (Double.pi / 180.0))
        
        /// The maximum arc angle (in radians) after being adjusted for distance from target.
        static let maxArcAngle = CGFloat(0.35)
        
        /// The maximum number of seconds for which the beam can be fired before recharging.
        static let maximumFireDuration: TimeInterval = 2.0
        
        /// The amount of charge points the beam drains from `TaskBot`s per second.
        static let damageLossPerSecond = 90.0
        
        /// The length of time that the beam takes to recharge when it is fully depleted.
        static let coolDownDuration: TimeInterval = 1.0
    }

    
    //  MARK:- IntoxicationComponent Properties
    struct Intoxication
    {
        static let maximumIntoxicationDuration: TimeInterval = 10.0
    }
    
    
    //  MARK:- OberveComponent Properties
    struct Observe
    {
        /// The length of time that the beam takes to recharge when it is fully depleted.
        static let coolDownDuration: TimeInterval = 1.0
        
        /// The maximum number of seconds for which the beam can be fired before recharging.
        static let maximumLookDuration: TimeInterval = 10.0
    }
    
    
    //  MARK:- AppetiteComponent Properties
    struct Appetite
    {
        /// The maximum number of seconds for which the beam can be fired before recharging.
//        static let maximumAppetiteDuration: TimeInterval = 10.0
    }
    
    
    
    //  MARK:- PlayerBot Properties
    struct PlayerBot
    {
        // The movement speed (in points per second) for the `PlayerBot`.
        static let movementSpeed: CGFloat = 210.0

        // The angular rotation speed (in radians per second) for the `PlayerBot`.
        static let angularSpeed = CGFloat(Double.pi) * 1.4
        
        // The radius of the `PlayerBot`'s physics body.
        static var physicsBodyRadius: CGFloat = 30.0
        
        // The offset of the `PlayerBot`'s physics body's center from the `PlayerBot`'s center.
        static let physicsBodyOffset = CGPoint(x: 0.0, y: -25.0)
        
        // The radius of the agent associated with this `PlayerBot` for pathfinding.
        static let agentRadius = Float(physicsBodyRadius)
        
        // The offset of the agent's center from the `PlayerBot`'s center.
        static let agentOffset = physicsBodyOffset
        
        // The offset of the `PlayerBot`'s antenna
        static let antennaOffset = CGPoint(x: 0.0, y: 50.0)

 
        // The initial charge value for the `PlayerBot`'s health bar.
        static let initialCharge = 100.0

        // The maximum charge value for the `PlayerBot`'s health bar.
        static let maximumHealth = 100.0
        
        // The maximum charge value for the `PlayerBot`'s health bar.
        static let maximumCharge = 100.0
        
        // The maximum amount of respect a `GroundBot` stores.
        static let maximumResistance = 100.0
        
        // The maximum amount of respect a `GroundBot` stores.
        static let maximumRespect = 100.0
        
        // The maximum amount of obeisance a `GroundBot` stores.
        static let maximumObeisance = 100.0
        

        
        // The length of time for which the `PlayerBot` remains in its "hit" state.
        static let hitStateDuration: TimeInterval = 0.75
        
        // The length of time that it takes the `PlayerBot` to recharge when deactivated.
        static let rechargeDelayWhenInactive: TimeInterval = 2.0
        
        // The amount of charge that the `PlayerBot` gains per second when recharging.
        static let rechargeAmountPerSecond = 10.0
        
        // The amount of time it takes the `PlayerBot` to appear in a level before becoming controllable by the player.
        static let appearDuration: TimeInterval = 0.50
    }
    
    
    
    //  MARK:- TaskBot Properties
    struct TaskBot
    {
        /// The length of time a `TaskBot` waits before re-evaluating its rules.
        static let rulesUpdateWaitDuration: TimeInterval = 1.0

        /// The length of time a `TaskBot` waits before re-checking for an appropriate behavior.
//        static let behaviorUpdateWaitDuration: TimeInterval = 0.25
        static let behaviorUpdateWaitDuration: TimeInterval = 1.0
        
        /// How close a `TaskBot` has to be to a patrol path start point in order to start patrolling.
        static let thresholdProximityToPatrolPathStartPoint: Float = 50.0
        
        // The minimum speed (in points per second) for the 'TaskBot'
        static let minimumSpeed: Float = 30.0
        
        /// The maximum speed (in points per second) for the `TaskBot` when in its "good" state.
        static let maximumSpeedWhenGood: Float = 100.0

        /// The maximum speed (in points per second) for the `TaskBot` when in its "bad" state.
        static let maximumSpeedWhenBad: Float = 100.0

        /// A convenience function to return the max speed for a state.
        static func maximumSpeedForIsGood(isGood: Bool) -> Float
        {
            return isGood ? maximumSpeedWhenGood : maximumSpeedWhenBad
        }
        
        /*
            `maximumAcceleration` is set to a high number to enable the TaskBot to turn very quickly.
            This ensures that the `TaskBot` can follow its patrol path more effectively.
        */
        /// The maximum acceleration (in points per second per second) for the `TaskBot`.
//        static let maximumAcceleration: Float = 10.0
        static let maximumAcceleration: Float = 1000.0

        /// The agent's mass.
        static let agentMass: Float = 0.25
        
        /// The radius of the `TaskBot`'s physics body.
        static var physicsBodyRadius: CGFloat = 26.0

        /// The offset of the `TaskBot` physics body's center from the `TaskBot`'s center.
        static let physicsBodyOffset = CGPoint(x: 0.0, y: 0.0)

        /// The radius (in points) of the agent associated with this `TaskBot` for steering.
        static let agentRadius = Float(physicsBodyRadius)
        
        /// The offset of the agent's center from the `TaskBot`'s center.
        static let agentOffset = physicsBodyOffset
        
        
        // A.I. Properties
        
        /// The maximum time to look ahead when following a path.
        static let maxPredictionTimeWhenFollowingPath: TimeInterval = 1.0
        
        /// The maximum time to look ahead for obstacles to be avoided.
        static let maxPredictionTimeForObstacleAvoidance: TimeInterval = 1.0
        
        /// The radius of the path along which an agent patrols.
        static let patrolPathRadius: Float = 10.0
        
        /// The radius of the path along which an agent travels when hunting.
        static let huntPathRadius: Float = 20.0

        /// The radius of the path along which an agent travels when wandering.
        static let wanderPathRadius: Float = 15.0

        /// The radius of the path along which an agent travels when fleeing.
        static let fleePathRadius: Float = 100.0
        
        // The radius of meatwagon location
        static let lockupRadius: Float = 25.0
        
        /// The radius of the path along which an agent travels when returning to its patrol path.
        static let returnToPatrolPathRadius: Float = 20.0
        
        /// The buffer radius (in points) to add to polygon obstacles when calculating agent pathfinding.
        static let pathfindingGraphBufferRadius: Float = 15.0
        
        /// How fast the `GroundBot` rotates to face its target in radians per second.
        static let preAttackRotationSpeed = Double.pi / 2
        
        /// The duration of a `TaskBot`'s pre-attack state.
        static let preAttackStateDuration: TimeInterval = 0.3
        
        /// The duration of a `TaskBot`'s zapped state.
        static let zappedStateDuration: TimeInterval = 0.75
        
        /// The duration of a `TaskBot`'s arresting state.
        static let arrestingStateDuration: TimeInterval = 2
        
        /// The duration of a `TaskBot`'s arrested state.
        static let arrestedStateDuration: TimeInterval = 5
        
        // How close a taskbot should be aligned with another (arrested)
        static let alignWithNeighbour: Float = 1.0
        
        // The alignment with neighbour angle
        static let alignWithNeighbourAngle: Float = 1
        
        /// The duration of a `TaskBot`'s being scared state.
        static let scaredStateDuration: TimeInterval = 10
        
        /// The duration of a `TaskBot`'s resistance cooldown state.
        static let resistanceCooldownDuration: TimeInterval = 5
        
        /// How close a `TaskBot` has to be to meatwagon point in order to be locked up
        static let thresholdProximityToMeatwagonPoint: Float = 50.0
    }
    
    
    
    //  MARK:- PoliceBot Properties
    struct PoliceBot
    {
        // MARK:- Physics Properties
        
        /*
         `maximumAcceleration` is set to a high number to enable the TaskBot to turn very quickly.
         This ensures that the `TaskBot` can follow its patrol path more effectively.
         */
        /// The maximum acceleration (in points per second per second) for the `TaskBot`.
//        static let maximumAcceleration: Float = 500.0
        
        // The agent's mass.
        static let agentMass: Float = 0.75

        
        /// The maximum speed (in points per second) for the `TaskBot` when in its "good" state.
        static let maximumSpeedWhenGood: Float = 50.0
        
        /// The maximum speed (in points per second) for the `TaskBot` when in its "bad" state.
        static let maximumSpeedWhenBad: Float = 75.0
        
        /// A convenience function to return the max speed for a state.
        static func maximumSpeedForIsGood(isGood: Bool) -> Float
        {
            return isGood ? maximumSpeedWhenGood : maximumSpeedWhenBad
        }
        
        

        // The radius of the path along which an agent patrols.
//        static let patrolPathRadius: Float = 10.0
        
        // The radius of the path along which an agent travels when hunting.
//        static let huntPathRadius: Float = 20.0

        // The radius of the path along which an agent travels when wandering.
//        static let wanderPathRadius: Float = 20.0
        
        // The radius of the path along which an agent travels when fleeing.
//        static let fleePathRadius: Float = 100.0
        

        
        /// The duration of a `TaskBot`'s zapped state.
        static let zappedStateDuration: TimeInterval = 0.75
        
        /// The duration of a `TaskBot`'s arresting state.
        static let arrestingStateDuration: TimeInterval = 2.0
        
        
        
        
        //MARK: Health Properties
        
        // The maximum amount of health a `GroundBot` stores.
        static let maximumHealth = 100.0
        
        // The amount of health a `PlayerBot` loses by a single `GroundBot` attack.
        static let healthLossPerContact = 15.0
        
        
        
        //MARK: Resistance Properties
        
        /// The maximum amount of resistance a `GroundBot` stores.
        static let maximumResistance = 100.0
        
        /// The amount of resistance a `PoliceBot` loses by a single `TaskBot` attack.
        static let resistanceLossPerContact = 5.0
        
        /// The amount of charge that the `PlayerBot` gains per second when recharging.
        static let resistanceRechargeAmountPerSecond = 2.0
        
        
        //MARK: Respect Properties
        
        /// The maximum amount of respect a `GroundBot` stores.
        static let maximumRespect = 100.0
        
        
        
        //MARK: Obeisance Properties
        
        /// The maximum amount of obesiance a `GroundBot` stores.
        static let maximumObesiance = 100.0
        
        /// The amount of obeisance a `PlayerBot` loses by a single `GroundBot` attack.
        static let obeisanceLossPerCycle = 1.0
        
        
        //MARK: Hit Properties
        
        /// The length of time for which the `PlayerBot` remains in its "hit" state.
        static let hitStateDuration: TimeInterval = 0.75
        
        
        
        //MARK: Charge Properties
        
        /// The maximum amount of charge a `GroundBot` stores.
        static let maximumCharge = 100.0
        
        /// The amount of charge a `PlayerBot` loses by a single `GroundBot` attack.
 //       static let chargeLossPerContact = 20.0
        
        /// The length of time that it takes the `ProtestorBot` to recharge when deactivated.
        static let rechargeDelayWhenInactive: TimeInterval = 2.0
        
        /// The amount of charge that the `ProtestorBot` gains per second when recharging.
        static let rechargeAmountPerSecond = 10.0
        
        
        //MARK: Attack Properties
        
        /// The duration of a `TaskBot`'s pre-attack state.
        static let preAttackStateDuration: TimeInterval = 0.3
        
        /// The amount of damage the PoliceBot delivers
        static let damageDealtPerContact = 20.0
        
        /// The maximum distance a `GroundBot` can be from a target before it attacks.
        static let maximumAttackDistance: Float = 150.0
        
        /// Proximity to the target after which the `GroundBot` attack should end.
        static let attackEndProximity: Float = 7.0
        
        /// How fast the `GroundBot` rotates to face its target in radians per second.
        static let preAttackRotationSpeed = Double.pi
        
        /// How much faster the `GroundBot` can move when attacking.
        static let movementSpeedMultiplierWhenAttacking: CGFloat = 2.5
        
        /// How much faster the `GroundBot` can rotate when attacking.
        static let angularSpeedMultiplierWhenAttacking: CGFloat = 2.5
        
        /// The amount of time to wait between `GroundBot` attacks.
        static let delayBetweenAttacks: TimeInterval = 2.0
        
        /// The offset from the `GroundBot`'s position that should be used for beam targeting.
        static let beamTargetOffset = CGPoint(x: 0.0, y: 40.0)
        
        
        
        //MARK: Flee Properties
        
        /// How much faster the `GroundBot` can move when attacking.
        static let movementSpeedMultiplierWhenFleeing: CGFloat = 5.0
        
    }
    
    
    //  MARK:- ProtestorBot Properties
    struct ProtestorBot
    {
        
        // MARK:- Physics Properties
        
        /*
         `maximumAcceleration` is set to a high number to enable the TaskBot to turn very quickly.
         This ensures that the `TaskBot` can follow its patrol path more effectively.
         */
        /// The maximum acceleration (in points per second per second) for the `TaskBot`.
        static let maximumAcceleration: Float = 100.0
        
        // The agent's mass.
        static let agentMass: Float = 0.25
        
        /// The maximum speed (in points per second) for the `TaskBot` when in its "good" state.
        static let maximumSpeedWhenGood: Float = 50.0
        
        /// The maximum speed (in points per second) for the `TaskBot` when in its "bad" state.
        static let maximumSpeedWhenBad: Float = 75.0
        
        /// A convenience function to return the max speed for a state.
        static func maximumSpeedForIsGood(isGood: Bool) -> Float
        {
            return isGood ? maximumSpeedWhenGood : maximumSpeedWhenBad
        }


        // The radius of the path along which an agent patrols.
//        static let patrolPathRadius: Float = 10.0
        
        // The radius of the path along which an agent travels when hunting.
//        static let huntPathRadius: Float = 20.0
        
        // The radius of the path along which an agent travels when wandering.
//        static let wanderPathRadius: Float = 20.0
        
        // The radius of the path along which an agent travels when fleeing.
//        static let fleePathRadius: Float = 100.0
        

        
        /// The duration of a `TaskBot`'s zapped state.
        static let zappedStateDuration: TimeInterval = 0.75
        
        /// The duration of a `TaskBot`'s arresting state.
        static let arrestingStateDuration: TimeInterval = 2.0
        
        /// The duration of a `TaskBot`'s arresting state.
        static let maximumSpeedForIsGood: Float = 150.0
        
        
        //MARK: Health Properties
        
        // The maximum amount of health a `GroundBot` stores.
        static let maximumHealth = 100.0
        
        // The amount of health a `PlayerBot` loses by a single `GroundBot` attack.
        static let healthLossPerContact = 15.0
        
        
        
        //MARK: Resistance Properties
        
        /// The maximum amount of resistance a `GroundBot` stores.
        static let maximumResistance = 100.0
        
        /// The amount of resistance a `PlayerBot` loses by a single `GroundBot` attack.
        static let resistanceLossPerContact = 20.0
        
        /// The amount of charge that the `PlayerBot` gains per second when recharging.
        static let resistanceRechargeAmountPerSecond = 1.0
        
        
        //MARK: Respect Properties
        
        /// The maximum amount of respect a `GroundBot` stores.
        static let maximumRespect = 100.0
        
        
        
        //MARK: Appetite Properties
        
        /// The maximum amount of appetite a `GroundBot` stores.
        static let maximumAppetite = 100.0
        
        /// The amount of appetite a `Protestor gains per cycle
        static let appetiteGainPerCycle = 0.1
        
        
        
        // The amount of appetite a Protestor loses per cycle
        static let appetiteLossPerCycle = 0.01
        
        //MARK: Intoxication Properties
        
        /// The maximum amount of intoxication a `GroundBot` stores.
        static let maximumIntoxication = 100.0
        
        /// The amount of intoxication a `Protestor` gains each cycle
        static let intoxicationGainPerCycle = 1.0
        
        
        //MARK: Obeisance Properties
        
        /// The maximum amount of obesiance a `GroundBot` stores.
        static let maximumObesiance = 100.0
        
        /// The amount of obeisance a `PlayerBot` loses by a single `GroundBot` attack.
        static let obeisanceLossPerCycle = 1.0
        
        
        //MARK: Hit Properties
        
        /// The length of time for which the `PlayerBot` remains in its "hit" state.
        static let hitStateDuration: TimeInterval = 0.75
        
        
        
        //MARK: Charge Properties
        
        /// The maximum amount of charge a `GroundBot` stores.
        static let maximumCharge = 100.0
        
        /// The amount of charge a `PlayerBot` loses by a single `GroundBot` attack.
        static let chargeLossPerContact = 20.0
        
        /// The length of time that it takes the `ProtestorBot` to recharge when deactivated.
        static let rechargeDelayWhenInactive: TimeInterval = 2.0
        
        /// The amount of charge that the `ProtestorBot` gains per second when recharging.
        static let rechargeAmountPerSecond = 10.0
        

        //MARK: Attack Properties
        
        /// The duration of a `TaskBot`'s pre-attack state.
        static let preAttackStateDuration: TimeInterval = 0.3
        
        /// The amount of damage the ProtestorBot delivers
        static let damageDealtPerContact = 20.0
        
        /// The maximum distance a `GroundBot` can be from a target before it attacks.
        static let maximumAttackDistance: Float = 100.0
        
        /// Proximity to the target after which the `GroundBot` attack should end.
        static let attackEndProximity: Float = 7.0
        
        /// How fast the `GroundBot` rotates to face its target in radians per second.
        static let preAttackRotationSpeed = Double.pi / 4
        
        /// How much faster the `GroundBot` can move when attacking.
        static let movementSpeedMultiplierWhenAttacking: CGFloat = 2.5
        
        /// How much faster the `GroundBot` can rotate when attacking.
        static let angularSpeedMultiplierWhenAttacking: CGFloat = 10.0
        
        /// The amount of time to wait between `GroundBot` attacks.
        static let delayBetweenAttacks: TimeInterval = 1.0
        
        /// The offset from the `GroundBot`'s position that should be used for beam targeting.
        static let beamTargetOffset = CGPoint(x: 0.0, y: 40.0)
        

        
        //MARK: Flee Properties
        
        /// How much faster the `GroundBot` can move when attacking.
        static let movementSpeedMultiplierWhenFleeing: CGFloat = 5.0
    }
    
    
    
    //  MARK:- CriminalBot Properties
    struct CriminalBot
    {
      
        // MARK:- Physics Properties
        
        /*
         `maximumAcceleration` is set to a high number to enable the TaskBot to turn very quickly.
         This ensures that the `TaskBot` can follow its patrol path more effectively.
         */
        /// The maximum acceleration (in points per second per second) for the `TaskBot`.
        static let maximumAcceleration: Float = 500.0
        
        // The agent's mass.
        static let agentMass: Float = 0.50
        
        /// The maximum speed (in points per second) for the `TaskBot` when in its "good" state.
        static let maximumSpeedWhenGood: Float = 80.0
        
        /// The maximum speed (in points per second) for the `TaskBot` when in its "bad" state.
        static let maximumSpeedWhenBad: Float = 100.0
        
        /// A convenience function to return the max speed for a state.
        static func maximumSpeedForIsGood(isGood: Bool) -> Float
        {
            return isGood ? maximumSpeedWhenGood : maximumSpeedWhenBad
        }
        
        
        // The radius of the path along which an agent patrols.
//        static let patrolPathRadius: Float = 10.0
        
        // The radius of the path along which an agent travels when hunting.
//        static let huntPathRadius: Float = 20.0
        
        // The radius of the path along which an agent travels when wandering.
//        static let wanderPathRadius: Float = 20.0
        
        // The radius of the path along which an agent travels when fleeing.
//        static let fleePathRadius: Float = 100.0
        
        /// The duration of a `TaskBot`'s pre-attack state.
        static let preAttackStateDuration: TimeInterval = 0.3
        
        /// The duration of a `TaskBot`'s zapped state.
        static let zappedStateDuration: TimeInterval = 0.75
        
        /// The duration of a `TaskBot`'s arresting state.
        static let arrestingStateDuration: TimeInterval = 2
        
        
        //MARK: Health Properties
        
        // The maximum amount of health a `GroundBot` stores.
        static let maximumHealth = 100.0
        
        // The amount of health a `PlayerBot` loses by a single `GroundBot` attack.
        static let healthLossPerContact = 15.0
        
        //MARK: Appetite Properties
        
        /// The maximum amount of appetite a `GroundBot` stores.
        static let maximumAppetite = 100.0
        
        /// The amount of appetite a `PlayerBot` loses by a single `GroundBot` attack.
        static let appetiteLossPerCycle = 1.0
        
        
        
        //MARK: Intoxication Properties
        
        /// The maximum amount of intoxication a `GroundBot` stores.
        static let maximumIntoxication = 100.0
        
        /// The amount of intoxication a `PlayerBot` loses by a single `GroundBot` attack.
        static let intoxicationLossPerCycle = 1.0
        
        
        //MARK: Resistance Properties
        
        /// The maximum amount of resistance a `GroundBot` stores.
        static let maximumResistance = 100.0
        
        /// The amount of resistance a `CriminalBot` loses by a single `TaskBot` attack.
        static let resistanceLossPerContact = 20.0
        
        /// The amount of charge that the `CriminalBot` gains per second when recharging.
        static let resistanceRechargeAmountPerSecond = 0.5
        
        
        //MARK: Respect Properties
        
        /// The maximum amount of respect a `GroundBot` stores.
        static let maximumRespect = 100.0
        
        
        
        //MARK: Obeisance Properties
        
        /// The maximum amount of obesiance a `GroundBot` stores.
        static let maximumObeisance = 100.0
        
        /// The amount of obeisance a `PlayerBot` loses by a single `GroundBot` attack.
        static let obeisanceLossPerCycle = 1.0
        
        
        //MARK: SellingWares Properties
        
        /// The maximum amount of obesiance a `GroundBot` stores.
        static let maximumWares = 100.0
        
        /// The amount of product a `CriminalBot` loses by a single `Protestor` purchase.
        static let sellingWaresLossPerCycle = 1.0
        
        
        //MARK: Hit Properties
        
        /// The length of time for which the `PlayerBot` remains in its "hit" state.
        static let hitStateDuration: TimeInterval = 0.75
        
        
        
        //MARK: Charge Properties
        
        /// The maximum amount of charge a `GroundBot` stores.
        static let maximumCharge = 100.0
        
        /// The amount of charge a `PlayerBot` loses by a single `GroundBot` attack.
        static let chargeLossPerContact = 20.0
        
        /// The length of time that it takes the `ProtestorBot` to recharge when deactivated.
        static let rechargeDelayWhenInactive: TimeInterval = 2.0
        
        /// The amount of charge that the `ProtestorBot` gains per second when recharging.
        static let rechargeAmountPerSecond = 10.0
        
        
        //MARK: Attack Properties
        
        /// The amount of damage the CriminalBot delivers
        static let damageDealtPerContact = 20.0
        
        /// The maximum distance a `GroundBot` can be from a target before it attacks.
        static let maximumAttackDistance: Float = 100.0
        
        /// Proximity to the target after which the `GroundBot` attack should end.
        static let attackEndProximity: Float = 7.0
        
        /// How fast the `GroundBot` rotates to face its target in radians per second.
        static let preAttackRotationSpeed = Double.pi / 4
        
        /// How much faster the `GroundBot` can move when attacking.
        static let movementSpeedMultiplierWhenAttacking: CGFloat = 2.5
        
        /// How much faster the `GroundBot` can rotate when attacking.
        static let angularSpeedMultiplierWhenAttacking: CGFloat = 10.0
        
        /// The amount of time to wait between `GroundBot` attacks.
        static let delayBetweenAttacks: TimeInterval = 2.0
        
        /// The offset from the `GroundBot`'s position that should be used for beam targeting.
        static let beamTargetOffset = CGPoint(x: 0.0, y: 40.0)
        
        
        
        //MARK: Flee Properties
        
        /// How much faster the `GroundBot` can move when attacking.
        static let movementSpeedMultiplierWhenFleeing: CGFloat = 5.0
        
    }

    
    //  MARK:- FlyingBot Properties
    struct FlyingBot
    {
        /// The maximum amount of charge a `FlyingBot` stores.
        static let maximumCharge = 100.0
        
        /// The radius of a `FlyingBot` blast.
        static let blastRadius: Float = 100.0
        
        /// The amount of charge a `FlyingBot` blast drains from `PlayerBot`s per second.
        static let blastChargeLossPerSecond = 25.0

        /// The duration of a `FlyingBot` blast.
        static let blastDuration: TimeInterval = 1.25
        
        /// The duration over which a `FlyingBot` blast affects entities in its blast radius.
        static let blastEffectDuration: TimeInterval = 0.75

        /// The offset from the `FlyingBot`'s position for the blast particle emitter node.
        static let blastEmitterOffset = CGPoint(x: 0.0, y: 20.0)
        
        /// The offset from the `FlyingBot`'s position that should be used for beam targeting.
        static let beamTargetOffset = CGPoint(x: 0.0, y: 65.0)
    }

    
    //  MARK:- GroundBot Properties
    struct GroundBot
    {
        /// The maximum amount of charge a `GroundBot` stores.
        static let maximumCharge = 100.0
        
        /// The amount of charge a `PlayerBot` loses by a single `GroundBot` attack.
        static let chargeLossPerContact = 25.0
        
        /// The maximum distance a `GroundBot` can be from a target before it attacks.
        static let maximumAttackDistance: Float = 300.0
        
        /// Proximity to the target after which the `GroundBot` attack should end.
        static let attackEndProximity: Float = 7.0
        
        /// How fast the `GroundBot` rotates to face its target in radians per second.
        static let preAttackRotationSpeed = Double.pi / 4
        
        /// How much faster the `GroundBot` can move when attacking.
        static let movementSpeedMultiplierWhenAttacking: CGFloat = 2.5
        
        /// How much faster the `GroundBot` can rotate when attacking.
        static let angularSpeedMultiplierWhenAttacking: CGFloat = 2.5
        
        /// The amount of time to wait between `GroundBot` attacks.
        static let delayBetweenAttacks: TimeInterval = 2.0
        
        /// The offset from the `GroundBot`'s position that should be used for beam targeting.
        static let beamTargetOffset = CGPoint(x: 0.0, y: 40.0)
    }
    
    
    
    //  MARK:- ManBot Properties
    struct ManBot
    {
        /// The maximum amount of charge a `GroundBot` stores.
        static let maximumCharge = 100.0
        
        /// The amount of charge a `PlayerBot` loses by a single `GroundBot` attack.
        static let chargeLossPerContact = 25.0
        
        /// The maximum distance a `GroundBot` can be from a target before it attacks.
        static let maximumAttackDistance: Float = 300.0
        
        /// Proximity to the target after which the `GroundBot` attack should end.
        static let attackEndProximity: Float = 7.0
        
        /// How fast the `GroundBot` rotates to face its target in radians per second.
        static let preAttackRotationSpeed = Double.pi / 4
        
        /// How much faster the `GroundBot` can move when attacking.
        static let movementSpeedMultiplierWhenAttacking: CGFloat = 2.5
        
        /// How much faster the `GroundBot` can rotate when attacking.
        static let angularSpeedMultiplierWhenAttacking: CGFloat = 2.5
        
        /// The amount of time to wait between `GroundBot` attacks.
        static let delayBetweenAttacks: TimeInterval = 2.0
        
        /// The offset from the `GroundBot`'s position that should be used for beam targeting.
        static let beamTargetOffset = CGPoint(x: 0.0, y: 40.0)
    }
    
    
    //  MARK:- Flocking Properties
    struct Flocking
    {
        /// Separation, alignment, and cohesion parameters for multiple `TaskBot`s.
        static let separationRadius: Float = 25.3
        static let separationAngle = Float (3 * Double.pi / 4)
        static let separationWeight: Float = 2.0
        
        static let alignmentRadius: Float = 43.333
        static let alignmentAngle = Float(Double.pi / 4)
        static let alignmentWeight: Float = 1.667
        
        static let cohesionRadius: Float = 50.0
        static let cohesionAngle = Float(Double.pi / 2)
        static let cohesionWeight: Float = 1.667
        
        static let agentSearchDistanceForFlocking: Float = 50.0
        static let agentSearchDistanceForArrest: Float = 50.0
        static let agentSupportSearchDistanceForArrest: Float = 500.0
    }
    
    
    //  MARK:- TouhcControl Properties
    struct TouchControl
    {
        /// The minimum distance a virtual thumbstick must move before it is considered to have been moved.
        static let minimumRequiredThumbstickDisplacement: Float = 0.35
        
        /// The minimum size for an on-screen control.
        static let minimumControlSize: CGFloat = 140
        
        /// The ideal size for an on-screen control as a ratio of the scene's width.
        static let idealRelativeControlSize: CGFloat = 0.15
    }
    
    
    //  MARK:- SceneManager Properties
    struct SceneManager
    {
        /// The duration of a transition between loaded scenes.
        static let transitionDuration: TimeInterval = 1.0
        
        /// The duration of a transition from the progress scene to its loaded scene.
        static let progressSceneTransitionDuration: TimeInterval = 0.5
    }
    
    
    //  MARK:- Timer Properties
    struct Timer
    {
        /// The name of the font to use for the timer.
        static let fontName = "DINCondensed-Bold"
        
        /// The size of the timer node font as a proportion of the level scene's height.
        static let fontSize: CGFloat = 0.05
        
        #if os(tvOS)
        /// The size of padding between the top of the scene and the timer node.
        static let paddingSize: CGFloat = 60.0
        #else
        /// The size of padding between the top of the scene and the timer node as a proportion of the timer node's font size.
        static let paddingSize: CGFloat = 0.2
        #endif
    }
}

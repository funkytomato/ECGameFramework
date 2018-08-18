/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    This file introduces the rules used by the `TaskBot` rule system to determine an appropriate action for the `TaskBot`. The rules fall into three distinct sets:
                Percentage of bad `TaskBot`s in the level (low, medium, high):
                    `BadTaskBotPercentageLowRule`
                    `BadTaskBotPercentageMediumRule`
                    `BadTaskBotPercentageHighRule`
                How close the `TaskBot` is to the `PlayerBot` (near, medium, far):
                    `PlayerBotNearRule`
                    `PlayerBotMediumRule`
                    `PlayerBotFarRule`
                How close the `TaskBot` is to its nearest "good" `TaskBot` (near, medium, far):
                    `TaskBotNearRule`
                    `TaskBotMediumRule`
                    `TaskBotFarRule`
 
                 Percentage of Police `TaskBot`s in the level (low, medium, high):
                     `PoliceTaskBotPercentageLowRule`
                     `PoliceTaskBotPercentageMediumRule`
                     `PoliceTaskBotPercentageHighRule`
                 How close the `TaskBot` is to the `PlayerBot` (near, medium, far):
                     `PlayerBotNearRule`
                     `PlayerBotMediumRule`
                     `PlayerBotFarRule`
                 How close the `TaskBot` is to its nearest "Protestor" `TaskBot` (near, medium, far):
                     `TaskBotNearRule`
                     `TaskBotMediumRule`
                     `TaskBotFarRule`
*/

import GameplayKit

enum Fact: String
{
    // Fuzzy rules pertaining to the proportion of "Police" bots in the level.
    case policeTaskBotPercentageLow = "PoliceTaskBotPercentageLow"
    case policeTaskBotPercentageMedium = "PoliceTaskBotPercentageMedium"
    case policeTaskBotPercentageHigh = "PoliceTaskBotPercentageHigh"

    // Fuzzy rules pertaining to this `TaskBot`'s proximity to the `PoliceBot`.
    case policeBotNear = "PoliceBotNear"
    case policeBotMedium = "PoliceBotMedium"
    case policeBotFar = "PoliceBotFar"
    
    // Fuzzy rules pertaining to this 'TaskBot''s proximity to a PoliceBot in trouble
    case policeBotInTroubleNear = "PoliceBotInTroubleNear"
    case policeBotInTroubleMedium = "PoliceBotInTroubleMedium"
    case policeBotInTroubleFar = "PoliceBotInTroubleFar"
    
    // Fuzzy rules pertaining to this `TaskBot`'s proximity to the `PlayerBot`.
    case playerBotNear = "PlayerBotNear"
    case playerBotMedium = "PlayerBotMedium"
    case playerBotFar = "PlayerBotFar"

    // Fuzzy rules pertaining to this `TaskBot`'s proximity to the nearest "RingLeader" `TaskBot`.
    case ringLeaderTaskBotNear = "RingLeaderTaskBotNear"
    case ringLeaderTaskBotMedium = "RingLeaderTaskBotMedium"
    case ringLeaderTaskBotFar = "RingLeaderTaskBotFar"
    
    // Fuzzy rules pertaining to this `TaskBot`'s proximity to the nearest "Protestor" `TaskBot`.
    case protestorTaskBotNear = "ProtestorTaskBotNear"
    case protestorTaskBotMedium = "ProtestorTaskBotMedium"
    case protestorTaskBotFar = "ProtestorTaskBotFar"
    
    // Fuzzy rules pertaining to the proportion of "Subservient" bots in the level.
    case subservientTaskBotPercentageLow = "SubservientTaskBotPercentageLow"
    case subservientTaskBotPercentageMedium = "SubservientTaskBotPercentageMedium"
    case subservientTaskBotPercentageHigh = "SubservientTaskBotPercentageHigh"
    
    // Fuzzy rules pertaining to this `TaskBot`'s proximity to the nearest "Subservient" `TaskBot`.
    case subservientTaskBotNear = "SubservientTaskBotNear"
    case subservientTaskBotMedium = "SubservientTaskBotMedium"
    case subservientTaskBotFar = "SubservientTaskBotFar"
    
    // Fuzzy rules pertaining to the proportion of "Dangerous" bots in the level.  A dangerous taskbot is violent and attacking, either Police or Protestor
    case dangerousTaskBotPercentageLow = "DangerousTaskBotPercentageLow"
    case dangerousTaskBotPercentageMedium = "DangerousTaskBotPercentageMedium"
    case dangerousTaskBotPercentageHigh = "DangerousTaskBotPercentageHigh"
    
    // Fuzzy rules pertaining to this `TaskBot`'s proximity to the nearest "Dangerous Protestor" `TaskBot`.
    case dangerousTaskBotNear = "DangerousProtestorTaskBotNear"
    case dangerousTaskBotMedium = "DangerousProtestorTaskBotMedium"
    case dangerousTaskBotFar = "DangerousProtestorTaskBotFar"
    
    // Fuzzy rules pertaining to this `TaskBot`'s proximity to the nearest "Scared Protestor" `TaskBot`.
    case scaredTaskBotNear = "ScaredTaskBotNear"
    case scaredTaskBotMedium = "ScaredTaskBotMedium"
    case scaredTaskBotFar = "ScaredTaskBotFar"

    // Fuzzy rules pertaining to the proportion of "Criminal" bots in the level.
    case criminalTaskBotPercentageLow = "CriminalTaskBotPercentageLow"
    case criminalTaskBotPercentageMedium = "CriminalTaskBotPercentageMedium"
    case criminalTaskBotPercentageHigh = "CriminalTaskBotPercentageHigh"
    
    // Fuzzy rules pertaining to this `TaskBot`'s proximity to the nearest "Criminal" `TaskBot`.
    case criminalTaskBotNear = "CriminalTaskBotNear"
    case criminalTaskBotMedium = "CriminalTaskBotMedium"
    case criminalTaskBotFar = "CriminalTaskBotFar"
    
    // Fuzzy rules pertaining to this `TaskBot`'s proximity to the nearest "Seller" `TaskBot`.
    case sellerTaskBotNear = "SellerTaskBotNear"
    case sellerTaskBotMedium = "SellerTaskBotMedium"
    case sellerTaskBotFar = "SellerTaskBotFar"

    // Fuzzy rules pertaining to this `TaskBot`'s proximity to the nearest "Buyer" `TaskBot`.
    case buyerTaskBotNear = "BuyerTaskBotNear"
    case buyerTaskBotMedium = "BuyerTaskBotMedium"
    case buyerTaskBotFar = "BuyerTaskBotFar"
    
    // Fuzzy rules pertaining to the proportion of "Injured" bots in the level.
    case injuredTaskBotPercentageLow = "InjuredTaskBotPercentageLow"
    case injuredTaskBotPercentageMedium = "InjuredTaskBotPercentageMedium"
    case injuredTaskBotPercentageHigh = "InjuredTaskBotPercentageHigh"
    
    // Fuzzy rules pertaining to this `TaskBot`'s proximity to the nearest "Injured" `TaskBot`.
    case injuredTaskBotNear = "InjuredTaskBotNear"
    case injuredTaskBotMedium = "InjuredTaskBotMedium"
    case injuredTaskBotFar = "InjuredTaskBotFar"
}

/// Asserts whether the number of "bad" `TaskBot`s is considered "low".
class PoliceTaskBotPercentageLowRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        return max(0.0, 1.0 - 3.0 * snapshot.policeBotPercentage)
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .policeTaskBotPercentageLow) }
    
    deinit {
//        print("Deallocating PoliceTaskBotPercentageLowRule")
    }
}

/// Asserts whether the number of "Police" `TaskBot`s is considered "medium".
class PoliceTaskBotPercentageMediumRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        if snapshot.policeBotPercentage <= 1.0 / 3.0
        {
            return min(1.0, 3.0 * snapshot.policeBotPercentage)
        }
        else
        {
            return max(0.0, 1.0 - (3.0 * snapshot.policeBotPercentage - 1.0))
        }
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .policeTaskBotPercentageMedium) }
    
    deinit {
//        print("Deallocating PoliceTaskBotPercentageMediumRule")
    }
}

/// Asserts whether the number of "bad" `TaskBot`s is considered "high".
class PoliceTaskBotPercentageHighRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        return min(1.0, max(0.0, (3.0 * snapshot.policeBotPercentage - 1)))
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .policeTaskBotPercentageHigh) }
    
    deinit {
//        print("Deallocating PoliceTaskBotPercentageHighRule")
    }
}

/// Asserts whether the `PoliceBot` is considered to be "near" to this `TaskBot`.
class PoliceBotNearRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        guard let distance = snapshot.nearestPoliceTaskBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return (oneThird - distance) / oneThird
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .policeBotNear) }
    
    deinit {
//        print("Deallocating PoliceBotNearRule")
    }
}

/// Asserts whether the `PoliceBot` is considered to be at a "medium" distance from this `TaskBot`.
class PoliceBotMediumRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        guard let distance = snapshot.nearestPoliceTaskBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return 1 - (fabs(distance - oneThird) / oneThird)
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .policeBotMedium) }
    
    deinit {
//        print("Deallocating PoliceBotMediumRule")
    }
}

/// Asserts whether the `PoliceBot` is considered to be "far" from this `TaskBot`.
class PoliceBotFarRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        guard let distance = snapshot.nearestPoliceTaskBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return (distance - oneThird) / oneThird
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .policeBotFar) }
    
    deinit {
//        print("Deallocating PoliceBotFarRule")
    }
}


/// Asserts whether the `PoliceBot` is considered to be "near" to this `TaskBot`.
class PoliceBotInTroubleNearRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        guard let distance = snapshot.nearestPoliceTaskBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return (oneThird - distance) / oneThird
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .policeBotNear) }
    
    deinit {
//        print("Deallocating PoliceBotNearRule")
    }
}

/// Asserts whether the `PoliceBot` is considered to be at a "medium" distance from this `TaskBot`.
class PoliceBotInTroubleMediumRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        guard let distance = snapshot.nearestPoliceTaskBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return 1 - (fabs(distance - oneThird) / oneThird)
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .policeBotMedium) }
    
    deinit {
//        print("Deallocating PoliceBotMediumRule")
    }
}

/// Asserts whether the `PoliceBot` is considered to be "far" from this `TaskBot`.
class PoliceBotInTroubleFarRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        guard let distance = snapshot.nearestPoliceTaskBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return (distance - oneThird) / oneThird
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .policeBotFar) }
    
    deinit {
//        print("Deallocating PoliceBotFarRule")
    }
}



/// Asserts whether the number of "bad" `TaskBot`s is considered "low".
class DangerousTaskBotPercentageLowRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        return max(0.0, 1.0 - 3.0 * snapshot.dangerousBotPercentage)
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .dangerousTaskBotPercentageLow) }
    
    deinit {
//        print("Deallocating DangerousTaskBotPercentageLowRule")
    }
}

/// Asserts whether the number of "Dangerous" `TaskBot`s is considered "medium".
class DangerousTaskBotPercentageMediumRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        if snapshot.dangerousBotPercentage <= 1.0 / 3.0
        {
            return min(1.0, 3.0 * snapshot.dangerousBotPercentage)
        }
        else
        {
            return max(0.0, 1.0 - (3.0 * snapshot.dangerousBotPercentage - 1.0))
        }
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .dangerousTaskBotPercentageMedium) }
    
    deinit {
//        print("Deallocating DangerousTaskBotPercentageMediumRule")
    }
}

/// Asserts whether the number of "Dangerous" `TaskBot`s is considered "high".
class DangerousTaskBotPercentageHighRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        return min(1.0, max(0.0, (3.0 * snapshot.dangerousBotPercentage - 1)))
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .dangerousTaskBotPercentageHigh) }
    
    deinit {
//        print("Deallocating DangerousTaskBotPercentageHighRule")
    }
}






/// Asserts whether the `PlayerBot` is considered to be "near" to this `TaskBot`.
class PlayerBotNearRule: FuzzyTaskBotRule
{
    // MARK: Properties

    override func grade() -> Float
    {
        guard let distance = snapshot.playerBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return (oneThird - distance) / oneThird
    }

    // MARK: Initializers
    
    init() { super.init(fact: .playerBotNear) }
    
    deinit {
//        print("Deallocating PlayerBotNearRule")
    }
}

/// Asserts whether the `PlayerBot` is considered to be at a "medium" distance from this `TaskBot`.
class PlayerBotMediumRule: FuzzyTaskBotRule
{
    // MARK: Properties

    override func grade() -> Float
    {
        guard let distance = snapshot.playerBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return 1 - (fabs(distance - oneThird) / oneThird)
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .playerBotMedium) }
    
    deinit {
//        print("Deallocating PlayerBotMediumRule")
    }
}

/// Asserts whether the `PlayerBot` is considered to be "far" from this `TaskBot`.
class PlayerBotFarRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        guard let distance = snapshot.playerBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return (distance - oneThird) / oneThird
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .playerBotFar) }
    
    deinit {
//        print("Deallocating PlayerBotfarRule")
    }
}

// MARK: TaskBot Proximity Rules


/// Asserts whether the nearest "RingLeader" `TaskBot` is considered to be "near" to this `TaskBot`.
class RingLeaderTaskBotNearRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        guard let distance = snapshot.nearestRingLeaderTaskBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return (oneThird - distance) / oneThird
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .ringLeaderTaskBotNear) }
    
    deinit {
        //        print("Deallocating RingLeaderTaskBotNearRule")
    }
}

/// Asserts whether the nearest "Protestor" `TaskBot` is considered to be at a "medium" distance from this `TaskBot`.
class RingLeaderTaskBotMediumRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        guard let distance = snapshot.nearestRingLeaderTaskBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return 1 - (fabs(distance - oneThird) / oneThird)
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .ringLeaderTaskBotMedium) }
    
    deinit {
        //        print("Deallocating RingLeaderTaskBotMediumRule")
    }
}

/// Asserts whether the nearest "Protestor" `TaskBot` is considered to be "far" from this `TaskBot`.
class RingLeaderTaskBotFarRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        guard let distance = snapshot.nearestRingLeaderTaskBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return (distance - oneThird) / oneThird
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .ringLeaderTaskBotFar) }
    
    deinit {
        //        print("Deallocating RingLeaderTaskBotFarRule")
    }
}

/// Asserts whether the nearest "Protestor" `TaskBot` is considered to be "near" to this `TaskBot`.
class ProtestorTaskBotNearRule: FuzzyTaskBotRule
{
    // MARK: Properties

    override func grade() -> Float
    {
        guard let distance = snapshot.nearestProtestorTaskBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return (oneThird - distance) / oneThird
    }

    // MARK: Initializers
    
    init() { super.init(fact: .protestorTaskBotNear) }
    
    deinit {
//        print("Deallocating ProtestorTaskBotNearRule")
    }
}

/// Asserts whether the nearest "Protestor" `TaskBot` is considered to be at a "medium" distance from this `TaskBot`.
class ProtestorTaskBotMediumRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        guard let distance = snapshot.nearestProtestorTaskBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return 1 - (fabs(distance - oneThird) / oneThird)
    }

    // MARK: Initializers
    
    init() { super.init(fact: .protestorTaskBotMedium) }
    
    deinit {
//        print("Deallocating ProtestorTaskBotMediumRule")
    }
}

/// Asserts whether the nearest "Protestor" `TaskBot` is considered to be "far" from this `TaskBot`.
class ProtestorTaskBotFarRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        guard let distance = snapshot.nearestProtestorTaskBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return (distance - oneThird) / oneThird
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .protestorTaskBotFar) }
    
    deinit {
//        print("Deallocating ProtestorTaskBotFarRule")
    }
}


/// Asserts whether the number of "Subservient" `TaskBot`s is considered "low".
class SubservientTaskBotPercentageLowRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        return max(0.0, 1.0 - 3.0 * snapshot.subservientBotPercentage)
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .subservientTaskBotPercentageLow) }
    
    deinit {
//        print("Deallocating SubservientTaskBotPercentageLowRule")
    }
}

/// Asserts whether the number of "Subservient" `TaskBot`s is considered "medium".
class SubservientTaskBotPercentageMediumRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        if snapshot.subservientBotPercentage <= 1.0 / 3.0
        {
            return min(1.0, 3.0 * snapshot.subservientBotPercentage)
        }
        else
        {
            return max(0.0, 1.0 - (3.0 * snapshot.subservientBotPercentage - 1.0))
        }
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .subservientTaskBotPercentageMedium) }
    
    deinit {
//        print("Deallocating SubservientTaskBotPercentageMediumRule")
    }
}

/// Asserts whether the number of "Subservient" `TaskBot`s is considered "high".
class SubservientTaskBotPercentageHighRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        return min(1.0, max(0.0, (3.0 * snapshot.subservientBotPercentage - 1)))
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .subservientTaskBotPercentageHigh) }
    
    deinit {
//        print("Deallocating SubservientTaskBotPercentageHighRule")
    }
}


/// Asserts whether the nearest "Subservient Protestor" `TaskBot` is considered to be "near" to this `TaskBot`.
class SubservientTaskBotNearRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        guard let distance = snapshot.nearestSubservientTaskBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return (oneThird - distance) / oneThird
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .subservientTaskBotNear) }
    
    deinit {
//        print("Deallocating ProtestorTaskBotNearRule")
    }
}

/// Asserts whether the nearest "Subservient Protestor" `TaskBot` is considered to be at a "medium" distance from this `TaskBot`.
class SubservientTaskBotMediumRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        guard let distance = snapshot.nearestSubservientTaskBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return 1 - (fabs(distance - oneThird) / oneThird)
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .subservientTaskBotMedium) }
    
    deinit {
//        print("Deallocating SubservientTaskBotMediumRule")
    }
}

/// Asserts whether the nearest "Subservient Protestor" `TaskBot` is considered to be "far" from this `TaskBot`.
class SubservientTaskBotFarRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        guard let distance = snapshot.nearestSubservientTaskBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return (distance - oneThird) / oneThird
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .subservientTaskBotFar) }
    
    deinit {
//        print("Deallocating SubservientTaskBotFarRule")
    }
}




/// Asserts whether the nearest "Dangerous" `TaskBot` is considered to be "near" to this `TaskBot`.
class DangerousProtestorTaskBotNearRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        guard let distance = snapshot.nearestDangerousTaskBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return (oneThird - distance) / oneThird
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .dangerousTaskBotNear) }
    
    deinit {
//        print("Deallocating DangerousProtestorTaskBotNearRule")
    }
}

/// Asserts whether the nearest "Dangerous" `TaskBot` is considered to be at a "medium" distance from this `TaskBot`.
class DangerousProtestorTaskBotMediumRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        guard let distance = snapshot.nearestDangerousTaskBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return 1 - (fabs(distance - oneThird) / oneThird)
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .dangerousTaskBotMedium) }
    
    deinit {
//        print("Deallocating DangerousProtestorTaskBotMediumRule")
    }
}

/// Asserts whether the nearest "Dangerous" `TaskBot` is considered to be "far" from this `TaskBot`.
class DangerousProtestorTaskBotFarRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        guard let distance = snapshot.nearestDangerousTaskBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return (distance - oneThird) / oneThird
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .dangerousTaskBotFar) }
    
    deinit {
//        print("Deallocating DangerousProtestorTaskBotFarRule")
    }
}

/// Asserts whether the nearest "Scared" `TaskBot` is considered to be "near" to this `TaskBot`.
class ScaredTaskBotNearRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        guard let distance = snapshot.nearestScaredTaskBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return (oneThird - distance) / oneThird
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .scaredTaskBotNear) }
    
    deinit {
//        print("Deallocating ScaredTaskBotNearRule")
    }
}

/// Asserts whether the nearest "Scared" `TaskBot` is considered to be at a "medium" distance from this `TaskBot`.
class ScaredTaskBotMediumRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        guard let distance = snapshot.nearestScaredTaskBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return 1 - (fabs(distance - oneThird) / oneThird)
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .scaredTaskBotMedium) }
    
    deinit {
//        print("Deallocating ScaredTaskBotMediumRule")
    }
}

/// Asserts whether the nearest "Scared" `TaskBot` is considered to be "far" from this `TaskBot`.
class ScaredTaskBotFarRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        guard let distance = snapshot.nearestScaredTaskBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return (distance - oneThird) / oneThird
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .scaredTaskBotFar) }
    
    deinit {
//        print("Deallocating ScaredTaskBotFarRule")
    }
}

/// Asserts whether the number of "criminal" `TaskBot`s is considered "low".
class CriminalTaskBotPercentageLowRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        return max(0.0, 1.0 - 3.0 * snapshot.criminalBotPercentage)
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .criminalTaskBotPercentageLow) }
    
    deinit {
//        print("Deallocating CriminalTaskBotPercentageLowRule")
    }
}

/// Asserts whether the number of "Criminal" `TaskBot`s is considered "medium".
class CriminalTaskBotPercentageMediumRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        if snapshot.criminalBotPercentage <= 1.0 / 3.0
        {
            return min(1.0, 3.0 * snapshot.criminalBotPercentage)
        }
        else
        {
            return max(0.0, 1.0 - (3.0 * snapshot.criminalBotPercentage - 1.0))
        }
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .criminalTaskBotPercentageMedium) }
    
    deinit {
//        print("Deallocating CriminalTaskBotPercentageMediumRule")
    }
}

/// Asserts whether the number of "Criminal" `TaskBot`s is considered "high".
class CriminalTaskBotPercentageHighRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        return min(1.0, max(0.0, (3.0 * snapshot.criminalBotPercentage - 1)))
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .criminalTaskBotPercentageHigh) }
    
    deinit {
//        print("Deallocating CriminalTaskBotPercentageHighRule")
    }
}

/// Asserts whether the nearest "Criminal" `TaskBot` is considered to be "near" to this `TaskBot`.
class CriminalTaskBotNearRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        guard let distance = snapshot.nearestCriminalTaskBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return (oneThird - distance) / oneThird
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .criminalTaskBotNear) }
    
    deinit {
//        print("Deallocating CriminalTaskBotNearRule")
    }
}

/// Asserts whether the nearest "Criminal" `TaskBot` is considered to be at a "medium" distance from this `TaskBot`.
class CriminalTaskBotMediumRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        guard let distance = snapshot.nearestCriminalTaskBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return 1 - (fabs(distance - oneThird) / oneThird)
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .criminalTaskBotMedium) }
    
    deinit {
//        print("Deallocating CriminalTaskBotMediumRule")
    }
}

/// Asserts whether the nearest "Criminal" `TaskBot` is considered to be "far" from this `TaskBot`.
class CriminalTaskBotFarRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        guard let distance = snapshot.nearestCriminalTaskBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return (distance - oneThird) / oneThird
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .criminalTaskBotFar) }
    
    deinit {
//        print("Deallocating CriminalTaskBotFarRule")
    }
}


/// Asserts whether the nearest "Criminal Seller" `TaskBot` is considered to be "near" to this `TaskBot`.
class SellerTaskBotNearRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        guard let distance = snapshot.nearestSellerTaskBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return (oneThird - distance) / oneThird
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .sellerTaskBotNear) }
    
    deinit {
//        print("Deallocating SellerTaskBotNearRule")
    }
}

/// Asserts whether the nearest "Criminal" `TaskBot` is considered to be at a "medium" distance from this `TaskBot`.
class SellerTaskBotMediumRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        guard let distance = snapshot.nearestSellerTaskBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return 1 - (fabs(distance - oneThird) / oneThird)
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .sellerTaskBotMedium) }
    
    deinit {
//        print("Deallocating CriminalTaskBotMediumRule")
    }
}

/// Asserts whether the nearest "Criminal" `TaskBot` is considered to be "far" from this `TaskBot`.
class SellerTaskBotFarRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        guard let distance = snapshot.nearestSellerTaskBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return (distance - oneThird) / oneThird
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .sellerTaskBotFar) }
    
    deinit {
//        print("Deallocating CriminalTaskBotFarRule")
    }
}


/// Asserts whether the nearest "Criminal Seller" `TaskBot` is considered to be "near" to this `TaskBot`.
class BuyerTaskBotNearRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        guard let distance = snapshot.nearestBuyerTaskBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return (oneThird - distance) / oneThird
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .buyerTaskBotNear) }
    
    deinit {
        //        print("Deallocating SellerTaskBotNearRule")
    }
}

/// Asserts whether the nearest "Criminal" `TaskBot` is considered to be at a "medium" distance from this `TaskBot`.
class BuyerTaskBotMediumRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        guard let distance = snapshot.nearestBuyerTaskBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return 1 - (fabs(distance - oneThird) / oneThird)
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .buyerTaskBotMedium) }
    
    deinit {
        //        print("Deallocating CriminalTaskBotMediumRule")
    }
}

/// Asserts whether the nearest "Criminal" `TaskBot` is considered to be "far" from this `TaskBot`.
class BuyerTaskBotFarRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        guard let distance = snapshot.nearestBuyerTaskBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return (distance - oneThird) / oneThird
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .buyerTaskBotFar) }
    
    deinit {
        //        print("Deallocating CriminalTaskBotFarRule")
    }
}


/// Asserts whether the number of "Injured" `TaskBot`s is considered "low".
class InjuredTaskBotPercentageLowRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        return max(0.0, 1.0 - 3.0 * snapshot.injuredBotPercentage)
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .injuredTaskBotPercentageLow) }
    
    deinit {
//        print("Deallocating InjuredTaskBotPercentageLowRule")
    }
}

/// Asserts whether the number of "Injured" `TaskBot`s is considered "medium".
class InjuredTaskBotPercentageMediumRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        if snapshot.injuredBotPercentage <= 1.0 / 3.0
        {
            return min(1.0, 3.0 * snapshot.injuredBotPercentage)
        }
        else
        {
            return max(0.0, 1.0 - (3.0 * snapshot.injuredBotPercentage - 1.0))
        }
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .injuredTaskBotPercentageMedium) }
    
    deinit {
//        print("Deallocating InjuredTaskBotPercentageMediumRule")
    }
}

/// Asserts whether the number of "Injured" `TaskBot`s is considered "high".
class InjuredTaskBotPercentageHighRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        return min(1.0, max(0.0, (3.0 * snapshot.injuredBotPercentage - 1)))
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .injuredTaskBotPercentageHigh) }
    
    deinit {
//        print("Deallocating InjuredTaskBotPercentageHighRule")
    }
}


/// Asserts whether the nearest "Injured" `TaskBot` is considered to be "near" to this `TaskBot`.
class InjuredTaskBotNearRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        guard let distance = snapshot.nearestInjuredTaskBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return (oneThird - distance) / oneThird
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .injuredTaskBotNear) }
    
    deinit {
//        print("Deallocating InjuredTaskBotNearRule")
    }
}

/// Asserts whether the nearest "Injured" `TaskBot` is considered to be at a "medium" distance from this `TaskBot`.
class InjuredTaskBotMediumRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        guard let distance = snapshot.nearestInjuredTaskBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return 1 - (fabs(distance - oneThird) / oneThird)
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .injuredTaskBotMedium) }
    
    deinit {
//        print("Deallocating InjuredTaskBotMediumRule")
    }
    
}

/// Asserts whether the nearest "Injured" `TaskBot` is considered to be "far" from this `TaskBot`.
class InjuredTaskBotFarRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        guard let distance = snapshot.nearestInjuredTaskBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return (distance - oneThird) / oneThird
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .injuredTaskBotFar) }
    
    deinit {
//        print("Deallocating InjuredTaskBotFarRule")
    }
}

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

    // Fuzzy rules pertaining to this `TaskBot`'s proximity to the `PlayerBot`.
    case playerBotNear = "PlayerBotNear"
    case playerBotMedium = "PlayerBotMedium"
    case playerBotFar = "PlayerBotFar"

    // Fuzzy rules pertaining to this `TaskBot`'s proximity to the nearest "Protestor" `TaskBot`.
    case protestorTaskBotNear = "ProtestorTaskBotNear"
    case protestorTaskBotMedium = "ProtestorTaskBotMedium"
    case protestorTaskBotFar = "ProtestorTaskBotFar"
    
    // Fuzzy rules pertaining to this `TaskBot`'s proximity to the nearest "Dangerous Protestor" `TaskBot`.
    case dangerousProtestorTaskBotNear = "DangerousProtestorTaskBotNear"
    case dangerousProtestorTaskBotMedium = "DangerousProtestorTaskBotMedium"
    case dangerousProtestorTaskBotFar = "DangerousProtestorTaskBotFar"
    
    // Fuzzy rules pertaining to this `TaskBot`'s proximity to the nearest "Scared Protestor" `TaskBot`.
    case scaredTaskBotNear = "ScaredTaskBotNear"
    case scaredTaskBotMedium = "ScaredTaskBotMedium"
    case scaredTaskBotFar = "ScaredTaskBotFar"
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
}

// MARK: TaskBot Proximity Rules

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
}


/// Asserts whether the nearest "Violent Protestor" `TaskBot` is considered to be "near" to this `TaskBot`.
class DangerousProtestorTaskBotNearRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        guard let distance = snapshot.nearestDangerousProtestorTaskBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return (oneThird - distance) / oneThird
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .dangerousProtestorTaskBotNear) }
}

/// Asserts whether the nearest "Violent Protestor" `TaskBot` is considered to be at a "medium" distance from this `TaskBot`.
class DangerousProtestorTaskBotMediumRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        guard let distance = snapshot.nearestDangerousProtestorTaskBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return 1 - (fabs(distance - oneThird) / oneThird)
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .dangerousProtestorTaskBotMedium) }
}

/// Asserts whether the nearest "Protestor" `TaskBot` is considered to be "far" from this `TaskBot`.
class DangerousProtestorTaskBotFarRule: FuzzyTaskBotRule
{
    // MARK: Properties
    
    override func grade() -> Float
    {
        guard let distance = snapshot.nearestDangerousProtestorTaskBotTarget?.distance else { return 0.0 }
        let oneThird = snapshot.proximityFactor / 3
        return (distance - oneThird) / oneThird
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .dangerousProtestorTaskBotFar) }
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
}

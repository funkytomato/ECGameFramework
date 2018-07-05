/*
//
//  ColourBar.swift
//  ECGameFramework
//
//  Created by Jason Fry on 09/06/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//
Abstract:
An `SKSpriteNode` subclass that displays a `PlayerBot`'s remaining charge.
*/

import SpriteKit

class ColourBar: SKSpriteNode
{
    // MARK: Static Properties
    
    struct Configuration
    {
        /// The size of the complete bar (back and level indicator).
        static let size = GameplayConfiguration.ColourBar.size
        
        /// The size of the colored level bar.
        static let chargeLevelNodeSize = GameplayConfiguration.ColourBar.levelNodeSize
        
        /// The duration used for actions to update the level indicator.
        static let levelUpdateDuration: TimeInterval = GameplayConfiguration.ColourBar.levelUpdateDuration
        
        /// The background color.
        static let backgroundColor = GameplayConfiguration.ColourBar.backgroundColour
        
        /// The charge level node color.
        static let chargeLevelColor = GameplayConfiguration.ColourBar.foregroundLevelColour
    }
    
    // MARK: Properties
    
    var level: Double = 1.0
    {
        didSet
        {
            // Scale the level bar node based on the current health level.
            let action = SKAction.scaleX(to: CGFloat(level), duration: Configuration.levelUpdateDuration)
            action.timingMode = .easeInEaseOut
            
            chargeLevelNode.run(action)
        }
    }
    
    /// A node representing the charge level.
    let chargeLevelNode = SKSpriteNode(color: Configuration.chargeLevelColor, size: Configuration.chargeLevelNodeSize)
    
    // MARK: Initializers
    
    init(levelColour: SKColor)
    {
        super.init(texture: nil, color: Configuration.backgroundColor, size: Configuration.size)
        
        chargeLevelNode.color = levelColour
        
        addChild(chargeLevelNode)
        
        // Constrain the position of the `chargeLevelNode`.
        let xRange = SKRange(constantValue: chargeLevelNode.size.width / -2.0)
        let yRange = SKRange(constantValue: 0.0)
        
        let constraint = SKConstraint.positionX(xRange, y: yRange)
        constraint.referenceNode = self
        
        chargeLevelNode.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        chargeLevelNode.constraints = [constraint]
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
//        print("Deallocating ChargeBar")
    }
}

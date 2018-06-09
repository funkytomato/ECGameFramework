/*
//
//  RespectBar.swift
//  ECGameFramework
//
//  Created by Jason Fry on 09/06/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
An `SKSpriteNode` subclass that displays a `PlayerBot`'s remaining charge.
*/

import SpriteKit

class RespectBar: SKSpriteNode
{
    // MARK: Static Properties
    
    struct Configuration
    {
        /// The size of the complete bar (back and level indicator).
        static let size = CGSize(width: 74.0, height: 10.0)
        
        /// The size of the colored level bar.
        static let chargeLevelNodeSize = CGSize(width: 70.0, height: 6.0)
        
        /// The duration used for actions to update the level indicator.
        static let levelUpdateDuration: TimeInterval = 0.1
        
        /// The background color.
        static let backgroundColor = SKColor.black
        
        /// The charge level node color.
        static let respectLevelColor = SKColor.green
    }
    
    // MARK: Properties
    
    var level: Double = 1.0
    {
        didSet
        {
            // Scale the level bar node based on the current health level.
            let action = SKAction.scaleX(to: CGFloat(level), duration: Configuration.levelUpdateDuration)
            action.timingMode = .easeInEaseOut
            
            respectLevelNode.run(action)
        }
    }
    
    /// A node representing the charge level.
    let respectLevelNode = SKSpriteNode(color: Configuration.respectLevelColor, size: Configuration.chargeLevelNodeSize)
    
    // MARK: Initializers
    
    init()
    {
        super.init(texture: nil, color: Configuration.backgroundColor, size: Configuration.size)
        
        addChild(respectLevelNode)
        
        // Constrain the position of the `chargeLevelNode`.
        let xRange = SKRange(constantValue: respectLevelNode.size.width / -2.0)
        let yRange = SKRange(constantValue: 0.0)
        
        let constraint = SKConstraint.positionX(xRange, y: yRange)
        constraint.referenceNode = self
        
        respectLevelNode.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        respectLevelNode.constraints = [constraint]
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("Deallocating RespectBar")
    }
}


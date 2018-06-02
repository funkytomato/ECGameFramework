/*
//
//  ResistanceBar.swift
//  ECGameFramework
//
//  Created by Jason Fry on 03/05/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
An `SKSpriteNode` subclass that displays a `PlayerBot`'s remaining resistance.
*/

import SpriteKit

class ResistanceBar: SKSpriteNode
{
    // MARK: Static Properties
    
    struct Configuration
    {
        /// The size of the complete bar (back and level indicator).
        static let size = CGSize(width: 74.0, height: 10.0)
        
        /// The size of the colored level bar.
        static let resistanceLevelNodeSize = CGSize(width: 70.0, height: 6.0)
        
        /// The duration used for actions to update the level indicator.
        static let levelUpdateDuration: TimeInterval = 0.1
        
        /// The background color.
        static let backgroundColor = SKColor.black
        
        /// The resistance level node color.
        static let resistanceLevelColor = SKColor.white
    }
    
    // MARK: Properties
    
    var level: Double = 1.0
    {
        didSet
        {
            // Scale the level bar node based on the current health level.
            let action = SKAction.scaleX(to: CGFloat(level), duration: Configuration.levelUpdateDuration)
            action.timingMode = .easeInEaseOut
            
            resistanceLevelNode.run(action)
        }
    }
    
    /// A node representing the resistance level.
    let resistanceLevelNode = SKSpriteNode(color: Configuration.resistanceLevelColor, size: Configuration.resistanceLevelNodeSize)
    
    // MARK: Initializers
    
    init()
    {
        super.init(texture: nil, color: Configuration.backgroundColor, size: Configuration.size)
        
        addChild(resistanceLevelNode)
        
        // Constrain the position of the `resistanceLevelNode`.
        let xRange = SKRange(constantValue: resistanceLevelNode.size.width / -2.0)
        let yRange = SKRange(constantValue: 0.0)
        
        let constraint = SKConstraint.positionX(xRange, y: yRange)
        constraint.referenceNode = self
        
        resistanceLevelNode.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        resistanceLevelNode.constraints = [constraint]
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("Deallocating ResistanceBar")
    }
}

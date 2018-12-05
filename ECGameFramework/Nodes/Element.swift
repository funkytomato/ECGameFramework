//
//  Element.swift
//  SKSpriteNode Colour Change
//
//  Created by Spaceman on 05/12/2018.
//  Copyright © 2018 Spaceman. All rights reserved.
//
import SpriteKit

class Element: SKNode
{
    
    var texture : SKTexture?
    
    var green : SKSpriteNode?
    var red : SKSpriteNode?
    
    override init()
    {
        texture = SKTexture(imageNamed: "Green")
        green = SKSpriteNode(imageNamed: "Green")
        red = SKSpriteNode(imageNamed: "Red")
        
        
        super.init()
        self.addChild(green!)
        red!.alpha = 0
        self.addChild(red!)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    // colorProgressionRatio must be a value between 1 (full green) and 0 (full red)
    func update(colorProgressionRatio: CGFloat)
    {
        guard colorProgressionRatio >= 0 && colorProgressionRatio <= 1 else {
            debugPrint("colorProgressionRatio must be a value between 0 and 1")
            return
        }
        
        let greenIntensity: CGFloat
        let redIntensity: CGFloat
        
        if colorProgressionRatio == 0
        {
            greenIntensity = 0
            redIntensity = 1
        } else if colorProgressionRatio == 1 
        {
            greenIntensity = 1
            redIntensity = 0
        } else
        {
            greenIntensity = colorProgressionRatio
            redIntensity = 1 - colorProgressionRatio
        }
        
        green!.run(.fadeAlpha(to: greenIntensity, duration: 2))
        red!.run(.fadeAlpha(to: redIntensity, duration: 2))
        
    }
    
    func turnRed(duration: TimeInterval)
    {
        green!.run(.fadeOut(withDuration: duration))
        red!.run(.fadeIn(withDuration: duration))
    }
}


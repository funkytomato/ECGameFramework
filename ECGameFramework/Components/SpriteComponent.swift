//
//  SpriteComponent.swift
//  ECGameFramework
//
//  Created by Jason Fry on 06/03/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

import SpriteKit
import GameplayKit

class SpriteComponent: GKComponent
{
    // MARK:- Properties
    
    //The SpriteNode
    let node : SKSpriteNode

    var oldColour: SKColor
    
    //MARK:- Initialisers
    init(entity: GKEntity, texture: SKTexture, textureSize: CGSize)
    {
        oldColour = .clear
        node = SKSpriteNode(texture: nil, size: textureSize)
        node.entity = entity
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- GKComponent
    
    override func update(deltaTime: TimeInterval)
    {
        super.update(deltaTime: deltaTime)
    }
    
    
    // Convenience methods
    func changeColour(colour: SKColor)
    {
        oldColour = node.color
        node.color = colour
    }
    
    func revertColour()
    {
        node.color = oldColour
    }

    
    /*
    func addToNodeKey()
    {
        self.node.userData = NSMutableDictionary()
        self.node.userData?.setObject(self.entity!, forKey: "entity" as NSCopying)
    }
    */
    func entityTouched (touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        print("SpriteComponent entityTouched!!!")
    
    }
}

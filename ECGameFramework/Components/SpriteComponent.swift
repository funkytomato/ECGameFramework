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

    
    //MARK:- Initialisers
    init(entity: GKEntity, texture: SKTexture, textureSize: CGSize)
    {
        node = EntityNode(texture: texture, size: textureSize)
        node.entity = entity
        
        //node = SKSpriteNode(texture: nil, size: textureSize)
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
        node.color = colour
    }
    
    func entityTouched (touches: Set<UITouch>, withEvent event: UIEvent?) {}
}

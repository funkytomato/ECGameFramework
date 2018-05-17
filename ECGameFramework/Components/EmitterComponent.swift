//
//  EmitterComponent.swift
//  ECGameFramework
//
//  Created by Jason Fry on 10/03/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

import SpriteKit
import GameplayKit


class EmitterComponent: GKComponent
{
    // MARK :- Properties
    
    //The Emitter Node
    let node : SKEmitterNode
    
    var defaultParticleBirthRate : Float
    
    
    // MARK :- Initialisers
    init(particleName: String)
    {
        
        node = SKEmitterNode(fileNamed: particleName)!
        
        defaultParticleBirthRate = Float(node.particleBirthRate)
        node.position = CGPoint(x: 0, y: 0)
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime: TimeInterval)
    {
        super.update(deltaTime: deltaTime)
    }
}

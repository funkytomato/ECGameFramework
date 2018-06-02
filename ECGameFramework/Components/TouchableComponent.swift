//
//  TouchableComponent.swift
//  ECGameFramework
//
//  Created by Jason Fry on 11/05/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

import GameplayKit
import SpriteKit

class TouchableComponent: GKComponent
{
    
    var touchControlSpriteNode: TouchControlSpriteNode?

    var entityTouched: ()->Void;
    
    init(f:@escaping () -> Void)
    {
        self.entityTouched = f
        
        super.init()
    }

    /*
    override init()
    {
        touchControlSpriteNode = TouchControlSpriteNode(size: CGSize(width: 120, height: 120))
        
        super.init()
    }
    */
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("Deallocating TouchableComponent")
    }
    
    func setPath(path: [float2])
    {
//        self.entityTouched()
    }
    
    func callFunction()
    {
        self.entityTouched()
    }
}

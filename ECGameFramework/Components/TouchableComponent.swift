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
    
    var entityTouched: ()->Void;
    
    init(f:@escaping () -> Void)
    {
        self.entityTouched = f
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func callFunction() {
        self.entityTouched()
    }
}

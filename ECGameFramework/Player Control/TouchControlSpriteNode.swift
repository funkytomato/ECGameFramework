/*
//
//  TouchControlSpriteNode.swift
//  ECGameFramework
//
//  Created by Jason Fry on 13/05/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//

Abstract:
An implementation of the `ControlInputSourceType` protocol that enables support for touch-based thumbsticks on iOS.
*/

import SpriteKit
import GameplayKit

class TouchControlSpriteNode: SKSpriteNode, ControlInputSourceType
{

    
    var allowsStrafing: Bool
    
    // MARK: Properties
    
    /// `ControlInputSourceType` delegates.
    weak var delegate: ControlInputSourceDelegate?
    var gameStateDelegate: ControlInputSourceGameStateDelegate?
    
    // MARK: Initialization
    
    /*
     `TouchControlSpriteNode` is intended as an overlay for the entire screen,
     therefore the `frame` is usually the scene's bounds or something equivalent.
     */
    init(size: CGSize)
    {
        
        allowsStrafing = false
        
        super.init(texture: nil, color: .clear, size: size)
        
        /*
         A `TouchControlInputNode` is designed to receive all user interaction
         and forwards it along to the child nodes.
         */
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("Deallocating TouchControlSpriteNode")
    }
    
    // MARK: ControlInputSourceType
    
    func resetControlState()
    {
        // Nothing to do here.
    }
    
    // MARK: UIResponder
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        super.touchesBegan(touches, with: event)
 /*
        for touch in touches
        {
            let touchPoint = touch.location(in: self)
            
         }
 */
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        super.touchesMoved(touches, with: event)

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        super.touchesEnded(touches, with: event)
        
        /*
        for touch in touches
        {
            let touchPoint = touch.location(in: self)
            
        }
 */
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?)
    {
        super.touchesCancelled(touches!, with: event)
    }
}


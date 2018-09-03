/*
//
//  JointComponent.swift
//  ECGameFramework
//
//  Created by Jason Fry on 01/09/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//
Abstract:
A `GKComponent` that supplies and manages the 'TaskBot's inciting others.

A TaskBot can only incite others periodically and can only influence others nearby.
*/

import SpriteKit
import GameplayKit

class JointComponent: GKComponent
{
    // MARK: Types
    
    
    // MARK: Properties
    
    /// Set to `true` whenever the player is holding down the attack button.
    var isTriggered = false
    
    var physicsJoint : SKPhysicsJointLimit?
    
    
    /// The `RenderComponent' for this component's 'entity'.
    var renderComponent: RenderComponent
    {
        guard let renderComponent = entity?.component(ofType: RenderComponent.self) else { fatalError("A InciteComponent's entity must have a RenderComponent") }
        return renderComponent
    }
    
    /// The `RenderComponent' for this component's 'entity'.
    var animationComponent: AnimationComponent
    {
        guard let animationComponent = entity?.component(ofType: AnimationComponent.self) else { fatalError("A InciteComponent's entity must have a AnimationComponent") }
        return animationComponent
    }
    
    
    // MARK: Initializers
    
    init(physicsJoint: SKPhysicsJointLimit, entityA: SKPhysicsBody, entityB: SKPhysicsBody)
    {
        
        let physicsJoint = SKPhysicsJointLimit.joint(withBodyA: entityA, bodyB: entityB, anchorA: CGPoint(x: 0.5, y: 0.0), anchorB: CGPoint(x: -0.5, y: 0.0))
        self.physicsJoint = physicsJoint
        
//        self.physicsJoint = physicsJoint
//        self.physicsJoint.maxLength = 10.0
//        self.physicsJoint.bodyA = entityA
//        self.physicsJoint.bodyB = entityB

        
//        guard let policeBot = agent.entity as? PoliceBot else { return }
//        guard let policePhysicsComponent = policeBot.component(ofType: PhysicsComponent.self) else { return }
//
//        guard let policeSupport = target.entity as? PoliceBot else { return }
//        guard let policeSupportPhysicsComponent = policeSupport.component(ofType: PhysicsComponent.self) else { return }
//        joint = SKPhysicsJointLimit.joint(withBodyA: <#T##SKPhysicsBody#>, bodyB: <#T##SKPhysicsBody#>, anchorA: <#T##CGPoint#>, anchorB: <#T##CGPoint#>)
        
        
        
//        var myJoint = SKPhysicsJointPin.joint(withBodyA: policePhysicsComponent.physicsBody, bodyB: policeSupportPhysicsComponent.physicsBody, anchor: CGPoint(x: 0.5, y: 0.0))
//
   
        super.init()
     }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit
    {
        //        print("Deallocating JointComponent")
    }
}


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
    
//    var entity: GKEntity?
    
    // MARK: Types
    let kPinnedNode = "pinned"
    let kSatelliteNode = "satellite"
    let kJointOutlineNode = "jointoutline"
    let kPinDotNode = "pindot"
    let kSatelliteDotNode = "satellitedot"
    let kLineNode = "lineNode"
    
    enum JointLabels : String
    {
        case Pin = "Pin"
        case Fixed = "Fixed"
        case Spring = "Spring"
        case Sliding = "Sliding"
        case Limit = "Limit"
    }
    
    var thisJoint = SKNode()
    var entityB : TaskBot?
    var pinDot : SKShapeNode?
    var satelliteDot : SKShapeNode?
    var lineNode : SKShapeNode?
    
    // MARK: Properties
    
    /// Set to `true` whenever the player is holding down the attack button.
    var isTriggered = false
    
//    var physicsJoint : SKPhysicsJointLimit?
    
    
    /// The `RenderComponent' for this component's 'entity'.
    var renderComponent: RenderComponent
    {
        guard let renderComponent = entity?.component(ofType: RenderComponent.self) else { fatalError("A JointComponent's entity must have a RenderComponent") }
        return renderComponent
    }
    
    
    // MARK: Initializers
    
    init(entity: TaskBot)
    {
//        var parent = JointOutline()
//        parent.name = kJointOutlineNode
//        self.entity = entity
        self.entityB = nil
        
        super.init()
        
//        let pinDot = SKShapeNode(circleOfRadius: 6)
//        pinDot.fillColor = UIColor.green
//        pinDot.name = kPinDotNode
//        pinDot.zPosition = 10
//        self.pinDot = pinDot
//
//        let satelliteDot = SKShapeNode(circleOfRadius: 6)
//        satelliteDot.fillColor = UIColor.red
//        satelliteDot.name = kSatelliteDotNode
//        satelliteDot.zPosition = 12
//        self.satelliteDot = satelliteDot
//
//        let lineNode = SKShapeNode()
//        lineNode.name = kLineNode
//        lineNode.strokeColor = UIColor.red
//        lineNode.lineWidth = 3.0
//        self.lineNode = lineNode
//
//
//        guard let renderComponent = entity.component(ofType: RenderComponent.self) else { return }
//        renderComponent.node.addChild(pinDot)
//        renderComponent.node.addChild(satelliteDot)
//        renderComponent.node.addChild(lineNode)
        
        

     }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit
    {
        //        print("Deallocating JointComponent")
    }
    
    
    override func update(deltaTime seconds: TimeInterval)
    {
        
        //Joint has been created, redraw it repective to entity changed positions
        if isTriggered
        {
        
////            var pin = renderComponent.node.childNode(withName: kPinnedNode)
////            var satellite = renderComponent.node.childNode(withName: kSatelliteNode)
//            var pinDot = renderComponent.node.childNode(withName: kPinDotNode)
//            var satelliteDot = renderComponent.node.childNode(withName: kSatelliteDotNode)
////            var line = renderComponent.node.childNode(withName: kLineNode) as! SKShapeNode
//            
//            
//            guard let renderComponent = entity?.component(ofType: RenderComponent.self) else { return }
//            pinDot!.position = renderComponent.node.scene!.convert(CGPoint(x: 50.0, y: 0.0), from: renderComponent.node.parent!)
//
////            pinDot!.position = renderComponent.node.scene!.convert(CGPoint.zero, from: renderComponent.node.parent!)
//            
////            guard let entityBRenderComponent = entityB?.component(ofType: RenderComponent.self) else { return }
////            satelliteDot!.position = renderComponent.node.scene!.convert(CGPoint(x: -0.5, y: -0.5), from: entityBRenderComponent.node)
////            satelliteDot!.position = renderComponent.node.scene!.convert(CGPoint.zero, from: entityBRenderComponent.node.parent!)
//            
////            print("entityA position: \(renderComponent.node.position), entityb position: \(entityBRenderComponent.node.position)")
//            
//            self.pinDot = pinDot as! SKShapeNode
////            self.satelliteDot = satelliteDot as! SKShapeNode
//            
//            
////            let bez = UIBezierPath()
////            bez.move(to: pinDot!.position)
////            bez.addLine(to: satelliteDot!.position)
////            self.lineNode?.path = bez.cgPath
        }
    }
    
    // Convenience methods
    
    func setEntityB(targetEntity: TaskBot)
    {
        self.entityB = targetEntity
        
        guard let renderComponent = targetEntity.component(ofType: RenderComponent.self) else { return }
//        satelliteDot?.position = renderComponent.node.scene!.convert(CGPoint.zero, from: renderComponent.node)
        
        let bodyA = entity!.component(ofType: RenderComponent.self)?.node.physicsBody
        let bodyB = self.entityB!.component(ofType: RenderComponent.self)?.node.physicsBody
        
        let physicsJoint = SKPhysicsJointLimit.joint(withBodyA: bodyA!,
                                                     bodyB: bodyB!,
                                                     anchorA: CGPoint.zero,
                                                     anchorB: CGPoint.zero)
        
        physicsJoint.maxLength = 10.0
        
        
//        let physicsJoint = SKPhysicsJointFixed.joint(withBodyA: bodyA!, bodyB: bodyB!, anchor: CGPoint.zero)

        
        renderComponent.node.scene?.physicsWorld.add(physicsJoint)
        
        self.isTriggered = true
    }
}


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

let kPinnedNode = "pinned"                  //this will be the policeman A
let kSatelliteNode = "satellite"            //this will be the policeman b
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

class JointOutline : SKNode
{
    
    class func create(_ scene:SKScene) -> SKNode
    {
        let parent = JointOutline()
        parent.name = kJointOutlineNode
        
        let pinDot = SKShapeNode(circleOfRadius: 6)
        pinDot.fillColor = UIColor.red
        pinDot.name = kPinDotNode
        
        let satelliteDot = SKShapeNode(circleOfRadius: 6)
        satelliteDot.fillColor = UIColor.red
        satelliteDot.name = kSatelliteDotNode
        
        let lineNode = SKShapeNode()
        lineNode.name = kLineNode
        lineNode.strokeColor = UIColor.red
        lineNode.lineWidth = 3.0
        
        scene.addChild(parent)
        parent.updateOutline()
        
        return parent
    }
    
    func updateOutline()
    {
        guard let renderComponent = entity?.component(ofType: RenderComponent.self) else { return }
        guard let jointComponent = entity?.component(ofType: JointComponent.self) else { return }
        
//         Make the pin the Policeman A node
        let pin = renderComponent.node
        
//         Make the satellite the Policeman B node
        let satellite = jointComponent.entityB?.component(ofType: RenderComponent.self)?.node
        let pinDot = childNode(withName: kPinDotNode)
        let satelliteDot = childNode(withName: kSatelliteDotNode)
        let line = childNode(withName: kLineNode) as! SKShapeNode
        
        pinDot?.position = (scene?.convert(CGPoint.zero, from: pin))!
        satelliteDot?.position = (scene?.convert(CGPoint.zero, from: satellite!))!
        
        let bez = UIBezierPath()
        bez.move(to: (pinDot?.position)!)
        bez.addLine(to: (satelliteDot?.position)!)
        line.path = bez.cgPath
        
    }
    
}


class JointComponent: GKComponent
{
    
    var entityB : TaskBot?
    var pinDot : SKShapeNode?
    var pinned : SKSpriteNode?
    var satelliteDot : SKShapeNode?
    var satellite : SKSpriteNode?
    var lineNode : SKShapeNode?
    

    var midPt:CGPoint {
        return (pinned?.anchorPoint)!
    }
    
    var pinnedHome:CGPoint {
        var mid = midPt
        mid.y += 120
        return mid
    }
    
    var satelliteHome:CGPoint {
        var mid = midPt
        mid.y -= 120
        return mid
    }
    
    // MARK: Properties
    
    /// Set to `true` whenever the player is holding down the attack button.
    var isTriggered = false
    
    
    /// The `RenderComponent' for this component's 'entity'.
    var renderComponent: RenderComponent
    {
        guard let renderComponent = entity?.component(ofType: RenderComponent.self) else { fatalError("A JointComponent's entity must have a RenderComponent") }
        return renderComponent
    }
    
    
    // MARK: Initializers
    
    init(entity: TaskBot)
    {
        var parent = JointOutline()
        parent.name = kJointOutlineNode

        self.entityB = nil
        
        super.init()
        
        let pinDot = SKShapeNode(circleOfRadius: 6)
        pinDot.fillColor = UIColor.green
        pinDot.name = kPinDotNode
        pinDot.zPosition = 10
        self.pinDot = pinDot

        let satelliteDot = SKShapeNode(circleOfRadius: 6)
        satelliteDot.fillColor = UIColor.red
        satelliteDot.name = kSatelliteDotNode
        satelliteDot.zPosition = 12
        self.satelliteDot = satelliteDot
        
        let pinned = SKSpriteNode(color: UIColor.green, size: CGSize(width: 20,height: 20))
        pinned.name = kPinnedNode
        self.pinned = pinned
        
        let satellite = SKSpriteNode(color: UIColor.yellow, size: CGSize(width: 20,height: 20))
        satellite.name = kSatelliteNode
        self.satellite = satellite

        
        

        let lineNode = SKShapeNode()
        lineNode.name = kLineNode
        lineNode.strokeColor = UIColor.red
        lineNode.lineWidth = 3.0
        self.lineNode = lineNode
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
        
            let jointOutline = renderComponent.node.scene!.childNode(withName: kJointOutlineNode) as! JointOutline
            jointOutline.updateOutline()
            
//            if( alternating )
//            {
//                if let timeMark = lastTimeMark
//                {
//                    if( currentTime - timeMark > alternatingThreshold )
//                    {
//                        impulseVelocity = CGVector( dx: impulseVelocity.dx * -1.0, dy: impulseVelocity.dy * -1.0)
//                        _doImpulse(impulseVelocity)
//                        lastTimeMark = currentTime
//                    }
//                }
//                else
//                {
//                    lastTimeMark = currentTime
//                }
//            }
            
        }
    }
    
    // Convenience methods
    
    func setEntityB(targetEntity: TaskBot)
    {
        self.entityB = targetEntity
        
//        satellite!.position = (entityB?.component(ofType: RenderComponent)?.node.position)!

        
        renderComponent.node.addChild(pinned!)
        renderComponent.node.addChild(pinDot!)
        
        
        self.entityB?.component(ofType: RenderComponent.self)?.node.addChild(satellite!)
        self.entityB?.component(ofType: RenderComponent.self)?.node.addChild(satelliteDot!)
        
        resetPhysicsBodies()
        JointOutline.create(renderComponent.node.scene!)
        makeJoint(JointLabels.Limit)
        
        self.isTriggered = true
        
        
//        print("bodyAPosition: \(bodyAPosition), bodyBPosition: \(bodyBPosition)")
    }
    
    func resetPhysicsBodies()
    {
    
//        let pinned = self.pinned as? SKSpriteNode
//        let satellite = self.satellite as? SKSpriteNode
//        let pinned = renderComponent.node.scene!.childNode(withName: kPinnedNode) as! SKSpriteNode
//        let satellite = renderComponent.node.scene!.childNode(withName: kSatelliteNode) as! SKSpriteNode
        
        // remember if the pinned body is currently dynamic
        var dynamic = false
        if let pbody = pinned!.physicsBody
        {
            dynamic = pbody.isDynamic
        }
        
//        pinned!.physicsBody = SKPhysicsBody(rectangleOf: pinned!.size)
        pinned!.physicsBody?.isDynamic = dynamic
//        pinned!.physicsBody?.affectedByGravity = false
        
//        satellite!.physicsBody = SKPhysicsBody(rectangleOf: satellite!.size)
//        satellite!.physicsBody?.isDynamic = true
    }
    
    func resetNodes()
    {
        renderComponent.node.scene!.childNode(withName: kPinnedNode)?.position = pinnedHome
        renderComponent.node.scene!.childNode(withName: kSatelliteNode)?.position = satelliteHome
    }
    
    func makeJoint(_ name:JointLabels)
    {
        renderComponent.node.scene!.physicsWorld.removeAllJoints()
        
        resetNodes()
        if( name != .Pin )
        {
            resetPhysicsBodies()
        }
        
//        let pinned = renderComponent.node.scene!.childNode(withName: kPinnedNode)
//        let satellite = renderComponent.node.scene!.childNode(withName: kSatelliteNode)
        
        //Connect joint to Police nodes
        let pinned = entity?.component(ofType: RenderComponent.self)?.node
        let satellite = entityB?.component(ofType: RenderComponent.self)?.node
        
        var vz = CGVector(dx: 0, dy: 0)
        let pinnedAnchor = renderComponent.node.scene!.convert(CGPoint.zero, from: pinned!)
        let satelliteAnchor = renderComponent.node.scene!.convert(CGPoint.zero, from: satellite!)
        var joint:SKPhysicsJoint!
        
        switch(name)
        {
        case .Pin:
            pinned?.position.y -= ((pinned?.position.y)! - (satellite?.position.y)!) / 2.0
            resetPhysicsBodies()
            let pin = SKPhysicsJointPin.joint(withBodyA: (pinned?.physicsBody!)!,
                                              bodyB: (satellite?.physicsBody!)!,
                                              anchor: (pinned?.position)!)
            joint = pin
        case .Fixed:
            let fixed = SKPhysicsJointFixed.joint(withBodyA: (pinned?.physicsBody!)!,
                                                  bodyB: (satellite?.physicsBody!)!,
                                                  anchor: pinnedAnchor)
            joint = fixed
        case JointLabels.Sliding:
            let sliding = SKPhysicsJointSliding.joint(withBodyA: (pinned?.physicsBody!)!,
                                                      bodyB: (satellite?.physicsBody!)!,
                                                      anchor: pinnedAnchor, axis: CGVector(dx: 0, dy: 1))
            sliding.lowerDistanceLimit = 40
            sliding.upperDistanceLimit = (pinned?.position.y)! - (satellite?.position.y)!
            sliding.shouldEnableLimits = true
            joint = sliding
        case JointLabels.Spring:
            let spring = SKPhysicsJointSpring.joint(withBodyA: (pinned?.physicsBody!)!,
                                                    bodyB: (satellite?.physicsBody!)!,
                                                    anchorA: pinnedAnchor,
                                                    anchorB: satelliteAnchor)
            spring.frequency = 0.5
            joint = spring
        case JointLabels.Limit:
            let limit = SKPhysicsJointLimit.joint(withBodyA: (pinned?.physicsBody!)!,
                                                  bodyB: (satellite?.physicsBody!)!,
                                                  anchorA: pinnedAnchor,
                                                  anchorB: satelliteAnchor)
            limit.maxLength = 100.0
            joint = limit
        }
        
        renderComponent.node.scene!.physicsWorld.add(joint)
        
    }
}


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


class JointComponent: GKComponent
{
    
    var thisJoint:SKPhysicsJoint?
    
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
        lineNode.name = kLineNode + entity.id.description
        lineNode.strokeColor = UIColor.red
        lineNode.lineWidth = 3.0
        lineNode.zPosition = 12
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
        guard let taskBot = entity as? TaskBot else { return }
        
        //Joint has been created, redraw it repective to entity changed positions
        if isTriggered
        {
        
            //Get pointer to our Pin node
            let pin = renderComponent.node.childNode(withName: kPinnedNode)
            
            //Get pointer to the Satellite node
            let satellite = entityB!.renderComponent.node.childNode(withName: kSatelliteNode)
            
            //Make TaskBots face the same direction
//            entityB!.renderComponent.node.zRotation = renderComponent.node.zRotation
            
            //Get pointer to the Line node
//            let line = renderComponent.node.scene!.childNode(withName: kLineNode) as! SKShapeNode
            let line = renderComponent.node.scene!.childNode(withName: (lineNode?.name)!) as! SKShapeNode

            //Get the anchor positions for the joint to display the connecting line
            let anchorA = (renderComponent.node.scene!.convert(CGPoint.zero, from: pin!))
            let anchorB = (entityB!.renderComponent.node.scene!.convert(CGPoint.zero, from: satellite!))
            
            //Draw the line between the joint nodes
            let bez = UIBezierPath()
            bez.move(to: anchorA)
            bez.addLine(to: anchorB)
            line.path = bez.cgPath
          
        }
    }
    
    // Convenience methods
    
    func setEntityB(targetEntity: TaskBot)
    {
        //Set the connecting entity as the target entity
        self.entityB = targetEntity
        
        
        //Add the pin nodes to this entity
        renderComponent.node.addChild(pinned!)
        renderComponent.node.addChild(pinDot!)

        //Add the satellite nodes to the target entity
        self.entityB?.component(ofType: RenderComponent.self)?.node.addChild(satellite!)
        self.entityB?.component(ofType: RenderComponent.self)?.node.addChild(satelliteDot!)
        
        //Create the joint between this node and the target node
        
        
        //Lock the two entities to a specified distance
//        let distanceRange = SKRange(lowerLimit: 55.0, upperLimit: 100.0)
//        let lockDistance = SKConstraint.distance(distanceRange, to: targetEntity.renderComponent.node)
//        renderComponent.node.constraints = [ lockDistance ]
  
        //Position PoliceBot 100p to the right of the PoliceBot
//        let positionRange = SKRange(lowerLimit: 50.0, upperLimit: 150.0)
////        let lockPosition = SKConstraint.positionX(positionRange)
//        let lockPosition = SKConstraint.positionX(positionRange, y: positionRange)
//        renderComponent.node.constraints = [ lockPosition ]
        
        
        //Lock orientation to a specified directtion
//        let lookAtConstraint = SKConstraint.orient(to: targetProtestor, offset: SKRange(constantValue: -CGFloat.pi /2)
//        renderComponent.node.constraints = [ lookAtConstraint ]
        
        /*
        
        let lockOn = SKConstraint.positionX(range, y: range)
    
        entity?.component(ofType: RenderComponent.self)?.node.constraints = [ lockOn ]
        targetEntity.renderComponent.node.constraints = [ lockOn ]
        */
        
        makeJoint(JointLabels.Limit)
//        makeJoint(JointLabels.Fixed)
        
        //Inform the JointComponent that a joint has been created
        self.isTriggered = true
        
        //Add the line node to the scene
        renderComponent.node.scene?.addChild(lineNode!)
        
        //Increment the connections property on this TaskBot and the target TaskBot
        guard let taskBot = entity as? TaskBot else { return }
        taskBot.connections += 1
        targetEntity.connections += 1
        
        //Increase the wall account
        entity?.component(ofType: WallComponent.self)?.currentWallSize += 1

        
//        print("bodyAPosition: \(bodyAPosition), bodyBPosition: \(bodyBPosition)")
    }
    
    
    func makeJoint(_ name:JointLabels)
    {
//        renderComponent.node.scene!.physicsWorld.removeAllJoints()
        
//        if( name != .Pin )
//        {
////            resetPhysicsBodies()
//        }

        
        //Connect joint to Police nodes
        let pinned = entity?.component(ofType: RenderComponent.self)?.node
        let satellite = entityB?.component(ofType: RenderComponent.self)?.node
        
        var vz = CGVector(dx: 0, dy: 0)
//        let pinnedAnchor = renderComponent.node.scene!.convert(CGPoint.zero, from: pinned!)
//        let satelliteAnchor = renderComponent.node.scene!.convert(CGPoint.zero, from: satellite!)
        
        let pinnedAnchor = renderComponent.node.scene!.convert(CGPoint(x: 0.0, y: 0.5), from: pinned!)
        let satelliteAnchor = renderComponent.node.scene!.convert(CGPoint(x: 0.0, y: 0.5), from: satellite!)
        var joint:SKPhysicsJoint!
        
        switch(name)
        {
        case .Pin:
            pinned?.position.y -= ((pinned?.position.y)! - (satellite?.position.y)!) / 2.0
//            resetPhysicsBodies()
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
            limit.maxLength = 75.0
            joint = limit
        }
        
        self.thisJoint = joint
        
        //Add the Physics Joint to the scene's physics world
        renderComponent.node.scene!.physicsWorld.add(joint)
    }
    
    func removeJoint()
    {
        //Remove this joint from the scene
        renderComponent.node.scene?.physicsWorld.remove(thisJoint!)
        self.thisJoint = nil
        
        
        guard let policeBot = entity as? PoliceBot else { return }
        policeBot.connections -= 1
        self.isTriggered = false
        policeBot.requestWall = false
        
        //Remove connections from other entity and reset
        self.entityB?.connections -= 1
        self.entityB?.component(ofType: WallComponent.self)?.isTriggered = false
        self.entityB?.requestWall = false
        
        //Remove the line node to the scene
        renderComponent.node.scene?.removeChildren(in: [lineNode!])
        
        //Remove the pin nodes to this entity
        renderComponent.node.removeChildren(in: [pinned!])
        renderComponent.node.removeChildren(in: [pinDot!])
        
        //Add the satellite nodes to the target entity
        self.entityB?.component(ofType: RenderComponent.self)?.node.removeChildren(in: [satellite!])
        self.entityB?.component(ofType: RenderComponent.self)?.node.removeChildren(in: [satelliteDot!])

        
        print("Removing joint on entity: \(policeBot.debugDescription), connections: \(policeBot.connections)")
    }
}


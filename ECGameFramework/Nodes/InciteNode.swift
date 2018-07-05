/*
//
//  InciteNode.swift
//  ECGameFramework
//
//  Created by Jason Fry on 08/06/2018.
//  Copyright © 2018 Jason Fry. All rights reserved.
//
    Abstract:
    An `SKNode` subclass used as a container for the visual components that make up a `PlayerBot`'s incite area (circular).
*/

import SpriteKit
import GameplayKit

class InciteNode: SKNode, ResourceLoadableType
{
    // MARK: Static properties
    
    struct AnimationActions
    {
        static var source: SKAction!
        static var untargetedSource: SKAction!
        static var destination: SKAction!
        static var cooling: SKAction!
    }
    
    /// The size to use for the `InciteNode`'s dot animation textures.
    static var dotTextureSize = CGSize(width: 30.0, height: 30.0)
    
    static let animationActionKey = "Animation"
    
    static let lineNodeTemplate: SKSpriteNode = {
        let templateScene = SKScene(fileNamed: "BeamLine.sks")!
        return templateScene.childNode(withName: "BeamLine") as! SKSpriteNode
    }()
    
    // MARK: Properties
    
    let sourceNode: SKSpriteNode
    
    let destinationNode: SKSpriteNode
    
    var lineNode: SKSpriteNode?
    
    var runningNodeAnimations = [SKNode: SKAction]()
    
    let debugNode: SKShapeNode
    
    var debugDrawingEnabled = false
    
    // MARK: Initializers
    
    override init()
    {
        sourceNode = SKSpriteNode()
        sourceNode.size = InciteNode.dotTextureSize
        sourceNode.isHidden = true
        
        destinationNode = SKSpriteNode()
        destinationNode.size = InciteNode.dotTextureSize
        destinationNode.isHidden = true
        
        let arcPath = CGMutablePath.init()
        let center = CGPoint(x: 0.0, y: 0.0)
        arcPath.addArc(center: center, radius: GameplayConfiguration.Incite.arcLength, startAngle: GameplayConfiguration.Incite.arcAngle * 0.5, endAngle: GameplayConfiguration.Incite.arcAngle * -0.5, clockwise: true)
        arcPath.addLine(to: center)
        
        debugNode = SKShapeNode(path: arcPath)
        debugNode.fillColor = SKColor.blue
        debugNode.lineWidth = 0.0
        debugNode.alpha = 0.5
        debugNode.isHidden = true
        
        super.init()
        
        self.addChild(sourceNode)
        self.addChild(destinationNode)
        self.addChild(debugNode)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
//        print("Deallocating InciteNode")
    }
    
    // MARK: Actions
    
    func update(withInciteState state: GKState, source: PlayerBot, target: TaskBot? = nil)
    {
        // Constrain the position of the target's antenna if it's not already constrained to it.
        if let target = target, let targetNode = target.component(ofType: RenderComponent.self)?.node, destinationNode.constraints?.first?.referenceNode != targetNode
        {
            let xRange = SKRange(constantValue: target.beamTargetOffset.x)
            let yRange = SKRange(constantValue: target.beamTargetOffset.y)
            
            let constraint = SKConstraint.positionX(xRange, y: yRange)
            constraint.referenceNode = targetNode
            
            destinationNode.constraints = [constraint]
        }
        
        switch state
        {
            case is InciteIdleState:
                // Hide the source and destination nodes.
                sourceNode.isHidden = true
                destinationNode.isHidden = true
                
                // Remove the `lineNode` from the scene.
                lineNode?.removeFromParent()
                lineNode = nil
                
                debugNode.isHidden = true
            
            case is InciteActiveState:
                /*
                 If there is no `lineNode`, create one from the template node.
                 Adding a new copy of the template will ensure the actions are re-started when
                 the Incite starts being fired.
                 */
                if lineNode == nil
                {
                    lineNode = InciteNode.lineNodeTemplate.copy() as? SKSpriteNode
                    lineNode!.isHidden = true
                    addChild(lineNode!)
                }
                
                if let target = target
                {
                    // Show the `sourceNode` with the its firing animation.
                    sourceNode.isHidden = false
                    animate(sourceNode, withAction: AnimationActions.source)
                    
                    // Show the `destinationNode` with its animation.
                    destinationNode.isHidden = false
                    animate(destinationNode, withAction: AnimationActions.destination)
                    
                    // Position the `lineNode` and make sure it's visible.
                    positionLineNode(from: source, to: target)
                    lineNode?.isHidden = false
                }
                else
                {
                    // Show the `sourceNode` with the its untargeted animation.
                    sourceNode.isHidden = false
                    animate(sourceNode, withAction: AnimationActions.untargetedSource)
                    
                    // Hide the `destinationNode` and `lineNode`.
                    destinationNode.isHidden = true
                    lineNode?.isHidden = true
                }
                
                // Update the debug node if debug drawing is enabled.
                debugNode.isHidden = !debugDrawingEnabled
                
                if debugDrawingEnabled
                {
                    guard let sourceOrientation = source.component(ofType: OrientationComponent.self) else {
                        fatalError("InciteNodees must be associated with entities that have an orientation node")
                    }
                    
                    /*
                     Update the `debugNode` with an arc based off the
                     ratio of the distance from the source to the target.
                     
                     This allows for easier aiming the closer the source is to
                     the target.
                     */
                    let arcPath = CGMutablePath.init()
                    
                    // Only draw Incite arc if there is a target.
                    if let target = target
                    {
                        let distanceRatio = GameplayConfiguration.Incite.arcLength / CGFloat(distance(source.agent.position, target.agent.position))
                        let arcAngle = min(GameplayConfiguration.Incite.arcAngle * distanceRatio, 1 / GameplayConfiguration.Incite.maxArcAngle)
                        
                        let center = CGPoint(x: 0, y: 0)
                        
                        arcPath.addArc(center: center, radius: GameplayConfiguration.Incite.arcLength, startAngle: arcAngle * 0.5, endAngle: -arcAngle * 0.5, clockwise: true)
                        arcPath.addLine(to: center)
                    }
                    debugNode.path = arcPath
                    
                    debugNode.zRotation = sourceOrientation.zRotation
                }
            
            case is InciteCoolingState:
                // Show the `sourceNode` with the "cooling" animation.
                sourceNode.isHidden = false
                animate(sourceNode, withAction: AnimationActions.cooling)
                
                // Hide the `destinationNode`.
                destinationNode.isHidden = true
                
                // Remove the `lineNode` from the scene.
                lineNode?.removeFromParent()
                lineNode = nil
                
                debugNode.isHidden = true
            
            default:
                break
        }
    }
    
    // MARK: Convenience
    
    func animate(_ node: SKSpriteNode, withAction action: SKAction)
    {
        if runningNodeAnimations[node] != action
        {
            node.run(action, withKey: InciteNode.animationActionKey)
            runningNodeAnimations[node] = action
        }
    }
    
    func positionLineNode(from source: PlayerBot, to target: TaskBot)
    {
        guard let lineNode = lineNode else { fatalError("positionLineNodeFrom(_: to:) requires a lineNode to have been created.") }
        
        // Calculate the source and destination positions.
        let sourcePosition: CGPoint = {
            guard let node = source.component(ofType: RenderComponent.self)?.node, let nodeParent = node.parent else {
                fatalError("positionLineNodeFrom(_: to:) requires the source to have a node with a parent.")
            }
            
            var position = convert(node.position, from: nodeParent)
            position.x += source.antennaOffset.x
            position.y += source.antennaOffset.y
            
            return position
        }()
        
        let destinationPosition: CGPoint = {
            guard let node = target.component(ofType: RenderComponent.self)?.node, let nodeParent = node.parent else {
                fatalError("positionLineNodeFrom(_: to:) requires the destination to have a node with a parent.")
            }
            
            var position = convert(node.position, from: nodeParent)
            position.x += target.beamTargetOffset.x
            position.y += target.beamTargetOffset.y
            
            return position
        }()
        
        // Set the line's position and rotation.
        let dx = destinationPosition.x - sourcePosition.x
        let dy = destinationPosition.y - sourcePosition.y
        
        lineNode.position = sourcePosition
        lineNode.zRotation = atan2(dy, dx)
        
        // Scale the line's length.
        let InciteLength = hypot(dx, dy)
        lineNode.xScale = InciteLength / InciteNode.lineNodeTemplate.size.width
    }
    
    // MARK: ResourceLoadableType
    
    static var resourcesNeedLoading: Bool
    {
        return AnimationActions.source == nil || AnimationActions.untargetedSource == nil || AnimationActions.destination == nil || AnimationActions.cooling == nil
    }
    
    static func loadResources(withCompletionHandler completionHandler: @escaping () -> ())
    {
        let InciteAtlasNames = [
            "InciteDot",
            "InciteCharging"
        ]
        
        /*
         Preload all of the texture atlases for `InciteNode`. This improves
         the overall loading speed of the animation cycles for the Incite.
         */
        SKTextureAtlas.preloadTextureAtlasesNamed(InciteAtlasNames) { error, InciteAtlases in
            if let error = error {
                fatalError("One or more texture atlases could not be found: \(error)")
            }
            
            let InciteDotAction = AnimationComponent.actionForAllTexturesInAtlas(atlas: InciteAtlases[0])
            AnimationActions.source = InciteDotAction
            AnimationActions.untargetedSource = InciteDotAction
            AnimationActions.destination = InciteDotAction
            AnimationActions.cooling = AnimationComponent.actionForAllTexturesInAtlas(atlas: InciteAtlases[1])
            
            // Invoke the passed `completionHandler` to indicate that loading has completed.
            completionHandler()
        }
    }
    
    static func purgeResources()
    {
        AnimationActions.source = nil
        AnimationActions.destination = nil
        AnimationActions.untargetedSource = nil
        AnimationActions.cooling = nil
    }
}

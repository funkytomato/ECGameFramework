/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    A `GKComponent` that provides and manages the actions used to animate characters on screen as they move through different states and face different directions. `AnimationComponent` is supported by a structure called `Animation` that encapsulates information about an individual animation.
*/

import SpriteKit
import GameplayKit

/// The different animation states that an animated character can be in.
enum AnimationState: String
{
    case idle = "Idle"
    case preAttack = "PreAttack"
    case attack = "Attack"
    case beingArrested = "BeingArrested"
    case arresting = "Arresting"
    case arrested = "Arrested"
    case detained = "Detained"
    case holdingPrisoner = "HoldingPrisoner"
    case patrol = "Patrol"
    case zapped = "Zapped"
    case hit = "Hit"
    case inactive = "Inactive"
    case inciting = "Inciting"
    case injured = "Injured"
    
    case drinking = "Drinking"
    case drunk = "Drunk"
    case looking = "Looking"
    case selling = "Selling"
    case buying = "Buying"
    
    case walkForward = "WalkForward"
    case walkBackward = "WalkBackward"
    
    case angry = "Angry"
    case calm = "Calm"
    case scared = "Scared"
    case unhappy = "Unhappy"
    case violent = "Violent"
    
    case looting = "Looting"
    case vandalising = "Vandalising"
    case sellingWares = "SellingWares"
}

/**
    Encapsulates all of the information needed to animate an entity and its shadow
    for a given animation state and facing direction.
*/
struct Animation
{

    // MARK: Properties
    
    /// The animation state represented in this animation.
    let animationState: AnimationState
    
    /// One or more `SKTexture`s to animate as a cycle for this animation.
    let textures: [SKTexture]
    
    /**
        The offset into the `textures` array to use as the first frame of the animation.
        Defaults to zero, but will be updated if a copy of this animation decides to offset
        the starting frame to continue smoothly from the end of a previous animation.
    */
    var frameOffset = 0
    
    /**
        An array of textures that runs from the animation's `frameOffset` to its end,
        followed by the textures from its start to just before the `frameOffset`.
    */
    var offsetTextures: [SKTexture]
    {
        if frameOffset == 0
        {
            return textures
        }
        let offsetToEnd = Array(textures[frameOffset..<textures.count])
        let startToBeforeOffset = textures[0..<frameOffset]
        
        //print("\(offsetToEnd) \(startToBeforeOffset)")
        
        return offsetToEnd + startToBeforeOffset
    }

    /// Whether this action's `textures` array should be repeated forever when animated.
    let repeatTexturesForever: Bool

    /// The name of an optional action for this entity's body, loaded from an action file.
    let bodyActionName: String?

    /// The optional action for this entity's body, loaded from an action file.
    let bodyAction: SKAction?

    /// The name of an optional action for this entity's shadow, loaded from an action file.
    let shadowActionName: String?

    /// The optional action for this entity's shadow, loaded from an action file.
    let shadowAction: SKAction?
}

class AnimationComponent: GKComponent
{
    
    /// The key to use when adding an optional action to the entity's body.
    static let bodyActionKey = "bodyAction"

    /// The key to use when adding an optional action to the entity's shadow.
    static let shadowActionKey = "shadowAction"

    /// The key to use when adding a texture animation action to the entity's body.
    static let textureActionKey = "textureAction"

    /// The time to display each frame of a texture animation.
    static let timePerFrame = TimeInterval(1.0 / 10.0)
    
    // MARK: Properties
    
    //Taskbot lightnode
    var lightNode = SKLightNode()
    
    /**
        The most recent animation state that the animation component has been requested to play,
        but has not yet started playing.
    */
    var requestedAnimationState: AnimationState?
    
    /// The node on which animations should be run for this animation component.
    let node: SKSpriteNode
//    let node: ElementNode
    
    
    
    /// The node for the entity's shadow (to be set by the entity if needed).
    var shadowNode: SKSpriteNode?
    
    /// The current set of animations for the component's entity.
    //var animations: [AnimationState: [CompassDirection: Animation]]
    var animations: [AnimationState: Animation]
    
    /// The animation that is currently running.
    private(set) var currentAnimation: Animation?
    
    /// The length of time spent in the current animation state and direction.
    private var elapsedAnimationDuration: TimeInterval = 0.0
    
    // MARK: Initializers

    //init(textureSize: CGSize, animations: [AnimationState: [CompassDirection: Animation]])
    init(textureSize: CGSize, animations: [AnimationState: Animation])
    {
        node = SKSpriteNode(texture: nil, size: textureSize)
//        node = ElementNode()
        self.animations = animations
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit
    {
//        print("Deallocating AnimationComponent")
    }
    
    // MARK: Character Animation
    private func runAnimationForAnimationState(animationState: AnimationState, deltaTime: TimeInterval)
    {
        
        // Update the tracking of how long we have been animating.
        elapsedAnimationDuration += deltaTime
        
        // Check if we are already running this animation. There's no need to do anything if so.
        if currentAnimation != nil && currentAnimation!.animationState == animationState { return }
        /*
            Retrieve a copy of the stored animation for the requested state and compass direction.
            `Animation` is a structure - i.e. a value type - so the `animation` variable below
            will contain a unique copy of the animation's data.
            We request this copy as a variable (rather than a constant) so that the
            `animation` variable's `frameOffset` property can be modified later in this method
            if we choose to offset the animation's start point from zero.
        */

        //For prototype, use the same graphic (they are all the same)
        guard let unwrappedAnimation = animations[animationState] else {
//            print("Unknown animation for state \(animationState.rawValue)")
            return
        }
        var animation = unwrappedAnimation
        
        // Check if the action for the body node has changed.
        if currentAnimation?.bodyActionName != animation.bodyActionName
        {
            // Remove the existing body action if it exists.
//            node.green?.removeAction(forKey: AnimationComponent.bodyActionKey)
            node.removeAction(forKey: AnimationComponent.bodyActionKey)
            
            // Reset the node's position in its parent (it may have been animating with a move action).
            node.position = CGPoint.zero

            // Add the new body action to the node if an action exists.
            if let bodyAction = animation.bodyAction
            {
//                node.green?.run(SKAction.repeatForever(bodyAction), withKey: AnimationComponent.bodyActionKey)
                node.run(SKAction.repeatForever(bodyAction), withKey: AnimationComponent.bodyActionKey)
            }
        }

        // Check if the action for the shadow node has changed.
        if currentAnimation?.shadowActionName != animation.shadowActionName
        {
            // Remove the existing shadow action if it exists.
            shadowNode?.removeAction(forKey: AnimationComponent.shadowActionKey)

            // Reset the node's position in its parent (it may have been animating with a move action).
            shadowNode?.position = CGPoint.zero

            // Reset the node's scale (it may have been changed with a resize action).
            shadowNode?.xScale = 1.0
            shadowNode?.yScale = 1.0
            
            // Add the new shadow action to the shadow node if an action exists.
            if let shadowAction = animation.shadowAction
            {
                shadowNode?.run(SKAction.repeatForever(shadowAction), withKey: AnimationComponent.shadowActionKey)
            }
        }

        // Remove the existing texture animation action if it exists.
        node.removeAction(forKey: AnimationComponent.textureActionKey)

        // Create a new action to display the appropriate animation textures.
        let texturesAction: SKAction
        
        if animation.textures.count == 1
        {
            // If the new animation only has a single frame, create a simple "set texture" action.
            texturesAction = SKAction.setTexture(animation.textures.first!)
        }
        else
        {
            
            if currentAnimation != nil && animationState == currentAnimation!.animationState
            {
                /*
                    We have just changed facing direction within the same animation state.
                    To make the animation feel smooth as we change direction,
                    begin the animation for the new direction on the frame after
                    the last frame displayed for the old direction.
                    This prevents (e.g.) a walk cycle from resetting to its start
                    every time a character turns to the left or right.
                */
                
                // Work out how many frames of this animation have played since the animation began.
                let numberOfFramesInCurrentAnimation = currentAnimation!.textures.count
                let numberOfFramesPlayedSinceCurrentAnimationBegan = Int(elapsedAnimationDuration / AnimationComponent.timePerFrame)
                
                /*
                    Work out how far into the animation loop the next frame would be.
                    This takes into account the fact that the current animation may have been
                    started from a non-zero offset.
                */
                animation.frameOffset = (currentAnimation!.frameOffset + numberOfFramesPlayedSinceCurrentAnimationBegan + 1) % numberOfFramesInCurrentAnimation
            }
            
            // Create an appropriate action from the (possibly offset) animation frames.
            if animation.repeatTexturesForever
            {
                texturesAction = SKAction.repeatForever(SKAction.animate(with: animation.offsetTextures, timePerFrame: AnimationComponent.timePerFrame))
            }
            else
            {
                texturesAction = SKAction.animate(with: animation.offsetTextures, timePerFrame: AnimationComponent.timePerFrame)
            }
        }
        
        // Add the textures animation to the body node.
//        node.green?.run(texturesAction, withKey: AnimationComponent.textureActionKey)
        node.run(texturesAction, withKey: AnimationComponent.textureActionKey)

        
        // Remember the animation we are currently running.
        currentAnimation = animation
        
        // Reset the "how long we have been animating" counter.
        elapsedAnimationDuration = 0.0
    }
    
    // MARK: GKComponent Life Cycle
    
    override func update(deltaTime: TimeInterval)
    {
        super.update(deltaTime: deltaTime)
        
        // If an animation has been requested, run the animation.
        if let animationState = requestedAnimationState
        {
//            print("entiy: \(self.entity?.debugDescription) animationState: \(requestedAnimationState)")
            runAnimationForAnimationState(animationState: animationState, deltaTime: deltaTime)
            requestedAnimationState = nil
        }
    }
    
    func moveNode()
    {
        var actions = Array<SKAction>();
        actions.append(SKAction.move(to: CGPoint(x:100,y:100), duration: 1));
        actions.append(SKAction.rotate(byAngle: 6.28, duration: 1));
        actions.append(SKAction.colorize(with: .cyan, colorBlendFactor: 1.0, duration: 2.0));
        let sequence = SKAction.sequence(actions);
        node.run(sequence);
    }
   
    func createHighlightNode()
    {
        
        //Inform background we have a lightsource
//        guard let scene = entity?.component(ofType: RenderComponent.self) else { return }
        
        //Is the background effected by lighting
//        background.lightingBitMask = 1
        
        //Does the background cast a shadow?
//        background.shadowCastBitMask = 0
        
//        Can this background have shadows cast on it?
//        background.shadowedBitMask = 1
        
        //Taskbot lightnode
        let lightNode = SKLightNode()

        
        //Ambient Color is the light everywhere but our lightsource isn't (night time settings)
        lightNode.ambientColor = SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.87)
        
        //LightColor is the color of our main light source
        lightNode.lightColor = SKColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.2)
        
        //ShadowColor is the color of shadows
        lightNode.shadowColor = SKColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8)
        
        //Falloff in intensity of the light over distance, defaults to 1.
        lightNode.falloff = 0
        
        //The category of the light, which determines the group(s) a light belongs to.
        //Any node that has its corresponding light and shadow bitmasks set to an overlapping value
        //will be lit, shadow casting or shadowed by this light.
        lightNode.categoryBitMask = 1
        lightNode.isEnabled = false
        
        node.addChild(lightNode)
        
        //Bitmask to indicate being lit by a set of lights using overlapping lighting categories.
        //A light whose category is set to a value that masks to non-zero using this mask will
        //apply light to this sprite.
        //When used together with a normal texture, complex lighting effects can be used.
        node.lightingBitMask = 0
        node.shadowCastBitMask = 0
        node.shadowedBitMask = 0
        
        self.lightNode = lightNode
    }
    
    func removeHighlightNode()
    {
        self.lightNode.isEnabled = false
        node.lightingBitMask = 0
    }
    
    func createPulseAction()
    {
        let expandAction = SKAction.scale(to: 1.5, duration: 0.33)
        let contractAction = SKAction.scale(to: 0.7, duration: 0.33)
        let pulsateAction = SKAction.repeatForever(
            SKAction.sequence([expandAction, contractAction]))
        
        node.run(pulsateAction)
    }
    
    func changeColour(color: UIColor)
    {
        var actions = Array<SKAction>();
        actions.append(SKAction.colorize(with: color, colorBlendFactor: 1.0, duration: 5.0));
        let sequence = SKAction.sequence(actions);
        node.run(sequence);
    }
    
    // MARK: Texture loading utilities

    /// Returns the first texture in an atlas
    class func firstTextureForOrientation(inAtlas atlas: SKTextureAtlas, withImageIdentifier identifier: String) -> SKTexture
    {
        // Filter for this facing direction, and sort the resulting texture names alphabetically.
        let textureNames = atlas.textureNames.filter {
             $0.hasPrefix("\(identifier)_")
        }.sorted()
        
        // Find and return the first texture for this direction.
        return atlas.textureNamed(textureNames.first!)
    }
    
    /// Creates a texture action from all textures in an atlas.
    class func actionForAllTexturesInAtlas(atlas: SKTextureAtlas) -> SKAction
    {
        // Sort the texture names alphabetically, and map them to an array of actual textures.
        let textures = atlas.textureNames.sorted().map {
            atlas.textureNamed($0)
        }

        // Create an appropriate action for these textures.
        if textures.count == 1
        {
            return SKAction.setTexture(textures.first!)
        }
        else
        {
            let texturesAction = SKAction.animate(with: textures, timePerFrame: AnimationComponent.timePerFrame)
            return SKAction.repeatForever(texturesAction)
        }
    }

    /// Creates an `Animation` from textures in an atlas and actions loaded from file.
    class func animationsFromAtlas(atlas: SKTextureAtlas, withImageIdentifier identifier: String, forAnimationState animationState: AnimationState, bodyActionName: String? = nil, shadowActionName: String? = nil, repeatTexturesForever: Bool = true, playBackwards: Bool = false) -> Animation
    {
        // Load a body action from an actions file if requested.
        let bodyAction: SKAction?
        if let name = bodyActionName
        {
            bodyAction = SKAction(named: name)
        }
        else
        {
            bodyAction = nil
        }

        // Load a shadow action from an actions file if requested.
        let shadowAction: SKAction?
        if let name = shadowActionName
        {
            shadowAction = SKAction(named: name)
        }
        else
        {
            shadowAction = nil
        }
        
        /// A dictionary of animations with an entry for each compass direction.
        //var animations = [CompassDirection: Animation]()
        var animation : Animation
        

        // Find all matching texture names, sorted alphabetically, and map them to an array of actual textures.
        let textures = atlas.textureNames.filter {
            $0.hasPrefix("\(identifier)_")
        }.sorted {
            playBackwards ? $0 > $1 : $0 < $1
        }.map {
            atlas.textureNamed($0)
        }
        
        
        // Create a new `Animation` for these settings.
        animation = Animation(
            animationState: animationState,
            textures: textures,
            frameOffset: 0,
            repeatTexturesForever: repeatTexturesForever,
            bodyActionName: bodyActionName,
            bodyAction: bodyAction,
            shadowActionName: shadowActionName,
            shadowAction: shadowAction)
        
        return animation
    }
}

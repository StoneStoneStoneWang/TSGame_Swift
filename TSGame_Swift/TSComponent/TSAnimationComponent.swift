//
//  TSAnimationComponent.swift
//  Test
//
//  Created by 王磊 on 15/12/24.
//  Copyright © 2015年 tarena. All rights reserved.
//

import SpriteKit
import GameplayKit
enum TSAnimationState: String {
    case Idle = "Idle"
    case Walk = "Walk"
}
struct TSAnimation {
    
    // MARK: Properties
    
    /// The animation state represented in this animation.
    let animationState: TSAnimationState
    
    /// The direction the entity is facing during this animation.
    let compassDirection: TSCompassDirection
    
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
    var offsetTextures: [SKTexture] {
        if frameOffset == 0 {
            return textures
        }
        let offsetToEnd = Array(textures[frameOffset..<textures.count])
        let startToBeforeOffset = textures[0..<frameOffset]
        return offsetToEnd + startToBeforeOffset
    }
    
    /// Whether this action's `textures` array should be repeated forever when animated.
    let repeatTexturesForever: Bool
    
    /// The name of an optional action for this entity's body, loaded from an action file.
    let bodyActionName: String?
    
    /// The optional action for this entity's body, loaded from an action file.
    let bodyAction: SKAction?
    
}

class TSAnimationComponent: GKComponent {
    /// The key to use when adding an optional action to the entity's body.
    static let bodyActionKey = "bodyAction"
    
    static let textureActionKey = "textureAction"
    /// The time to display each frame of a texture animation.
    static let timePerFrame = NSTimeInterval(1.0 / 10.0)
    /// The key to use when adding a texture animation action to the entity's body.
    var node: SKSpriteNode!
    
    var textures: [SKTexture] = []
    
    // The animation that is currently running.
    private(set) var currentAnimation: TSAnimation?
    
    var animations: [TSAnimationState: [TSCompassDirection: TSAnimation]]
    // The length of time spent in the current animation state and direction.
    private var elapsedAnimationDuration: NSTimeInterval = 0.0
    
    init(textureSize: CGSize , animations: [TSAnimationState: [TSCompassDirection: TSAnimation]]) {
        node = SKSpriteNode(texture: nil, size: textureSize)
        self.animations = animations
    }
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        super.updateWithDeltaTime(seconds)
        guard let orientationComponent = entity?.componentForClass(TSOrientationComponent.self) else { fatalError("An AnimationComponent's entity must have an OrientationComponent.") }
        
        runAnimationForAnimationState(.Walk, compassDirection: orientationComponent.compassDirection, deltaTime: seconds)
        
    }
    private func runAnimationForAnimationState(animationState: TSAnimationState , compassDirection: TSCompassDirection , deltaTime: NSTimeInterval) {
        
        elapsedAnimationDuration += deltaTime
        
        if currentAnimation != nil && currentAnimation?.animationState == animationState && currentAnimation?.compassDirection == compassDirection { return }
        
        guard var animation = animations[animationState]?[compassDirection]else {
            print("Unknown animation for state \(animationState.rawValue), compass direction \(compassDirection.rawValue).")
            return
        }
        if currentAnimation?.bodyAction != animation.bodyActionName {
            node.removeActionForKey(TSAnimationComponent.bodyActionKey)
            // Reset the node's position in its parent (it may have been animating with a move action).
            node.position = CGPoint.zero
            if let bodyAction = animation.bodyAction {
                node.runAction(SKAction.repeatActionForever(bodyAction), withKey: TSAnimationComponent.bodyActionKey)
            }
        }
        node.removeActionForKey(TSAnimationComponent.textureActionKey)
        
        let texturesAction: SKAction
        
        if animation.textures.count == 1 {
            // If the new animation only has a single frame, create a simple "set texture" action.
            texturesAction = SKAction.setTexture(animation.textures.first!)
        }
        else {
            
            if currentAnimation != nil && animationState == currentAnimation!.animationState {
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
                let numberOfFramesPlayedSinceCurrentAnimationBegan = Int(elapsedAnimationDuration / TSAnimationComponent.timePerFrame)
                
                /*
                Work out how far into the animation loop the next frame would be.
                This takes into account the fact that the current animation may have been
                started from a non-zero offset.
                */
                animation.frameOffset = (currentAnimation!.frameOffset + numberOfFramesPlayedSinceCurrentAnimationBegan + 1) % numberOfFramesInCurrentAnimation
            }
            if animation.repeatTexturesForever {
                texturesAction = SKAction.repeatActionForever(SKAction.animateWithTextures(animation.offsetTextures, timePerFrame: TSAnimationComponent.timePerFrame))
            }
            else {
                texturesAction = SKAction.animateWithTextures(animation.offsetTextures, timePerFrame: TSAnimationComponent.timePerFrame)
            }
        }
        node.runAction(texturesAction , withKey: TSAnimationComponent.textureActionKey)
        
        currentAnimation = animation
        
        elapsedAnimationDuration = 0.0
        
    }
    class func firstTextureForOrientation(compassDirection: TSCompassDirection, inAtlas atlas: SKTextureAtlas, withImageIdentifier identifier: String) -> SKTexture {
        // Filter for this facing direction, and sort the resulting texture names alphabetically.
        let textureNames = atlas.textureNames.filter {
            $0.hasPrefix("\(identifier)_\(compassDirection.rawValue)_")
            }.sort()
        // Find and return the first texture for this direction.
        return atlas.textureNamed(textureNames.first!)
    }
    class func animationsFromAtlas(atlas: SKTextureAtlas, withImageIdentifier identifier: String, forAnimationState animationState: TSAnimationState, bodyActionName: String? = nil, shadowActionName: String? = nil, repeatTexturesForever: Bool = true, playBackwards: Bool = false) -> [TSCompassDirection: TSAnimation] {
        // Load a body action from an actions file if requested.
        let bodyAction: SKAction?
        if let name = bodyActionName {
            bodyAction = SKAction(named: name)
        }
        else {
            bodyAction = nil
        }
        /// A dictionary of animations with an entry for each compass direction.
        var animations = [TSCompassDirection: TSAnimation]()
        
        for compassDirection in TSCompassDirection.allDirections {
            
            // Find all matching texture names, sorted alphabetically, and map them to an array of actual textures.
            let textures = atlas.textureNames.filter {
                $0.hasPrefix("\(identifier)_\(compassDirection.rawValue)_")
                }.sort {
                    playBackwards ? $0 > $1 : $0 < $1
                }.map {
                    atlas.textureNamed($0)
            }
            
            // Create a new `Animation` for these settings.
            animations[compassDirection] = TSAnimation(
                animationState: animationState,
                compassDirection: compassDirection,
                textures: textures,
                frameOffset: 0,
                repeatTexturesForever: repeatTexturesForever,
                bodyActionName: bodyActionName,
                bodyAction: bodyAction
            )
        }
        return animations
    }
    
    
    
    
}
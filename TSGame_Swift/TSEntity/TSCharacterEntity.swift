//
//  TSCharacterEntity.swift
//  TSGame_Swift
//
//  Created by 王磊 on 16/1/28.
//  Copyright © 2016年 tarena. All rights reserved.
//
import SpriteKit
import GameplayKit

class TSCharacterEntity: GKEntity {

    var node: SKSpriteNode?
    
    /// The animations to use for a `PlayerBot`.
    static var animations: [TSAnimationState: [TSCompassDirection: TSAnimation]]?
    
    var animationComponent: TSAnimationComponent!
    
    override init() {
        super.init()
        
        node = SKSpriteNode(texture: nil, size: CGSize(width: 100, height: 100))
        
        TSCharacterEntity.animations = [:]
        
        let oritentationComponent = TSOrientationComponent()
        
        addComponent(oritentationComponent)
        
        TSCharacterEntity.animations![.Walk] = TSAnimationComponent.animationsFromAtlas(SKTextureAtlas(named: "char"), withImageIdentifier: "char", forAnimationState: .Walk)
        
        guard let animations = TSCharacterEntity.animations else {
            fatalError("Attempt to access PlayerBot.animations before they have been loaded.")
        }
        
        animationComponent = TSAnimationComponent(textureSize: CGSize(width: 100, height: 100), animations: animations)
        
        addComponent(animationComponent)
        
        node?.addChild(animationComponent.node)
        
        
    }

    
}

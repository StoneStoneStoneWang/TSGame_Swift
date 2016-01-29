//
//  GameScene.swift
//  TSGame_Swift
//
//  Created by 王磊 on 16/1/27.
//  Copyright (c) 2016年 tarena. All rights reserved.
//

import SpriteKit

class TSGameScene: SKScene {
    
    let char = TSCharacterEntity()
    
    override func didMoveToView(view: SKView) {
        
        size = view.bounds.size
        
        char.node?.position = CGPoint(x: 100, y: 100)
        
        let or = char.componentForClass(TSOrientationComponent.self)! as TSOrientationComponent
        
        or.zRotation = CGFloat(M_PI / 8.0 * 3)
        
        addChild(char.node!)
        
        //  加入 摄像头
//        let myCamera = SKCameraNode()
//        
//        camera = myCamera
//        
//        myCamera.name = "camera"
//        
//        myCamera.position = char.animationComponent.node!.position
//        
//        myCamera.setScale(1.0)
//        
//        addChild(myCamera)
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        char.updateWithDeltaTime(currentTime)
        
//        if let camera = camera {
//            camera.position = char.animationComponent.node!.position
//        }
    }
}


//
//  GameViewController.swift
//  TSGame_Swift
//
//  Created by 王磊 on 16/1/28.
//  Copyright © 2016年 tarena. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure the view.
        let skView = SKView(frame: UIScreen.mainScreen().bounds)
        
        skView.backgroundColor = UIColor.whiteColor()
        
        view.addSubview(skView)
        
        skView.showsFPS = true
        
        skView.showsNodeCount = true
        
        let scene = TSGameScene()
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
        
        skView.presentScene(scene)
        
        
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .LandscapeLeft
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

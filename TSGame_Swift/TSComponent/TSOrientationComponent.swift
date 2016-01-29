//
//  TSOrientationComponent.swift
//  TSEncapsulation
//
//  Created by 王磊 on 15/12/17.
//  Copyright © 2015年 tarena. All rights reserved.
//

import SpriteKit
import GameplayKit

class TSOrientationComponent: GKComponent {
    // MARK: Properties
    
    var zRotation: CGFloat = 0.0 {
        didSet {
            let twoPi = CGFloat(M_PI * 2)
            zRotation = (zRotation + twoPi) % twoPi
        }
    }
    var compassDirection: TSCompassDirection {
        get {
            return TSCompassDirection(zRotation: zRotation)
        }
        set {
            zRotation = newValue.zRotation
        }
    }
   
    
}

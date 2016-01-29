//
//  TSCompassDirection.swift
//  TSEncapsulation
//
//  Created by 王磊 on 15/12/16.
//  Copyright © 2015年 tarena. All rights reserved.
//

import CoreGraphics

enum TSCompassDirection: Int {
    case Up = 1,RightUp
    case Right , RightDown
    case Down , LeftDown
    case Left , LeftUp
    static let allDirections: [TSCompassDirection] = [.Up, .RightUp , .Right , .RightDown , .Down , .LeftDown , .Left , .LeftUp]
    
    // 方向 度数
    var zRotation: CGFloat {
        let directionChangedAngle = CGFloat(M_PI * 2) / CGFloat(TSCompassDirection.allDirections.count)
        return directionChangedAngle * CGFloat(self.rawValue)
    }
    
    init(zRotation: CGFloat) {
        // 360°
        let twoPi = M_PI * 2
        
        let rotation = (Double(zRotation) + twoPi) % twoPi
        
        let orientation = rotation / twoPi
        
        let rawFacingValue = round(orientation * 16.0) % 16.0
        
        self = TSCompassDirection(rawValue: Int(rawFacingValue))!
        
    }
    init(string: String) {
        switch string {
        case "Up":
            self = .Up
        case "RightUp":
            self = .RightUp
        case "Right":
            self = .Right
        case "RightDown":
            self = .RightDown
        case "Down":
            self = .Down
        case "LeftDown":
            self = .LeftDown
        case "Left":
            self = .Left
        case "LeftUp":
            self = .LeftUp
        default:
            fatalError("Unknown or unsupported string ---- \(string)")
        }
    }
    
    
}

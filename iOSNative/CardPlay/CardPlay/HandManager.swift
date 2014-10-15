//
//  HandManager.swift
//  CardPlay
//
//  Created by Michael Garrido on 10/15/14.
//  Copyright (c) 2014 Michael Garrido. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import SceneKit
import SpriteKit

struct Layout {
    
    enum Axis {
        case x, y, z
    }
    
    func distributePositionsAlongVector(){
        
    }
    
    func distributePositionsAcrossAxis(count:Int, origin:SCNVector3, cardWidth:Float, axis:Axis) -> [Float] {
        println("distributePositionsAcrossAxis")
        var positions:[Float] = []
        
        for index in 1...count {
            println("position \(index)")
        }
        
        var position:SCNVector3 = origin
        var value:Float!
        
        switch (axis) {
            case Axis.x:
                position.x = value
            
            case Axis.y:
                position.y = value
            
            case Axis.z:
                position.z = value
        }
        
        println("adding position \(position)")
        
        
        return positions
    }
}
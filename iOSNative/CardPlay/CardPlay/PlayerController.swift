//
//  PlayerController.swift
//  CardPlay
//
//  Created by Michael Garrido on 10/15/14.
//  Copyright (c) 2014 Michael Garrido. All rights reserved.
//

import Foundation
import SceneKit

class Player {
    
    var rootNode = SCNNode()
    var positionIndicator:SCNNode!
    
    let INDICATOR_SIZE:CGFloat = 20.0
    
    init(){
        
        // indicator is a floating sphere
        positionIndicator = SCNNode(geometry: SCNSphere(radius: INDICATOR_SIZE))
        
        rootNode.addChildNode(positionIndicator)
    }
    
    
    
    // define hand zone
    
    // define table zone in front of player
    
    // assign user and other identifiers
    
    
    // if player, 
    // attach camera
    
}
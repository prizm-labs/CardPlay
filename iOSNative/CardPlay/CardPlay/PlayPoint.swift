//
//  PlayPoint.swift
//  CardPlay
//
//  Created by Michael Garrido on 10/23/14.
//  Copyright (c) 2014 Michael Garrido. All rights reserved.
//

import Foundation
import SpriteKit
import SceneKit
import UIKit

class PlayPoint {
    
    var rootNode:SCNNode!
    var indicatorNode:SCNNode!
    var highlightNode:SCNNode!
    
    let ORB_RADIUS:CGFloat = CGFloat(10.0)
    
    // animate creation
    // set detection radius
    // show dormant indicator
    
    // link active edge
    
    // detect pending object
    // show active indicator, about to receive object
    // show action path into point
    
    // release pending object
    // show dormant indicator
    
    // commit object
    // animate object to point
    // release object
    
    // animate destruction
    
    init(position:SCNVector3, orientation:SCNVector3){
        
        rootNode = SCNNode()
        
        indicatorNode = SCNNode(geometry: SCNSphere(radius: ORB_RADIUS))
        rootNode.addChildNode(indicatorNode)
        
    }
    
}

class GhostAction {
    
    // origin
    // destination
    
    // path 
    
    // ghost object
    
}
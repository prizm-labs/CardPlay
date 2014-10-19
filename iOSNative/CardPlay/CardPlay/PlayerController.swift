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
    
    var origin:SCNVector3!
    
    var handGroup:CardGroup!
    var fieldGroup:CardGroup!
    
    let INDICATOR_SIZE:CGFloat = 20.0
    
    init(origin:SCNVector3){
        
        self.origin = origin
        
        // indicator is a floating sphere
        positionIndicator = SCNNode(geometry: SCNSphere(radius: INDICATOR_SIZE))
        
        rootNode.addChildNode(positionIndicator)
        rootNode.position = self.origin
        
        // card groups
        handGroup = CardGroup(organizationMode: CardGroup.OrganizationMode.Fan, orientation: SCNVector3Make(0, 0, 0), origin:self.origin)
        
        fieldGroup = CardGroup(organizationMode: CardGroup.OrganizationMode.Open, orientation: SCNVector3Make(CFloat(M_PI/2), 0, 0), origin:self.origin)
        
    }
    
    func drawCardFromGroup(card:CardNode, group:CardGroup) {
        
        group.removeCard(card)
        group.organize(group.organizationMode, vector: SCNVector3Zero, duration: 1.0)
        
        handGroup.addCard(card)
        handGroup.organize(handGroup.organizationMode, vector: SCNVector3Zero, duration: 2.0)
    }
    
    func drawCardsFromGroup(drawCount:Int, group:CardGroup){
        
        // draw from top
        
        // draw from bottom
        
    }
    
    
    
    // define hand zone
    
    // define table zone in front of player
    
    // assign user and other identifiers
    
    
    // if player, 
    // attach camera
    
}
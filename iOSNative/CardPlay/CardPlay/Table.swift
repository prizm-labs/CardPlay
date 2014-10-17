//
//  Table.swift
//  CardPlay
//
//  Created by Michael Garrido on 10/15/14.
//  Copyright (c) 2014 Michael Garrido. All rights reserved.
//

import Foundation
import SceneKit
import UIKit

class Table {
    
    
    // dimensions
    let RADIUS:CGFloat = 500.0
    let DEPTH:CGFloat = 20.0
    
    // tabletop, circle
    var rootNode:SCNNode!
    
    var tableMaterial:SCNMaterial!
    
    init(){
        
        var tablePath:UIBezierPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: RADIUS, height: RADIUS), cornerRadius: RADIUS)
        
        var tableGeometry = SCNShape(path: tablePath, extrusionDepth: DEPTH)

        
        //tableMaterial.diffuse.contents =  "green-felt.jpg"
        tableMaterial.diffuse.contents = UIImage(named:"green-felt.jpg")
        tableMaterial.locksAmbientWithDiffuse = true
        tableMaterial.diffuse.wrapS = SCNWrapMode.Repeat
        tableMaterial.diffuse.wrapT = SCNWrapMode.Repeat
        tableMaterial.diffuse.mipFilter = SCNFilterMode.Linear
        
        
        tableGeometry.firstMaterial = tableMaterial
        
        rootNode = SCNNode(geometry: tableGeometry)
        rootNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Static, shape: nil)
        rootNode.physicsBody?.restitution = 1.0
    }
    
    
    
    // player count
    
    // spawn player
    
    // arrange players around table
    
    
    
    // set play point
    // highlight play point
    
        // spawn deck
    
        // place a card
        // place a deck
    
    
    
}
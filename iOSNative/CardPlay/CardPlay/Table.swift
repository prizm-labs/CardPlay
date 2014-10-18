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
    var tableNode:SCNNode!
    //
    
    var players:[Player] = []
    
    init(){
        
        rootNode = SCNNode()
        
        var tablePath:UIBezierPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: RADIUS, height: RADIUS), cornerRadius: RADIUS)
        
        var tableGeometry = SCNShape(path: tablePath, extrusionDepth: DEPTH)

        var tableMaterial = SCNMaterial()
        //tableMaterial.diffuse.contents =  "green-felt.jpg"
        tableMaterial.diffuse.contents = UIImage(named:"green-felt.jpg")
        tableMaterial.locksAmbientWithDiffuse = true
        tableMaterial.diffuse.wrapS = SCNWrapMode.Repeat
        tableMaterial.diffuse.wrapT = SCNWrapMode.Repeat
        tableMaterial.diffuse.mipFilter = SCNFilterMode.Linear
        
        tableGeometry.firstMaterial = tableMaterial
        
        tableNode = SCNNode(geometry: tableGeometry)
        tableNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Static, shape: nil)
        tableNode.physicsBody?.restitution = 1.0
        tableNode.eulerAngles = SCNVector3Make(CFloat(M_PI), 0, 0)
        //tableNode.pivot = SCNMatrix4MakeTranslation(CFloat(RADIUS)*0.5, 0, 0)
        
        rootNode.addChildNode(tableNode)
    }
    
    func spawnPlayer() {
        
        
        
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
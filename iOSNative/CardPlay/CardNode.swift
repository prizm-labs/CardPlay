//
//  CardNode.swift
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

class CardNode {
    
    enum RenderModes {
        case FrontAndBack
        case FrontOnly
        case BackOnly
        case BodyOnly
    }
    
    var rootNode = SCNNode()
    var currentRenderMode = RenderModes.FrontAndBack
    
    var _cardBack:SCNNode!
    var _cardFront:SCNNode!
    var _cardBody:SCNNode!
    
    
    init(height:CGFloat, width:CGFloat, thickness:CGFloat, cornerRadius:CGFloat, cardFrontImage:String, cardBackImage:String){
    
        var cardPath:UIBezierPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: width, height: height), cornerRadius: cornerRadius)
    
        var cardVolume = SCNShape(path: cardPath, extrusionDepth: thickness)
        var cardFrontPlane = SCNShape(path: cardPath, extrusionDepth: 0)
        var cardBackPlane = SCNShape(path: cardPath, extrusionDepth: 0)
        
        _cardBack = SCNNode(geometry: cardBackPlane)
        _cardBack.name = "back"
        _cardBack.pivot = SCNMatrix4MakeTranslation(CFloat(width)*0.5, 0, 0)
        //cardBack.pivot = SCNMatrix4MakeTranslation(CFloat(CARD_WIDTH*CARD_RESIZE_FACTOR), CFloat(CARD_HEIGHT*CARD_RESIZE_FACTOR), 0)
        
        var backMaterial = SCNMaterial()
        backMaterial.diffuse.contents = cardBackImage
        backMaterial.locksAmbientWithDiffuse = true
        backMaterial.diffuse.mipFilter = SCNFilterMode.Linear
        
        _cardFront = SCNNode(geometry: cardFrontPlane)
        _cardFront.name = "front"
        _cardFront.pivot = SCNMatrix4MakeTranslation(CFloat(width)*0.5, 0, 0)
        
        var frontMaterial = SCNMaterial()
        frontMaterial.diffuse.contents =  cardFrontImage
        frontMaterial.locksAmbientWithDiffuse = true
        frontMaterial.diffuse.mipFilter = SCNFilterMode.Linear
        
        var cardPlaneOffset = CFloat(thickness) / 2.0 + 0.01
        
        _cardFront.geometry?.firstMaterial = frontMaterial
        _cardFront.position = SCNVector3Make(0, 0, cardPlaneOffset)
        
        _cardBack.geometry?.firstMaterial = backMaterial
        _cardBack.position = SCNVector3Make(0, 0, -cardPlaneOffset)
        _cardBack.eulerAngles = SCNVector3Make(0, CFloat(M_PI), 0)
        _cardBack.rotation = SCNVector4Make(0, 1.0, 0, CFloat(M_PI))
        
        
        _cardBody = SCNNode(geometry: cardVolume);
        _cardBody.name = "body"
        _cardBody.pivot = SCNMatrix4MakeTranslation(CFloat(width)*0.5, 0, 0)
        //        cardNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Dynamic, shape: nil)
        //        cardNode.physicsBody?.restitution = 0.01
        //        cardNode.physicsBody?.mass = 5
        //        cardNode.physicsBody?.angularVelocity = SCNVector4Make(5, 1, 1, 1)
        
        rootNode.addChildNode(_cardBody)
        rootNode.addChildNode(_cardFront)
        rootNode.addChildNode(_cardBack)
        
        //updateRenderMode(currentRenderMode)
        
    }
    
    func updateRenderMode(mode:RenderModes){
        
        println("updateRenderMode \(mode)")
        
        currentRenderMode = mode
        
        switch currentRenderMode {
        case .FrontAndBack:
            _cardFront.hidden = false
            _cardBack.hidden = false
            _cardBody.hidden = true
            
        case .FrontOnly:
            _cardFront.hidden = false
            _cardBack.hidden = true
            _cardBody.hidden = false
            
        case .BackOnly:
            _cardFront.hidden = true
            _cardBack.hidden = false
            _cardBody.hidden = false
            
        case .BodyOnly:
            _cardFront.hidden = true
            _cardBack.hidden = true
            _cardBody.hidden = false

            
        }
        
    }

}
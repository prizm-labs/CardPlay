//
//  CardDeck.swift
//  CardPlay
//
//  Created by Michael Garrido on 10/16/14.
//  Copyright (c) 2014 Michael Garrido. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

class Deck {
    
    var cardNodes:[CardNode] = []
    var rootNode:SCNNode!
    var size:CardSize!
    var origin:SCNVector3!
    
    init(atlas:[String:String], manifest:[[String]], size:CardSize, origin:SCNVector3) {
        for card in manifest {
            
            self.size = size
            self.origin = origin
            
            let imageFront = atlas[card[1]]
            let imageBack = atlas[card[0]]
            
            rootNode = SCNNode()
            
            println("\(card) : \(imageFront) , \(imageBack)")
            
            //var cardNode = createCard(imageFront!, cardBackImage:imageBack!)
            
            var cardNode = CardNode(size:size, cardFrontImage: imageFront!, cardBackImage: imageBack!)
            cardNode.rootNode.position = self.origin
            cardNode.rootNode.position.y += 100
            
            cardNodes.append(cardNode)
            
            //deckCards.append(cardNode)
            //deckCards.addObject(cardNode)
            
            //_scene.rootNode.addChildNode(cardNode.rootNode)
        }
    }
    
    func spawn(rootNode:SCNNode) {
        // TODO animate cards entering gme world
        // fade in?
        
        for card in cardNodes {
            rootNode.addChildNode(card.rootNode)
        }
    }
    
    func gatherCards(position:SCNVector3) {
        
        self.origin = position
        
        var index:Int
        
        //for index = 0; index < cardNodes.count; ++index {
        
        for (index, cardNode) in enumerate(cardNodes) {
            
            var cardNode = cardNodes[index]
            
            cardNode.updateRenderMode(CardNode.RenderModes.BackOnly)
            
            SCNTransaction.begin()
            SCNTransaction.setAnimationDuration(2.0)
            
            println("card height \(index)")
            
            // Lay card flat
            println("card rotation x \(cardNode.rootNode.rotation.x)")
            //cardNode.rotation.x = CFloat(M_PI / 2)
            //cardNode.rotation.x = 0.5
            
            cardNode.rootNode.runAction(SCNAction.rotateByX(CGFloat(M_PI / 2), y: 0, z: 0, duration: 1))
            
            
            // Stack height by index
            cardNode.rootNode.position = self.origin
            cardNode.rootNode.position.y = Float(size.thickness) * (Float(index)*2.0+0.5)
            
            
            SCNTransaction.commit()
        }
        
        // TODO the topmost card, show back
        
    }
    
}
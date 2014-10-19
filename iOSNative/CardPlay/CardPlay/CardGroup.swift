//
//  CardGroup.swift
//  CardPlay
//
//  Created by Michael Garrido on 10/15/14.
//  Copyright (c) 2014 Michael Garrido. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

class CardGroup {
    
    enum TransitionType {
        case Direct
    }
    
    enum OrganizationMode {
        case Open
        case Stack
        case Fan
        case Vector
    }
    
    var cards:NSMutableArray = []
    var organizationMode:OrganizationMode
    var orientation:SCNVector3!
    var origin:SCNVector3!
    
    // origin
    
    init(organizationMode:OrganizationMode, orientation:SCNVector3, origin:SCNVector3){
        
        self.organizationMode = organizationMode
        self.orientation = orientation
        self.origin = origin // within scene.rootNode
        
    }
    
    func addCard(card:CardNode){
        println("addCard")
        if !cards.containsObject(card) {
            cards.addObject(card)
        }
        println("card group \(self.cards.count)")
    }
    
    func addCards(cards:NSMutableArray) {
        println("addCards")
        for card in cards {
            if !self.cards.containsObject(card) {
                self.cards.addObject(card)
            }
        }
        println("card group \(self.cards.count)")
    }
    
    func removeCard(card:CardNode){
        println("removeCard")
        
        if self.cards.containsObject(card) {
            self.cards.removeObject(card)
        }
        
    }
    
    func removeCards(cards:[CardNode]) {
        
    }
    
    func commitTransfer() {
        
        // generate positions for updated cards
        
        
        // animate cards into position
        
    }
    
    func organize(mode:OrganizationMode, vector:SCNVector3, duration:CFloat) {

        organizationMode = mode
        
        switch organizationMode {
            
        case .Open:
            println("Open")
            
            
        case .Stack:
            println("Stack")
            for (index, cardNode) in enumerate(cards) {
                
                var cardNode:CardNode = cards[index] as CardNode
                
                cardNode.updateRenderMode(CardNode.RenderModes.BackOnly)
                
                if duration>0 {
                    SCNTransaction.begin()
                    SCNTransaction.setAnimationDuration(2.0)
                }
                
            
                cardNode.rootNode.eulerAngles = self.orientation
                
                // TODO stack along vector
                
                // Stack height by index
                cardNode.rootNode.position = self.origin
                cardNode.rootNode.position.y = Float(cardNode.size.thickness) * (Float(index)*2.0+0.5)
                
                if duration>0 {
                    SCNTransaction.commit()
                }
            }
            
            
        case .Fan:
            println("Fan")
            for (index, cardNode) in enumerate(cards) {
                
                var cardNode:CardNode = cards[index] as CardNode
                
                cardNode.updateRenderMode(CardNode.RenderModes.FrontAndBack)
                
                if duration>0 {
                    SCNTransaction.begin()
                    SCNTransaction.setAnimationDuration(2.0)
                }
                
                
                cardNode.rootNode.eulerAngles = self.orientation
                
                // TODO stack along vector
                
                // Stack height by index
                cardNode.rootNode.position = self.origin
                //cardNode.rootNode.position.y = Float(cardNode.size.thickness) * (Float(index)*2.0+0.5)
                
                if duration>0 {
                    SCNTransaction.commit()
                }
            }
            
            
        case .Vector:
            println("Vector")
            
        }
        
        
    }
    // orientation
    // flat on table
    // in hand
    
    
    // auto-organize 
    // into even fan
    // into straight line
    
    
    // manipulate
    // spread fan to highlight middle card
    
    // gather and stack
    // shuffle
}

/*
Zones:

on table

in hand

above table

*/

class CardZone {
    
    // orientation
    // horizontal
    
    
    // add card with transition
    // OutAndDown
    // i.e. draw card from deck
    // UpAndIn
    // i.e. play card from hand
    
    // straight vector translation
    
    
    // remove card
}
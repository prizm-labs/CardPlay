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
        case Open, Stack, Fan
    }
    
    var cards:[CardNode] = []
    var organizationMode:OrganizationMode!
    var orientation:SCNVector3!
    
    // origin
    
    init(organizationMode:OrganizationMode, orientation:SCNVector3){
        
        self.organizationMode = organizationMode
        self.orientation = orientation
        
    }
    
    func addCard(card:CardNode){
        
    }
    
    func addCards(cards:[CardNode]) {
        
    }
    
    func removeCard(card:CardNode){
        
    }
    
    func removeCards(cards:[CardNode]) {
        
    }
    
    func commitTransfer() {
        
        // generate positions for updated cards
        
        
        // animate cards into position
        
    }
    
    func organize(mode:OrganizationMode) {
        
        
        
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
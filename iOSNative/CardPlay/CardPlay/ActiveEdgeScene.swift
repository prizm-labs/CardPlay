//
//  ActiveEdgeScene.swift
//  CardPlay
//
//  Created by Michael Garrido on 10/23/14.
//  Copyright (c) 2014 Michael Garrido. All rights reserved.
//

import Foundation
import SpriteKit


class UIOverlayScene:SKScene {
    
    var egdeGroups:NSMutableArray = NSMutableArray()
    var currentEdgeGroup:EdgeGroup?
    var currentHotspot:Hotspot?
    
    
    // main menu buton
    
    override init(size: CGSize) {
        
        
        super.init(size: size)
        
        
        println("overlay size: \(size.width) , \(size.height)")
        
        currentEdgeGroup = nil
        currentHotspot = nil
        
        self.backgroundColor = SKColor(red: 0.15, green: 0.15, blue: 0.3, alpha: 0.5)
        
        var scoreLabel:SKLabelNode = SKLabelNode(text: "hello world")
        scoreLabel.position = CGPoint(x: 100.0, y: 100.0)
        self.addChild(scoreLabel)
        
        scoreLabel.calculateAccumulatedFrame()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //on pan update (with active object) near edge
    func detectHotspotNearLocation(location:CGPoint)->Hotspot? {
        
        var hotspot:Hotspot? = currentEdgeGroup?.findHotspotNearLocation(location)
        
        if (hotspot != nil) {
            self.activateHotspot(hotspot)
        } else {
            self.deactivateHotspot()
        }
        
        return hotspot
    }
    
    func activateHotspot(hotspot:Hotspot?) {
        currentHotspot=hotspot
        currentHotspot?.updateActionState(Hotspot.ActionState.pending)
    }
    
    //on pan update leaves edge
    func deactivateHotspot(){
        currentHotspot?.updateActionState(Hotspot.ActionState.inactive)
        currentHotspot = nil
    }
    
    //on pan ended and inside hotspot
    func confirmHotspot()->Bool{
        
        if currentHotspot != nil {
            
            currentHotspot?.updateActionState(Hotspot.ActionState.activated)
            currentHotspot = nil
            
            return true
        } else {
            return false
        }
    }
    
    
    func activateEdgeGroup() {
        
    }
    
    func deactivateEdgeGroup() {
        
    }
    
}


class EdgeGroup {
    
    var hotspots:NSMutableArray = NSMutableArray()
    
    var camera:Camera?
    
    // position on screen
    
    // PlayPoint linked
    
    // Ghost Action derived
    
    func addHotspot(location:CGPoint, playPoint:PlayPoint) {
        
        
    }
    
    func arrangeHotspots(){
        
        // when hotspot is added / removed 
        // reposition hotspots and resize radius
        
        //TODO animate changes
    }
    
    func findHotspotNearLocation(location:CGPoint)->Hotspot? {
        
        var hotspot:Hotspot? = nil
        
        
        
        return hotspot
    }
    
}

class Hotspot {
    
    enum ActionState {
        case inactive, pending, activated
    }
    
    var playPoint:PlayPoint?
    var location:CGPoint!
    var actionState:ActionState = ActionState.inactive
    
    init(location:CGPoint, playPoint:PlayPoint) {
        self.location = location
        self.playPoint = playPoint
    }
    
    func updateActionState(state:ActionState) {
        
        actionState = state
        
    }
    
}
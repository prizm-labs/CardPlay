//
//  CameraController.swift
//  CardPlay
//
//  Created by Michael Garrido on 10/15/14.
//  Copyright (c) 2014 Michael Garrido. All rights reserved.
//

import Foundation
import SceneKit
import UIKit

class CameraPerspective {
    var orientation:SCNVector3!
    var position:SCNVector3!
    
    init(orientation:SCNVector3, position:SCNVector3) {
        self.orientation = orientation
        self.position = position
    }
    
    init(camera:Camera) {
        // copy transform from existing camera
        self.orientation = camera.orientationHandle.eulerAngles
        self.position = camera.positionHandle.position
    }
    
    func transformCamera(camera:Camera) {
        camera.positionHandle.position = self.position
        camera.orientationHandle.eulerAngles = self.orientation
    }
    
}


class Camera {
    
    var perspectives:NSMutableArray = []
    
    var cameraNode:SCNNode!
    var positionHandle:SCNNode!
    var orientationHandle:SCNNode!
    
    var orientation:SCNVector3!
    var position:SCNVector3!
    
    var orientationMode:OrientationMode
    
    enum OrientationMode {
        case PlayerHand, TableOverhead, TablePanorama, Opponent
    }
    // update gesture bindings based on camera orientation mode
    /*
        case PlayerHand
        translate card in vertical plane
    */
    /*
        case TableOverhead
        translate card in horizontal plane
    */
    
    
    init(){
        
    
        // create and add a camera to the scene
        cameraNode = SCNNode()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        positionHandle = SCNNode()
        positionHandle.position = SCNVector3(x: 0, y: 0, z: 0)
        
        orientationHandle = SCNNode()
        
        positionHandle.addChildNode(orientationHandle)
        orientationHandle.addChildNode(cameraNode)
        
        orientationMode = OrientationMode.PlayerHand
        
        var camera = SCNCamera()
        camera.zFar = 2000
        
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            camera.yFov = 55
        } else {
            camera.xFov = 75
        }
        
        cameraNode.camera = camera
        
        //TODO setup general transforms
        
        //        _cameraHandleTransforms.insert(_cameraNode.transform, atIndex: 0)
        //
    }
    
    func transform(position:SCNVector3, orientation:SCNVector3) {
        
        self.position = position
        self.orientation = orientation
        
        
        positionHandle.position = self.position
        orientationHandle.eulerAngles = self.orientation
    }
    
    func lookAtNode(target:SCNNode) {
        
        //cameraNode.camera
    }
    
    func setPerspective(){
        
    }
    
    
    // attach to player
    
    // dock a card on edge of view
        // on left edge
        // on right edge
        // on bottom edge
    
    // show edge highlights
    
    /*
    Orientations:
    
    focus hand from afar
    
    focus hand near
    
    focus single card hand
    
    overhead table
        zoom in/out
        focus single card table
    
    focus player
        from afar: hand and field
        focus on hand
        focus on field
    
    
    */
    
}
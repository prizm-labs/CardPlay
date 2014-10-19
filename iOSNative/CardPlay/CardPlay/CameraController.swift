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

class Camera {
    
    var cameraNode:SCNNode!
    var positionHandle:SCNNode!
    var orientationHandle:SCNNode!
    
    var orientation:SCNVector3!
    var position:SCNVector3!
    
    init(){
    
        // create and add a camera to the scene
        cameraNode = SCNNode()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        positionHandle = SCNNode()
        positionHandle.position = SCNVector3(x: 0, y: 0, z: 0)
        
        orientationHandle = SCNNode()
        
        positionHandle.addChildNode(orientationHandle)
        orientationHandle.addChildNode(cameraNode)
        
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
    
    func registerPresetTransform(){
        
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
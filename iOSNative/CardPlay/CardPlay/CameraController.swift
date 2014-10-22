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
    //var orientationMode:Camerea
    
    var zoomPositionStart:SCNVector3?

    

    func initRoot(orientation:SCNVector3, position:SCNVector3) {
        self.orientation = orientation
        self.position = position
        //self.key = key
        
        zoomPositionStart = nil
    }
    
    init(orientation:SCNVector3, position:SCNVector3) {
        initRoot(orientation, position:position)
    }

    
    init(camera:Camera) {
        // copy transform from existing camera
        initRoot(camera.orientationHandle.eulerAngles, position:camera.positionHandle.position)
    }
    
    func transformCamera(camera:Camera) {
        camera.positionHandle.position = self.position
        camera.orientationHandle.eulerAngles = self.orientation
    }
    
    
    func cachePosition(){
        
        // save position relative to perspective
        
    }
}


class Camera {
    
    var isInteractive = true
    
    var perspectives:NSMutableArray = []
    
    var cameraNode:SCNNode!
    var positionHandle:SCNNode!
    var orientationHandle:SCNNode!
    
    var orientation:SCNVector3!
    var position:SCNVector3!
    
    var orientationMode:OrientationMode
    
    var zoomPositionStart:SCNVector3?
    var panPositionStart:SCNVector3?
    
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
        
        zoomPositionStart = nil
        panPositionStart = nil
    
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
    
    func transform(position:SCNVector3, orientation:SCNVector3, duration:Float) {
        
        if (!isInteractive) {
            return
        }
        
        isInteractive = false
        
        self.position = position
        self.orientation = orientation
        
        //if duration>0 {
        SCNTransaction.begin()
        SCNTransaction.setAnimationDuration(CFTimeInterval(duration))
        
        SCNTransaction.setCompletionBlock({ () -> Void in
            self.isInteractive = true
        })
        //}
        
        positionHandle.position = self.position
        orientationHandle.eulerAngles = self.orientation
        
        SCNTransaction.commit()
    }
    
    func lookAtNode(target:SCNNode) {
        
        //cameraNode.camera
    }
    
    func setPerspective(){
        
    }
    
    func pan(translation:CGPoint) {
        
        if panPositionStart == nil {
            
            panPositionStart = SCNVector3Make(positionHandle.position.x,positionHandle.position.y,positionHandle.position.z)
        } else {
            
            let x = panPositionStart?.x
            let y = panPositionStart?.y
            let z = panPositionStart?.z
            
            switch orientationMode {
                
            case .TableOverhead:
                positionHandle.position = SCNVector3Make(x! - CFloat(translation.x), y!, z! + CFloat(translation.y))
                
            case .PlayerHand:
                positionHandle.position = SCNVector3Make(x! - CFloat(translation.x), y! - CFloat(translation.y), z!)
                
            default:
                println()
            }
            
        }

    }
    
    func resetPan() {
        
        println("resetPan")
        panPositionStart = nil
        
    }
    
    
    //func zoom(scale:CFloat) {
    func zoom(rotation:CFloat) {
        
        if zoomPositionStart == nil {
            zoomPositionStart = SCNVector3Make(positionHandle.position.x, positionHandle.position.y, positionHandle.position.z)
        } else {
            
            let zoomIn = rotation > 0
            //let zoomIn = scale > 1 // zoom mapped to pinch scale
            
            let maxDelta:CFloat = CFloat(300.0)
            var delta:CFloat!
            var zoomPosition:SCNVector3!
            //var delta:CFloat = zoomIn ? -(scale-CFloat(1.0))*maxDelta : (CFloat(1.0)-scale)*maxDelta
            
            
            let x = zoomPositionStart?.x
            let y = zoomPositionStart?.y
            let z = zoomPositionStart?.z
            
            // if playerHand
            switch orientationMode {
                
            case OrientationMode.PlayerHand:
                delta = -(rotation/CFloat(M_PI))*maxDelta
                //delta = zoomIn ? -(rotation/CFloat(M_PI))*maxDelta : (rotation/CFloat(M_PI))*maxDelta
                //delta = zoomIn ? -(scale-CFloat(1.0))*maxDelta : (CFloat(1.0)-scale)*maxDelta
                zoomPosition = SCNVector3Make( CFloat(x!), CFloat(y!), CFloat(z!+delta) )
                
            case OrientationMode.TableOverhead:
                delta = -(rotation/CFloat(M_PI))*maxDelta
                //delta = zoomIn ? -(rotation/CFloat(M_PI))*maxDelta : (rotation/CFloat(M_PI))*maxDelta
                //delta = zoomIn ? -(scale-CFloat(1.0))*maxDelta : (CFloat(1.0)-scale)*maxDelta
                zoomPosition = SCNVector3Make( CFloat(x!), CFloat(y!+delta), CFloat(z!) )
                
            default:
                println("no camera binding")
            }
            
            println("delta z: \(delta)")
            
            positionHandle.position = zoomPosition
            
            // if tableOverhead
            
        }
        
    }
    
    func resetZoom() {
        println("resetZoom")
        zoomPositionStart = nil
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
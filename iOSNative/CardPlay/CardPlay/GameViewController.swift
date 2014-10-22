//
//  GameViewController.swift
//  CardPlay
//
//  Created by Michael Garrido on 10/13/14.
//  Copyright (c) 2014 Michael Garrido. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import SpriteKit

import CoreMotion

import Foundation

class GameViewController: UIViewController, SCNSceneRendererDelegate, SCNPhysicsContactDelegate {
    
    let ORB_RADIUS = CGFloat(15)
    let CARD_WIDTH = CGFloat(500)
    let CARD_HEIGHT = CGFloat(726)
    let CARD_RADIUS = CGFloat(20)
    let CARD_DEPTH = CGFloat(2.5)
    
    let CARD_RESIZE_FACTOR = CGFloat(0.1)
    
    let TABLE_RADIUS = CGFloat(600.0)
    let TABLE_DEPTH = CGFloat(50.0)
    
    var handPosition:SCNVector3!
    var handCards:NSMutableArray = []
    var deckCards:NSMutableArray = []
    
    var cardAtlas:[String: String]!
    var cardManifest:[[String]] = []
    
    var _scene:SCNScene!
    
    var _cameraNode:SCNNode!
    var _cameraHandle:SCNNode!
    var _cameraOrientation:SCNNode!
    
    var camera:Camera!
    var perspectives:NSMutableArray = []
    
    // Gestures
    var gestureLibrary:[String:UIGestureRecognizer]!
    
    var _cameraHandleTransforms = [SCNMatrix4](count:10, repeatedValue:SCNMatrix4(m11: 0.0, m12: 0.0, m13: 0.0, m14: 0.0, m21: 0.0, m22: 0.0, m23: 0.0, m24: 0.0, m31: 0.0, m32: 0.0, m33: 0.0, m34: 0.0, m41: 0.0, m42: 0.0, m43: 0.0, m44: 0.0))
    
    
    var _ambientLightNode:SCNNode!
    
    var _spotlightParentNode:SCNNode!
    var _spotlightNode:SCNNode!
    
    var _floorNode:SCNNode!
    
    var _playerOrb:SCNNode!
    
    var cardNodes:[CardNode] = []
    
    var players:NSMutableArray = []
    
    
    var activeObject:SCNNode?
    var activeObjectOrigin:SCNVector3?
    var activeCard:CardNode?
    
    // Accelerometer
    var motionManager:CMMotionManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func parseAcceleration(acceleration:CMAcceleration){
        
        //println("parseAcceleration x:\(acceleration.x), y:\(acceleration.y), z:\(acceleration.z)")
        var activePerspective:CameraPerspective?
        
        // landscape
        // x = 1    vertical   perpendicular to tabletop
        // x = 0    horizontal parallel to tabletop
        
        let x = acceleration.x
        let threshold = 0.8
        
        var targetOrientationMode:Camera.OrientationMode
        
        if x < threshold && x > -threshold {
            //println("switch to horizontal")
            activePerspective = perspectives[1] as? CameraPerspective
            //camera.orientationMode = Camera.OrientationMode.TableOverhead
            targetOrientationMode = Camera.OrientationMode.TableOverhead
            
        } else {
            //println("switch to vertical")
            activePerspective = perspectives[0] as? CameraPerspective
            //camera.orientationMode = Camera.OrientationMode.PlayerHand
            targetOrientationMode = Camera.OrientationMode.PlayerHand

        }
        
        
        // portrait 
        // y = -1   vertical   perpendicular to tabletop
        // y = 0    horizontal parallel to tabletop
        
        if -acceleration.y>0.8 && -acceleration.y<1.2 {
            //println("switch to horizontal")
        } else {
            //println("switch to vertical")
        }
        
        
        
        //if activePerspective? !== nil {
        
        if camera.orientationMode != targetOrientationMode {
            
            println("triggered camera perspective switch")
            
            camera.orientationMode = targetOrientationMode
            activePerspective?.transformCamera(self.camera)
            
            
            // TODO update gestures???
            //updateGestures()
        }
        
        
    }
    
    func setupAccelerometer() {
        println("setupAccelerometer")
        
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler: { (accelerometerData, error) -> Void in
            self.parseAcceleration(accelerometerData.acceleration)
        })
        
//        if (motionManager.accelerometerAvailable) {
//            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue()) {
//                (data, error) in
//                
//                println("accelerometer \(data.acceleration)")
//                let currentX = monkey.position.x
//                let currentY = monkey.position.y
//                if(data.acceleration.y < -0.25) { // tilting the device to the right
//                    var destX = (CGFloat(data.acceleration.y) * CGFloat(kPlayerSpeed) + CGFloat(currentX))
//                    var destY = CGFloat(currentY)
//                    motionManager.accelerometerActive == true;
//                    let action = SKAction.moveTo(CGPointMake(destX, destY), duration: 1)
//                    monkey.runAction(action)
//                } else if (data.acceleration.y > 0.25) { // tilting the device to the left
//                    var destX = (CGFloat(data.acceleration.y) * CGFloat(kPlayerSpeed) + CGFloat(currentX))
//                    var destY = CGFloat(currentY)
//                    motionManager.accelerometerActive == true;
//                    let action = SKAction.moveTo(CGPointMake(destX, destY), duration: 1)
//                    monkey.runAction(action)
//                }
//            }
//            
//        }
        
    }
    
    func setupGestures() {
        
        let sceneView = view as SCNView
        
        // TODO double tap to flip card over
        //let doubleTapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        
        
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        //let tapGesture = UITapGestureRecognizer(target: self, action: "moveCamera")
        
        let panGesture = UIPanGestureRecognizer(target: self, action: "handlePan:")
        
        let pan1FGesture = UIPanGestureRecognizer(target: self, action: "handlePan1F:")
        pan1FGesture.minimumNumberOfTouches = 1
        pan1FGesture.maximumNumberOfTouches = 1
        
        let pan3FGesture = UIPanGestureRecognizer(target: self, action: "handlePan3F:")
        pan3FGesture.minimumNumberOfTouches = 2
        pan3FGesture.maximumNumberOfTouches = 2
        
        
        // pinch gesture
        // zoom camera in and out
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
        //pinchGesture.requireGestureRecognizerToFail(pan3FGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: "handleRotation:")
        
        gestureLibrary = [
            "OnTapHighlightObject": tapGesture,
            "OnPanTranslateObject":panGesture,
            "OnPinchZoomCamera":pinchGesture
        ]
        
        let gestureRecognizers = NSMutableArray()
        gestureRecognizers.addObject(tapGesture)
        //gestureRecognizers.addObject(panGesture)
        gestureRecognizers.addObject(pan1FGesture)
        gestureRecognizers.addObject(pan3FGesture)
        gestureRecognizers.addObject(rotationGesture)
        //gestureRecognizers.addObject(pinchGesture)
        
        if let existingGestureRecognizers = sceneView.gestureRecognizers {
            gestureRecognizers.addObjectsFromArray(existingGestureRecognizers)
        }
        sceneView.gestureRecognizers = gestureRecognizers
        
    }
    
    func updateGestures(){
        
        switch camera.orientationMode {
            
        case .PlayerHand:
            println("PlayerHand")
            // 1F pan on object to translate in vertical plane
            
//            let gestureRecognizers = NSMutableArray()
//            gestureRecognizers.addObject(tapGesture)
//            gestureRecognizers.addObject(panGesture)
            
        case .TableOverhead:
            println("TableOverhead")
            // 1F pan on object to translate in horizontal plane
            
        case .TablePanorama:
            println("TablePanorama")
            //
            
        case .Opponent:
            println("Opponent")
            
        }
        
        
        // TODO determine object specific bindings???
        
    }
    
    func setup() {
        
        // retrieve the SCNView
        let sceneView = view as SCNView
        
        sceneView.backgroundColor = SKColor.whiteColor()
    
        // cache for binding objects to gestures
        activeObject = nil
        activeCard = nil
        
        // Get cards manifest

        var error: NSError?

        let filePath = NSBundle.mainBundle().pathForResource("card-manifest", ofType: "json")
        
        println("sprite manifest path \(filePath)")
        
        let jsonData = NSData.dataWithContentsOfFile(filePath!, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: nil)
        
        println("sprite manifest \(jsonData)")
        
        let jsonDict = NSJSONSerialization.JSONObjectWithData(jsonData, options: nil, error: &error) as NSDictionary
        
        println("sprite manifest \(jsonDict)")
        
        if ((jsonDict["images"]) != nil) {
            
            cardAtlas = jsonDict["images"] as Dictionary
//            for (key, image) in cardAtlas {
//                println("\(key) : \(image)")
//            }
        }

        if ((jsonDict["cards"]) != nil) {
            cardManifest = jsonDict["cards"] as Array
        }
        
        
        setupScene()
        
        _scene.physicsWorld.speed = 2.0;
        _scene.physicsWorld.gravity = SCNVector3Make(0, -70, 0)
        
        sceneView.scene = _scene;
        
        sceneView.delegate = self
        //sceneView.jitteringEnabled = true
        
        sceneView.pointOfView = _cameraNode
        //sceneView.allowsCameraControl = true
        
        sceneView.showsStatistics = true
        

        setupGestures()

        
//        var overlay = SpriteKitOverlayScene
//        sceneView.overlaySKScene = overlay
        //        // retrieve the SCNView
        //        let scnView = self.view as SCNView
        //
        //        // set the scene to the view
        //        scnView.scene = scene
        //
        //        // allows the user to manipulate the camera
        //        scnView.allowsCameraControl = true
        //
        //        // show statistics such as fps and timing information
        //        scnView.showsStatistics = true
        //
        //        // configure the view
        //        scnView.backgroundColor = UIColor.blackColor()
        //
    }
    
    func setupScene() {
        
        _scene = SCNScene()
        
        setupEnvironment()
        setupSceneElements()
        setupInitialLighting()
        
        //        // create a new scene
        //        let scene = SCNScene(named: "art.scnassets/ship.dae")
        //

        //
        //        // retrieve the ship node
        //        let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
        //        
        //        // animate the 3d object
        //        ship.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 2, z: 0, duration: 1)))
        //
    }
    
    func setupPlayerCamera() {
        
        camera = Camera()
        
        _scene.rootNode.addChildNode(camera.positionHandle)
        _cameraNode = camera.cameraNode
        
        // position default behind player
        var playerDefaultPerspective = CameraPerspective(orientation: SCNVector3Make(-CFloat(M_PI * 0.15), 0, 0), position: SCNVector3Make(0,150,Float(TABLE_RADIUS*0.75)))
        
        // position over table
        var tableDefaultPerspective = CameraPerspective(orientation: SCNVector3Make(-CFloat(M_PI_2),0,0), position: SCNVector3Make(0, 250, 0))
        
        self.perspectives.addObject(playerDefaultPerspective)
        self.perspectives.addObject(tableDefaultPerspective)
        
        //camera.transform(SCNVector3Make(0,150,Float(TABLE_RADIUS*0.75)), orientation: SCNVector3Make(-CFloat(M_PI * 0.15), 0, 0))
        
        // Accelerometer bound to... camera?
        setupAccelerometer()
    }
    
    func setupEnvironment() {

        setupPlayerCamera()
        
        _ambientLightNode = SCNNode()
        
        var ambientLight = SCNLight()
        ambientLight.type = SCNLightTypeAmbient
        ambientLight.color = SKColor(white: 0.8, alpha: 0.8)
        _ambientLightNode.light = ambientLight
        
        _scene.rootNode.addChildNode(_ambientLightNode)
        
        _spotlightParentNode = SCNNode()
        _spotlightParentNode.position = SCNVector3Make(0, 90, 20)
        
        _spotlightNode = SCNNode()
        _spotlightNode.rotation = SCNVector4Make(1, 0, 0, CFloat(-M_PI_4))
        
        var spotlight = SCNLight()
        spotlight.type = SCNLightTypeSpot
        spotlight.color = SKColor(white: 1.0, alpha: 1.0)
        spotlight.castsShadow = true
        spotlight.shadowColor = SKColor(white: 0, alpha: 0.5)
        spotlight.zNear = 30
        spotlight.zFar = 800
        spotlight.shadowRadius = 1.0
        spotlight.spotInnerAngle = 15
        spotlight.spotOuterAngle = 70
        
        _spotlightNode.light = spotlight
        _cameraNode.addChildNode(_spotlightParentNode)
        _spotlightParentNode.addChildNode(_spotlightNode)
        
        
        // Floor
        var floor = SCNFloor()
        floor.reflectionFalloffEnd = 0
        floor.reflectivity = 0
        
        var tableMaterial = SCNMaterial()
        //tableMaterial.diffuse.contents =  "green-felt.jpg"
        tableMaterial.diffuse.contents = UIImage(named:"green-felt.jpg")
        tableMaterial.locksAmbientWithDiffuse = true
        tableMaterial.diffuse.wrapS = SCNWrapMode.Repeat
        tableMaterial.diffuse.wrapT = SCNWrapMode.Repeat
        tableMaterial.diffuse.mipFilter = SCNFilterMode.Linear
        
        floor.firstMaterial = tableMaterial
        
        _floorNode = SCNNode()
        _floorNode.geometry = floor
        _floorNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Static, shape: nil)
        _floorNode.physicsBody?.restitution = 1.0
        
        _floorNode.position.y -= 200.0
        
        _scene.rootNode.addChildNode(_floorNode)
        
        var table = Table(radius: 600.0, depth: 50.0)
        
        _scene.rootNode.addChildNode(table.rootNode)
    }
    
    func setupSceneElements() {
        
    }
    
    func setupInitialLighting() {
        
//        _playerOrb = SCNNode(geometry: SCNSphere(radius: ORB_RADIUS))
//        //_playerOrb.geometry.firstMaterial.diffuse.contents = SKColor(red: 1.0, green: 0, blue: 0, alpha: 1.0)
//        _playerOrb.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Dynamic, shape: nil)
//        _playerOrb.physicsBody?.restitution = 0.9
//        
//        _playerOrb.position = SCNVector3Make(0, 0, 0)
//        _playerOrb.position.y += CFloat(ORB_RADIUS * 8)
//        
//        _scene.rootNode.addChildNode(_playerOrb)
        
        
//        var cardNode = createCard("ace_of_spades.png", cardBackImage:"back-default.png")
//        cardNode.position = SCNVector3Make(0, 0, 0)
//        cardNode.position.y += 50
//        _scene.rootNode.addChildNode(cardNode)
        
        //cardNode.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: CGFloat(M_PI), z: 0, duration: 4)))

        
        // Deck of cards
        var size = CardSize(height: CARD_HEIGHT, width: CARD_WIDTH, cornerRadius: CARD_RADIUS, thickness: CARD_DEPTH)
        size.scale(CARD_RESIZE_FACTOR)

        var deck = Deck(atlas:cardAtlas,manifest:cardManifest,size:size,origin:SCNVector3Make(0, 0, 0))
        // Deck default group as stack
        var deckStackGroup = CardGroup(organizationMode: CardGroup.OrganizationMode.Stack, orientation: SCNVector3Make(CFloat(M_PI/2), 0, 0), origin:SCNVector3Make(0, 0, 0))
        
        deck.setGroup(deckStackGroup)
        deck.spawn(_scene.rootNode)

        
        // Players
        var player = Player(origin: SCNVector3Make(0, 50, Float(TABLE_RADIUS*0.5)))
        
        // Draw card
        player.drawCardFromGroup(deck.cards[0] as CardNode, group: deck.group)
        
        // general table surface
        var tableSurfaceGroup = CardGroup(organizationMode: CardGroup.OrganizationMode.Open, orientation: SCNVector3Make(CFloat(M_PI/2), 0, 0), origin:SCNVector3Make(0, 0, 0))
        
        // hover group
        var tableHoverGroup = CardGroup(organizationMode: CardGroup.OrganizationMode.Open, orientation: SCNVector3Make(CFloat(M_PI/2), 0, 0), origin:SCNVector3Make(0, 150.0, 0))
        
        
    }
    
    func createCard (cardFrontImage:String, cardBackImage:String) -> SCNNode {
        
        var cardPath:UIBezierPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: CARD_WIDTH*CARD_RESIZE_FACTOR, height: CARD_HEIGHT*CARD_RESIZE_FACTOR), cornerRadius: CARD_RADIUS*CARD_RESIZE_FACTOR)
        
        var cardVolume = SCNShape(path: cardPath, extrusionDepth: CARD_DEPTH*CARD_RESIZE_FACTOR)
        var cardFrontPlane = SCNShape(path: cardPath, extrusionDepth: 0)
        var cardBackPlane = SCNShape(path: cardPath, extrusionDepth: 0)
        
        var cardContainer = SCNNode()
        
        var cardBack = SCNNode(geometry: cardBackPlane)
        cardBack.name = "back"
        cardBack.pivot = SCNMatrix4MakeTranslation(CFloat(CARD_WIDTH*CARD_RESIZE_FACTOR)*0.5, 0, 0)
        //cardBack.pivot = SCNMatrix4MakeTranslation(CFloat(CARD_WIDTH*CARD_RESIZE_FACTOR), CFloat(CARD_HEIGHT*CARD_RESIZE_FACTOR), 0)
        
        var backMaterial = SCNMaterial()
        backMaterial.diffuse.contents = cardBackImage
        backMaterial.locksAmbientWithDiffuse = true
        backMaterial.diffuse.mipFilter = SCNFilterMode.Linear
        
        var cardFront = SCNNode(geometry: cardFrontPlane)
        cardFront.name = "front"
        cardFront.pivot = SCNMatrix4MakeTranslation(CFloat(CARD_WIDTH*CARD_RESIZE_FACTOR)*0.5, 0, 0)
        
        var frontMaterial = SCNMaterial()
        frontMaterial.diffuse.contents =  cardFrontImage
        frontMaterial.locksAmbientWithDiffuse = true
        frontMaterial.diffuse.mipFilter = SCNFilterMode.Linear
        
        var cardPlaneOffset = CFloat(CARD_DEPTH*CARD_RESIZE_FACTOR) / 2.0 + 0.01
        
        cardFront.geometry?.firstMaterial = frontMaterial
        cardFront.position = SCNVector3Make(0, 0, cardPlaneOffset)
        
        cardBack.geometry?.firstMaterial = backMaterial
        cardBack.position = SCNVector3Make(0, 0, -cardPlaneOffset)
        cardBack.eulerAngles = SCNVector3Make(0, CFloat(M_PI), 0)
        cardBack.rotation = SCNVector4Make(0, 1.0, 0, CFloat(M_PI))
        
        
        var cardBody = SCNNode(geometry: cardVolume);
        cardBody.name = "body"
        cardBody.pivot = SCNMatrix4MakeTranslation(CFloat(CARD_WIDTH*CARD_RESIZE_FACTOR)*0.5, 0, 0)
        //        cardNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Dynamic, shape: nil)
        //        cardNode.physicsBody?.restitution = 0.01
        //        cardNode.physicsBody?.mass = 5
        //        cardNode.physicsBody?.angularVelocity = SCNVector4Make(5, 1, 1, 1)
        
        cardContainer.addChildNode(cardBody)
        cardContainer.addChildNode(cardFront)
        cardContainer.addChildNode(cardBack)
        
        //cardFront.hidden = true;
        
        return cardContainer
    }
    
    func bindObjectToPan(object:SCNNode, recognizer:UIGestureRecognizer) {
        
        
        
    }
    
    func handleRotation(recognizer:UIRotationGestureRecognizer) {
        
        println("handleRotation: \(recognizer.rotation) , \(recognizer.velocity)")
        
        let rotation:CFloat = CFloat(recognizer.rotation)
        
        camera.zoom(rotation)
        
        if recognizer.state == UIGestureRecognizerState.Ended {
            println("rotation Gesture ended")
            camera.resetZoom()
        }
    }
    
    func handlePinch(recognizer:UIPinchGestureRecognizer) {
        
        println("handlePinch, scale:\(recognizer.scale)")
        
        let scale:CFloat = CFloat(recognizer.scale)
        
        camera.zoom(scale)
        
        if recognizer.state == UIGestureRecognizerState.Ended {
            println("pinch Gesture ended")
            camera.resetZoom()
        }
    }
    
    func handleTap(recognizer: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as SCNView
        
        
        // check what nodes are tapped
        let p = recognizer.locationInView(scnView)
        //        if let hitResults = scnView.hitTest(p, options: nil) {
        //            highlightObject(hitResults)
        //        }
        
       
        
        
        
        let object:SCNNode? = getObjectFromHitTest(p)
        
        if object !== nil {
            
            let cardNode = findActiveObject(object!) as CardNode?
            
            if cardNode != nil {
                cardNode?.flip(1.0)
            }
        }
        
        
        if recognizer.state == UIGestureRecognizerState.Ended {
            println("tapGesture ended")
            
            //releaseActiveObject()
            
        }
        
    }
    
    func releaseActiveObject(){
        
        println("releaseActiveObject")
        
        activeObject = nil
        activeObjectOrigin = nil
        activeCard = nil
    }
    
    func findActiveObject(object:SCNNode) -> CardNode? {
        
        if object.name == "cardFront" || object.name == "cardBack" {
            
            let rootNode = object.parentNode as? RootNode
            return rootNode?.parentObject
            
        } else {
            return nil
        }
    }
    
    func setActiveObject(object:SCNNode) {
            
        // if card, bind to root node
        if object.name == "cardFront" || object.name == "cardBack" {
        //if object.name == "cardFront" || object.name == "cardBack" || object.name == "cardBody" {
            // cache object
            
            
            println("setActiveObject")
            
            var rootNode = object.parentNode as? RootNode
            activeCard = rootNode?.parentObject
            
            activeObject = activeCard?.positionHandle
            activeObjectOrigin = activeCard?.positionHandle?.position
            
            //                    activeObject = object?.parentNode
            //                    activeObjectOrigin = object?.parentNode?.position
            
            //activeObjectOrigin = SCNVector3Make(CFloat(object?.position.x), CFloat(object?.position.y), CFloat(object?.position.z))
            
        }

    }
    
    func handlePan1F(recognizer:UIPanGestureRecognizer) {
        
        let translation:CGPoint = recognizer.translationInView(self.view)
        println("handlePan \(translation)")
        
        //TODO !!! translate object to raycast intersection with object's plane
        
        // Check if touchDownInside card
        
        let sceneView = self.view as SCNView
        // check what nodes are tapped
        let p = recognizer.locationInView(sceneView)
        
        var object:SCNNode? = getObjectFromHitTest(p)
        
        if object !== nil && activeObject == nil {
            println("pan inside object")
            
            setActiveObject(object!)
        }
        
        if activeObject != nil {
            // manipulate object
            
            
            let x = activeObjectOrigin?.x
            let y = activeObjectOrigin?.y
            let z = activeObjectOrigin?.z
            
            switch camera.orientationMode {
                
            case .TableOverhead:
                activeObject?.position = SCNVector3Make(x! + CFloat(translation.x), y!, z! + CFloat(translation.y))
                
            case .PlayerHand:
                activeObject?.position = SCNVector3Make(x! + CFloat(translation.x), y! - CFloat(translation.y), z!)
                
            default:
                println()
            }
            
            
            
            //                activeObject.position?.x = activeObjectOrigin.x? + CFloat(translation.x)
            //                activeObject?.position.y = CFloat(activeObjectOrigin?.y+translation.y)
            
        }
        
        
        if recognizer.state == UIGestureRecognizerState.Ended {
            println("panGesture ended")
            
            releaseActiveObject()
            
        }
        
        //        recognizer.view!.center = CGPoint(x:recognizer.view!.center.x + translation.x,
        //            y:recognizer.view!.center.y + translation.y)
        //        recognizer.setTranslation(CGPointZero, inView: self.view)
        //
        //        if recognizer.state == UIGestureRecognizerState.Ended {
        //            // 1
        //            let velocity = recognizer.velocityInView(self.view)
        //            let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
        //            let slideMultiplier = magnitude / 200
        //            println("magnitude: \(magnitude), slideMultiplier: \(slideMultiplier)")
        //
        //            // 2
        //            let slideFactor = 0.1 * slideMultiplier     //Increase for more of a slide
        //            // 3
        //            var finalPoint = CGPoint(x:recognizer.view!.center.x + (velocity.x * slideFactor),
        //                y:recognizer.view!.center.y + (velocity.y * slideFactor))
        //            // 4
        //            finalPoint.x = min(max(finalPoint.x, 0), self.view.bounds.size.width)
        //            finalPoint.y = min(max(finalPoint.y, 0), self.view.bounds.size.height)
        //
        //            // 5
        //            UIView.animateWithDuration(Double(slideFactor * 2),
        //                delay: 0,
        //                // 6
        //                options: UIViewAnimationOptions.CurveEaseOut,
        //                animations: {recognizer.view!.center = finalPoint },
        //                completion: nil)
        //        }

    }
    
    func handlePan3F(recognizer:UIPanGestureRecognizer) {
        
        let translation:CGPoint = recognizer.translationInView(self.view)
        println("handlePan 3F\(translation)")
        
        camera.pan(translation)

        if recognizer.state == UIGestureRecognizerState.Ended {
            println("pan 3F ended")
            camera.resetPan()
        }
        
    }
    
    func handlePan(recognizer:UIPanGestureRecognizer) {
        //comment for panning
        //uncomment for tickling
        //return;
        
        let fingers = recognizer.numberOfTouches()
        
        switch fingers {
        
        case 1:
            //recognizer.enabled = true
            handlePan1F(recognizer)
            
        case 3:
            //recognizer.enabled = true
            handlePan3F(recognizer)
            
        case 2:
            recognizer.enabled = false
            recognizer.enabled = true
        
        default:
            println("no pan handler")
        }
        
    }
    
    func getObjectFromHitTest(location:CGPoint) ->SCNNode? {
        
        var result:SCNNode?
        let sceneView = self.view as SCNView
        
        let hitResults:NSArray = sceneView.hitTest(location, options: nil)!
        //println("hit objects: \(hitResults)")
        
        if hitResults.count>0 {
            println("first object")
            result = hitResults[0].node! as SCNNode
        } else {
            println("no objects")
            result = nil
        }
    
        return result
    }

    
    //func highlightObject(hitResults:NSArray) {
    func highlightObject(hitResult:AnyObject?) {
        
        // check that we clicked on at least one object
        //if hitResults.count > 0 {
        if hitResult !== nil {
            
            // retrieved the first clicked object
            //let result: AnyObject! = hitResults[0]
            let result = hitResult as SCNNode
            
            // get its material
            let material = result.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.setAnimationDuration(0.5)
            
            // on completion - unhighlight
            SCNTransaction.setCompletionBlock {
                SCNTransaction.begin()
                SCNTransaction.setAnimationDuration(0.5)
                
                material.emission.contents = UIColor.blackColor()
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.redColor()
            
            SCNTransaction.commit()
        }

    }
    
    func moveCamera() {
        
        SCNTransaction.begin()
        SCNTransaction.setAnimationDuration(1.0)
        
        SCNTransaction.setCompletionBlock() {
            println("camera moved");
        }
        
        _cameraNode.position.z -= 100
        
        SCNTransaction.commit()
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.toRaw())
        } else {
            return Int(UIInterfaceOrientationMask.All.toRaw())
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}

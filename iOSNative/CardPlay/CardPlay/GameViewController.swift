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
    
    var _cameraHandleTransforms = [SCNMatrix4](count:10, repeatedValue:SCNMatrix4(m11: 0.0, m12: 0.0, m13: 0.0, m14: 0.0, m21: 0.0, m22: 0.0, m23: 0.0, m24: 0.0, m31: 0.0, m32: 0.0, m33: 0.0, m34: 0.0, m41: 0.0, m42: 0.0, m43: 0.0, m44: 0.0))
    
    
    var _ambientLightNode:SCNNode!
    
    var _spotlightParentNode:SCNNode!
    var _spotlightNode:SCNNode!
    
    var _floorNode:SCNNode!
    
    var _playerOrb:SCNNode!
    
    var cardNodes:[CardNode] = []
    
    var players:NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setupAccelerometer() {
        
        let motionManager: CMMotionManager = CMMotionManager()
        if (motionManager.accelerometerAvailable) {
            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue()) {
                (data, error) in
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
            }
            
        }
        
    }
    
    func setup() {
        
        // retrieve the SCNView
        let sceneView = view as SCNView
        
        sceneView.backgroundColor = SKColor.whiteColor()
    
        
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
        
        // add a tap gesture recognizer
//        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
//        //let tapGesture = UITapGestureRecognizer(target: self, action: "moveCamera")
//        let gestureRecognizers = NSMutableArray()
//        gestureRecognizers.addObject(tapGesture)
//        
//        if let existingGestureRecognizers = sceneView.gestureRecognizers {
//            gestureRecognizers.addObjectsFromArray(existingGestureRecognizers)
//        }
//        sceneView.gestureRecognizers = gestureRecognizers

        
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
        
        
        var camera = Camera()
        
        _scene.rootNode.addChildNode(camera.positionHandle)
        _cameraNode = camera.cameraNode
        
        // position default behind player
        camera.transform(SCNVector3Make(0,150,Float(TABLE_RADIUS*0.75)), orientation: SCNVector3Make(-CFloat(M_PI * 0.15), 0, 0))
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
        
        _playerOrb = SCNNode(geometry: SCNSphere(radius: ORB_RADIUS))
        //_playerOrb.geometry.firstMaterial.diffuse.contents = SKColor(red: 1.0, green: 0, blue: 0, alpha: 1.0)
        _playerOrb.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Dynamic, shape: nil)
        _playerOrb.physicsBody?.restitution = 0.9
        
        _playerOrb.position = SCNVector3Make(0, 0, 0)
        _playerOrb.position.y += CFloat(ORB_RADIUS * 8)
        
        _scene.rootNode.addChildNode(_playerOrb)
        
        
        var cardNode = createCard("ace_of_spades.png", cardBackImage:"back-default.png")
        cardNode.position = SCNVector3Make(0, 0, 0)
        cardNode.position.y += 50
        _scene.rootNode.addChildNode(cardNode)
        
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
    
    func updateRenderState(){
        
        // case: front and back only
        // when card is floating/moving in space
        
        // case: front and body only
        // when card is face-up on table
        
        // case: back and body only
        // when card is face-down on table
        // when card is partiallly overlapped in stack
        
        // case: body only
        // when card is fully overlapped in stack
        
    }

    
    func drawCards(count:Int) {
        
        for index in 0...count {
            
            moveCardIntoHand(cardNodes[index])
            
            //TODO stagger each card drawn
        }
        
    }
    
    func moveCardIntoHand(cardNode:CardNode) {
        
        let actionDuration = 3.0
        
        println("moveCardIntoHand: \(cardNode)")
        
        deckCards.removeObject(cardNode)
        handCards.addObject(cardNode)
        
        cardNode.updateRenderMode(CardNode.RenderModes.FrontAndBack)
        
        //TODO recalculate card positions, distributed across view
        
        SCNTransaction.begin()
        SCNTransaction.setAnimationDuration(actionDuration)
        
        // Card upright
        println("card rotation x \(cardNode.rootNode.rotation.x)")

        cardNode.rootNode.runAction(SCNAction.rotateByX(-CGFloat(M_PI / 2), y: 0, z: 0, duration: actionDuration))
        
        
        // Stack height by index
        cardNode.rootNode.position = handPosition
        //cardNode.position.y = Float(CARD_DEPTH * CARD_RESIZE_FACTOR) * (Float(index)*2.0+0.5)
        
        
        SCNTransaction.commit()
        
    }
    
//    func gatherCardsIntoDeck(position:SCNVector3) {
//        
//        var index:Int
//        
//        //for index = 0; index < cardNodes.count; ++index {
//        
//        for (index, cardNode) in enumerate(cardNodes) {
//            
//            var cardNode = cardNodes[index]
//            
//            cardNode.updateRenderMode(CardNode.RenderModes.BackOnly)
//            
//            SCNTransaction.begin()
//            SCNTransaction.setAnimationDuration(2.0)
//            
//            println("card height \(index)")
//            
//            // Lay card flat
//            println("card rotation x \(cardNode.rootNode.rotation.x)")
//            //cardNode.rotation.x = CFloat(M_PI / 2)
//            //cardNode.rotation.x = 0.5
//            
//            cardNode.rootNode.runAction(SCNAction.rotateByX(CGFloat(M_PI / 2), y: 0, z: 0, duration: 1))
//
//            
//            // Stack height by index
//            cardNode.rootNode.position = position
//            cardNode.rootNode.position.y = Float(CARD_DEPTH * CARD_RESIZE_FACTOR) * (Float(index)*2.0+0.5)
//            
//            
//            SCNTransaction.commit()
//        }
//        
//        // TODO the topmost card, show back
//        
//    }

    
    func handleTap(gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as SCNView
        
        
        // check what nodes are tapped
        let p = gestureRecognize.locationInView(scnView)
        if let hitResults = scnView.hitTest(p, options: nil) {
            highlightObject(hitResults)
        }
        
        
    }
    
    func highlightObject(hitResults:NSArray) {
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result: AnyObject! = hitResults[0]
            
            // get its material
            let material = result.node!.geometry!.firstMaterial!
            
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

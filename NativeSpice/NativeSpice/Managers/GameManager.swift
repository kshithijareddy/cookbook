//
//  GameView.swift
//  NativeSpice
//
//  Created by Kshithija on 3/14/22.
//

import ARKit
import Foundation

enum BitMaskCategory: Int {
    case bullet = 2
    case target = 3
}

class GameManager {

    var power: Float = 50
    var arSceneView: ARSCNView?
    
    // addEggs will add three eggs to the scene 
    func addEggs(arSceneView: ARSCNView) {
        addEgg(x: -20, y: -30, z: -40, arSceneView: arSceneView)
        addEgg(x: -10, y: -30, z: -40, arSceneView: arSceneView)
        addEgg(x: 0, y: -30, z: -40,arSceneView: arSceneView)
    }
    
    // addScoreBoard will add the scoreboard to the scene
    func addScoreBoard(arSceneView : ARSCNView) {
        self.arSceneView = arSceneView
        let box = SCNPlane(width: 0.6, height: 0.15)
        box.cornerRadius = 0.3
        let boxNode = SCNNode()
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.systemBlue
        box.materials = [material]
        boxNode.geometry = box
        boxNode.position = SCNVector3(0,-2.5,-3)
        boxNode.opacity = 0.7
        
        arSceneView.scene.rootNode.addChildNode(boxNode)
        let boxtextNode = SCNNode()
        let boxtextString = "Score: 0"
        let boxtext = SCNText(string: boxtextString , extrusionDepth: 0.1)
        boxtextNode.geometry = boxtext
        boxtextNode.name = "ScoreBoard"
        boxtextNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        boxtextNode.scale = SCNVector3(0.01,0.01,0.01)
        boxtextNode.position = SCNVector3(-0.25,-2.5-0.075,-2.99)
        arSceneView.scene.rootNode.addChildNode(boxtextNode)
    }

    // addEgg will create an egg node with egg.scn and add it to the scene
    func addEgg(x: Float, y: Float, z: Float, arSceneView: ARSCNView) {
        let eggScene = SCNScene(named: "egg.scn")
        let eggNode = (eggScene?.rootNode.childNode(withName: "egg", recursively: false))!
        eggNode.position = SCNVector3(x,y,z)
        eggNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: eggNode, options: nil))
        eggNode.physicsBody?.categoryBitMask = BitMaskCategory.target.rawValue
        eggNode.physicsBody?.contactTestBitMask = BitMaskCategory.bullet.rawValue
        
        let moveNorthEast = SCNAction.moveBy(x: 10, y: 10, z: 0, duration: 0.5)
        let moveLeft = SCNAction.moveBy(x: -20, y: 0, z: 0, duration: 0.5)
        let moveSouthEast = SCNAction.moveBy(x: 10, y: -10, z: 0, duration: 0.5)
        moveNorthEast.timingMode = .easeInEaseOut
        moveSouthEast.timingMode = .easeInEaseOut
        moveLeft.timingMode = .easeInEaseOut
        let moveSequence = SCNAction.sequence([moveNorthEast,moveNorthEast,moveLeft,moveSouthEast,moveSouthEast,moveLeft])
        let moveLoop = SCNAction.repeatForever(moveSequence)
        eggNode.runAction(moveLoop)
        
        arSceneView.scene.rootNode.addChildNode(eggNode)
    }
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

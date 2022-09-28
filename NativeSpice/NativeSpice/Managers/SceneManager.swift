//
//  SceneManager.swift
//  NativeSpice
//
//  Created by Kshithija on 3/10/22.
//

import Foundation
import ARKit

class SceneManager{
    
    // restartARSession will restart the AR session by removing all the nodes and resetting the session
    func restartARSession(arScene : ARSCNView, configuration: ARWorldTrackingConfiguration){
        arScene.session.pause()
        arScene.scene.rootNode.enumerateChildNodes{ (node, _) in
            node.runAction(SCNAction.fadeOut(duration: 1))
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            arScene.scene.rootNode.enumerateChildNodes{ (node, _) in
                node.removeFromParentNode()
            }
            arScene.session.run(configuration, options: .resetTracking)
        }
    }
    
    // displayCategories will display the categories of the recipes in the AR scene for the user to choose from
    func displayCategories(arScene: ARSCNView, categoriesList: [String]) {
        var y = -0.5
        for category in categoriesList {
            
            let box = SCNPlane(width: 1, height: 0.15)
            box.cornerRadius = 0.3
            let text = SCNText(string: category, extrusionDepth: 0.1)
            let boxNode = SCNNode()
            let textNode = SCNNode()
            textNode.geometry = text
            textNode.geometry?.firstMaterial?.diffuse.contents = UIColor.black
            textNode.scale = SCNVector3(0.01,0.01,0.01)
            textNode.position = SCNVector3(-0.25,y - 0.075,-2.99)
            textNode.geometry?.name = category

            let material = SCNMaterial()
            material.diffuse.contents = UIColor.systemYellow
            box.materials = [material]
            boxNode.geometry = box
            boxNode.geometry?.name = category
            boxNode.position = SCNVector3(0,y,-3)
            boxNode.opacity = 0.7
            textNode.opacity = 1
            
            arScene.scene.rootNode.addChildNode(textNode)
            arScene.scene.rootNode.addChildNode(boxNode)
            y -= 0.3

        }
    }
    
    // displayRecipes will display the recipes in the AR scene for the category selected by the user
    func displayRecipes(recipes: [Recipe], arSceneView: ARSCNView) {
        var y = -0.5
        for recipe in recipes {
            
            let box = SCNPlane(width: 1.5, height: 0.15)
            box.cornerRadius = 0.3
            let text = SCNText(string: recipe.name, extrusionDepth: 0.1)
            let boxNode = SCNNode()
            let textNode = SCNNode()
            var image = UIImage(named: "Nativespice")
            
            RecipeClient.getImage(imageName: recipe.imageName!){ resultImage, error in
                    
                    guard let resultImage = resultImage, error == nil else {
                        print(error ?? NSError())
                        return
                    }
                    image = resultImage
                let imageNode = SCNNode(geometry: SCNPlane(width: 0.15, height: 0.15))
                imageNode.geometry?.firstMaterial?.diffuse.contents = image
                imageNode.position = SCNVector3(-0.75,y, -2.99)
                textNode.geometry = text
                textNode.geometry?.firstMaterial?.diffuse.contents = UIColor.black
                textNode.scale = SCNVector3(0.01,0.01,0.01)
                textNode.position = SCNVector3(-0.65,y - 0.075,-2.99)
                textNode.geometry?.name = recipe.name

                let material = SCNMaterial()
                material.diffuse.contents = UIColor.systemYellow
                box.materials = [material]
                boxNode.geometry = box
                boxNode.geometry?.name = recipe.name
                boxNode.position = SCNVector3(0,y,-3)
                boxNode.opacity = 0.7
                textNode.opacity = 1
                
                arSceneView.scene.rootNode.addChildNode(textNode)
                arSceneView.scene.rootNode.addChildNode(boxNode)
                arSceneView.scene.rootNode.addChildNode(imageNode)
                
                y -= 0.3
            }
        }
    }
    
    // displayIngredients will display the ingredients of the recipe selected by the user
    func displayIngredients(arSceneView: SCNView, recipe: Recipe) {
        
        let textNode = SCNNode()
        let text = SCNText(string: recipe.name, extrusionDepth: 0.1)
        textNode.geometry = text
        textNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        textNode.scale = SCNVector3(0.01,0.01,0.01)
        textNode.position = SCNVector3(-0.3,-0.45,-3)
        arSceneView.scene?.rootNode.addChildNode(textNode)
        
        let textNodeMessage = SCNNode()
        let textMessage = SCNText(string: "Tap the Next Button to see the steps for the recipe!", extrusionDepth: 0.1)
        textNodeMessage.geometry = textMessage
        textNodeMessage.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        textNodeMessage.scale = SCNVector3(0.01,0.01,0.01)
        textNodeMessage.position = SCNVector3(-1.25,-2, -3)
        arSceneView.scene?.rootNode.addChildNode(textNodeMessage)
        
        var x = -1.5
        for item in recipe.items! {
            RecipeClient.getIngredient(ingredient: item.ingredient!){ ingredientResult, error in
                
                guard let ingredientResult = ingredientResult, error == nil else {
                    print(error ?? NSError())
                    return
                }
                RecipeClient.getImage(imageName: ingredientResult.image!){ resultImage, error in
                    
                    guard let resultImage = resultImage, error == nil else {
                        print(error ?? NSError())
                        return
                    }
                    let imageNode = SCNNode(geometry: SCNPlane(width: 0.75, height: 0.75))
                    imageNode.geometry?.firstMaterial?.diffuse.contents = resultImage
                    imageNode.position = SCNVector3(x,-1, -3)
                    arSceneView.scene?.rootNode.addChildNode(imageNode)
                    
                    let box = SCNPlane(width: 0.8, height: 0.3)
                    box.cornerRadius = 0.3
                    let boxNode = SCNNode()
                    let material = SCNMaterial()
                    material.diffuse.contents = UIColor.systemYellow
                    box.materials = [material]
                    boxNode.geometry = box
                    boxNode.position = SCNVector3(x,-1.6,-3)
                    boxNode.opacity = 0.7
                    
                    arSceneView.scene?.rootNode.addChildNode(boxNode)
                    
                    let textNode = SCNNode()
                    let name_split = item.ingredient?.split(separator: "_")
                    var textString = item.quantity! + " " + item.unit! + " \n"
                    for s in name_split! {
                        textString += s.capitalized + " "
                    }
                    let text = SCNText(string: textString , extrusionDepth: 0.1)
                    textNode.geometry = text
                    textNode.geometry?.firstMaterial?.diffuse.contents = UIColor.black
                    textNode.scale = SCNVector3(0.007,0.007,0.007)
                    textNode.position = SCNVector3(x-0.27,-1.7,-3)
                    arSceneView.scene?.rootNode.addChildNode(textNode)
                    x += 0.9
                }
                
            }
        }
    }
    
    // displaySteps will display the steps of the recipe selected by the user
    func displaySteps(arSceneView: ARSCNView, recipe: Recipe) {
        
        let box = SCNPlane(width: 0.6, height: 0.15)
        box.cornerRadius = 0.3
        let boxNode = SCNNode()
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.systemYellow
        box.materials = [material]
        boxNode.geometry = box
        boxNode.position = SCNVector3(0,-0.5,-3)
        boxNode.opacity = 0.7
        
        arSceneView.scene.rootNode.addChildNode(boxNode)
        
        let boxtextNode = SCNNode()
        let boxtextString = "Step 1"
        let boxtext = SCNText(string: boxtextString , extrusionDepth: 0.1)
        boxtextNode.geometry = boxtext
        boxtextNode.name = "StepNumBox"
        boxtextNode.geometry?.firstMaterial?.diffuse.contents = UIColor.black
        boxtextNode.scale = SCNVector3(0.01,0.01,0.01)
        boxtextNode.position = SCNVector3(-0.25,-0.5-0.075,-2.99)
        arSceneView.scene.rootNode.addChildNode(boxtextNode)
        
        let textNode = SCNNode()
        let text = SCNText(string: recipe.steps!["1"], extrusionDepth: 0.1)
        textNode.geometry = text
        textNode.name = "StepText"
        textNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        textNode.scale = SCNVector3(0.01,0.01,0.01)
        textNode.position = SCNVector3(-1,-1,-3)
        arSceneView.scene.rootNode.addChildNode(textNode)
    }
}

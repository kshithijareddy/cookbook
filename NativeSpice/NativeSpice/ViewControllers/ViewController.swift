//
//  ViewController.swift
//  NativeSpice
//
//  Created by Kshithija on 3/8/22.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {
    
    @IBOutlet var plusButton: UIButton!
    @IBOutlet var alertView: AlertView!
    @IBOutlet var alertText: UILabel!
    @IBOutlet var homeButton: UIButton!
    
    @IBOutlet var infoButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var prevButton: UIButton!
    
    let categoriesList: [String] = DataManager.sharedInstance.getCategories()
    let scene = SceneManager()
    let game = GameManager()
    let networkMonitor = NetworkMonitor()
    var defaults = UserDefaults.standard
    var onboardController: OnboardingViewController?
    var internetConnection: Bool = true
    
    var Target: SCNNode?
    var points: Int = 0
    
    @IBOutlet var arSceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkMonitor.startMonitoring()
        arSceneView.delegate = self
        
        self.arSceneView.session.run(configuration)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.arSceneView.addGestureRecognizer(tapGestureRecognizer)
        self.arSceneView.scene.physicsWorld.contactDelegate = self
        
        nextButton.isHidden = true
        prevButton.isHidden = true
        plusButton.isHidden = true
        
        // Checking for internet connection
        if networkMonitor.isReachable {
            fetchRecipes()
            print("DEBUG ----> Recipes :")
            print(DataManager.sharedInstance.recipes)
        } else {
            noInternet()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if networkMonitor.isReachable {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.scene.displayCategories(arScene: self.arSceneView, categoriesList: self.categoriesList)
                if self.defaults.object(forKey: "launchNumber") as! Int == 3 {
                    self.alertText.text = "Rate this App in the App Store 🙏"
                    self.alertView.isHidden = false
                    let animator = UIViewPropertyAnimator(duration:0.5, curve: .easeIn) {
                        self.alertView.alpha = 1.0
                        let offsetY = self.arSceneView.frame.height/2 + self.alertView.frame.height/2
                        self.alertView.frame = self.alertView.frame.offsetBy(dx:0, dy:offsetY)
                     }
                    animator.startAnimation()
                }

                if self.defaults.object(forKey: "launchNumber") as! Int ==  1 {
                    self.onboardController = self.storyboard?.instantiateViewController(identifier: "OnboardingViewController") as? OnboardingViewController
                    self.onboardController?.delegate = self
                    if let sheet = self.onboardController?.sheetPresentationController {
                            sheet.detents = [.large()]
                            sheet.largestUndimmedDetentIdentifier = .large
                            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                            sheet.prefersEdgeAttachedInCompactHeight = true
                            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
                        }
                    self.present(self.onboardController!, animated: true, completion: nil)
                }
            }
        } else {
            noInternet()
        }
        
    }
    
    // fetchRecipes fetches all recipes from the backend and stores them in the shared instance
    func fetchRecipes() -> Void {
        print("DEBUG ----> Fetching recipes")
        RecipeClient.fetchRecipeList() { recipesData, error in
            
            guard let recipesData = recipesData, error == nil else {
                print(error ?? NSError())
                return
            }
            DataManager.sharedInstance.recipes = recipesData.results
            
        }
    }
 
    // handleTap handles the tap gesture on the screen and responds according to the tapped node
    @objc func handleTap(sender: UITapGestureRecognizer) {
        let sceneViewTappedOn = sender.view as! SCNView
        let touchCoordinates = sender.location(in: sceneViewTappedOn)
        
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
        let currentPage = DataManager.sharedInstance.getCurrentPage()
        if currentPage == "game" {
            guard let sceneView = sender.view as? ARSCNView else {return}
            guard let pointOfView = sceneView.pointOfView else {return}
            let transform = pointOfView.transform
            let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
            let location = SCNVector3(transform.m41, transform.m42, transform.m43)
            let position = orientation + location
            let bullet = SCNNode(geometry: SCNSphere(radius: 0.1))
            bullet.geometry?.firstMaterial?.diffuse.contents = UIColor.red
            bullet.position = position
            let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: bullet, options: nil))
            body.isAffectedByGravity = false
            bullet.physicsBody = body
            bullet.physicsBody?.applyForce(SCNVector3(orientation.x*game.power, orientation.y*game.power, orientation.z*game.power), asImpulse: true)
            bullet.physicsBody?.categoryBitMask = BitMaskCategory.bullet.rawValue
            bullet.physicsBody?.contactTestBitMask = BitMaskCategory.target.rawValue
            self.arSceneView.scene.rootNode.addChildNode(bullet)
            bullet.runAction(
                SCNAction.sequence([SCNAction.wait(duration: 2.0),
                                    SCNAction.removeFromParentNode()])
            )
        } else {
            if hitTest.isEmpty {
               print("Tapped No where!")
            } else {
                let results = hitTest.first!
                if networkMonitor.isReachable {
                    print(currentPage)
                    if currentPage == "categories" {
                        scene.restartARSession(arScene: self.arSceneView, configuration: self.configuration)
                        let recipesOfCategory = DataManager.sharedInstance.loadRecipes(tapCategory: categoriesList.firstIndex(of: results.node.geometry!.name!)! + 1)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                            self.scene.displayRecipes(recipes: recipesOfCategory, arSceneView: self.arSceneView)
                        }
                        DataManager.sharedInstance.setCurrentPage(page: "recipes")
                        DataManager.sharedInstance.categorySelected = results.node.geometry!.name!
                        //self.homeButton.isHidden = false
                    }
                    else if currentPage == "recipes"{
                        scene.restartARSession(arScene: self.arSceneView, configuration: self.configuration)
                        let recipe = DataManager.sharedInstance.getRecipe(name: (results.node.geometry?.name)!)
                        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                            self.scene.displayIngredients(arSceneView: self.arSceneView, recipe: recipe)
                        }
                        DataManager.sharedInstance.setCurrentPage(page: "ingredients")
                        DataManager.sharedInstance.recipeSelected = recipe.name!
                        print(DataManager.sharedInstance.recipeSelected)
                        nextButton.isHidden = false
                        prevButton.isHidden = false
                    }
                } else {
                    noInternet()
                }
            }
        }
    }
    
    // homeButtonPressed handles the tap gesture on the home button and returns the categories page
    @IBAction func homeButtonTapped(_ sender: UIButton) {
        print("DEBUG ----> HOME Button tapped")
        if networkMonitor.isReachable {
            self.internetConnection = true
            scene.restartARSession(arScene: self.arSceneView, configuration: configuration)
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                self.scene.displayCategories(arScene: self.arSceneView, categoriesList: self.categoriesList)
            }
            DataManager.sharedInstance.refresh()
            nextButton.isHidden = true
            prevButton.isHidden = true
            plusButton.isHidden = true
            infoButton.isHidden = false
        } else {
            if DataManager.sharedInstance.currentPage == "game"{
                self.onboardController = self.storyboard?.instantiateViewController(identifier: "OnboardingViewController") as? OnboardingViewController
                self.onboardController?.delegate = self
                if let sheet = self.onboardController?.sheetPresentationController {
                        sheet.detents = [ .large()]
                        sheet.largestUndimmedDetentIdentifier = .large
                        sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                        sheet.prefersEdgeAttachedInCompactHeight = true
                        sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
                    }
                self.present(self.onboardController!, animated: true, completion: nil)
            } else {
                noInternet()
            }
        }
    }
    
    // nextButtonPressed handles the tap gesture on the next button and returns the next page
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        print("DEBUG ----> NEXT Button Tapped")
        let currentPage = DataManager.sharedInstance.getCurrentPage()
        if currentPage == "ingredients" {
            scene.restartARSession(arScene: self.arSceneView, configuration: self.configuration)
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                self.scene.displaySteps(arSceneView: self.arSceneView, recipe: DataManager.sharedInstance.getRecipe(name: DataManager.sharedInstance.recipeSelected))
            }
            DataManager.sharedInstance.setCurrentPage(page: "steps")
        } else if currentPage == "steps" {
            let currentStep = DataManager.sharedInstance.getStepNumber()
            let stepTextNode = self.arSceneView.scene.rootNode.childNode(withName: "StepText", recursively: true)
            let stepText = stepTextNode!.geometry as! SCNText
            let stepNumNode = self.arSceneView.scene.rootNode.childNode(withName: "StepNumBox", recursively: true)
            let stepNum = stepNumNode!.geometry as! SCNText
            if currentStep < DataManager.sharedInstance.getTotalSteps() {
                DataManager.sharedInstance.setStepNumber(step: currentStep + 1)
                stepText.string = DataManager.sharedInstance.getStepText()
                stepNum.string = "Step "+String(currentStep+1)
            } else {
                stepText.string = "Your Recipe is Ready!!"
                stepNum.string = "Done!"
                nextButton.isHidden = true
            }
        }
    }
    
    // prevButtonPressed handles the tap gesture on the previous button and returns the previous page
    @IBAction func prevButtonTapped(_ sender: UIButton) {
        print("DEBUG ----> PREV Button Tapped")
        let currentPage = DataManager.sharedInstance.getCurrentPage()
        if currentPage == "ingredients" {
            if networkMonitor.isReachable {
                scene.restartARSession(arScene: self.arSceneView, configuration: self.configuration)
                let recipesOfCategory = DataManager.sharedInstance.loadRecipes(tapCategory: categoriesList.firstIndex(of: DataManager.sharedInstance.categorySelected)! + 1)
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    self.scene.displayRecipes(recipes: recipesOfCategory, arSceneView: self.arSceneView)
                }
                DataManager.sharedInstance.setCurrentPage(page: "recipes")
                //self.homeButton.isHidden = false
                nextButton.isHidden = true
                prevButton.isHidden = true
            } else {
                noInternet()
            }
        } else if currentPage == "steps" {
            let currentStep = DataManager.sharedInstance.getStepNumber()
            let stepTextNode = self.arSceneView.scene.rootNode.childNode(withName: "StepText", recursively: true)
            let stepText = stepTextNode!.geometry as! SCNText
            let stepNumNode = self.arSceneView.scene.rootNode.childNode(withName: "StepNumBox", recursively: true)
            let stepNum = stepNumNode!.geometry as! SCNText
            if currentStep == DataManager.sharedInstance.getTotalSteps() {
                nextButton.isHidden = false
            }
            if currentStep > 1 {
                DataManager.sharedInstance.setStepNumber(step: currentStep - 1)
                stepText.string = DataManager.sharedInstance.getStepText()
                stepNum.string = "Step "+String(currentStep-1)
            } else {
                if networkMonitor.isReachable {
                    scene.restartARSession(arScene: self.arSceneView, configuration: self.configuration)
                    let recipe = DataManager.sharedInstance.getRecipe(name: DataManager.sharedInstance.recipeSelected)
                    DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                        self.scene.displayIngredients(arSceneView: self.arSceneView, recipe: recipe)
                    }
                    DataManager.sharedInstance.setCurrentPage(page: "ingredients")
                    nextButton.isHidden = false
                    prevButton.isHidden = false
                } else {
                    noInternet()
                }
            }
        }
    }
    
    // physicsWorld handles the collision between the nodes i.e eggs and the bullet
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        if nodeA.physicsBody?.categoryBitMask == BitMaskCategory.target.rawValue {
            self.Target = nodeA
        } else if nodeB.physicsBody?.categoryBitMask == BitMaskCategory.target.rawValue {
            self.Target = nodeB
        }
        let confetti = SCNParticleSystem(named: "Fire.scnp", inDirectory: nil)
        confetti?.loops = false
        confetti?.particleLifeSpan = 4
        confetti?.emitterShape = Target?.geometry
        let confettiNode = SCNNode()
        confettiNode.addParticleSystem(confetti!)
        confettiNode.position = contact.contactPoint
        arSceneView!.scene.rootNode.addChildNode(confettiNode)
        Target?.removeFromParentNode()
        points += 1
        if points%3 == 0{
            game.addEgg(x: -20, y: -30, z: -40, arSceneView: arSceneView!)
            game.addEgg(x: -10, y: -30, z: -40, arSceneView: arSceneView!)
            game.addEgg(x: 0, y: -30, z: -40, arSceneView: arSceneView!)
        }
        let scoreNode = arSceneView!.scene.rootNode.childNode(withName: "ScoreBoard", recursively: true)
        let score = scoreNode!.geometry as! SCNText
        score.string = "Score: \(points)"
    }
    
    // alertOKButton handles the tap gesture on the OK button of the alert
    @IBAction func alertOKButton(_ sender: UIButton) {
        print("DEBUG ----> Alert OK Button Tapped")
        let animator = UIViewPropertyAnimator(duration:0.5, curve: .easeIn) {
            self.alertView.alpha = 0.0
            self.alertView.frame = self.alertView.frame.offsetBy(dx:0, dy: self.arSceneView.frame.maxY)
         }
        animator.startAnimation()
    }
    
    // infoButton handles the tap gesture on the info button and displays the info sheet controller
    @IBAction func infoButton(_ sender: UIButton) {
        print("DEBUG ----> Onboard Button Clicked (Question Mark) ")
        self.internetConnection = true
        self.onboardController = self.storyboard?.instantiateViewController(identifier: "OnboardingViewController") as? OnboardingViewController
        onboardController?.delegate = self
        if let sheet = self.onboardController?.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.largestUndimmedDetentIdentifier = .large
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.prefersEdgeAttachedInCompactHeight = true
                sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            }
        self.present(self.onboardController!, animated: true, completion: nil)
    }
    
    // noInternet handles the screens when there is no internet connection
    func noInternet() {
        self.internetConnection = false
        infoButton.isHidden = true
        plusButton.isHidden = false
        onboardController = self.storyboard?.instantiateViewController(identifier: "OnboardingViewController") as? OnboardingViewController
        onboardController?.delegate = self
        if let sheet = onboardController?.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.largestUndimmedDetentIdentifier = .large
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.prefersEdgeAttachedInCompactHeight = true
                sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            }
        self.present(onboardController!, animated: true, completion: nil)
        scene.restartARSession(arScene: arSceneView, configuration: self.configuration)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            DataManager.sharedInstance.setCurrentPage(page: "game")
            self.game.addScoreBoard(arSceneView: self.arSceneView)
            self.game.addEggs(arSceneView: self.arSceneView)
        }
    }
    
    // getInternetStae returns the current state of the internet connection
    func getInternetState() -> Bool {
        return self.internetConnection
    }
    
    
}



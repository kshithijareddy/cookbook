//
//  OnboardingViewController.swift
//  NativeSpice
//
//  Created by Kshithija on 3/14/22.
//

import Foundation
import UIKit

class OnboardingViewController : UIViewController {
    
    @IBOutlet var onboardMessage: UILabel!
    var internetConnection: Bool = true
    weak var delegate: ViewController!
    override func viewDidLoad() {
        super.viewDidLoad()

        internetConnection = delegate.getInternetState()
        
        if internetConnection{
            // Message when info button is clicked
            onboardMessage.text = "Experience how to make your favorite recipes in Augmented Reality with Native Spice!\nSelect a category to get started.\n Tap on the recipe to see the ingredients and instructions.\n Use the Previous and Next buttons to follow along with the recipe steps! "
        } else {
            // Message when internet connection is lost
            onboardMessage.text = "Oops! Looks like you are currently not connected to Internet!\n But don't worry!\n We have an exiting game for you to play while you wait to reconnect to internet \n🥚🥚🥚🔫.\n Please click on the Home button when you reconnect to Internet \n to go back to the cookbook!🍔 \n ( Tap to shoot the eggs 🔫 )"
        }
        
    }
    @IBAction func onboardButton(_ sender: Any) {
        print("DEBUG ----> Onboard OK Button Tapped")
        dismiss(animated: true, completion: nil)
    }
}

//
//  SplashViewController.swift
//  NativeSpice
//
//  Created by Kshithija on 3/12/22.
//

import UIKit

class SplashViewController: UIViewController {
    
     let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        if (defaults.object(forKey: "launchNumber") != nil){
            defaults.set(1 + (defaults.object(forKey: "launchNumber") as! Int) , forKey: "launchNumber")
        } else {
            defaults.set(1, forKey: "launchNumber")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainVC = storyboard.instantiateViewController(withIdentifier: "ARScreen") as! ViewController
            
            mainVC.modalPresentationStyle = .fullScreen
            mainVC.modalTransitionStyle = .flipHorizontal
            mainVC.defaults = self.defaults

            self.present(mainVC, animated: true) {
                UIView.animate(withDuration: 1.0, delay: 0.5, options: .autoreverse, animations: {
                    self.view.alpha = 0
                }, completion: nil)
            }
        }
    }
}

//
//  AlertView.swift
//  NativeSpice
//
//  Created by Kshithija on 3/13/22.
//

import Foundation
import UIKit

class AlertView: UIView{
    
    override func awakeFromNib() {
        layer.cornerRadius = 20.0
        layer.borderWidth = 5.0
        layer.borderColor = UIColor.black.cgColor
        self.isHidden = true
        self.alpha = 0.0
    }
}

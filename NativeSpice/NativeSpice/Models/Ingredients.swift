//
//  Ingredients.swift
//  NativeSpice
//
//  Created by Kshithija on 3/8/22.
//

import Foundation
import UIKit

struct Ingredient : Decodable, Hashable {
    
    let name: String?
    let id: Int?
    let isVegan: Bool?
    let image: String?
}

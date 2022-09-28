//
//  Recipe.swift
//  NativeSpice
//
//  Created by Kshithija on 3/8/22.
//

import Foundation
import UIKit

struct recipeList: Decodable {
    let results: [Recipe]
}

struct Recipe : Decodable, Hashable {
    
    let name: String?
    let recipeDescription: String?
    let duration: String?
    let category: Int?
    let items: [Item]?
    let steps: [String: String]?
    let imageName: String?
    
}

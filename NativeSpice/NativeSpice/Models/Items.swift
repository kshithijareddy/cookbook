//
//  Items.swift
//  NativeSpice
//
//  Created by Kshithija on 3/8/22.
//

import Foundation

struct Item: Decodable, Hashable {
    
    let quantity: String?
    let unit: String?
    let ingredient: String?
}

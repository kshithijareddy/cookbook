//
//  RecipeClient.swift
//  NativeSpice
//
//  Created by Kshithija on 3/8/22.
//

import Foundation
import UIKit

class RecipeClient {
    static let imageCache = NSCache<NSString,UIImage>()
    
    // fetchRecipeList will fetch the list of recipes from the server
    static func fetchRecipeList( completion: @escaping (recipeList?, Error?) -> Void) {
        print("DEBUG -----> Fetching Recipes from http://54.221.151.24/recipes/")
        let url = URL(string: "http://54.221.151.24/recipes/")!
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(nil,error)
                }
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                let recipes = try decoder.decode(recipeList.self, from: data)
                DispatchQueue.main.async {
                    completion(recipes, nil)
                }
                
            } catch (let parsingError){
                DispatchQueue.main.async {
                    completion(nil,parsingError)
                }
            }
        }
        task.resume()
    }
    
    // getIngredient will fetch the ingredient from the server
    static func getIngredient(ingredient: String, completion: @escaping (Ingredient?, Error?) -> Void) {
        print("DEBUG -----> Fetching Ingredient from http://54.221.151.24/getingredient/")
        let url = URL(string: "http://54.221.151.24/getingredient/\(ingredient)")!
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(nil,error)
                }
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                let ingredient = try decoder.decode(Ingredient.self, from: data)
                DispatchQueue.main.async {
                    completion(ingredient, nil)
                }
                
            } catch (let parsingError){
                DispatchQueue.main.async {
                    completion(nil,parsingError)
                }
            }
        }
        task.resume()
    }
    
    // getImage will fetch the image from the server
    static func getImage(imageName: String, completion: @escaping (UIImage?, Error?) -> Void) {
        print("DEBUG -----> Fetching Images from http://54.221.151.24/getimage/")
        let url = "http://54.221.151.24/getimage/\(imageName)"
        let key = url as NSString
        if let image = imageCache.object(forKey: key) {
            completion(image, nil)
        } else {
            let url = URL(string: url)!
            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data, error == nil else {
                    DispatchQueue.main.async {
                        completion(nil,error)
                    }
                    return
                }
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        completion(image,nil)
                    }
                    imageCache.setObject(image, forKey: key)
                } else {
                    DispatchQueue.main.async {
                        completion(nil,error)
                    }
                }
            }
            task.resume()
        }
    }
}

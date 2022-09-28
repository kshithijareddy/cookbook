//
//  DataManager.swift
//  NativeSpice
//
//  Created by Kshithija on 3/8/22.
//

import Foundation

class DataManager {
    
    static let sharedInstance = DataManager()
    
    var recipes: [Recipe]
    var filteredRecipes: [Recipe]
    var categoriesList = ["Breakfast", "Appetizers", "Soups","Desserts", "Main Dishes", "Breads"]
    var currentPage: String
    var recipeSelected: String
    var categorySelected: String
    var currentStep: Int
    
    private init() {
        recipes = []
        filteredRecipes = []
        currentPage = "categories"
        recipeSelected = ""
        categorySelected = ""
        currentStep = 1
    }
    
    // refresh will refresh the filtered recipes, current page, current step and selected recipe and category
    func refresh(){
        filteredRecipes = []
        currentPage = "categories"
        recipeSelected = ""
        categorySelected = ""
        currentStep = 1
    }
    
    // getCategories will return the categories list
    func getCategories() -> [String]{
        return categoriesList
    }
    
    // loadRecipes will load the recipes of selected category to filtered recipes
    func loadRecipes(tapCategory : Int) -> [Recipe] {
        filteredRecipes = []
        for recipe in recipes {
            if recipe.category == tapCategory {
                filteredRecipes.append(recipe)
            }
        }
        return filteredRecipes
    }
    
    // getTotalSteps will return the total steps of selected recipe
    func getTotalSteps() -> Int {
        for recipe in filteredRecipes {
            if recipe.name == recipeSelected {
                return recipe.steps!.count
            }
        }
        return 0
    }
    
    // getStepText will return the text of selected step
    func getStepText() -> String {
        for recipe in filteredRecipes {
            if recipe.name == recipeSelected {
                return recipe.steps![String(currentStep)]!
            }
        }
        return ""
    }
    
    // getCurrentPage will return the current page the user is on
    func getCurrentPage() -> String {
        return currentPage
    }
    
    // setCurrentPage will set the current page to the page user is on
    func setCurrentPage(page: String){
        currentPage = page
    }
    
    // getStepNumber will return the current step number
    func getStepNumber() -> Int {
        return currentStep
    }
    
    // setStepNumber will set the current step number
    func setStepNumber(step: Int) {
        currentStep = step
    }
    
    // getRecipe will return the selected recipe from filtered recipes
    func getRecipe(name: String) -> Recipe {
        for recipe in filteredRecipes{
            if recipe.name == name{
                return recipe
            }
        }
        return filteredRecipes[0]
    }
}

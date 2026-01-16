//
//  NutritionViewModel.swift
//  TMMHealthDashboard
//
//  Created by Shivya Aggarwal on 15/01/26.
//

import Foundation
import SwiftUI

class NutritionViewModel: ObservableObject {
    @Published var meals: [Meal] = []
    @Published var isLoading = false
    
    private let coreDataManager = CoreDataManager.shared
    
    // Refresh meals list
    func loadMeals() {
        isLoading = true
        meals = coreDataManager.fetchTodaysMeals()
        isLoading = false
    }
    
    // Add new meal
    func addMeal(foodName: String, calories: Double, protein: Double, carbs: Double, fats: Double) {
        coreDataManager.saveMeal(
            foodName: foodName,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fats: fats
        )
        loadMeals()
    }
    
    // Delete meal
    func deleteMeal(_ meal: Meal) {
        coreDataManager.deleteMeal(id: meal.id)
        loadMeals()
    }
    
    // Today's totals
    var totalCalories: Double {
        meals.reduce(0) { $0 + $1.calories }
    }
    
    var totalProtein: Double {
        meals.reduce(0) { $0 + $1.protein }
    }
    
    var totalCarbs: Double {
        meals.reduce(0) { $0 + $1.carbs }
    }
    
    var totalFats: Double {
        meals.reduce(0) { $0 + $1.fats }
    }
    
    var formattedTotalCalories: String {
        String(format: "%.0f kcal", totalCalories)
    }
}

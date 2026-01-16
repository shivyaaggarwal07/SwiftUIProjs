//
//  Meal.swift
//  TMMHealthDashboard
//
//  Created by Shivya Aggarwal on 15/01/26.
//

import Foundation

struct Meal: Identifiable {
    let id: UUID
    let foodName: String
    let calories: Double
    let protein: Double
    let carbs: Double
    let fats: Double
    let timestamp: Date
    
    var formattedCalories: String {
        String(format: "%.0f kcal", calories)
    }
    
    var formattedProtein: String {
        String(format: "%.1f g", protein)
    }
    
    var formattedCarbs: String {
        String(format: "%.1f g", carbs)
    }
    
    var formattedFats: String {
        String(format: "%.1f g", fats)
    }
    
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: timestamp)
    }
    
    var totalMacros: String {
        String(format: "P: %.1f g | C: %.1f g | F: %.1f g", protein, carbs, fats)
    }
        
}

//
//  ActivityMetrics.swift
//  TMMHealthDashboard
//
//  Created by Shivya Aggarwal on 10/01/26.
//

import Foundation

struct ActivityMetrics: Identifiable {
    let id = UUID()
    let category: String
    let iconName: String
    let currentValue: Double
    let targetValue: Double
    let unit: String
    let iconColor: String
    
    var progressPercentage: Double {
        return min((currentValue / targetValue) * 100, 100)
    }
    
    var formattedCurrentValue: String {
        return String(format: "%.0f", currentValue)
    }
    
    var formattedTarget: String {
        return String(format: "%.0f", targetValue)
    }
    
    var isGoalMet: Bool {
        return currentValue >= targetValue
    }
    
}

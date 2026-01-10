//
//  ActivityViewModel.swift
//  TMMHealthDashboard
//
//  Created by Shivya Aggarwal on 10/01/26.
//

import Foundation
import SwiftUI

class ActivityViewModel: ObservableObject {
    @Published var activeCalories: Double = 0
    @Published var dailySteps: Double = 0
    @Published var isLoadingData = false
    @Published var lastUpdatedTime: Date?
    
    private let healthServiceManager =  TMMHealthServiceManager()
    
    ///GOALS
    private let stepGoal: Double = 10000 //10,000 steps
    private let calorieGoal: Double = 500 //500 active calories
    
    ///refresh health data
    func refreshHealthActivityData() {
        isLoadingData = true
        healthServiceManager.fetchDailySteps { [weak self] steps in
            guard let strongSelf = self else { return }
            strongSelf.dailySteps = steps
            strongSelf.checkIfBothLoaded()
        }
        
        healthServiceManager.fetchActiveCalories { [weak self] calories in
            guard let strongSelf = self else { return }
            strongSelf.activeCalories = calories
            strongSelf.checkIfBothLoaded()
        }
    }
        
        func checkIfBothLoaded() {
            if dailySteps >= 0 || activeCalories >= 0 {
                isLoadingData = false
                lastUpdatedTime = Date()
            }
        }
        
        ///Generate metric for steps
        var stepsMetric: ActivityMetrics {
            ActivityMetrics(category: "Active Energy", iconName: "bolt.heart.fill", currentValue: activeCalories, targetValue: calorieGoal, unit: "kcal", iconColor: "orange")
        }
        
        //Formatted last updated time
        var lastUpdatedText: String {
            guard let time = lastUpdatedTime else {
                return "Never"
            }
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: time)
        }
    
    
}


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
    @Published var lastUpdateTime: Date?
    
    
    @Published var weeklyStepsData: [DailyActivity] = []
    @Published var weeklyCaloriesData: [DailyActivity] = []
    @Published var showingChartType: ChartType = .steps
    
    @Published var showGoalCelebration = false
    @Published var isUsingCachedData = false
    
    @Published var dataState: DataState = .empty
    
    enum DataState {
        case empty          // No data yet
        case loading        // Fetching data
        case loaded         // Has data
        case error(String)  // Error occurred
    }
    
    private let cacheManager = CoreDataManager.shared
    private let healthServiceManager =  TMMHealthServiceManager()
    
    ///GOALS
    private let stepGoal: Double = 10000 //10,000 steps
    private let calorieGoal: Double = 500 //500 active calories
    
    enum ChartType {
        case steps
        case calories
    }
    
    ///refresh health data
    func refreshHealthActivityData() {
        
        // Set loading state
                dataState = .loading
        
        // First, try to load cached data immediately
               let hasCachedData = loadCachedData()
        
        // If we have cached data, show it while loading fresh data
               if hasCachedData {
                   dataState = .loaded
               }
               
        
        // Then fetch fresh data from HealthKit
        isLoadingData = true
        var stepsFetched = false
               var caloriesFetched = false
        
        healthServiceManager.fetchDailySteps { [weak self] steps in
            guard let strongSelf = self else { return }
            strongSelf.dailySteps = steps
            strongSelf.isUsingCachedData = false
            stepsFetched = true
            
            
            // Cache the fresh data
            strongSelf.cacheManager.cacheHealthData(
                            date: Date(),
                            steps: steps,
                            calories: strongSelf.activeCalories
                        )
            strongSelf.checkForGoalReached()
            
            if stepsFetched && caloriesFetched {
                strongSelf.updateDataState()
                       }
            
            strongSelf.checkIfBothLoaded()
        }
        
        healthServiceManager.fetchActiveCalories { [weak self] calories in
            guard let strongSelf = self else { return }
            strongSelf.activeCalories = calories
            strongSelf.isUsingCachedData = false
            caloriesFetched = true
            
            // Cache the fresh data
            strongSelf.cacheManager.cacheHealthData(
                           date: Date(),
                           steps: strongSelf.dailySteps,
                           calories: calories
                       )
            
            strongSelf.checkForGoalReached()
            if stepsFetched && caloriesFetched {
                strongSelf.updateDataState()
                        }
            strongSelf.checkIfBothLoaded()
            
        }
        
        //fetch weekly steps
        healthServiceManager.fetchWeeklySteps { [weak self] weeklySteps in
            guard let strongSelf = self else { return }
            strongSelf.weeklyStepsData = weeklySteps
            
            // Cache each day
            weeklySteps.forEach { daily in
                            self?.cacheManager.cacheHealthData(
                                date: daily.date,
                                steps: daily.steps,
                                calories: 0
                            )
                        }
        }
        
        //fetch weekly calories
        healthServiceManager.fetchWeeklyCalories { [weak self] weeklyCalories in
            guard let strongSelf = self else { return }
            strongSelf.weeklyCaloriesData = weeklyCalories
            // Cache each day
            weeklyCalories.forEach { daily in
                            self?.cacheManager.cacheHealthData(
                                date: daily.date,
                                steps: 0,
                                calories: daily.calories
                            )
                        }
        }
        
    }
    
    private func updateDataState() {
            isLoadingData = false
            lastUpdateTime = Date()
            
            // Check if we have any data
            if dailySteps == 0 && activeCalories == 0 && weeklyStepsData.isEmpty {
                dataState = .empty
            } else {
                dataState = .loaded
            }
        }
    
    private func loadCachedData() -> Bool {
        var hasData = false
           if let cachedToday = cacheManager.fetchTodaysCachedData() {
               self.dailySteps = cachedToday.steps
               self.activeCalories = cachedToday.calories
               self.isUsingCachedData = true
               self.lastUpdateTime = Date()
               hasData = true
           }
           
           let cachedWeekly = cacheManager.fetchWeeklyCachedData()
           if !cachedWeekly.isEmpty {
               self.weeklyStepsData = cachedWeekly
               self.weeklyCaloriesData = cachedWeekly
               hasData = true
           }
        return hasData
       }
    
    func checkIfBothLoaded() {
        if dailySteps >= 0 || activeCalories >= 0 {
            isLoadingData = false
            lastUpdateTime = Date()
        }
    }
    
    func checkForGoalReached() {
        if dailySteps >= stepGoal && activeCalories >= calorieGoal {
            if !showGoalCelebration {
                showGoalCelebration = true
                
            }
        }
    }
        
        //current chart data based on selection
        var currentChartData: [DailyActivity] {
            showingChartType == .steps ? weeklyStepsData : weeklyCaloriesData
        }
        
        ///Generate metric for steps
        var stepsMetric: ActivityMetrics {
            ActivityMetrics(category: "Movement", iconName: "bolt.heart.fill", currentValue: dailySteps, targetValue: stepGoal, unit: "steps", iconColor: "blue")
        }
        
        ///Generate metric for active calories
        var activeCaloriesMetric: ActivityMetrics {
            ActivityMetrics(category: "Active Energy", iconName: "flame.circle.fill", currentValue: activeCalories, targetValue: calorieGoal, unit: "kcal", iconColor: "orange")
        }
        
        //Insight calculations
        var bestDayThisWeek: String {
            let data = showingChartType == .steps ? weeklyStepsData : weeklyCaloriesData
            
            guard !data.isEmpty else { return "N/A"}

            guard let best = data.max(by:  {
                let val1 = $0.steps + $0.calories
                let val2 =  $1.steps + $1.calories
                return val1 < val2
            }) else {
                return "N/A"
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: best.date)
        }
        
        //weekly average
        
        var weeklyAverage: Double {
            let data = showingChartType == .steps ? weeklyStepsData : weeklyCaloriesData
            
            guard !data.isEmpty else { return 0 }
            
            let total = data.reduce(0.0) { $0 + $1.steps + $1.calories }
            return total / Double(data.count)
        }
        
        var weeklyAverageText: String {
            let avg = weeklyAverage
            guard avg.isFinite else { return "0" }
            return String(format: "%.0f", avg)
        }
        
        var compareToLastWeek: String {
            let current  = weeklyAverage
            
            guard current.isFinite && current > 0 else { return "No data" }
            
            //For simplicity, assuming last week's average is 10% less than current
            let simulated = current * 0.85
            guard simulated > 0 else { return "No data" }
            
            let difference = current - simulated
            let percentage = (difference / simulated) * 100
            
            guard percentage.isFinite else { return "No data" }
            
            if percentage > 0 {
                return "+\(Int(percentage))% vs last week"
            } else {
                return "\(Int(percentage))% vs last week"
            }
        }
        
        //Formatted last updated time
        var lastUpdateText: String {
            guard let time = lastUpdateTime else {
                return "Never"
            }
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: time)
        }
        
}


//
//  TMMHealthServiceManager.swift
//  TMMHealthDashboard
//
//  Created by Shivya Aggarwal on 07/01/26.
//

import Foundation
import HealthKit

class TMMHealthServiceManager: ObservableObject {
    let healthStore = HKHealthStore()
    
    ///track permission status
    @Published var permissionStatus: AuthStatus = .notDetermined
    
    enum AuthStatus {
        case notDetermined //haven't asked yet
        case granted //user granted permission
        case denied
    }
    
    ///Health data types we want to read
    let typesToRead: Set<HKObjectType> = [
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
    ]
    
    ///Request permission to access health data
    func requestPermission() {
        ///check if health data is available
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data not available on this device.")
            return
        }
        
        ///Request permission
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            DispatchQueue.main.async {
                if success {
                    self.permissionStatus = .granted
                    print("Health data access authorized.")
                } else {
                    self.permissionStatus = .denied
                    if let error = error {
                        print("Health data access denied: \(error.localizedDescription)")
                    } else {
                        print("Health data access denied.")
                    }
                }
            }
        }
    }
    
    ///Fetch today's step count
    func fetchDailySteps(completion: @escaping (Double) -> Void) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(0)
            return
        }
        
        let today = Date()
        let startOfDay = Calendar.current.startOfDay(for: today)
        let datePredicate = HKQuery.predicateForSamples(withStart: startOfDay, end: today, options: .strictStartDate)
        
        let stepsQuery = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: datePredicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let totalSteps = result.sumQuantity() else  {
                DispatchQueue.main.async {
                    completion(0)
                    
                }
                return
            }
            
            let steps = totalSteps.doubleValue(for: HKUnit.count())
            DispatchQueue.main.async {
                completion(steps)
            }
        }
        self.healthStore.execute(stepsQuery)
        
    }
    
    ///Fetch today's active energy
    func fetchActiveCalories(completion: @escaping (Double) -> Void) {
        guard let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(0)
            return
        }
        let today = Date()
        let startOfDay = Calendar.current.startOfDay(for: today)
        let datePredicate = HKQuery.predicateForSamples(withStart: startOfDay, end: today, options: .strictStartDate)
        
        let energyQuery = HKStatisticsQuery(quantityType: energyType, quantitySamplePredicate: datePredicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let totalEnergy = result.sumQuantity() else {
                DispatchQueue.main.async {
                    completion(0)
                }
                return
            }
            
            let calories = totalEnergy.doubleValue(for: HKUnit.kilocalorie())
            DispatchQueue.main.async {
                completion(calories)
            }
            
        }
        
        healthStore.execute(energyQuery)
    }
    
    //fetch last 7 days of step data
    func fetchWeeklySteps(completion: @escaping ([DailyActivity]) -> Void) {
        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion([])
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -6, to: today)!
        
        let predicate = HKQuery.predicateForSamples(withStart: sevenDaysAgo, end: Date(), options: .strictStartDate)
        
        var anchorComponents = calendar.dateComponents([.year, .month, .day], from: today)
        anchorComponents.hour = 0
        let anchorDate = calendar.date(from: anchorComponents)!
        
        let daily = DateComponents(day: 1)
        let query = HKStatisticsCollectionQuery(quantityType: stepsType, quantitySamplePredicate: predicate, options: .cumulativeSum, anchorDate: anchorDate, intervalComponents: daily)
        
        query.initialResultsHandler = { query, results, error in
            guard let results = results else {
                DispatchQueue.main.async { completion([])  }
                return
            }
            
            var dailyData: [DailyActivity] = []
            results.enumerateStatistics(from: sevenDaysAgo, to: Date()) { statistics, stop in
                let steps = statistics.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                let activity = DailyActivity(date: statistics.startDate, steps: steps, calories: 0)
                dailyData.append(activity)
            }
            
            DispatchQueue.main.async {
                completion(dailyData)
            }
                
        }
        healthStore.execute(query)
    }
    
    //calories 7 days data
    func fetchWeeklyCalories(completion: @escaping ([DailyActivity]) -> Void) {
        guard let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion([])
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -6, to: today)!
        
        let predicate = HKQuery.predicateForSamples(withStart: sevenDaysAgo, end: Date(), options: .strictStartDate)
        
        var anchorComponents = calendar.dateComponents([.year, .month, .day], from: today)
        anchorComponents.hour = 0
        let anchorDate = calendar.date(from: anchorComponents)!
        
        let daily = DateComponents(day: 1)
        let query = HKStatisticsCollectionQuery(quantityType: energyType, quantitySamplePredicate: predicate, options: .cumulativeSum, anchorDate: anchorDate, intervalComponents: daily)
        
        query.initialResultsHandler = { query, results, error in
            guard let results = results else {
                DispatchQueue.main.async { completion([])  }
                return
            }
            
            var dailyData: [DailyActivity] = []
            results.enumerateStatistics(from: sevenDaysAgo, to: Date()) { statistics, stop in
                let calories = statistics.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
                let activity = DailyActivity(date: statistics.startDate, steps: 0, calories: calories)
                dailyData.append(activity)
            }
            
            DispatchQueue.main.async {
                completion(dailyData)
            }
                
        }
        healthStore.execute(query)
    }
}

struct DailyActivity: Identifiable {
    let id = UUID()
    let date: Date
    let steps: Double
    let calories: Double
    
    var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
        
    }
    
    var isToday: Bool {
        return Calendar.current.isDateInToday(date)
    }
}

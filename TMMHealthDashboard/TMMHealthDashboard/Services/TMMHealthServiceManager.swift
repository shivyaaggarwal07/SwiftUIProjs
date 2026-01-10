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
}

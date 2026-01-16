//
//  CoreDataManager.swift
//  TMMHealthDashboard
//
//  Created by Shivya Aggarwal on 15/01/26.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    private init() {}
    
    //CORE DATA STACK
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "HealthCacheCoredataModel")
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    //MARK: SAVE CONTEXT
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            
            } catch {
                let nsError = error as NSError
                print("Error saving context: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    //Cache Health Data
    func cacheHealthData(date: Date, steps: Double, calories: Double) {
           let context = self.context
           
           // Check if entry already exists for this date
           let fetchRequest: NSFetchRequest<CachedHealthData> = CachedHealthData.fetchRequest()
           let calendar = Calendar.current
           let startOfDay = calendar.startOfDay(for: date)
           let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
           
           fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
           
           do {
               let results = try context.fetch(fetchRequest)
               
               if let existingData = results.first {
                   // Update existing
                   existingData.steps = steps
                   existingData.calories = calories
               } else {
                   // Create new
                   let newData = CachedHealthData(context: context)
                   newData.id = UUID()
                   newData.date = startOfDay
                   newData.steps = steps
                                  newData.calories = calories
                              }
                              
                              saveContext()
                          } catch {
                              print("Error caching health data: \(error)")
                          }
                      }
    
    // MARK: - Fetch Cached Data for Today
        func fetchTodaysCachedData() -> (steps: Double, calories: Double)? {
            let context = self.context
            let fetchRequest: NSFetchRequest<CachedHealthData> = CachedHealthData.fetchRequest()
            
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
            
            fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", today as NSDate, tomorrow as NSDate)
            fetchRequest.fetchLimit = 1
            
            do {
                let results = try context.fetch(fetchRequest)
                if let cachedData = results.first {
                    return (steps: cachedData.steps, calories: cachedData.calories)
                }
            } catch {
                print("Error fetching cached data: \(error)")
            }
            
            return nil
        }
        
    // MARK: - Fetch Last 7 Days
    func fetchWeeklyCachedData() -> [DailyActivity] {
        let context = self.context
        let fetchRequest: NSFetchRequest<CachedHealthData> = CachedHealthData.fetchRequest()
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -6, to: today)!
        
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date <= %@", sevenDaysAgo as NSDate, today as NSDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.map { cached in
                DailyActivity(date: cached.date ?? Date(), steps: cached.steps, calories: cached.calories)
            }
        } catch {
            print("Error fetching weekly cached data: \(error)")
            return []
        }
    }
    
    // MARK: - Clear Old Data (optional - keep last 30 days)
        func clearOldData() {
            let context = self.context
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CachedHealthData.fetchRequest()
            
            let calendar = Calendar.current
            let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date())!
            
            fetchRequest.predicate = NSPredicate(format: "date < %@", thirtyDaysAgo as NSDate)
            
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
                saveContext()
            } catch {
                print("Error clearing old data: \(error)")
            }
        }
    
    // MARK: - Meal Management
    
    func saveMeal(foodName: String, calories: Double, protein: Double, carbs: Double, fats: Double) {
        let context = self.context
        
        let newMeal = MealEntry(context: context)
        newMeal.id = UUID()
        newMeal.foodName = foodName
        newMeal.calories = calories
        newMeal.protein = protein
        newMeal.carbs = carbs
        newMeal.fats = fats
        newMeal.timestamp = Date()
        
        saveContext()
    }
    
    func fetchAllMeals() -> [Meal] {
        let context = self.context
        let fetchRequest: NSFetchRequest<MealEntry> = MealEntry.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.map { entry in
                Meal(
                    id: entry.id ?? UUID(),
                    foodName: entry.foodName ?? "",
                    calories: entry.calories,
                    protein: entry.protein,
                    carbs: entry.carbs,
                    fats: entry.fats,
                    timestamp: entry.timestamp ?? Date()
                )
            }
        } catch {
            print("Error fetching meals: \(error)")
            return []
        }
    }
    
    func fetchTodaysMeals() -> [Meal] {
        let context = self.context
        let fetchRequest: NSFetchRequest<MealEntry> = MealEntry.fetchRequest()
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        fetchRequest.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp < %@", today as NSDate, tomorrow as NSDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.map { entry in
                Meal(
                    id: entry.id ?? UUID(),
                    foodName: entry.foodName ?? "",
                    calories: entry.calories,
                    protein: entry.protein,
                    carbs: entry.carbs,
                    fats: entry.fats,
                    timestamp: entry.timestamp ?? Date()
                )
            }
        } catch {
            print("Error fetching today's meals: \(error)")
            return []
        }
    }
    
    func deleteMeal(id: UUID) {
        let context = self.context
        let fetchRequest: NSFetchRequest<MealEntry> = MealEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let mealToDelete = results.first {
                context.delete(mealToDelete)
                saveContext()
            }
        } catch {
            print("Error deleting meal: \(error)")
        }
    }
    
    func getTodaysTotalCalories() -> Double {
        let meals = fetchTodaysMeals()
        return meals.reduce(0) { $0 + $1.calories }
    }
}

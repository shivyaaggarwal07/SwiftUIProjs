    //
    //  NutritionLogView.swift
    //  TMMHealthDashboard
    //
    //  Created by Shivya Aggarwal on 15/01/26.
    //

    import SwiftUI

    struct NutritionLogView: View {
        @StateObject private var viewModel = NutritionViewModel()
        @State private var showingMealForm = false
        
        var body: some View {
            NavigationView {
                ZStack {
                    Color.appBackground
                        .ignoresSafeArea()
                    
                    if viewModel.meals.isEmpty {
                        emptyStateView
                    } else {
                        mealListView
                    }
                }
                .navigationTitle("Nutrition Log")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingMealForm = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.blue)
                        }
                    }
                }
                .sheet(isPresented: $showingMealForm) {
                    MealFormView(viewModel: viewModel)
                }
                .onAppear {
                    viewModel.loadMeals()
                }
            }
        }
        
        // MARK: - Empty State
        private var emptyStateView: some View {
            VStack(spacing: 24) {
                Spacer()
                
                Image(systemName: "fork.knife.circle")
                    .font(.system(size: 80))
                    .foregroundColor(.blue.opacity(0.5))
                
                VStack(spacing: 12) {
                    Text("No Meals Logged Today")
                        .font(.system(size: 26, weight: .bold))
                    
                    Text("Track your meals to monitor your nutrition intake")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Button(action: {
                    showingMealForm = true
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 18))
                        Text("Log Your First Meal")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(Color.primaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.blue)
                    .cornerRadius(16)
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                
                Spacer()
            }
        }
        
        // MARK: - Meal List
        private var mealListView: some View {
            ScrollView {
                VStack(spacing: 20) {
                    // Today's Summary
                    todaySummaryCard
                    
                    // Meals List
                    VStack(spacing: 12) {
                        HStack {
                            Text("Today's Meals")
                                .font(.system(size: 20, weight: .bold))
                            Spacer()
                            Text("\(viewModel.meals.count) meals")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 20)
                        
                        ForEach(viewModel.meals) { meal in
                            MealCard(meal: meal) {
                                viewModel.deleteMeal(meal)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Log Meal Button
                    Button(action: {
                        showingMealForm = true
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 18))
                            Text("Log Another Meal")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(14)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .accessibilityLabel("Add new meal")
                    .accessibilityHint("Opens meal entry form")
                }
                .padding(.vertical, 20)
            }
        }
        
        // MARK: - Summary Card
        private var todaySummaryCard: some View {
            VStack(spacing: 16) {
                HStack {
                    Text("Today's Totals")
                        .font(.system(size: 18, weight: .bold))
                    Spacer()
                    Text(Date(), style: .date)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                // Total Calories
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 24))
                    
                    Text(viewModel.formattedTotalCalories)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                    
                    Spacer()
                }
                
                Divider()
                
                // Macros Grid
                HStack(spacing: 20) {
                    MacroColumn(
                        title: "Protein",
                        value: String(format: "%.1f", viewModel.totalProtein),
                        unit: "g",
                        color: .blue
                    )
                    
                    Divider()
                        .frame(height: 40)
                    
                    MacroColumn(
                        title: "Carbs",
                        value: String(format: "%.1f", viewModel.totalCarbs),
                        unit: "g",
                        color: .purple
                    )
                    
                    Divider()
                        .frame(height: 40)
                    
                    MacroColumn(
                        title: "Fats",
                        value: String(format: "%.1f", viewModel.totalFats),
                        unit: "g",
                        color: .pink
                    )
                }
            }
            .padding(20)
            .background(Color.cardBackground)
            .cornerRadius(18)
            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Meal Card
    struct MealCard: View {
        let meal: Meal
        let onDelete: () -> Void
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(meal.foodName)
                            .font(.system(size: 17, weight: .semibold))
                        
                        Text(meal.formattedTimestamp)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.red.opacity(0.7))
                    }
                }
                
                Divider()
                
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.orange)
                        Text(meal.formattedCalories)
                            .font(.system(size: 15, weight: .semibold))
                    }
                    
                    Spacer()
                    
                    Text(meal.totalMacros)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .background(Color.cardBackground)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        }
    }

    // MARK: - Macro Column
    struct MacroColumn: View {
        let title: String
        let value: String
        let unit: String
        let color: Color
        
        var body: some View {
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(color)
                    Text(unit)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    #Preview {
        NutritionLogView()
    }

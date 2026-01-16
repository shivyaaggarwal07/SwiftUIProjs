//
//  MealFormView.swift
//  TMMHealthDashboard
//
//  Created by Shivya Aggarwal on 15/01/26.
//

import SwiftUI

struct MealFormView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: NutritionViewModel
    
    @State private var foodName = ""
    @State private var caloriesText = ""
    @State private var proteinText = ""
    @State private var carbsText = ""
    @State private var fatsText = ""
    
    @State private var showValidationError = false
    
    var isFormValid: Bool {
        !foodName.isEmpty &&
        Double(caloriesText) != nil &&
        Double(proteinText) != nil &&
        Double(carbsText) != nil &&
        Double(fatsText) != nil
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "fork.knife.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.blue)
                            
                            Text("Log Your Meal")
                                .font(.system(size: 24, weight: .bold))
                            
                            Text("Track your nutrition intake")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)
                        
                        // Form
                        VStack(spacing: 20) {
                            // Food Name
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Food Name", systemImage: "text.bubble")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.secondary)
                                
                                TextField("e.g., Grilled Chicken Salad", text: $foodName)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                            
                            // Calories
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Calories", systemImage: "flame")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.secondary)
                                
                                TextField("e.g., 350", text: $caloriesText)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                            
                            // Macros Row
                            HStack(spacing: 12) {
                                // Protein
                                VStack(alignment: .leading, spacing: 8) {
                                    Label("Protein (g)", systemImage: "p.circle")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.secondary)
                                        .labelStyle(.titleOnly)
                                    
                                    TextField("25", text: $proteinText)
                                        .keyboardType(.decimalPad)
                                        .textFieldStyle(CustomTextFieldStyle())
                                }
                                
                                // Carbs
                                VStack(alignment: .leading, spacing: 8) {
                                    Label("Carbs (g)", systemImage: "c.circle")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.secondary)
                                        .labelStyle(.titleOnly)
                                    
                                    TextField("30", text: $carbsText)
                                        .keyboardType(.decimalPad)
                                        .textFieldStyle(CustomTextFieldStyle())
                                }
                                
                                // Fats
                                VStack(alignment: .leading, spacing: 8) {
                                    Label("Fats (g)", systemImage: "f.circle")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.secondary)
                                        .labelStyle(.titleOnly)
                                    
                                    TextField("15", text: $fatsText)
                                        .keyboardType(.decimalPad)
                                        .textFieldStyle(CustomTextFieldStyle())
                                }
                            }
                            
                            // Scan Button (Placeholder)
                            Button(action: {
                                // Placeholder for barcode scanning
                                showValidationError = true
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "barcode.viewfinder")
                                        .font(.system(size: 18))
                                    Text("Scan Barcode")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                            }
                            
                            if showValidationError {
                                Text("Barcode scanning coming soon!")
                                    .font(.system(size: 13))
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Save Button
                        Button(action: saveMeal) {
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18))
                                Text("Save Meal")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(Color.primaryText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(isFormValid ? Color.green : Color.gray)
                            .cornerRadius(16)
                        }
                        .disabled(!isFormValid)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveMeal() {
        guard isFormValid,
              let calories = Double(caloriesText),
              let protein = Double(proteinText),
              let carbs = Double(carbsText),
              let fats = Double(fatsText) else {
            return
        }
        
        viewModel.addMeal(
            foodName: foodName,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fats: fats
        )
        
        dismiss()
    }
}

// Custom TextField Style
struct CustomTextFieldStyle: TextFieldStyle {
    @Environment(\.colorScheme) var colorScheme
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(colorScheme == .dark ? Color(white: 0.15) : Color(white: 0.95))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
    }
}

#Preview {
    MealFormView(viewModel: NutritionViewModel())
}

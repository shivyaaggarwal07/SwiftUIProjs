//
//  OnboardingView.swift
//  TMMHealthDashboard
//
//  Created by Shivya Aggarwal on 07/01/26.
//

import SwiftUI

struct OnboardingView: View {
    
    @Binding var showOnboarding: Bool
    
    var body: some View {
        ZStack {
            //Gradient Background
            
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.1, green: 0.3, blue: 0.6), Color(red: 0.05, green: 0.15, blue: 0.4  )]), startPoint: .topLeading, endPoint: .bottomTrailing)
        }.ignoresSafeArea()
        
        VStack(spacing: 30) {
            Spacer()
            
            //App icon
            Image(systemName: "waveform.path.ecg.rectangle")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
                .foregroundStyle(
                    LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            
            //TITLE
            Text("Welcome to TMM Health Dashboard")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 25)
                .padding(.bottom, 12)
                .foregroundColor(.white)
                
            
            //Subtitle
            Text("Your personal health companion to track your health journey with insights that matter")
                .font(.system(size: 16, weight: .regular))
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, 35)
                .padding(.bottom, 35)
            
            //BENEFITS
            VStack(alignment: .leading, spacing: 15) {
                BenefitRow(icon: "figure.run.circle.fill",text: "Track your daily steps")
                BenefitRow(icon: "bolt.heart.fill", text: "Monitor active calories ")
                BenefitRow(icon: "chart.line.uptrend.xyaxis", text: "Premium health insights")
            }
            .padding(.vertical)
            
            Spacer()
            
            //CTA Button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    showOnboarding = false
                }
            }) {
                HStack(spacing: 10) {
                    Text("Get Started")
                        .font(.system(size: 18, weight: .semibold))
                        
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 20))
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .frame(height: 54)
                .background(LinearGradient(colors: [Color.blue, Color.blue.opacity(0.8)], startPoint: .leading, endPoint: .trailing))
                .cornerRadius(16)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
    }
    
}
//BENEFITROW
    struct BenefitRow: View {
        let icon: String
        let text: String
        
        var body: some View {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .foregroundColor(.cyan)
                    .frame(width: 24)
                Text(text)
                    .font(.body)
                    .foregroundColor(.white)
            }
        }
    }
        
#Preview {
    OnboardingView(showOnboarding: .constant(true))
}

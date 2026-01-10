//
//  PermissionsView.swift
//  TMMHealthDashboard
//
//  Created by Shivya Aggarwal on 07/01/26.
//

import SwiftUI

struct PermissionsView: View {
    @ObservedObject var healthServiceManager: TMMHealthServiceManager
    @Binding var showPermissions: Bool
    
    //Animation States
    @State private var cardScale: CGFloat = 0.8
    @State private var cardOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.05)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 35) {
                Spacer()
                Image(systemName: "waveform.path.ecg.rectangle")
                    .resizable()
                    .frame(width: 90, height: 80)
                    .foregroundStyle(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .symbolEffect(.bounce, value: cardScale)
                
                //TITLE
                VStack(spacing: 8) {
                    Text("Health Data Permissions")
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                    
                    Text("Allow TMM to access your Health Data to provide personalized insights and track your wellness journey.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                }
                
                //PERMISSION CARDS
                VStack(spacing: 16) {
                    PermissionCard(icon: "figure.walk", title: "Step Count", description: "Track your daily steps to monitor activity levels.", accentColor: .blue)
                    
                    PermissionCard(icon: "bolt.heart.fill", title: "Active Energy", description: "Monitor calories burned during activities.", accentColor: .orange)
                }.scaleEffect(cardScale)
                    .opacity(cardOpacity)
                    .padding(.horizontal, 30)
                
                Spacer()
                
                //PRIMARY ACTION BUTTON
                Button(action: {
                    //HAPTIC FEEDBACK
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    
                    //Request Permission
                    healthServiceManager.requestPermission()
                    
                    //Wait for permission dialog to complete
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation(.spring()) {
                            showPermissions = false
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "heart.circle.fill")
                        Text("Connect Health")
                            .fontWeight(.semibold)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(LinearGradient(colors: [Color.blue, Color.blue.opacity(0.8)], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(16)
                    .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
                }
                .padding(.horizontal, 30)
                
                Button(action: {
                    healthServiceManager.permissionStatus = .denied
                    withAnimation {
                        showPermissions = false
                    }
                }) {
                    Text("Maybe Later")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            //entrance animation
            withAnimation(.spring(duration: 0.6)) {
                cardScale = 1.0
                cardOpacity = 1.0
            }
        }
    }
}

struct PermissionCard: View {
    let icon: String
    let title: String
    let description: String
    let accentColor: Color
    
    @State private var isPressed = false
    var body: some View {
        HStack(spacing: 16) {
            //Icon with gradient background
            ZStack {
                Circle().fill(accentColor.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(accentColor)
            }
            
            //Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBackground)).shadow(color: Color.black.opacity(0.05), radius: 8, y: 2))
        .scaleEffect(isPressed ? 0.97 : 1.0)
    }

}

#Preview {
    PermissionsView(healthServiceManager: TMMHealthServiceManager(), showPermissions: .constant(true))
}

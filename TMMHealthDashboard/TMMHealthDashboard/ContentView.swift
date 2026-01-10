//
//  ContentView.swift
//  TMMHealthDashboard
//
//  Created by Shivya Aggarwal on 06/01/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var tmmHealthServiceManager = TMMHealthServiceManager()
    @State private var showOnboarding = true
    @State private var showPermissions = false
    
    var body: some View {
        ZStack {
            VStack {
                Text("Main Dashboard")
                    .font(.title)
                    .foregroundColor(.gray)
            }
            
            //Permissions flow
            if showPermissions {
                PermissionsView(healthServiceManager: tmmHealthServiceManager, showPermissions: $showPermissions)
                    .transition(.move(edge: .trailing))
            }
            
            //onboarding overlay
            if showOnboarding {
                OnboardingView(showOnboarding: $showOnboarding)
                    .transition(.move(edge: .bottom) )
                    .onDisappear {
                        //show permissions after onboarding
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showPermissions = true
                        }
                    }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

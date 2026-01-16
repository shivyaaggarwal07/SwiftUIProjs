import SwiftUI

struct ContentView: View {
    @StateObject private var healthDataService = TMMHealthServiceManager()
    @State private var showOnboarding = true
    @State private var showPermissions = false
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // ONLY show main app when both onboarding and permissions are done
            if !showOnboarding && !showPermissions {
                TabView(selection: $selectedTab) {
                    DashboardView(healthServiceManager: healthDataService)
                        .tabItem {
                            Label("Activity", systemImage: "figure.walk")
                        }
                        .tag(0)
                    
                    NutritionLogView()
                        .tabItem {
                            Label("Nutrition", systemImage: "fork.knife")
                        }
                        .tag(1)
                }
                .accentColor(.blue)
            } else {
                // Show placeholder while onboarding/permissions are active
                Color(red: 0.97, green: 0.97, blue: 0.98)
                    .ignoresSafeArea()
            }
            
            // Permission screen overlay (only shows if permissions not done)
            if showPermissions && !showOnboarding {
                PermissionsView(
                    healthServiceManager: healthDataService,
                    showPermissions: $showPermissions
                )
                .transition(.move(edge: .trailing))
                .zIndex(1)
            }
            
            // Onboarding overlay (shows first, on top of everything)
            if showOnboarding {
                OnboardingView(showOnboarding: $showOnboarding)
                    .transition(.move(edge: .bottom))
                    .zIndex(2)
                    .onDisappear {
                        // Show permissions after onboarding
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.spring()) {
                                showPermissions = true
                            }
                        }
                    }
            }
        }
    }
}

#Preview {
    ContentView()
}

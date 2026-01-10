//
//  DashboardView.swift
//  TMMHealthDashboard
//
//  Created by Shivya Aggarwal on 10/01/26.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = ActivityViewModel()
    @ObservedObject var healthServiceManager = TMMHealthServiceManager()
    
    var body: some View {
        NavigationView {
            ZStack {
                //Background
                Color(red: 0.97, green: 0.97, blue: 0.98)
                    .ignoresSafeArea()
                
                if healthServiceManager.permissionStatus == .granted {
                    //full dashboard Data
                    authorizedDashboard
                } else {
                    //limited dashboard view
                    restrictedDashboard
                }
            }
            .navigationTitle("Activity")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    //authorized dashboard view
    private var authorizedDashboard: some View {
        ScrollView {
            VStack(spacing: 24) {
                //Header with date and refresh
                
            }
        }
    }
    
    //restricted dashboard view
    private var restrictedDashboard: some View {
        VStack(spacing: 20) {
            Spacer()
            
            //Lock Icon
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "lock.fill")
                    .font(.system(size: 45))
                    .foregroundColor(.red)
            }
            
            VStack(spacing: 12) {
                Text("Limited Access")
                    .font(.system(size: 28, weight: .bold))
                
                Text("Health data permissions are needed\n to display your activity dashboard.")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            
            //RETRY BUTTON
        }
    }
    
}

#Preview {
    DashboardView(healthServiceManager: TMMHealthServiceManager())
}

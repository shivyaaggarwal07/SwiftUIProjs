//
//  DashboardView.swift
//  TMMHealthDashboard
//
//  Created by Shivya Aggarwal on 10/01/26.
//

import SwiftUI
import Charts

struct DashboardView: View {
    @StateObject private var viewModel = ActivityViewModel()
    @ObservedObject var healthServiceManager = TMMHealthServiceManager()
    
    var body: some View {
        NavigationView {
            ZStack {
                //Background
                Color.appBackground
                    .ignoresSafeArea()
                
                if healthServiceManager.permissionStatus == .granted {
                    // Check data state
                    switch viewModel.dataState {
                    case .empty:
                        EmptyStateView {
                            viewModel.refreshHealthActivityData()
                        }
                    case .loading where !viewModel.isUsingCachedData:
                        LoadingStateView()
                    case .error(let message):
                        ErrorStateView(message: message) {
                            viewModel.refreshHealthActivityData()
                        }
                    case .loaded, .loading:
                        //full dashboard Data
                        authorizedDashboard
                    }
                }else {
                    //limited dashboard view
                    restrictedDashboard
                }
            }
            .navigationTitle("Activity")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    ///authorized dashboard view
    @ViewBuilder
    private var authorizedDashboard: some View {
        ScrollView {
            VStack(spacing: 24) {
                ///Header with date and refresh
                headerSection
                
                VStack (spacing: 16) {
                    MetricCard(metric: viewModel.stepsMetric)
                    MetricCard(metric: viewModel.activeCaloriesMetric)
                    
                }.padding(.horizontal, 20)
                
                ///7 day trend chart
                weeklyTrendSection
                
                ///Insight cards
                insightCardsSection
                
                ///last update info
                updateInfoSection
            }.padding(.vertical, 20)
        }.onAppear {
            viewModel.refreshHealthActivityData()
        }.refreshable {
            viewModel.refreshHealthActivityData()
        }.alert("Goal Reached!", isPresented: $viewModel.showGoalCelebration) {
            Button("Awesome!") {
                triggerHapticFeedback()
            }
        }message: {
            Text("Congratulations on achieving your daily activity goals! Keep up the great work!")
        }
        
    }
    ///Header Section
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(Date(), style: .date)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.blue)
            
            if viewModel.isUsingCachedData {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.clockwise.icloud")
                                    .font(.system(size: 14))
                                Text("Showing cached data")
                                    .font(.system(size: 13))
                            }
                            .foregroundColor(.orange)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(12)
                        }
            
            Button(action: {
                viewModel.refreshHealthActivityData()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.system(size: 18))
                    Text("Refresh Data")
                        .font(.system(size: 14, weight: .semibold))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(20)
            }
        }
    }
    
    //UPDATE INFO
    
    private var updateInfoSection: some View {
        HStack(spacing: 6) {
            Image(systemName: "clock.fill")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            
            Text("Last updated: \(viewModel.lastUpdateText)")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
        .padding(.top, 8)
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
            
            //what's unavailable
            VStack(alignment: .leading, spacing: 14){
                RestrictedFeature(text: "Real-time step tracking")
                RestrictedFeature(text: "Active calorie monitoring")
                RestrictedFeature(text: "Daily programs insights")
            }.padding(20)
                .background(Color.cardBackground)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
                .padding(.horizontal, 30)
            
            //RETRY BUTTON
            Button(action: {
                healthServiceManager.requestPermission()
                
                //wait for permission dialog to complete, then check status and refresh
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    if healthServiceManager.permissionStatus == .granted {
                        viewModel.refreshHealthActivityData()
                    }
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 16))
                    Text("Retry Permission")
                        .font(.system(size: 17, weight: .semibold))
                }.foregroundColor(Color.primaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(LinearGradient(colors: [Color.blue, Color.blue.opacity(0.8), Color.blue], startPoint: .leading, endPoint: .trailing)).cornerRadius(14)
                    .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }.padding(.horizontal, 30)
            Spacer()
        }
    }
    
    //WEEKLY TREND SECTION
    @ViewBuilder
    private var weeklyTrendSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("7 Day trend")
                    .font(.system(size: 19, weight: .bold))
                
                Spacer()
                
                Picker("Chart Type", selection: $viewModel.showingChartType) {
                    Text("Steps").tag(ActivityViewModel.ChartType.steps)
                    Text("Calories").tag(ActivityViewModel.ChartType.calories)
                    
                }.pickerStyle(.segmented)
                    .frame(width: 180)
            }
            
            if viewModel.currentChartData.isEmpty {
                Text("Loading chart data...")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                Chart(viewModel.currentChartData) { item in
                    if viewModel.showingChartType == .steps {
                        BarMark(x: .value("Day", item.dayName),
                                y: .value("Steps", item.steps)).foregroundStyle(item.isToday ? Color.blue : Color.blue.opacity(0.6)).cornerRadius(6)
                        
                        
                    } else {
                        BarMark(x: .value("Day", item.dayName),
                                y: .value("Calories", item.calories)).foregroundStyle(item.isToday ? Color.orange : Color.orange.opacity(0.6)).cornerRadius(6)
                    }
                }.frame(height: 100).chartYAxis {
                    AxisMarks(position: .leading)
                }
                .accessibilityLabel("7-day activity trend showing \(viewModel.showingChartType == .steps ? "steps" : "calories")")
                   .accessibilityHint("Bar chart with daily values")
            }
        }.padding(20).background(Color.cardBackground).cornerRadius(18).shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4).padding(.horizontal, 20)
    }
    
    //Insight crads section
    @ViewBuilder
    private var insightCardsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                InsightCard(icon: "star.fill", title: "Best Day This Week", value: viewModel.bestDayThisWeek, color: .green)
                
                InsightCard(icon: "chart.line.uptrend.xyaxis", title: "Weekly Average", value: viewModel.weeklyAverageText + (viewModel.showingChartType == .steps ? " steps" : " kcal"), color: .blue)
            }
            
            HStack(spacing: 12) {
                InsightCard(icon: "arrow.up.right", title: "Trend", value: viewModel.compareToLastWeek, color: .purple)
                
                InsightCard(
                    icon: "target",
                    title: "Goal Rate",
                    value: {
                        let percentage = viewModel.stepsMetric.progressPercentage
                        return percentage.isFinite ? String(format: "%.0f%%", percentage) : "0%"
                    }(),
                    color: .orange
                )
            }
        }.padding(.horizontal, 20)
    }
    
    //Haptic feedback
    private func triggerHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
}

//METRIC CARD COMPONENT
struct MetricCard: View {
    let metric: ActivityMetrics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            //HEADER
            HStack {
                Image(systemName: metric.iconName)
                    .font(.system(size: 26))
                    .foregroundColor(colorFromString(metric.iconColor))
                Text(metric.category)
                    .font(.system(size: 19, weight: .semibold))
                
                Spacer()
                
                if metric.isGoalMet {
                    Image(systemName: "checkMark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                }
                
            }
            
            //PROGRESS BAR
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    //Background
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 10)
                    
                    //progress fill
                    RoundedRectangle(cornerRadius: 6)
                        .fill(LinearGradient(colors: [colorFromString(metric.iconColor), colorFromString(metric.iconColor).opacity(0.7)], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geometry.size.width * CGFloat(metric.progressPercentage / 100), height: 10)
                        .animation(.spring(response: 0.6), value: metric.progressPercentage)
                    
                }.accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(metric.category): \(metric.currentValue)")
                    .accessibilityValue("\(Int(metric.progressPercentage))% of goal")
                
            }.frame(height: 10)
            
            //Values
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(metric.formattedCurrentValue)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text("of \(metric.formattedTarget) \(metric.unit) goal")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)

                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(metric.progressPercentage))%")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(colorFromString(metric.iconColor))
                    
                    Text("Completed")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        
                        
                }
            }
        }.padding(20)
            .background(Color.cardBackground)
            .cornerRadius(18)
            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 5)
    }
    
    private func colorFromString(_ colorName: String) -> Color {
        switch colorName.lowercased() {
        case "blue": return Color.blue
        case "orange": return Color.orange
        case "green": return Color .green
        case "red": return Color.red
        default: return Color.blue
        }
    }
}

//Restricted Feature
struct RestrictedFeature: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(.red.opacity(0.7))
            
            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.secondary)
            
            Spacer()
                
        }
    }
}

struct InsightCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                
                Spacer()
            }
            
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }.padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.cardBackground)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let onRefresh: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "chart.bar.doc.horizontal")
                    .font(.system(size: 45))
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 12) {
                Text("No Activity Data Yet")
                    .font(.system(size: 26, weight: .bold))
                
                Text("Start moving to see your health data appear here")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(.horizontal, 40)
            }
            
            VStack(spacing: 16) {
                Text("Tips to get started:")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 12) {
                    TipRow(icon: "figure.walk", text: "Take a walk to record steps")
                    TipRow(icon: "sportscourt", text: "Do a workout to burn calories")
                    TipRow(icon: "applewatch", text: "Wear your Apple Watch for tracking")
                }
                .padding(16)
                .background(Color.cardBackground)
                .cornerRadius(14)
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)
            
            Button(action: onRefresh) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16))
                    Text("Check for Data")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(Color.primaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.blue)
                .cornerRadius(14)
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)
            
            Spacer()
        }
    }
}

// MARK: - Loading State View
struct LoadingStateView: View {
    var body: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
            
            Text("Loading Your Activity...")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Error State View
struct ErrorStateView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Error icon
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 45))
                    .foregroundColor(.red)
            }
            
            VStack(spacing: 12) {
                Text("Unable to Load Data")
                    .font(.system(size: 26, weight: .bold))
                
                Text(message)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(.horizontal, 40)
            }
            
            VStack(spacing: 12) {
                Text("Possible reasons:")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 10) {
                    ErrorReasonRow(text: "No internet connection")
                    ErrorReasonRow(text: "HealthKit permissions changed")
                    ErrorReasonRow(text: "Health app is unavailable")
                }
                .padding(16)
                .background(Color.cardBackground)
                .cornerRadius(14)
            }
            .padding(.horizontal, 30)
            
            Button(action: onRetry) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16))
                    Text("Try Again")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(Color.primaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.red)
                .cornerRadius(14)
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)
            
            Spacer()
        }
    }
}

struct ErrorReasonRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "circle.fill")
                .font(.system(size: 6))
                .foregroundColor(.red)
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

struct TipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.primary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}

#Preview {
    DashboardView(healthServiceManager: TMMHealthServiceManager())
}

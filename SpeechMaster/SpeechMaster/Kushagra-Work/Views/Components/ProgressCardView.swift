import SwiftUI
import Charts

struct ProgressCardView: View {
    @State private var showingInsights = false
    let viewModel: HomeViewModel
    let title: String
    let progress: Double
    let fgColor: Color
    let bgColor: Color
    let circleColor: Color
    let lastCreatedScriptName: String?
    
    private var progressPercentage: Int {
        Int(progress)
    }
    
    private var improvementStatus: String {
        switch progress {
        case 0..<30: return "Getting Started 🌱"
        case 30..<60: return "Making Progress ⭐️"
        case 60..<80: return "Doing Great 🌟"
        default: return "Outstanding 👑"
        }
    }
    
    private var averageSessionDuration: String {
        // Calculate average duration from viewModel's sessions
        let totalMinutes = 45 // Replace with actual calculation from sessions
        return "\(totalMinutes) min"
    }
    
    private var recentImprovement: Double {
        // Calculate improvement between last two sessions
        return 15.0 // Replace with actual calculation
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Top row
            HStack(alignment: .center, spacing: 16) {
                // Progress percentage
                Text("\(progressPercentage)%")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundColor(.black)
                
                ProgressBarsView(progress: progress)
                
                Spacer(minLength: 24)
                
                // Updated Insights Button
                Button(action: { showingInsights = true }) {
                    Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                }
                .sheet(isPresented: $showingInsights) {
                    NavigationView {
                        ScrollView {
                            VStack(spacing: 20) {
                                // Header Stats
                                HStack(spacing: 20) {
                                    StatBox(
                                        title: "Overall Score",
                                        value: "\(progressPercentage)%",
                                        icon: "chart.bar.fill",
                                        color: .blue
                                    )
                                    
                                    StatBox(
                                        title: "Recent Growth",
                                        value: "+\(Int(recentImprovement))%",
                                        icon: "arrow.up.right",
                                        color: .green
                                    )
                                }
                                
                                // Divider with label
                                LabeledDivider(text: "Performance Metrics")
                                
                                // Detailed Stats Grid
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 16) {
                                    DetailStatItem(
                                        icon: "doc.fill",
                                        value: "\(viewModel.scripts.count)",
                                        label: "Total Scripts",
                                        color: .purple
                                    )
                                    
                                    DetailStatItem(
                                        icon: "clock.fill",
                                        value: averageSessionDuration,
                                        label: "Avg. Duration",
                                        color: .orange
                                    )
                                    
                                    DetailStatItem(
                                        icon: "calendar",
                                        value: "Last 7 Days",
                                        label: "Active Streak",
                                        color: .blue
                                    )
                                    
                                    DetailStatItem(
                                        icon: "star.fill",
                                        value: improvementStatus,
                                        label: "Current Level",
                                        color: .yellow
                                    )
                                }
                                
                                // Tips Section
                                LabeledDivider(text: "Improvement Tips")
                                
                                ImprovementTipView(progress: progress)
                            }
                            .padding()
                        }
                        .navigationTitle("Progress Details")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Done") {
                                    showingInsights = false
                                }
                            }
                        }
                    }
                }
            }
            
            // Bottom content
            BottomContentView(lastCreatedScriptName: lastCreatedScriptName)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(Color.green.opacity(0.1))
        .cornerRadius(16)
    }
}

private struct ProgressBarsView: View {
    let progress: Double
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...10, id: \.self) { index in
                Rectangle()
                    .fill(Double(index) * 10 <= progress ? Color.green : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 28)
                    .cornerRadius(4)
            }
        }
    }
}

private struct BottomContentView: View {
    let lastCreatedScriptName: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(lastCreatedScriptName ?? "No recent scripts")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black.opacity(0.6))
            
            Text("Overall Improvement")
                .font(.system(size: 26, weight: .semibold))
                .foregroundColor(.black.opacity(0.7))
        }
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
            }
            .foregroundStyle(color)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(color.opacity(0.7))
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct DetailStatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            
            Text(value)
                .font(.system(size: 16, weight: .semibold))
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct LabeledDivider: View {
    let text: String
    
    var body: some View {
        HStack {
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Rectangle()
                .fill(Color(.separator))
                .frame(height: 1)
        }
        .padding(.vertical, 8)
    }
}

struct ImprovementTipView: View {
    let progress: Double
    
    private var tip: (title: String, description: String) {
        if progress < 30 {
            return ("Focus on Basics", "Start with short scripts and practice regularly to build confidence.")
        } else if progress < 60 {
            return ("Keep Growing", "Try varying your pace and incorporating gestures into your delivery.")
        } else if progress < 80 {
            return ("Polish Your Skills", "Work on advanced techniques like vocal variety and audience engagement.")
        } else {
            return ("Master Level", "Share your expertise and try mentoring others in public speaking.")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(tip.title)
                .font(.headline)
            
            Text(tip.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

//#Preview {
//    VStack {
//        ProgressCardView(
//            viewModel: HomeViewModel.shared, 
//            title: "Overall Improvement",
//          //  progress: 65,
//            fgColor: .black,
//            bgColor: .green.opacity(0.1),
//            circleColor: .green,
//            lastCreatedScriptName: "Presentation Script"
//        )
//        .padding()
//    }
//    .background(Color(.systemBackground))
//}

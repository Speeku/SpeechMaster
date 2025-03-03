import SwiftUI
import Charts

struct ProgressCardView: View {
    let viewModel: HomeViewModel
    let title: String
    let progress: Double
    let fgColor: Color
    let bgColor: Color
    let circleColor: Color
    let lastCreatedScriptName: String?
    
    private var currentScriptId: UUID? {
        viewModel.scripts.first?.id
    }
    
    private var progressPercentage: Int {
        Int(viewModel.calculateOverallImprovement(for: currentScriptId))
    }
    
    private var sessionCount: Int {
        guard let scriptId = currentScriptId else { return 0 }
        return viewModel.sessionsArray.filter { $0.scriptId == scriptId }.count
    }
    
    private var improvementStatus: String {
        let progress = Double(progressPercentage)
        switch progress {
        case 0..<30: return "Getting Started 🌱"
        case 30..<60: return "Making Progress ⭐️"
        case 60..<80: return "Doing Great 🌟"
        default: return "Outstanding 👑"
        }
    }
    
    private var averageSessionDuration: String {
        guard let scriptId = currentScriptId else { return "0 min" }
        
        let scriptSessions = viewModel.sessionsArray.filter { $0.scriptId == scriptId }
        let scriptSessionIds = Set(scriptSessions.map { $0.id })
        let scriptReports = viewModel.userPerformanceReports.filter { scriptSessionIds.contains($0.sessionID) }
        
        guard !scriptReports.isEmpty else { return "0 min" }
        
        let totalDuration = scriptReports.reduce(0.0) { $0 + $1.duration }
        let averageMinutes = Int(totalDuration / Double(scriptReports.count) / 60.0)
        return "\(averageMinutes) min"
    }
    
    private var recentImprovement: Double {
        viewModel.calculateRecentImprovement(for: currentScriptId)
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
                
                // Simplified session count display
                VStack(alignment: .center, spacing: 2) {
                    Text("\(sessionCount)")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.blue)
                    
                    Text("Sessions")
                        .font(.system(size: 12))
                        .foregroundColor(.black.opacity(0.6))
                }
            }
            
            // Bottom content
            BottomContentView(lastCreatedScriptName: lastCreatedScriptName)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
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
                let barProgress = progress / 10.0
                let barIndex = Double(index)
                
                Rectangle()
                    .fill(getBarColor(barIndex: barIndex, barProgress: barProgress))
                    .frame(width: 8, height: 28)
                    .cornerRadius(4)
            }
        }
    }
    
    private func getBarColor(barIndex: Double, barProgress: Double) -> Color {
        if barIndex <= floor(barProgress) {
            return Color.green
        } else if barIndex <= ceil(barProgress) {
            let partialFill = progress.truncatingRemainder(dividingBy: 10) / 10
            return Color.green.opacity(partialFill)
        } else {
            return Color.gray.opacity(0.3)
        }
    }
}

private struct BottomContentView: View {
    let lastCreatedScriptName: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Script: \(lastCreatedScriptName ?? "No recent scripts")")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black.opacity(0.6))
            
            Text("Overall Improvement")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.black.opacity(0.5))
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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
            
            Text(value)
                .font(.title2.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
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
        .background(Color.white)
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
        .background(Color.white)
        .cornerRadius(12)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
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

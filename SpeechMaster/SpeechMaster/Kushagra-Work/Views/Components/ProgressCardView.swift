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
    
    @State private var progressPercentage: Int = 0
    @State private var recentImprovement: Double = 0
    @Environment(\.colorScheme) private var colorScheme
    
    private var currentScriptId: UUID? {
        viewModel.scripts.first?.id
    }
    
    private var sessionCount: Int {
        guard let scriptId = currentScriptId else { return 0 }
        return viewModel.sessionsArray.filter { $0.scriptId == scriptId }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            BottomContentView(lastCreatedScriptName: lastCreatedScriptName)
            // Top row
            HStack(alignment: .center, spacing: 16) {
                // Progress percentage
                Text("\(progressPercentage)%")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                ProgressBarsView(progress: progress)
                
                Spacer(minLength: 18)
                
                // Simplified session count display
                VStack(alignment: .center, spacing: 2) {
                    Text("\(sessionCount)")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.blue)
                    
                    Text("Sessions")
                        .font(.system(size: 12))
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.6))
                }
            }
            
            // Bottom content
            
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(colorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.2) : Color.blue.opacity(0.1))
        .cornerRadius(16)
        .onAppear {
            // Use a Task to fetch the improvement calculations asynchronously
            Task {
                do {
                    let overallValue = await viewModel.calculateOverallImprovement(for: currentScriptId)
                    let recentValue = await viewModel.calculateRecentImprovement(for: currentScriptId)
                    
                    // Update the state properties on the main thread
                    await MainActor.run {
                        progressPercentage = Int(overallValue)
                        recentImprovement = recentValue
                    }
                } catch {
                    print("Error fetching improvement data: \(error)")
                }
            }
        }
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
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Overall Improvement")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(colorScheme == .dark ? .white.opacity(0.9) : .black.opacity(0.5))
            
            Text("Script: \(lastCreatedScriptName ?? "No recent scripts")")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.6))
            
          
        }
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


import SwiftUI
import Charts

struct ProgressCardView: View {
    private let dataSource = DataController.shared
    @ObservedObject var viewModel: HomeViewModel
    let title: String
    let progress: Double
    let fgColor: Color
    let bgColor: Color
    let circleColor: Color
    let lastCreatedScriptName: String?
    @State private var animateProgress = false
    @State private var showDetails = false
    
    var body: some View {
        Button(action: { showDetails.toggle() }) {
            VStack(alignment: .leading, spacing: 18) {
                // Header
                HStack(alignment: .center, spacing: 8) {
                    Text(title)
                        .foregroundStyle(fgColor)
                        .font(.system(.headline, design: .rounded))
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text("\(Int(progress))%")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .foregroundStyle(fgColor)
                        .monospacedDigit()
                }
                
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(circleColor.opacity(0.2))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(circleColor)
                            .frame(width: animateProgress ? (geometry.size.width * progress / 100) : 0, height: 8)
                    }
                }
                .frame(height: 8)
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    if let lastScriptName = lastCreatedScriptName {
                        HStack(spacing: 4) {
                            Text("Last Practice:")
                                .font(.subheadline)
                                .foregroundStyle(fgColor.opacity(0.7))
                            Text(lastScriptName)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(fgColor)
                                .lineLimit(1)
                        }
                    }
                    
                    // Stats Row
                    HStack(alignment:.center,spacing: 30) {
                        StatItem(
                            icon: "clock.arrow.circlepath",
                            value: {
                                // Handle null cases and get session count
                                if !viewModel.isLoggedIn {
                                    return "0"
                                }
                                guard let lastScript = viewModel.scripts.first else {
                                    return "0"
                                }
                                let sessions = dataSource.getSessions(for: lastScript.id)
                                return "\(sessions.count)"
                            }(),
                            label: "Sessions",
                            color: fgColor
                        )
                        Spacer()
                        StatItem(
                            icon: "chart.line.uptrend.xyaxis",
                            value: "+5%",
                            label: "Growth",
                            color: fgColor
                        )
                    }.padding(.horizontal,10)
                }
            }
            .padding()
            .background(bgColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: circleColor.opacity(0.1), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                animateProgress = true
            }
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


#Preview {
    VStack {
        ProgressCardView(
            viewModel: HomeViewModel.shared, title: "Overall Improvement",
            progress: 75,
            fgColor: .black,
            bgColor: .green.opacity(0.1),
            circleColor: .green,
            lastCreatedScriptName: "Presentation Script"
        )
        .padding()
    }
    .background(Color(.systemBackground))
}

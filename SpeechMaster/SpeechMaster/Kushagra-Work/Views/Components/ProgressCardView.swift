import SwiftUI
struct ProgressCardView: View {
    let title: String
    let progress: Double
    let fgColor: Color
    let bgColor: Color
    let circleColor: Color
    let lastCreatedScriptName: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Title
            Text(title)
                .foregroundStyle(fgColor)
                .font(.headline)
                .lineLimit(2)

            // Content HStack
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 5) {
                    // Last Created Script Name
                    if let lastScriptName = lastCreatedScriptName {
                        Text(lastScriptName)
                            .font(.subheadline)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(fgColor)
                            .lineLimit(1)
                    }

                    // Progress Percentage
                    Text("\(Int(progress))%")
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(fgColor)
                }

                // Circular Progress Indicator
                Spacer() // Ensures the circle is pushed to the right
                ZStack {
                    Circle()
                        .stroke(lineWidth: 7)
                        .foregroundColor(circleColor.opacity(0.2))

                    Circle()
                        .trim(from: 0, to: progress / 100)
                        .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .foregroundColor(circleColor)
                        .rotationEffect(.degrees(-90))
                }
                .frame(width: 50, height: 50)
            }
        }
        .padding()
        .background(bgColor)
        .cornerRadius(15)
        .frame(maxHeight: .infinity)
    }
}
#Preview {
    HStack {
        ProgressCardView(title: "Audience Ebgagement", progress: 10, fgColor: .white, bgColor: .progressCardColorAudienceEngagement, circleColor: .orange, lastCreatedScriptName: "Avc")
        ProgressCardView(title: "Audience Ebgagement", progress: 10, fgColor: .white, bgColor: .progressCardColorAudienceEngagement, circleColor: .orange, lastCreatedScriptName: "Avc")}
}

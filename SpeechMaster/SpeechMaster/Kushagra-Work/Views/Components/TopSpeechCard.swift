import SwiftUI

struct TopSpeechCard: View {
    let speech: TopSpeech
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background Image
            Image(speech.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 170, height: 200)
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            .black.opacity(0.7)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            // Content Overlay
            VStack(alignment: .leading, spacing: 4) {
                // Category and Duration
                HStack {
                    Text(speech.category.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(categoryColor(for: speech.category))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    
                    Spacer()
                }
                
                Spacer()
                
                // Title and Description
                VStack(alignment: .leading, spacing: 2) {
                    Text(speech.title)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    
                    Text(speech.description)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                        .lineLimit(1)
                    
                    // Duration and Featured Badge
                    HStack {
                        Label(formatDuration(speech.duration), systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                        
                        if speech.isFeatured {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                        }
                    }
                }
            }
            .padding(8)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .frame(width: 170, height: 200)
        .shadow(radius: 5)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration / 60)
        return "\(minutes)min"
    }
    
    private func categoryColor(for category: SpeechCategory) -> Color {
        switch category {
        case .technology:
            return .blue
        case .leadership:
            return .purple
        case .education:
            return .green
        case .motivation:
            return .orange
        case .sports:
            return .red
        case .politics:
            return .indigo
        case .literature:
            return .pink
        case .other:
            return .gray
        }
    }
}

#Preview {
    ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(spacing: 16) {
            TopSpeechCard(speech: HomeViewModel.shared.topSpeeches[0])
            TopSpeechCard(speech: HomeViewModel.shared.topSpeeches[1])
        }
        .padding()
    }
    .background(Color(.systemBackground))
}

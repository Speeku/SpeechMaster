import SwiftUI

// MARK: - Onboarding Models
struct OnboardingPage: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
    let accentColor: Color
    let backgroundColor: Color
    let features: [String]
    let animationDuration: Double
}

// MARK: - Onboarding Theme
struct OnboardingTheme {
    static let lightBackground = Color(.systemBackground)
    static let darkBackground = Color(.systemBackground).opacity(0.8)
    static let shadowColor = Color.black.opacity(0.1)
    static let buttonHeight: CGFloat = 54
    static let iconSize: CGFloat = 50
    static let cornerRadius: CGFloat = 16
    static let spacing: CGFloat = 20
}

// MARK: - Onboarding Data
extension OnboardingPage {
    static let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Master Public Speaking",
            description: "Learn from the world's greatest speakers and develop your own unique style through expert analysis and guidance.",
            imageName: "speaker.wave.3.fill",
            accentColor: .blue,
            backgroundColor: .blue.opacity(0.1),
            features: [
                "Expert analysis of speech patterns",
                "Personalized coaching tips",
                "Voice modulation training"
            ],
            animationDuration: 0.6
        ),
        OnboardingPage(
            title: "Real-time Feedback",
            description: "Get instant feedback on your pace, tone, body language, and speech content to improve your delivery.",
            imageName: "waveform.path.ecg",
            accentColor: .green,
            backgroundColor: .green.opacity(0.1),
            features: [
                "Speech pace analysis",
                "Tone and pitch detection",
                "Body language recognition"
            ],
            animationDuration: 0.7
        ),
        OnboardingPage(
            title: "Learn from the Best",
            description: "Study iconic speeches from world leaders, innovators, and thought leaders to understand what makes them effective.",
            imageName: "star.fill",
            accentColor: .orange,
            backgroundColor: .orange.opacity(0.1),
            features: [
                "Library of iconic speeches",
                "Detailed speech breakdowns",
                "Interactive learning modules"
            ],
            animationDuration: 0.8
        ),
        OnboardingPage(
            title: "Track Your Progress",
            description: "Monitor your improvement over time with detailed analytics and personalized insights.",
            imageName: "chart.line.uptrend.xyaxis",
            accentColor: .purple,
            backgroundColor: .purple.opacity(0.1),
            features: [
                "Performance analytics",
                "Progress tracking",
                "Achievement milestones"
            ],
            animationDuration: 0.6
        ),
        OnboardingPage(
            title: "Practice Anywhere",
            description: "Take your practice sessions anywhere with our mobile-first approach and offline capabilities.",
            imageName: "iphone.gen3",
            accentColor: .indigo,
            backgroundColor: .indigo.opacity(0.1),
            features: [
                "Offline practice mode",
                "Cloud sync across devices",
                "Mobile-optimized interface"
            ],
            animationDuration: 0.7
        )
    ]
}

// MARK: - Onboarding View
struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var currentPage = 0
    @State private var isAnimating = false
    @State private var dragOffset: CGFloat = 0
    @State private var showFeatures = false
    
    private var currentTheme: OnboardingPage { OnboardingPage.pages[currentPage] }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Animated Background
                backgroundLayer
                
                VStack(spacing: OnboardingTheme.spacing) {
                    // Skip Button
                    skipButton
                    
                    Spacer()
                    
                    // Icon with Particles
                    iconSection
                    
                    // Content
                    contentSection
                    
                    // Features List
                    featuresSection
                    
                    Spacer()
                    
                    // Navigation
                    navigationSection(geometry: geometry)
                }
                .padding(.top, geometry.safeAreaInsets.top + OnboardingTheme.spacing)
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation.width
                    }
                    .onEnded { value in
                        let threshold = geometry.size.width * 0.2
                        withAnimation(.spring()) {
                            if value.translation.width > threshold && currentPage > 0 {
                                previousPage()
                            } else if value.translation.width < -threshold && currentPage < OnboardingPage.pages.count - 1 {
                                nextPage()
                            }
                            dragOffset = 0
                        }
                    }
            )
        }
        .onChange(of: currentPage) { _ in
            animateTransition()
        }
        .onAppear {
            animateTransition()
        }
    }
    
    // MARK: - View Components
    
    private var backgroundLayer: some View {
        currentTheme.backgroundColor
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: currentPage)
    }
    
    private var skipButton: some View {
        HStack {
            Spacer()
            Button(action: completeOnboarding) {
                Text("Skip")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, OnboardingTheme.spacing)
            }
        }
    }
    
    private var iconSection: some View {
        ZStack {
            Circle()
                .fill(currentTheme.backgroundColor)
                .frame(width: 120, height: 120)
                .shadow(color: OnboardingTheme.shadowColor, radius: 10)
            
            Image(systemName: currentTheme.imageName)
                .font(.system(size: OnboardingTheme.iconSize, weight: .medium))
                .foregroundColor(currentTheme.accentColor)
                .symbolEffect(.bounce, options: .repeat(1).speed(0.7), value: isAnimating)
        }
        .scaleEffect(isAnimating ? 1 : 0.5)
        .opacity(isAnimating ? 1 : 0)
        .rotation3DEffect(.degrees(dragOffset / 20), axis: (x: 0, y: 1, z: 0))
    }
    
    private var contentSection: some View {
        VStack(spacing: OnboardingTheme.spacing) {
            Text(currentTheme.title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top, OnboardingTheme.spacing)
                .offset(y: isAnimating ? 0 : 20)
                .opacity(isAnimating ? 1 : 0)
            
            Text(currentTheme.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, OnboardingTheme.spacing * 2)
                .offset(y: isAnimating ? 0 : 20)
                .opacity(isAnimating ? 1 : 0)
        }
    }
    
    private var featuresSection: some View {
        VStack(spacing: OnboardingTheme.spacing / 2) {
            ForEach(currentTheme.features.indices, id: \.self) { index in
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(currentTheme.accentColor)
                        .offset(x: isAnimating ? 0 : -20)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(.spring().delay(Double(index) * 0.1), value: isAnimating)
                    
                    Text(currentTheme.features[index])
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding(.horizontal, OnboardingTheme.spacing * 2)
            }
        }
    }
    
    private func navigationSection(geometry: GeometryProxy) -> some View {
        VStack(spacing: OnboardingTheme.spacing) {
            // Page Control
            HStack(spacing: 8) {
                ForEach(0..<OnboardingPage.pages.count, id: \.self) { index in
                    Capsule()
                        .fill(index == currentPage ? currentTheme.accentColor : .gray.opacity(0.3))
                        .frame(width: index == currentPage ? 20 : 8, height: 8)
                        .animation(.spring(), value: currentPage)
                }
            }
            
            // Navigation Buttons
            HStack(spacing: OnboardingTheme.spacing) {
                if currentPage > 0 {
                    Button(action: previousPage) {
                        Image(systemName: "arrow.left")
                            .font(.headline)
                            .foregroundColor(currentTheme.accentColor)
                            .frame(width: OnboardingTheme.buttonHeight, height: OnboardingTheme.buttonHeight)
                            .background(OnboardingTheme.lightBackground)
                            .clipShape(Circle())
                            .shadow(color: OnboardingTheme.shadowColor, radius: 5)
                    }
                }
                
                Button(action: currentPage == OnboardingPage.pages.count - 1 ? completeOnboarding : nextPage) {
                    HStack {
                        Text(currentPage == OnboardingPage.pages.count - 1 ? "Get Started" : "Next")
                            .font(.headline)
                        
                        if currentPage < OnboardingPage.pages.count - 1 {
                            Image(systemName: "arrow.right")
                                .font(.headline)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: OnboardingTheme.buttonHeight)
                    .background(currentTheme.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: OnboardingTheme.cornerRadius))
                    .shadow(color: currentTheme.accentColor.opacity(0.5), radius: 5)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(.horizontal, OnboardingTheme.spacing)
            .padding(.bottom, geometry.safeAreaInsets.bottom + OnboardingTheme.spacing)
        }
    }
    
    // MARK: - Helper Functions
    
    private func nextPage() {
        if currentPage < OnboardingPage.pages.count - 1 {
            withAnimation {
                currentPage += 1
            }
        }
    }
    
    private func previousPage() {
        if currentPage > 0 {
            withAnimation {
                currentPage -= 1
            }
        }
    }
    
    private func completeOnboarding() {
        withAnimation {
            hasCompletedOnboarding = true
            dismiss()
        }
    }
    
    private func animateTransition() {
        isAnimating = false
        showFeatures = false
        
        withAnimation(.spring(duration: currentTheme.animationDuration)) {
            isAnimating = true
        }
        
        withAnimation(.spring().delay(0.3)) {
            showFeatures = true
        }
    }
}

// MARK: - Supporting Views
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview {
    OnboardingView()
} 
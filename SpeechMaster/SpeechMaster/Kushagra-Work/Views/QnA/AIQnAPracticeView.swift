import SwiftUI

struct AIQnAPracticeView: View {
    let scriptId: UUID
    let scriptTitle: String
    
    @StateObject private var viewModel = AIQnAViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            if viewModel.isGeneratingQuestions {
                loadingView
            } else if let session = viewModel.session {
                if session.status == .completed {
                    completionView(session: session)
                } else {
                    practiceView(session: session)
                }
            } else {
                errorView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.startNewSession(scriptId: scriptId, scriptTitle: scriptTitle)
        }
        .alert("Error", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Generating Questions...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
    
    private func practiceView(session: AIQnASession) -> some View {
        VStack(spacing: 0) {
            // Progress Bar
            ProgressView(value: session.progress)
                .tint(.blue)
                .padding(.horizontal)
            
            // Question Counter
            Text("Question \(session.currentQuestionIndex + 1) of \(session.questions.count)")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.vertical, 8)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Question Card
                    questionCard(question: session.currentQuestion!)
                    
                    // Live Transcription
                    transcriptionCard
                    
                    // Recording Controls
                    recordingControls
                    
                    // Next Button
                    if !viewModel.transcribedText.isEmpty && !viewModel.isRecording {
                        Button(action: viewModel.nextQuestion) {
                            Text("Next Question")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .transition(.opacity)
                    }
                }
                .padding()
            }
        }
    }
    
    private func questionCard(question: AIGeneratedQuestion) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Question")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(question.question)
                .font(.title3)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var transcriptionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your Answer")
                    .font(.headline)
                
                Spacer()
                
                if viewModel.isRecording {
                    Text("Recording...")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
            }
            
            if viewModel.isRecording {
                // Audio Visualizer
                AudioVisualizerView(level: viewModel.audioLevel)
                    .frame(height: 60)
            }
            
            Text(viewModel.transcribedText)
                .font(.body)
                .foregroundColor(viewModel.transcribedText.isEmpty ? .secondary : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(minHeight: 100)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
        }
    }
    
    private var recordingControls: some View {
        Button(action: {
            if viewModel.isRecording {
                viewModel.stopRecording()
            } else {
                viewModel.startRecording()
            }
        }) {
            Circle()
                .fill(viewModel.isRecording ? Color.red : Color.blue)
                .frame(width: 72, height: 72)
                .overlay(
                    Image(systemName: viewModel.isRecording ? "stop.fill" : "mic.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                )
        }
        .padding()
    }
    
    private func completionView(session: AIQnASession) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Practice Complete!")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Let's review your answers")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Stats Card
                statsCard(session: session)
                
                // Questions Review
                ForEach(session.questions) { question in
                    QuestionReviewCard(question: question)
                }
            }
            .padding()
        }
    }
    
    private func statsCard(session: AIQnASession) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 24) {
                Stat(
                    title: "Questions",
                    value: "\(session.questions.count)",
                    icon: "text.bubble.fill",
                    color: .purple
                )
                
                Stat(
                    title: "Avg. Confidence",
                    value: "\(Int(session.averageConfidence * 100))%",
                    icon: "chart.bar.fill",
                    color: .orange
                )
                
                Stat(
                    title: "Completed",
                    value: formatDate(session.createdAt),
                    icon: "calendar",
                    color: .blue
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Failed to Start Session")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Please try again later")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(action: { dismiss() }) {
                Text("Go Back")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.top, 8)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct QuestionReviewCard: View {
    let question: AIGeneratedQuestion
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Question
            Text(question.question)
                .font(.headline)
            
            if let feedback = question.feedback {
                // Scores
                HStack(spacing: 16) {
                    ScoreView(
                        title: "Similarity",
                        score: feedback.similarityScore,
                        icon: "equal.circle.fill"
                    )
                    
                    ScoreView(
                        title: "Clarity",
                        score: feedback.clarity,
                        icon: "text.bubble.fill"
                    )
                    
                    ScoreView(
                        title: "Completeness",
                        score: feedback.completeness,
                        icon: "checkmark.circle.fill"
                    )
                }
            }
            
            // Answers
            VStack(alignment: .leading, spacing: 12) {
                // Your Answer
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Answer")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(question.userAnswer ?? "No answer provided")
                        .font(.body)
                }
                
                // Suggested Answer
                VStack(alignment: .leading, spacing: 8) {
                    Text("Suggested Answer")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(question.suggestedAnswer)
                        .font(.body)
                }
            }
            
            if let feedback = question.feedback {
                // Feedback
                VStack(alignment: .leading, spacing: 12) {
                    // Strengths
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Strengths")
                            .font(.subheadline)
                            .foregroundColor(.green)
                        
                        ForEach(feedback.strengths, id: \.self) { strength in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(strength)
                                    .font(.subheadline)
                            }
                        }
                    }
                    
                    // Improvements
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Areas for Improvement")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                        
                        ForEach(feedback.improvements, id: \.self) { improvement in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .foregroundColor(.orange)
                                Text(improvement)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

struct ScoreView: View {
    let title: String
    let score: Double
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                Text("\(Int(score * 100))%")
                    .fontWeight(.semibold)
            }
            .foregroundColor(scoreColor)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var scoreColor: Color {
        if score >= 0.8 { return .green }
        if score >= 0.6 { return .orange }
        return .red
    }
}

struct AudioVisualizerView: View {
    let level: Double
    private let barCount = 30
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<barCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.blue.opacity(0.8))
                    .frame(width: 4)
                    .frame(height: height(for: index))
                    .animation(.easeInOut(duration: 0.1), value: level)
            }
        }
    }
    
    private func height(for index: Int) -> CGFloat {
        let progress = Double(index) / Double(barCount)
        let amplitude = sin(progress * .pi) * level
        return max(3, amplitude * 60)
    }
}

#Preview {
    NavigationView {
        AIQnAPracticeView(
            scriptId: UUID(),
            scriptTitle: "Product Launch Presentation"
        )
    }
} 

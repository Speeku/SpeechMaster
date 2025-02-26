//import SwiftUI
//
//struct QnAView: View {
//    @StateObject private var viewModel = QnAViewModel(previewData: true)
//    @Environment(\.dismiss) private var dismiss
//    
//    var body: some View {
//        NavigationView {
//            ZStack {
//                Color(.systemGroupedBackground)
//                    .ignoresSafeArea()
//                
//                if viewModel.sessions.isEmpty {
//                    emptyStateView
//                } else {
//                    ScrollView {
//                        LazyVStack(spacing: 24) {
//                            // Progress Overview
//                            if let currentSession = viewModel.currentSession {
//                                sessionOverviewCard(session: currentSession)
//                            }
//                            
//                            // Session List
//                            sessionsList
//                        }
//                        .padding()
//                    }
//                }
//            }
//            .navigationTitle("Q&A Practice")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: { viewModel.showingNewSessionSheet = true }) {
//                        Image(systemName: "plus")
//                    }
//                }
//            }
//            .sheet(isPresented: $viewModel.showingNewSessionSheet) {
//                NewSessionSheet(viewModel: viewModel)
//            }
//            .sheet(isPresented: $viewModel.showingQuestionSheet) {
//                if let question = viewModel.currentQuestion {
//                    QuestionDetailSheet(
//                        question: question,
//                        isRecording: viewModel.isRecording,
//                        recordingDuration: viewModel.recordingDuration,
//                        audioLevel: viewModel.audioLevel,
//                        onStartRecording: viewModel.startRecording,
//                        onStopRecording: viewModel.stopRecording,
//                        onSave: { updatedQuestion in
//                            viewModel.updateQuestion(updatedQuestion)
//                            viewModel.showingQuestionSheet = false
//                        }
//                    )
//                }
//            }
//        }
//    }
//    
//    private var emptyStateView: some View {
//        VStack(spacing: 16) {
//            Image(systemName: "text.bubble")
//                .font(.system(size: 64))
//                .foregroundColor(.gray)
//            
//            Text("No Q&A Sessions")
//                .font(.title2)
//                .fontWeight(.bold)
//            
//            Text("Start a new session to practice answering questions")
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal)
//            
//            Button(action: { viewModel.showingNewSessionSheet = true }) {
//                Label("New Session", systemImage: "plus")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.blue)
//                    .cornerRadius(12)
//            }
//            .padding(.horizontal, 40)
//            .padding(.top, 8)
//        }
//    }
//    
//    private func sessionOverviewCard(session: QnASession1) -> some View {
//        VStack(spacing: 16) {
//            // Header
//            HStack {
//                VStack(alignment: .leading) {
//                    Text(session.title)
//                        .font(.headline)
//                    Text("In Progress")
//                        .font(.subheadline)
//                        .foregroundColor(.blue)
//                }
//                Spacer()
//                Menu {
//                    Button(action: {}) {
//                        Label("Edit", systemImage: "pencil")
//                    }
//                    Button(action: {}) {
//                        Label("Share", systemImage: "square.and.arrow.up")
//                    }
//                    Button(role: .destructive, action: {}) {
//                        Label("Delete", systemImage: "trash")
//                    }
//                } label: {
//                    Image(systemName: "ellipsis.circle.fill")
//                        .foregroundColor(.secondary)
//                        .font(.title3)
//                }
//            }
//            
//            // Progress Bar
//            ProgressView(value: viewModel.currentProgress)
//                .progressViewStyle(.linear)
//                .tint(.blue)
//            
//            // Stats
//            HStack(spacing: 24) {
//                Stat(
//                    title: "Questions",
//                    value: "\(session.questions.count)",
//                    icon: "text.bubble.fill",
//                    color: .purple
//                )
//                
//                Stat(
//                    title: "Answered",
//                    value: "\(session.questions.filter(\.isAnswered).count)",
//                    icon: "checkmark.circle.fill",
//                    color: .green
//                )
//                
//                Stat(
//                    title: "Confidence",
//                    value: "\(Int(viewModel.averageConfidence * 100))%",
//                    icon: "chart.bar.fill",
//                    color: .orange
//                )
//            }
//        }
//        .padding()
//        .background(Color(.systemBackground))
//        .cornerRadius(16)
//        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
//    }
//    
//    private var sessionsList: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            Text("Questions")
//                .font(.title2)
//                .fontWeight(.bold)
//            
//            ForEach(viewModel.currentSession?.questions ?? []) { question in
//                QnACard(
//                    question: question,
//                    isActive: viewModel.currentQuestion?.id == question.id,
//                    onTap: {
//                        viewModel.currentQuestion = question
//                        viewModel.showingQuestionSheet = true
//                    }
//                )
//            }
//        }
//    }
//}
//

import SwiftUICore
struct Stat: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 24))
            
            Text(value)
                .font(.headline)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
//
//struct NewSessionSheet: View {
//    @ObservedObject var viewModel: QnAViewModel
//    @Environment(\.dismiss) private var dismiss
//    @State private var title = ""
//    @State private var questions: [String] = [""]
//    
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Session Details")) {
//                    TextField("Session Title", text: $title)
//                }
//                
//                Section(
//                    header: Text("Questions"),
//                    footer: Text("Add all the questions you want to practice")
//                ) {
//                    ForEach(questions.indices, id: \.self) { index in
//                        TextField("Question \(index + 1)", text: $questions[index])
//                    }
//                    .onDelete { indexSet in
//                        questions.remove(atOffsets: indexSet)
//                    }
//                    
//                    Button(action: { questions.append("") }) {
//                        Label("Add Question", systemImage: "plus")
//                    }
//                }
//            }
//            .navigationTitle("New Session")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Cancel") { dismiss() }
//                }
//                ToolbarItem(placement: .confirmationAction) {
//                    Button("Create") {
//                        let newQuestions = questions
//                            .filter { !$0.isEmpty }
//                            .map { questionText in
//                                Question(
//                                    id: UUID(),
//                                    text: questionText,
//                                    answer: nil,
//                                    isAnswered: false,
//                                    confidence: 0,
//                                    feedback: [],
//                                    duration: nil
//                                )
//                            }
//                        
//                        viewModel.createNewSession(
//                            title: title,
//                            scriptId: UUID(), // TODO: Pass actual script ID
//                            questions: newQuestions
//                        )
//                        dismiss()
//                    }
//                    .disabled(title.isEmpty || questions.allSatisfy { $0.isEmpty })
//                }
//            }
//        }
//    }
//}
//
//struct QuestionDetailSheet: View {
//    let question: Question
//    let isRecording: Bool
//    let recordingDuration: TimeInterval
//    let audioLevel: Double
//    let onStartRecording: () -> Void
//    let onStopRecording: () -> Void
//    let onSave: (Question) -> Void
//    
//    @State private var answer: String = ""
//    @Environment(\.dismiss) private var dismiss
//    
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                VStack(spacing: 24) {
//                    // Question Card
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Question")
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//                        Text(question.text)
//                            .font(.title3)
//                            .fontWeight(.semibold)
//                    }
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding()
//                    .background(Color(.secondarySystemBackground))
//                    .cornerRadius(12)
//                    
//                    // Recording Section
//                    VStack(spacing: 16) {
//                        // Audio Visualizer
//                        AudioVisualizerView(level: audioLevel)
//                            .frame(height: 60)
//                            .padding(.horizontal)
//                        
//                        // Timer
//                        Text(formatDuration(recordingDuration))
//                            .font(.system(.title, design: .monospaced))
//                            .foregroundColor(.secondary)
//                        
//                        // Record Button
//                        Button(action: {
//                            if isRecording {
//                                onStopRecording()
//                            } else {
//                                onStartRecording()
//                            }
//                        }) {
//                            Circle()
//                                .fill(isRecording ? Color.red : Color.blue)
//                                .frame(width: 72, height: 72)
//                                .overlay(
//                                    Image(systemName: isRecording ? "stop.fill" : "mic.fill")
//                                        .font(.title2)
//                                        .foregroundColor(.white)
//                                )
//                        }
//                    }
//                    
//                    // Answer Section
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Your Answer")
//                            .font(.headline)
//                        
//                        TextEditor(text: $answer)
//                            .frame(minHeight: 100)
//                            .padding(8)
//                            .background(Color(.secondarySystemBackground))
//                            .cornerRadius(8)
//                    }
//                }
//                .padding()
//            }
//            .navigationTitle("Practice Question")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Cancel") { dismiss() }
//                }
//                ToolbarItem(placement: .confirmationAction) {
//                    Button("Save") {
//                        var updatedQuestion = question
//                        updatedQuestion.answer = answer
//                        updatedQuestion.isAnswered = true
//                        onSave(updatedQuestion)
//                    }
//                    .disabled(answer.isEmpty)
//                }
//            }
//        }
//    }
//    
//    private func formatDuration(_ duration: TimeInterval) -> String {
//        let minutes = Int(duration) / 60
//        let seconds = Int(duration) % 60
//        return String(format: "%02d:%02d", minutes, seconds)
//    }
//}
//
//struct AudioVisualizerView: View {
//    let level: Double
//    private let barCount = 30
//    
//    var body: some View {
//        HStack(spacing: 2) {
//            ForEach(0..<barCount, id: \.self) { index in
//                RoundedRectangle(cornerRadius: 2)
//                    .fill(Color.blue.opacity(0.8))
//                    .frame(width: 4)
//                    .frame(height: height(for: index))
//                    .animation(.easeInOut(duration: 0.1), value: level)
//            }
//        }
//    }
//    
//    private func height(for index: Int) -> CGFloat {
//        let progress = Double(index) / Double(barCount)
//        let amplitude = sin(progress * .pi) * level
//        return max(3, amplitude * 60)
//    }
//}
//
//#Preview {
//    QnAView()
//} 

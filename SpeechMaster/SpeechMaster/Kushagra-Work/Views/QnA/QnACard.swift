//import SwiftUI
//
//struct QnACard: View {
//    let question: Question
//    let isActive: Bool
//    let onTap: () -> Void
//    
//    private var backgroundColor: Color {
//        isActive ? Color(.systemBackground) : Color(.secondarySystemBackground)
//    }
//    
//    var body: some View {
//        Button(action: onTap) {
//            VStack(alignment: .leading, spacing: 16) {
//                // Question Header
//                HStack {
//                    Text(question.text)
//                        .font(.headline)
//                        .foregroundColor(.primary)
//                    Spacer()
//                    if question.isAnswered {
//                        Image(systemName: "checkmark.circle.fill")
//                            .foregroundColor(.green)
//                    }
//                }
//                
//                if question.isAnswered {
//                    // Answer Section
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Answer")
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//                        
//                        Text(question.answer ?? "")
//                            .font(.body)
//                            .foregroundColor(.primary)
//                    }
//                    
//                    // Metrics
//                    HStack(spacing: 16) {
//                        // Confidence Score
//                        HStack(spacing: 4) {
//                            Image(systemName: "chart.bar.fill")
//                                .foregroundColor(.blue)
//                            Text("\(Int(question.confidence * 100))%")
//                                .font(.subheadline)
//                                .foregroundColor(.secondary)
//                        }
//                        
//                        // Duration
//                        if let duration = question.duration {
//                            HStack(spacing: 4) {
//                                Image(systemName: "clock.fill")
//                                    .foregroundColor(.orange)
//                                Text(formatDuration(duration))
//                                    .font(.subheadline)
//                                    .foregroundColor(.secondary)
//                            }
//                        }
//                        
//                        // Feedback Count
//                        if !question.feedback.isEmpty {
//                            HStack(spacing: 4) {
//                                Image(systemName: "text.bubble.fill")
//                                    .foregroundColor(.purple)
//                                Text("\(question.feedback.count)")
//                                    .font(.subheadline)
//                                    .foregroundColor(.secondary)
//                            }
//                        }
//                    }
//                    
//                    // Feedback Preview
//                    if !question.feedback.isEmpty {
//                        VStack(alignment: .leading, spacing: 8) {
//                            ForEach(question.feedback.prefix(2)) { feedback in
//                                FeedbackBadge(feedback: feedback)
//                            }
//                        }
//                    }
//                }
//            }
//            .padding()
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .background(backgroundColor)
//            .clipShape(RoundedRectangle(cornerRadius: 16))
//            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
//            .overlay(
//                RoundedRectangle(cornerRadius: 16)
//                    .stroke(isActive ? Color.blue : Color.clear, lineWidth: 2)
//            )
//        }
//        .buttonStyle(PlainButtonStyle())
//    }
//    
//    private func formatDuration(_ duration: TimeInterval) -> String {
//        let minutes = Int(duration) / 60
//        let seconds = Int(duration) % 60
//        return String(format: "%d:%02d", minutes, seconds)
//    }
//}
//
//struct FeedbackBadge: View {
//    let feedback: Question.Feedback
//    
//    var body: some View {
//        HStack(spacing: 6) {
//            Circle()
//                .fill(Color(feedback.severity.color))
//                .frame(width: 8, height: 8)
//            
//            Text(feedback.message)
//                .font(.caption)
//                .foregroundColor(.secondary)
//                .lineLimit(1)
//            
//            Spacer()
//            
//            Text(feedback.category.rawValue)
//                .font(.caption2)
//                .foregroundColor(.secondary)
//                .padding(.horizontal, 6)
//                .padding(.vertical, 2)
//                .background(Color(.tertiarySystemBackground))
//                .clipShape(Capsule())
//        }
//    }
//}
//
//// Preview
//struct QnACard_Previews: PreviewProvider {
//    static var previews: some View {
//        ScrollView {
//            VStack(spacing: 16) {
//                QnACard(
//                    question: QnASession.sampleData[0].questions[0],
//                    isActive: true,
//                    onTap: {}
//                )
//                
//                QnACard(
//                    question: QnASession.sampleData[0].questions[1],
//                    isActive: false,
//                    onTap: {}
//                )
//            }
//            .padding()
//        }
//        .background(Color(.systemGroupedBackground))
//        .previewLayout(.sizeThatFits)
//    }
//} 

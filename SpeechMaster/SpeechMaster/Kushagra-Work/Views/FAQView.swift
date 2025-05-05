import SwiftUI

struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
    var isExpanded: Bool = false
}

struct FAQView: View {
    @State private var faqs = [
        FAQItem(question: "What is SpeechMaster?", 
                answer: "SpeechMaster is an app designed to help you practice and improve your public speaking skills through script creation, practice sessions, and performance analysis."),
        
        FAQItem(question: "How do I create a new speech script?", 
                answer: "Go to the Scripts tab, tap the '+' button, enter your script title and content, then save it. You can edit it anytime later."),
        
        FAQItem(question: "Can I practice with existing speeches?", 
                answer: "Yes! SpeechMaster includes a collection of famous speeches that you can use to practice your delivery skills."),
        
        FAQItem(question: "How does the Q&A preparation feature work?", 
                answer: "The Q&A feature generates likely questions based on your script content, allowing you to practice answering questions related to your speech."),
        
        FAQItem(question: "What metrics does SpeechMaster track?", 
                answer: "SpeechMaster tracks metrics like speaking rate (words per minute), filler word usage, pronunciation errors, and script adherence."),
        
        FAQItem(question: "Can I record my practice sessions?", 
                answer: "Yes, you can record both audio and video of your practice sessions for later review and analysis."),
        
        FAQItem(question: "How do I view my performance history?", 
                answer: "Go to your script details and check the 'Sessions' tab to see all your previous practice sessions and their performance metrics."),
        
        FAQItem(question: "Is my data secure?", 
                answer: "Yes, SpeechMaster uses secure authentication and storage. Your scripts and recordings are private and only accessible with your login credentials."),
        
        FAQItem(question: "Can I use SpeechMaster offline?", 
                answer: "Some features require an internet connection, but you can access your saved scripts and previous recordings offline."),
        
        FAQItem(question: "How do I provide feedback or report issues?", 
                answer: "You can contact us through the Help Center in the Support section, or email us directly at support@speechmaster.app.")
    ]
    
    var body: some View {
        List {
            ForEach($faqs) { $faq in
                VStack(alignment: .leading, spacing: 10) {
                    Button(action: {
                        faq.isExpanded.toggle()
                    }) {
                        HStack {
                            Text(faq.question)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: faq.isExpanded ? "chevron.up" : "chevron.down")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    if faq.isExpanded {
                        Text(faq.answer)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.top, 5)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("FAQs")
    }
}

#Preview {
    NavigationView {
        FAQView()
    }
} 
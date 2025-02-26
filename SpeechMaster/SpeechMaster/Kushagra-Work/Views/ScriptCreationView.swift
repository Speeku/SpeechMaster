import SwiftUI

struct KeyNoteOptionsStoryboardView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        // Get reference to your storyboard
     let storyboard = UIStoryboard(name: "PerformanceScreen", bundle: nil)
        
        // Instantiate the desired view controller
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "SelectingKeynoteVC") as? SelectingKeynoteVC
     else {
            fatalError("Could not instantiate ViewController")
        }
     
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
            
        }
     // Update the view controller if needed
}

struct TextEditorToolbar: View {
    @Binding var text: String
    @Binding var isBold: Bool
    @Binding var isItalic: Bool
    @Binding var fontSize: CGFloat
    @Binding var alignment: TextAlignment
    @Binding var selectedFont: String
    @State private var showingColorPicker = false
    @Binding var textColor: Color
    
    let availableFonts = ["SF Pro", "Helvetica Neue", "Times New Roman", "Arial"]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                // Font Picker
                Menu {
                    ForEach(availableFonts, id: \.self) { font in
                        Button(action: { selectedFont = font }) {
                            HStack {
                                Text(font)
                                if selectedFont == font {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Label(selectedFont, systemImage: "textformat")
                        .foregroundColor(.primary)
                }
                
                Divider()
                
                // Font Size Controls
                HStack(spacing: 8) {
                    Button(action: { if fontSize > 8 { fontSize -= 2 } }) {
                        Image(systemName: "minus.circle")
                    }
                    
                    Text("\(Int(fontSize))")
                        .frame(width: 30)
                        .monospacedDigit()
                    
                    Button(action: { if fontSize < 72 { fontSize += 2 } }) {
                        Image(systemName: "plus.circle")
                    }
                }
                
                Divider()
                
                // Text Style Controls
                HStack(spacing: 12) {
                    Button(action: { isBold.toggle() }) {
                        Image(systemName: "bold")
                            .foregroundColor(isBold ? .blue : .primary)
                    }
                    
                    Button(action: { isItalic.toggle() }) {
                        Image(systemName: "italic")
                            .foregroundColor(isItalic ? .blue : .primary)
                    }
                    
                    Button(action: { showingColorPicker.toggle() }) {
                        Image(systemName: "paintbrush.fill")
                            .foregroundColor(textColor)
                    }
                    .popover(isPresented: $showingColorPicker) {
                        ColorPicker("Text Color", selection: $textColor)
                            .padding()
                    }
                }
                
                Divider()
                
                // Alignment Controls
                HStack(spacing: 12) {
                    Button(action: { alignment = .leading }) {
                        Image(systemName: "text.alignleft")
                            .foregroundColor(alignment == .leading ? .blue : .primary)
                    }
                    
                    Button(action: { alignment = .center }) {
                        Image(systemName: "text.aligncenter")
                            .foregroundColor(alignment == .center ? .blue : .primary)
                    }
                    
                    Button(action: { alignment = .trailing }) {
                        Image(systemName: "text.alignright")
                            .foregroundColor(alignment == .trailing ? .blue : .primary)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct CustomTextEditor: View {
    @Binding var text: String
    @Binding var isBold: Bool
    @Binding var isItalic: Bool
    @Binding var isUnderline: Bool
    @Binding var fontSize: CGFloat
    @Binding var selectedFont: String
    @Binding var textColor: Color
    @Binding var alignment: TextAlignment
    
    var body: some View {
        TextEditor(text: $text)
            .font(.custom(selectedFont, size: fontSize))
            .fontWeight(isBold ? .bold : .regular)
            .italic(isItalic)
            .underline(isUnderline)
            .foregroundColor(textColor)
            .multilineTextAlignment(alignment)
            .scrollContentBackground(.hidden)
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray4), lineWidth: 0.5)
            )
    }
}

struct CustomAlertView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Binding var isPresented: Bool
    @Binding var scriptName: String
    let onSave: (String) -> Void
    @FocusState private var isTextFieldFocused: Bool
    @State private var showError = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Alert Header
                HStack {
                    Image(systemName: "doc.text")
                        .font(.title2)
                Text("Save Script")
                    .font(.headline)
                }
                
                // Text Field
                TextField("Script Name", text: $scriptName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($isTextFieldFocused)
                
                if showError {
                    Text("Please enter a script name")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                // Buttons
                HStack(spacing: 15) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Save") {
                        if scriptName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            showError = true
                            return
                        }
                        onSave(scriptName)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 10)
            .padding(.horizontal, 40)
        }
        .onAppear {
            isTextFieldFocused = true
        }
    }
}

// Add these new view components before the ScriptCreationView
private struct FontMenuButton: View {
    let selectedFont: String
    let availableFonts: [String]
    let onFontSelected: (String) -> Void
    
    var body: some View {
        Menu {
            ForEach(availableFonts, id: \.self) { font in
                Button(action: { onFontSelected(font) }) {
                    HStack {
                        Text(font)
                            .font(.custom(font, size: 17))
                        if selectedFont == font {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Label(selectedFont, systemImage: "textformat")
                .labelStyle(.iconOnly)
                .font(.system(size: 17))
        }
    }
}

private struct FontSizeControl: View {
    let fontSize: CGFloat
    let onIncrease: () -> Void
    let onDecrease: () -> Void
    
    var body: some View {
        HStack {
            Text("\(Int(fontSize))")
                .frame(width: 30)
                .font(.system(size: 15))
            VStack(spacing: 2) {
                Button(action: onIncrease) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.primary)
                }
                Button(action: onDecrease) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.primary)
                }
            }
            .frame(width: 20)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(Color(.systemGray6))
        .cornerRadius(6)
    }
}

struct StyleControls: View {
    @Binding var isBold: Bool
    @Binding var isItalic: Bool
    @Binding var isUnderline: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: { isBold.toggle() }) {
                Image(systemName: "bold")
                    .foregroundColor(isBold ? .blue : .primary)
            }
            
            Button(action: { isItalic.toggle() }) {
                Image(systemName: "italic")
                    .foregroundColor(isItalic ? .blue : .primary)
            }
            
            Button(action: { isUnderline.toggle() }) {
                Image(systemName: "underline")
                    .foregroundColor(isUnderline ? .blue : .primary)
            }
        }
    }
}

struct TypingAnimationView: View {
    let text: String
    @State private var displayedText = ""
    @State private var currentIndex = 0
    
    var body: some View {
        Text(displayedText)
            .font(.system(.body, design: .monospaced))
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
            .onAppear {
                startTypingAnimation()
            }
    }
    
    private func startTypingAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if currentIndex < text.count {
                let index = text.index(text.startIndex, offsetBy: currentIndex)
                displayedText += String(text[index])
                currentIndex += 1
            } else {
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    currentIndex = 0
                    displayedText = ""
                    startTypingAnimation()
                }
            }
        }
    }
}

struct GenerationStageView: View {
    let stage: String
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Group {
                if isActive {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .frame(width: 16, height: 16)
            
            Text(stage)
                .font(.subheadline)
                .foregroundColor(isActive ? .primary : .secondary)
                .lineLimit(1)
        }
    }
}

struct AIGenerationLoadingView: View {
    @Binding var currentStage: Int
    let stages = [
        "Analyzing prompt...",
        "Structuring content...",
        "Generating script...",
        "Refining output..."
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            // Progress Ring Container
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.2), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: CGFloat(currentStage) / CGFloat(stages.count))
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.6), value: currentStage)
                
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
            }
            .frame(width: 80, height: 80)
            
            // Typing Animation Container
            TypingAnimationView(text: "Creating your script...")
                .frame(height: 20)
                .padding(.vertical, 8)
            
            // Generation Stages Container
            VStack(alignment: .leading, spacing: 12) {
                ForEach(0..<stages.count, id: \.self) { index in
                    GenerationStageView(
                        stage: stages[index],
                        isActive: index == currentStage
                    )
                    .frame(height: 24)
                }
            }
            .frame(width: 250)
        }
        .frame(width: 300, height: 300)
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 20)
    }
}

struct ScriptCreationView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Text Editor State
    @State private var scriptText = ""
    @State private var showingSaveAlert = false
    @State private var showingCancelAlert = false
    @State private var showingClearAlert = false
    @State private var sessionName = ""
    
    // Text Formatting State
    @State private var isBold = false
    @State private var isItalic = false
    @State private var isUnderline = false
    @State private var fontSize: CGFloat = 16
    @State private var selectedFont = "SF Pro"
    @State private var textColor: Color = .primary
    @State private var alignment: TextAlignment = .leading
    
    // UI State
    @State private var showingWordCount = true
    @FocusState private var isEditorFocused: Bool
    @State private var isGeneratingAI = false
    @State private var showingAIError = false
    @State private var aiErrorMessage = ""
    @State private var showingAIPrompt = false
    @State private var aiPrompt = ""
    @State private var generationStage = 0
    
    private let availableFonts = ["SF Pro", "Helvetica Neue", "Georgia", "Times New Roman"]
    private let fontSizes: [CGFloat] = [12, 14, 16, 18, 20, 24, 28, 32]
    
    private var wordCount: Int {
        scriptText.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
    }
    
    private var characterCount: Int {
        scriptText.count
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                FormattingToolbar(
                    selectedFont: $selectedFont,
                    fontSize: $fontSize,
                    isBold: $isBold,
                    isItalic: $isItalic,
                    isUnderline: $isUnderline,
                    alignment: $alignment,
                    textColor: $textColor,
                    showingClearAlert: $showingClearAlert,
                    availableFonts: availableFonts
                )
                
                TextEditor(text: $scriptText)
                    .font(.custom(selectedFont, size: fontSize))
                    .fontWeight(isBold ? .bold : .regular)
                    .italic(isItalic)
                    .underline(isUnderline)
                    .foregroundColor(textColor)
                    .multilineTextAlignment(alignment)
                    .focused($isEditorFocused)
                    .scrollContentBackground(.hidden)
                    .background(Color(.systemBackground))
                    .padding(.horizontal)
                    .overlay(alignment: .bottomTrailing) {
                        if showingWordCount {
                            WordCountBadge(wordCount: wordCount, characterCount: characterCount)
                        }
                    }
            }
            
            if isGeneratingAI {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                AIGenerationLoadingView(currentStage: $generationStage)
                    .transition(.scale.combined(with: .opacity))
            }
            
            // Floating Generate Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showingAIPrompt = true }) {
                        HStack(spacing: 8) {
                            if isGeneratingAI {
                                ProgressView()
                                    .tint(.white)
                            }
                            Image(systemName: "wand.and.stars")
                                .imageScale(.large)
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .shadow(radius: 5)
                    }
                    .disabled(isGeneratingAI)
                    .padding()
                }
            }.padding(.bottom, 30)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    if !scriptText.isEmpty {
                        showingCancelAlert = true
                    } else {
                        dismiss()
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    showingSaveAlert = true
                }
                .disabled(scriptText.isEmpty)
            }
        }
        .alert("Discard Changes?", isPresented: $showingCancelAlert) {
            Button("Discard", role: .destructive) {
                dismiss()
            }
            Button("Keep Editing", role: .cancel) {}
        } message: {
            Text("Are you sure you want to discard your changes?")
        }
        .alert("Save Script", isPresented: $showingSaveAlert) {
            TextField("Script Name", text: $sessionName)
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                if !sessionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    saveScript()
                }
            }
        } message: {
            Text("Enter a name for your script.")
        }
        .alert("Clear Text", isPresented: $showingClearAlert) {
            Button("Clear", role: .destructive) {
                scriptText = ""
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to clear all text? This cannot be undone.")
        }
        .alert("Error", isPresented: $showingAIError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(aiErrorMessage)
        }
        .alert("Generate with AI", isPresented: $showingAIPrompt) {
            TextField("What should the script be about?", text: $aiPrompt)
            Button("Cancel", role: .cancel) {
                aiPrompt = ""
            }
            Button("Generate") {
                if !aiPrompt.isEmpty {
                    Task {
                        await generateAIContent(aiPrompt)
                        aiPrompt = ""
                    }
                }
            }
        } message: {
            Text("Describe what you'd like the AI to generate")
        }
    }
    
    private func saveScript() {
        let newScript = Script(
            id: UUID(),
            title: sessionName,
            scriptText: scriptText,
            createdAt: Date(),
            isPinned: false
        )
        viewModel.addScript(newScript)
        viewModel.uploadedScriptText = scriptText
        viewModel.currentScriptID = newScript.id
        viewModel.navigateToPiyushScreen = true
    }
    
    private func generateAIContent(_ prompt: String) async {
        guard !prompt.isEmpty else { return }
        
        isGeneratingAI = true
        generationStage = 0
        
        do {
            // Simulate different stages of generation
            for stage in 1...4 {
                try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds per stage
                generationStage = stage - 1
            }
            
            let generatedText = try await viewModel.generateScript(prompt: prompt)
            DispatchQueue.main.async {
                self.scriptText = generatedText
                self.isGeneratingAI = false
                self.generationStage = 0
            }
        } catch {
            DispatchQueue.main.async {
                let message: String
                
                if error.localizedDescription.contains("429") {
                    message = "Rate limit exceeded. Please try again later."
                } else if error.localizedDescription.contains("400") {
                    message = "Invalid request. Please check your input."
                } else if error.localizedDescription.contains("500") {
                    message = "Internal server error. Please try again."
                } else {
                    message = "An error occurred: \(error.localizedDescription)"
                }
                
                self.aiErrorMessage = message
                self.showingAIError = true
                self.isGeneratingAI = false
                self.generationStage = 0
            }
        }
    }
}

struct FormattingToolbar: View {
    @Binding var selectedFont: String
    @Binding var fontSize: CGFloat
    @Binding var isBold: Bool
    @Binding var isItalic: Bool
    @Binding var isUnderline: Bool
    @Binding var alignment: TextAlignment
    @Binding var textColor: Color
    @Binding var showingClearAlert: Bool
    let availableFonts: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                // Font Menu
                Menu {
                    ForEach(availableFonts, id: \.self) { font in
                        Button(action: { selectedFont = font }) {
                            HStack {
                                Text(font)
                                    .font(.custom(font, size: 17))
                                if selectedFont == font {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "textformat")
                }
                
                // Font Size Control
                HStack {
                    Text("\(Int(fontSize))")
                        .frame(width: 30)
                        .font(.system(size: 15))
                    VStack(spacing: 2) {
                        Button(action: { fontSize = min(fontSize + 2, 32) }) {
                            Image(systemName: "chevron.up")
                                .font(.system(size: 10, weight: .bold))
                        }
                        Button(action: { fontSize = max(fontSize - 2, 12) }) {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10, weight: .bold))
                        }
                    }
                    .frame(width: 20)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color(.systemGray6))
                .cornerRadius(6)
                
                // Style Buttons
                StyleControls(isBold: $isBold, isItalic: $isItalic, isUnderline: $isUnderline)
                
                // Alignment Buttons
                AlignmentControls(alignment: $alignment)
                
                // Color Picker
                ColorPicker("", selection: $textColor)
                    .labelsHidden()
                
                // Clear Button
                Button(action: { showingClearAlert = true }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.systemGray4))
                .opacity(0.5),
            alignment: .bottom
        )
    }
}

struct WordCountBadge: View {
    let wordCount: Int
    let characterCount: Int
    
    var body: some View {
        HStack(spacing: 12) {
            Label("\(wordCount) words", systemImage: "text.word.spacing")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Label("\(characterCount) characters", systemImage: "character.textbox")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(.systemGray6).opacity(0.9))
        .cornerRadius(6)
        .padding(12)
    }
}

struct AlignmentControls: View {
    @Binding var alignment: TextAlignment
    
    var body: some View {
        Group {
            Button(action: { alignment = .leading }) {
                Image(systemName: "text.alignleft")
                    .foregroundColor(alignment == .leading ? .blue : .primary)
            }
            
            Button(action: { alignment = .center }) {
                Image(systemName: "text.aligncenter")
                    .foregroundColor(alignment == .center ? .blue : .primary)
            }
            
            Button(action: { alignment = .trailing }) {
                Image(systemName: "text.alignright")
                    .foregroundColor(alignment == .trailing ? .blue : .primary)
            }
        }
    }
}

#Preview {
    NavigationView {
        ScriptCreationView(viewModel: HomeViewModel.shared)
    }
}

// Add this extension to help with font traits
extension UIFont {
    func withTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont? {
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else { return nil }
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}

// Add these extensions to support formatting attributes
extension NSAttributedString.Key {
    static let bold = NSAttributedString.Key("bold")
    static let italic = NSAttributedString.Key("italic")
}


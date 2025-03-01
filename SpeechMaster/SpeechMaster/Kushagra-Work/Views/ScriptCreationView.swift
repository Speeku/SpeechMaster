import SwiftUI
import GoogleGenerativeAI

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
                /*HStack(spacing: 12) {
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
                }*/
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

struct FormattingToolbar: View {
    @Binding var fontSize: CGFloat
    @Binding var isBold: Bool
    @Binding var textColor: Color
    @Binding var showingClearAlert: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Toolbar
            HStack(spacing: 20) {
                // Font Size Control with modern design
                HStack(spacing: 8) {
                    Text("\(Int(fontSize))")
                        .frame(width: 28)
                        .font(.system(size: 15, weight: .medium))
                    
                    VStack(spacing: 4) {
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
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                Divider()
                    .frame(height: 20)
                
                // Bold Button
                Button(action: { isBold.toggle() }) {
                    Image(systemName: "bold")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isBold ? .blue : .primary)
                        .frame(width: 32, height: 32)
                        .background(isBold ? Color.blue.opacity(0.1) : Color.clear)
                        .cornerRadius(6)
                }
                
                Divider()
                    .frame(height: 20)
                
                // Color Picker with custom design
                ColorPicker("", selection: $textColor)
                    .labelsHidden()
                    .frame(width: 32, height: 32)
                
                Divider()
                    .frame(height: 20)
                
                // Delete Button
                Button(action: { showingClearAlert = true }) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                        .frame(width: 32, height: 32)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            
            Divider()
        }
    }
}

struct WordCountBadge: View {
    let wordCount: Int
    let characterCount: Int
    
    var body: some View {
        HStack(spacing: 8) {
            Text("\(wordCount) words")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
            
            Text("•")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            
            Text("\(characterCount) characters")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(.systemGray6).opacity(0.8))
        .cornerRadius(6)
    }
}

struct GlowingTextField: View {
    @Binding var text: String
    @Binding var isVisible: Bool
    let onSubmit: () -> Void
    @State private var isBlueGlow = true
    @State private var shadowRadius: CGFloat = 20
    @State private var shadowOpacity: CGFloat = 0.8
    @FocusState private var isFocused: Bool
    @State private var keyboardHeight: CGFloat = 0
    @State private var isHovered = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Blurred background
                Color.black
                    .opacity(0.3)
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isVisible = false
                        text = ""
                    }
                
                VStack {
                    Spacer()
                        .frame(minHeight: geometry.size.height * 0.8)
                    
                    // Text field container
                    HStack(spacing: 12) {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                            .padding(.leading, 16)
                        
                        TextField("Describe Your Script", text: $text)
                            .font(.system(size: 16))
                            .padding(.vertical, 16)
                            .focused($isFocused)
                            .submitLabel(.send)
                            .textInputAutocapitalization(.sentences)
                        
                        Button(action: onSubmit) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(
                                    Group {
                                        if text.isEmpty {
                                            Circle().fill(Color.gray)
                                        } else {
                                            Circle().fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                        }
                                    }
                                )
                                .scaleEffect(isHovered ? 1.1 : 1.0)
                                .animation(.spring(response: 0.3), value: isHovered)
                        }
                        .disabled(text.isEmpty)
                        .onHover { hovering in
                            isHovered = hovering && !text.isEmpty
                        }
                        .padding(.trailing, 16)
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 0.5)
                    )
                    .shadow(color: isBlueGlow ? .blue.opacity(shadowOpacity) : .pink.opacity(shadowOpacity),
                            radius: shadowRadius,
                            x: 0,
                            y: 0)
                    .padding(.horizontal, 16)
                    .padding(.bottom, keyboardHeight > 0 ? keyboardHeight + 10 : geometry.safeAreaInsets.bottom + 8)
                    
                    Spacer()
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isVisible)
            .onAppear {
                isFocused = true
                startGlowAnimation()
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                    if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                        keyboardHeight = keyboardFrame.height
                    }
                }
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    keyboardHeight = 0
                }
            }
        }
    }
    
    private func startGlowAnimation() {
        let timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 1.0)) {
                isBlueGlow.toggle()
                shadowRadius = 25
                shadowOpacity = 0.9
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        shadowRadius = 20
                        shadowOpacity = 0.8
                    }
                }
            }
        }
        
        // Start first animation immediately
        withAnimation(.easeInOut(duration: 1.0)) {
            shadowRadius = 25
            shadowOpacity = 0.9
        }
        
        // Store timer in ViewState to prevent it from being deallocated
        objc_setAssociatedObject(self, "timer", timer, .OBJC_ASSOCIATION_RETAIN)
    }
}

struct PromptInputView: View {
    @Binding var promptText: String
    let onGenerate: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Generate Script")
                .font(.headline)
            
            TextEditor(text: $promptText)
                .frame(height: 120)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 0.5)
                )
            
            Text("What would you like to create a script about?")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
//            HStack(spacing: 100) {
//                Button("Cancel", role: .cancel, action: onCancel)
//                    .buttonStyle(.bordered)
//                
//                Button("Generate", action: onGenerate)
//                    .buttonStyle(.borderedProminent)
//                    .disabled(promptText.isEmpty)
//            }
        }
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
    @State private var fontSize: CGFloat = 16
    @State private var textColor: Color = .primary
    
    // AI Generation State
    @State private var showingPromptInput = false
    @State private var promptText = ""
    @State private var isGenerating = false
    @State private var currentStage = 0
    @State private var showingGenerationError = false
    @State private var generationError = ""
    private let model = GenerativeModel(name: "models/gemini-1.5-pro-001", apiKey: APIKey.default)
    
    // UI State
    @FocusState private var isEditorFocused: Bool
    @State private var textStorage = NSTextStorage()
    
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
                    fontSize: $fontSize,
                    isBold: $isBold,
                    textColor: $textColor,
                    showingClearAlert: $showingClearAlert
                )
                
                // Word Count Badge positioned below toolbar
                HStack {
                    Spacer()
                    WordCountBadge(wordCount: wordCount, characterCount: characterCount)
                        .padding(.trailing, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 12)
                }
                
                // Custom Text Editor using UIViewRepresentable
                CustomTextView(text: $scriptText, isBold: $isBold, fontSize: $fontSize, textColor: $textColor)
                    .padding(.horizontal)
            }
            
            // Floating AI Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { 
                        withAnimation {
                            showingPromptInput.toggle()
                            if !showingPromptInput {
                                promptText = ""
                            }
                        }
                    }) {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                Circle()
                                    .fill(Color.blue)
                                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
                            )
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
            
            // AI Generation Loading View
            if isGenerating {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                AIGenerationLoadingView(currentStage: $currentStage)
            }
            
            // Glowing Text Field
            if showingPromptInput {
                GlowingTextField(
                    text: $promptText,
                    isVisible: $showingPromptInput,
                    onSubmit: {
                        if !promptText.isEmpty {
                            showingPromptInput = false
                            generateScript()
                        }
                    }
                )
            }
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
            Button("Discard", role: .destructive) { dismiss() }
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
        .alert("Generation Error", isPresented: $showingGenerationError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(generationError)
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
    
    private func generateScript() {
        isGenerating = true
        currentStage = 0
        
        Task {
            do {
                let promptText = """
                You are a professional speech writer. Create a well-structured presentation script that is:
                1. Clear and engagin
                2. Includes natural transitions
                3. Has a strong opening and conclusion
                4. Uses appropriate pacing for verbal delivery
                5. generate it like a essay no hiphens and colens at all in one flow
                Create a presentation script about: \(self.promptText)
                
                
                """
                

                
                // Create a chat session
                let chat = model.startChat()
                
                // Update stages
                await MainActor.run {
                    currentStage = 1
                }
                
                // Generate content
                let response = try await chat.sendMessage(promptText)
                
                await MainActor.run {
                    currentStage = 2
                }
                
                if let responseText = response.text {
                    // Final stage and update UI
                    await MainActor.run {
                        currentStage = 3
                        scriptText = responseText
                        isGenerating = false
                        self.promptText = ""
                    }
                } else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to generate response"])
                }
            } catch {
                await MainActor.run {
                    isGenerating = false
                    generationError = "Failed to generate script: \(error.localizedDescription)"
                    showingGenerationError = true
                }
            }
        }
    }
}

struct CustomTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var isBold: Bool
    @Binding var fontSize: CGFloat
    @Binding var textColor: Color
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = .systemFont(ofSize: fontSize)
        textView.backgroundColor = .clear
        textView.textColor = UIColor(textColor)
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.text = text
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        // Update text if it changed externally
        if uiView.text != text {
            uiView.text = text
        }
        
        // Update formatting
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize, weight: isBold ? .bold : .regular),
            .foregroundColor: UIColor(textColor)
        ]
        
        if let selectedRange = uiView.selectedTextRange {
            if selectedRange.isEmpty {
                // Apply to new text
                uiView.typingAttributes = attributes
            } else {
                // Apply to selected text
                let location = uiView.offset(from: uiView.beginningOfDocument, to: selectedRange.start)
                let length = uiView.offset(from: selectedRange.start, to: selectedRange.end)
                let mutableAttrText = NSMutableAttributedString(attributedString: uiView.attributedText)
                mutableAttrText.addAttributes(attributes, range: NSRange(location: location, length: length))
                uiView.attributedText = mutableAttrText
            }
        }
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextView
        
        init(_ parent: CustomTextView) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
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


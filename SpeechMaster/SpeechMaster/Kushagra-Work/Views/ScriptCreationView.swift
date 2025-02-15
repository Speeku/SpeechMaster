import SwiftUI
/*        // Instantiate the desired view controller
 guard let viewController = storyboard.instantiateViewController(withIdentifier: "ScriptDetailedSection")as? ProgressViewController
 else{
     fatalError("Could not instantiate ViewController")
 }
 viewController.scriptTitle = script.title
 return viewController
}*/
struct KeyNoteOptionsStoryboardView: UIViewControllerRepresentable {
    let successText : String
    func makeUIViewController(context: Context) -> UIViewController {
        // Get reference to your storyboard
        
        let storyboard = UIStoryboard(name: "PerformanceScreen", bundle: nil)
        // Instantiate the desired view controller
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "SelectingKeynoteVC") as? SelectingKeynoteVC
        else{
            fatalError("Could not instantiate ViewController")
        }
        viewController.texty = successText
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Update the view controller if needed
        if let VC = uiViewController as?  SelectingKeynoteVC{
            VC.texty = successText
        }
    }
}

struct TextEditorToolbar: View {
    @Binding var text: String
    @Binding var isBold: Bool
    @Binding var isItalic: Bool
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                Button(action: { isBold.toggle() }) {
                    Image(systemName: "bold")
                        .foregroundStyle(isBold ? Color.orange : Color.primary)
                        .font(.title)
                }
                Divider()
                    .frame(height: 20)
                Button(action: { isItalic.toggle() }) {
                    Image(systemName: "italic")
                        .foregroundStyle(isItalic ? Color.orange : .primary).font(.title)
                }
                Divider()
                    .frame(height: 20)
                Button(action: { text = "" }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red).font(.title2)
                }
                .disabled(text.isEmpty)
                
                Divider()
                    .frame(height: 20)
                Spacer()
                Text("\(text.count) characters")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
        }
    }
}

struct CustomAlertView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Binding var isPresented: Bool
    @Binding var scriptName: String
    @Binding var scriptText: String
    @FocusState private var isTextFieldFocused: Bool
    @State private var showError = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 20) {
                Text("Save Script")
                    .font(.headline)
                    .padding(.top)
                
                TextField("Enter script name", text: $scriptName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .focused($isTextFieldFocused)
                
                if showError {
                    Text("Script name cannot be empty")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                HStack(spacing: 50) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.blue)
                    
                    Button("Save") {
                        if scriptName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            showError = true
                            return
                        }
                        
                        // Save script to array
                        let newScript = Script(id: UUID(), title: scriptName, scriptText: scriptText, createdAt: Date(), isKeynoteAssociated: false, isPinned: false)
                        viewModel.addScript(newScript)
                        viewModel.uploadedScriptText = scriptText
                        isPresented = false
                       // dismiss()
                        viewModel.navigateToPiyushScreen = true
                    }
                    .foregroundColor(.blue)
                    .bold()
                }
                .padding(.bottom)
            }
            .frame(width: 280)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 10)
        }
        .onAppear {
            isTextFieldFocused = true
        }
    }
}

struct ScriptCreationView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss
    @State var scriptText = ""
    @State private var showingSaveAlert = false
    @State private var sessionName = ""
    @State private var showingDiscardAlert = false
    @State private var isBold = false
    @State private var isItalic = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Text Editor Toolbar
                TextEditorToolbar(text: $scriptText, isBold: $isBold, isItalic: $isItalic)
                    .padding(.vertical, 8)
                    .background(Color(.systemBackground))
                
                Divider()
                
                // Script Editor
                TextEditor(text: $scriptText)
                    .font(.system(.body, design: .default).weight(isBold ? .bold : .regular))
                    .padding()
                    .background(Color(.systemBackground))
                    .frame(maxHeight: .infinity)
//                    .navigationDestination(isPresented: $viewModel.navigateToPiyushScreen) {
//                        KeyNoteOptionsStoryboardView()
//                    }
            }
        }.toolbar{
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    if !scriptText.isEmpty {
                        showingDiscardAlert = true
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
        .navigationTitle("Create Script")  .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
        .alert("Discard Changes?", isPresented: $showingDiscardAlert) {
            Button("Discard", role: .destructive) {
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to discard your changes?")
        }
        .overlay {
            if showingSaveAlert {
                CustomAlertView(
                    viewModel: viewModel,
                    isPresented: $showingSaveAlert,
                    scriptName: $sessionName,
                    scriptText: $scriptText
                )
            }
        }
    }
}

#Preview {
    ScriptCreationView(viewModel: HomeViewModel.shared)
}

//import SwiftUI
//struct CustomAlertView: View {
//    @ObservedObject var viewModel: HomeViewModel
//    @Binding var isPresented: Bool
//    @Binding var scriptName: String
//    let onSave: (String) -> Void
//    @FocusState private var isTextFieldFocused: Bool
//    @State private var showError = false
//
//    var body: some View {
//        ZStack {
//            Color.black.opacity(0.3)
//                .edgesIgnoringSafeArea(.all)
//                .onTapGesture {
//                    isPresented = false
//                }
//
//            VStack(spacing: 20) {
//                Text("Save Script")
//                    .font(.headline)
//                    .padding(.top)
//
//                TextField("Enter script name", text: $scriptName)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding(.horizontal)
//                    .focused($isTextFieldFocused)
//
//                if showError {
//                    Text("Script name cannot be empty")
//                        .foregroundColor(.red)
//                        .font(.caption)
//                }
//
//                HStack(spacing:50){
//                    Button("Cancel") {
//                        isPresented = false
//                    }
//                    .foregroundColor(.blue)
//
//                    Divider()
//                        .frame(height: 20)
//                    Button("Save") {
//                        if scriptName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//                            showError = true
//                            return
//                        }
//                        onSave(scriptName)
//                        viewModel.navigateToPiyushScreen = true
//                    }
//                    .foregroundColor(.blue)
//                    .bold()
//                }
//                .padding(.bottom)
//            }
//            .frame(width: 280)
//            .background(Color(.systemBackground))
//            .cornerRadius(12)
//            .shadow(radius: 10)
//        }
//        .onAppear {
//            isTextFieldFocused = true
//        }
//    }
//}
//struct ScriptCreationView: View {
//    @ObservedObject var viewModel: HomeViewModel
//    @Environment(\.dismiss) private var dismiss
//    @State private var scriptText = ""
//    @State private var showingSaveAlert = false
//    @State private var sessionName = "Session 1"
//    @State private var savedSessionName = ""
//    var body: some View {
//        TextEditor(text: $scriptText)
//            .padding()
//            .background(Color(.systemBackground))
//            .navigationTitle("Create Script")
//            .navigationBarTitleDisplayMode(.inline)
//        .toolbar {
//                    ToolbarItem(placement: .navigationBarTrailing) {
//                        Button("Save") {
//                            //viewModel.uploadedScriptText = scriptText
//                            //viewModel.navigateToPiyushScreen = true
//                            showingSaveAlert = true
//                        }
//                        .disabled(scriptText.isEmpty)
//                    }
//             }
//        if showingSaveAlert {
//            CustomAlertView(
//                isPresented: $showingSaveAlert,
//                scriptName: $sessionName
//            ) { name in
//                savedSessionName = name
//                viewModel.addScript(Script(
//                    title: name.trimmingCharacters(in: .whitespacesAndNewlines),
//                    date: Date(),
//                    isPinned: false
//                ))
//                viewModel.uploadedScriptText = scriptText
//
//            }
//        }
//    }
//}
//
//#Preview {
//    NavigationView{ScriptCreationView(viewModel: HomeViewModel())
//    } }
////.alert("Save Rehearsal", isPresented: $showingSaveAlert, actions: {
////                    TextField("Enter session name", text: $sessionName)
////                        .textFieldStyle(RoundedBorderTextFieldStyle())
////
////                    Button("Cancel", role: .cancel) {}
////
////                    Button("Save") {
////                        savedSessionName = sessionName
////                    }
////                }, message: {
////                    Text("Enter a name for your rehearsal session.")
////                })

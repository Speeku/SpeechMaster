import UIKit
import GoogleGenerativeAI
import Speech

class questionAndAnsVC: UIViewController, SFSpeechRecognizerDelegate, UITextViewDelegate {
    
    @IBOutlet var questionProgressBar: UIProgressView!
    @IBOutlet var questions: UITextView!
    @IBOutlet var userAnswer: UITextView!
    @IBOutlet var backwardButton: UIButton!
    @IBOutlet var forwardButton: UIButton!
    @IBOutlet var answerButton: UIButton!
    @IBOutlet weak var endButton: UIBarButtonItem!
    
    @IBOutlet weak var sumbitedButton: UIImageView!
    @IBOutlet weak var redoButton: UIButton!
    
    private var isAnimating = false
    
    // Speech recognition properties
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var isRecording = false
    
    // Add property for data controller
    let qna_dataController = QnaDataController.shared
    let activityIndicator = UIActivityIndicatorView(style: .large)
    private var scrollView: UIScrollView!
    
    private var lastTranscribedText: String = ""
    
    // Update viewDidLoad to remove keyboard setup
    // First, update viewDidLoad to set initial state
    override func viewDidLoad() {
        super.viewDidLoad()
        //setupActivityIndicator()
        setupInitialUI()
        setupSpeechRecognition()
        generateQuestions()
        setupKeyboardHandling()
        
        // Setup TextView delegate
        userAnswer.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupActivityIndicator() {
        // Configure activity indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        // Position activity indicator above center
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -160)
        ])
        
        activityIndicator.hidesWhenStopped = true
        
    }
    
    private func setupInitialUI() {
        questions.isEditable = false
        questions.isSelectable = true
        
        // Configure userAnswer TextView
        userAnswer.text = ""
        userAnswer.isEditable = true
        userAnswer.backgroundColor = .systemBackground
        userAnswer.layer.borderColor = UIColor.systemGray4.cgColor
        userAnswer.layer.borderWidth = 1
        userAnswer.layer.cornerRadius = 8
        userAnswer.font = .systemFont(ofSize: 16)
        userAnswer.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        userAnswer.layoutManager.allowsNonContiguousLayout = false
        userAnswer.isScrollEnabled = true
        
        endButton.isEnabled = false
        navigationItem.hidesBackButton = false
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        redoButton.tintColor = .systemGray
        redoButton.isEnabled = false
        answerButton.isEnabled = false
        answerButton.tintColor = .systemGray
        answerButton.setImage(UIImage(systemName: "waveform.circle"), for: .normal)
        
        backwardButton.isEnabled = false
        backwardButton.tintColor = .systemGray
        forwardButton.isEnabled = false
        forwardButton.tintColor = .systemGray
        
        questionProgressBar.isHidden = false
        questionProgressBar.translatesAutoresizingMaskIntoConstraints = false
        questionProgressBar.progress = 0.0
        
        setupActivityIndicator()
        
        // Set initial state for answer button
        userAnswer.isUserInteractionEnabled = false  // Disable text input
        userAnswer.alpha = 0.5  // Make it look disabled
        userAnswer.backgroundColor = .systemGray6  // Light gray background
        userAnswer.text = "Please wait while questions are loading..."
    }
    
    private func generateQuestions() {
        // Show activity indicator
        activityIndicator.startAnimating()
        questions.isHidden = true
        
        // Disable answer area and button during generation
        userAnswer.isUserInteractionEnabled = false
        userAnswer.alpha = 0.5
        userAnswer.backgroundColor = .systemGray6
        userAnswer.text = "Please wait while questions are loading..."
        
        // Keep answer button disabled and gray during loading
        answerButton.isEnabled = false
        answerButton.tintColor = .systemGray
        
        generateQuestionsAndAnswers(from: script) { [weak self] questions in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                // Hide activity indicator
                self.activityIndicator.stopAnimating()
                self.questions.isHidden = false
                
                if let questions = questions {
                    self.qna_dataController.questions = questions
                    self.updateUI()
                    
                    // Re-enable answer area and button
                    self.userAnswer.isUserInteractionEnabled = true
                    self.userAnswer.alpha = 1.0
                    self.userAnswer.backgroundColor = .systemBackground
                    self.userAnswer.text = ""  // Clear loading message
                    
                    // Enable and color the answer button
                    self.answerButton.isEnabled = true
                    self.answerButton.tintColor = .systemBlue
                } else {
                    print("Error in API call")
                    self.questions.text = "Failed to load questions. Please try again."
                }
            }
        }
    }
    
    var script = QnaDataController.shared.script
    var words: Int {
            return script.split(separator: " ").count
        }
    
    let model = GenerativeModel(name: "models/gemini-2.0-flash-lite-preview-02-05", apiKey: APIKey.default)
    
    func setQuestionNumber()->Int{
        switch words{
        case 100...199:
            return 5
        case 200...299:
            return 7
        case 300...399:
            return 10
        case 400...:
            return 15
        default:
            return 5
        }
    }
    func generateQuestionsAndAnswers(from script: String, completion: @escaping ([QnAQuestion]?) -> Void) {
        let prompt = """
        Based on the following script, generate exactly \(setQuestionNumber()) challenging and professional questions, along with their answers, focused on a **startup pitch** for a **product or prototype**.  

        ### **Instructions:**  
        - Assume the questions are coming from **investors, judges, or business experts** evaluating a pitch.  
        - The questions should be **indirect, thought-provoking, and require deep reasoning**.  
        - Ensure **the tone is relevant to entrepreneurs** presenting their **product or prototype**.  
        - Each question should encourage the presenter to **justify decisions, defend their market position, or clarify strategy**.  
        - Format:  

        **Example Format:**  
        Question: [A challenging, expert-level question]  
        Answer: [An insightful, articulate response]  
        Do not number the questions
        ### **Example Good Questions:**  
        ✅ *"What market inefficiency does your product exploit, and why hasn't it been solved before?"*  
        ✅ *"How does your revenue model scale beyond early adopters, and what obstacles might hinder mass adoption?"*  
        ✅ *"What data or trends validate your product-market fit, and how will you adjust if consumer behavior shifts?"*  

        Now, generate **\(setQuestionNumber())** expert-level questions and answers based on the following pitch:  

        \(script)
        """
        
        Task {
            do {
                let result = try await model.generateContent(prompt)
                if let responseText = result.text {
                    print("API Response: \(responseText)")
                    
                    // Create a new session ID when generating questions
                    let sessionId = UUID()
                    
                    // Parse and create questions with IDs and session ID
                    let questionsAndAnswers = qna_dataController.parseQuestionsAndAnswers(from: responseText, sessionId: sessionId)
                    print(questionsAndAnswers)
                    completion(questionsAndAnswers)
                } else {
                    completion(nil)
                }
            } catch {
                print("Error generating content: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    private func checkAllQuestionsAnswered() -> Bool {
        for question in qna_dataController.questions {
            if question.userAnswer.isEmpty {
                return false
            }
        }
        return true
    }
    private func setupSpeechRecognition() {
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.answerButton.isEnabled = true
                case .denied:
                    self.answerButton.isEnabled = false
                    self.showAlert(title: "Speech Recognition Error", message: "Speech recognition access denied")
                case .restricted:
                    self.answerButton.isEnabled = false
                    self.showAlert(title: "Speech Recognition Error", message: "Speech recognition restricted on this device")
                case .notDetermined:
                    self.answerButton.isEnabled = false
                    self.showAlert(title: "Speech Recognition Error", message: "Speech recognition not authorized")
                @unknown default:
                    fatalError("Unknown authorization status")
                }
            }
        }
    }
    
    var currentQuestionIndex = 0
    
    // Add persistent property for current answer
    private var currentAnswer: String = ""
    
    private func saveCurrentAnswer() {
        if !currentAnswer.isEmpty {
            qna_dataController.updateUserAnswer(at: currentQuestionIndex, with: currentAnswer)
            print("Saved answer for question \(currentQuestionIndex): \(currentAnswer)") 
        }
    }
    
    func updateUI() {
        guard currentQuestionIndex < qna_dataController.questions.count else { return }
        
        let currentQuestion = qna_dataController.questions[currentQuestionIndex]
        questions.text = currentQuestion.questionText
        
        // Update progress bar with animation
        let progress = Float(currentQuestionIndex + 1) / Float(qna_dataController.questions.count)
        questionProgressBar.setProgress(progress, animated: true)
        print("📊 Progress updated: \(progress)")
        
        // Reset transcription state
        lastTranscribedText = ""
        
        // Update answer text view
        userAnswer.text = currentQuestion.userAnswer
        currentAnswer = currentQuestion.userAnswer
        
        // Force layout update
        userAnswer.layoutIfNeeded()
        
        // Update navigation buttons state
        backwardButton.isEnabled = currentQuestionIndex > 0
        backwardButton.tintColor = currentQuestionIndex > 0 ? .systemBlue : .systemGray
        forwardButton.isEnabled = currentQuestionIndex < qna_dataController.questions.count - 1
        forwardButton.tintColor = currentQuestionIndex < qna_dataController.questions.count - 1 ? .systemBlue : .systemGray
        
        // Update UI state based on saved answer
        if !currentQuestion.userAnswer.isEmpty {
            print("💬 Answer exists - updating UI state")
            sumbitedButton.tintColor = .systemGreen
            redoButton.tintColor = .systemBlue
            redoButton.isEnabled = true
        } else {
            print("💬 No answer - resetting UI state")
            sumbitedButton.tintColor = .gray
            redoButton.tintColor = .systemGray
            redoButton.isEnabled = false
        }
        
        // Update navigation title
        navigationItem.title = "Question \(currentQuestionIndex + 1)"
    }
    
    // Add property to store recording start time
    private var recordingStartTime: Date?
    
    private func startRecording() {
        // Reset state
        userAnswer.text = ""
        lastTranscribedText = ""
        currentAnswer = ""
        isRecording = true
        
        // Update UI for recording state
        answerButton.setImage(UIImage(systemName: "waveform.circle.fill"), for: .normal)
        sumbitedButton.tintColor = .gray
        redoButton.isEnabled = false
        
        // Store start time
        recordingStartTime = Date()
        print("⏱️ Recording started at: \(recordingStartTime!)")
        
        // Cancel any existing task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Setup audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session setup failed: \(error)")
            showAlert(title: "Speech Recognition Error", message: "Audio session setup failed")
            return
        }
        
        // Create and configure recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            showAlert(title: "Speech Recognition Error", message: "Unable to create recognition request")
            return
        }
        recognitionRequest.shouldReportPartialResults = true
        
        // Create recognition task
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            var isFinal = false
            
            if let result = result {
                let transcribedText = result.bestTranscription.formattedString
                isFinal = result.isFinal
                print("🎤 Live transcription: \(transcribedText)")
                
                DispatchQueue.main.async {
                    // Update UI with transcribed text
                    self.userAnswer.text = transcribedText
                    
                    // Ensure text is visible
                    self.userAnswer.scrollRangeToVisible(NSRange(location: self.userAnswer.text.count, length: 0))
                }
            }
            
            if error != nil || isFinal {
                // Stop recording if there's an error or we have final result
                if let duration = self.recordingStartTime.map({ Date().timeIntervalSince($0) }) {
                    self.stopRecording(withFinalText: self.userAnswer.text ?? "", duration: duration)
                }
            }
        }
        
        // Setup audio engine
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("Audio engine start failed: \(error)")
            showAlert(title: "Speech Recognition Error", message: "Audio engine failed to start")
        }
    }
    
    private func stopRecording(withFinalText finalText: String, duration: TimeInterval) {
        print("🎤 Stopping recording with text: \(finalText) and duration: \(duration)")
        
        // Stop audio engine first
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        // End recognition request
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        // Cancel recognition task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Update data model
        if !finalText.isEmpty {
            qna_dataController.updateUserAnswer(
                at: currentQuestionIndex,
                with: finalText,
                timeTaken: duration
            )
            
            // Verify save
            let savedQuestion = qna_dataController.questions[currentQuestionIndex]
            print("💾 Saved answer verification: \(savedQuestion.userAnswer)")
        }
        
        // Update UI on main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Update recording state
            self.isRecording = false
            self.recordingStartTime = nil
            self.answerButton.setImage(UIImage(systemName: "waveform.circle"), for: .normal)
            
            if !finalText.isEmpty {
                // Update UI state for completed answer
                self.userAnswer.text = finalText
                self.currentAnswer = finalText
                self.sumbitedButton.tintColor = .systemGreen
                self.redoButton.tintColor = .systemBlue
                self.redoButton.isEnabled = true
            }
            
            // Update end button state
            self.endButton.isEnabled = self.checkAllQuestionsAnswered()
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @IBAction func answerButton(_ sender: Any) {
        if isRecording {
            if let duration = recordingStartTime.map({ Date().timeIntervalSince($0) }) {
                print("⏱️ Recording duration: \(duration) seconds")
                stopRecording(withFinalText: userAnswer.text ?? "", duration: duration)
            }
        } else {
            startRecording()
        }
    }
    
    // Update redo button action
    @IBAction func redoButtonTapped(_ sender: Any) {
        // Clear the current answer and time
        userAnswer.text = ""
        currentAnswer = ""
        recordingStartTime = nil  // Reset the start time
        
        // Update data model with empty answer and zero time
        qna_dataController.updateUserAnswer(
            at: currentQuestionIndex, 
            with: "", 
            timeTaken: 0  // Explicitly reset time to zero
        )
        
        // Reset UI state
        sumbitedButton.tintColor = .gray
        redoButton.tintColor = .systemGray
        redoButton.isEnabled = false
        
        // Update end button state
        endButton.isEnabled = checkAllQuestionsAnswered()
        
        print("Answer and time cleared for question \(currentQuestionIndex)") 
    }
    
    
    @IBAction func forwardButton(_ sender: Any) {
        if currentQuestionIndex < qna_dataController.questions.count - 1 {
            currentQuestionIndex += 1
            updateUI()
        }
    }
    
    // Update backwardButton to reset submit button state
    @IBAction func backwardButton(_ sender: Any) {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
            updateUI()
        }
    }
    
    // Update updateUI to handle submit button state
    
    
    // Add method to save all answers when finishing the session
    private func saveSession() {
        // Save the last answer if there is one
        if !userAnswer.text.isEmpty {
            qna_dataController.updateUserAnswer(at: currentQuestionIndex, with: userAnswer.text)
        }
        
        // Create reports from questions
       
    }
   
    // Add this line
    
    @IBAction func endSessionButtonTapped(_ sender: Any) {
        if audioEngine.isRunning {
            let currentText = userAnswer.text ?? ""
            stopRecording(withFinalText: currentText, duration: 0)
        }
        saveCurrentAnswer() // Save the final answer
        // Show confirmation alert
        let alert = UIAlertController(
            title: "End Session", 
            message: "Are you sure you want to end this Q&A session?", 
            preferredStyle: .alert
        )
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        cancel.setValue(UIColor.red, forKey: "titleTextColor")
        alert.addAction(cancel)
        
        alert.addAction(UIAlertAction(title: "End Session", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            // Save session and navigate
            if let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "QuestionAnswerList") {
                self.navigationController?.setViewControllers([destinationVC], animated: true)
            }
        })
        
        present(alert, animated: true)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        if isRecording {
            let currentText = userAnswer.text ?? ""
            if let duration = recordingStartTime.map({ Date().timeIntervalSince($0) }) {
                stopRecording(withFinalText: currentText, duration: duration)
            }
        }
        
        // Show confirmation alert
        let alert = UIAlertController(
            title: "Cancel Session",
            message: "Are you sure you want to cancel this Q&A session? All progress will be lost.",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "No, Continue", style: .cancel)
        let confirmAction = UIAlertAction(title: "Yes, Cancel", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.performSegue(withIdentifier: "moveToSession", sender: self)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        
        present(alert, animated: true)
    }
    
    private func setupKeyboardHandling() {
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        let contentInsets = UIEdgeInsets(
            top: 0.0,
            left: 0.0,
            bottom: keyboardSize.height,
            right: 0.0
        )
        
        // Adjust the bottom content inset of userAnswer
        userAnswer.contentInset = contentInsets
        userAnswer.scrollIndicatorInsets = contentInsets
        
        // Scroll to the cursor position
        if userAnswer.isFirstResponder {
            let selectedRange = userAnswer.selectedRange
            userAnswer.scrollRangeToVisible(selectedRange)
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        // Reset the content insets
        let contentInsets = UIEdgeInsets.zero
        userAnswer.contentInset = contentInsets
        userAnswer.scrollIndicatorInsets = contentInsets
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        if audioEngine.isRunning {
            let currentText = userAnswer.text ?? ""
            stopRecording(withFinalText: currentText, duration: 0)
        }
        saveCurrentAnswer() // Save the final answer
        
        // Show confirmation alert
        let alert = UIAlertController(
            title: "Save Session", 
            message: "Are you sure you want to save this Q&A session?", 
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        alert.addAction(cancelAction)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            // Save session and navigate back
            self.saveSession()
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(saveAction)
        
        present(alert, animated: true)
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        // Scroll to cursor position when editing begins
        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        print("📝 TextView content changed: \(textView.text ?? "")")
        // Scroll to cursor position as user types
        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
}



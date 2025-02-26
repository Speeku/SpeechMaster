import UIKit
import GoogleGenerativeAI
import Speech

class questionAndAnsVC: UIViewController, SFSpeechRecognizerDelegate, UITextViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet var questionProgressBar: UIProgressView!
    @IBOutlet var questions: UITextView!
    @IBOutlet var userAnswer: UITextView!
    @IBOutlet var backwardButton: UIButton!
    @IBOutlet var forwardButton: UIButton!
    @IBOutlet var answerButton: UIButton!
    @IBOutlet weak var endButton: UIBarButtonItem!
    
    @IBOutlet weak var sumbitedButton: UIImageView!
    @IBOutlet weak var redoButton: UIButton!
    
    // MARK: - Properties
    private var isAnimating = false
    private var isRecording = false
    private var recordingStartTime: Date?
    private var lastTranscribedText: String = ""
    private var isLoadingQuestions = false
    private var currentQuestionIndex = 0
    
    // Speech recognition properties
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    // Data controller
    let qna_dataController = QnaDataController.shared
    let activityIndicator = UIActivityIndicatorView(style: .large)
    private var scrollView: UIScrollView!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Force refresh script from HomeViewModel
        qna_dataController.refreshScript()
        
        // Debug print script info
        let script = qna_dataController.script
        print("📝 Initial Script Content: \(script)")
        print("📊 Initial Word Count: \(script.split(separator: " ").count)")
        
        setupInitialUI()
        setupSpeechRecognition()
        generateQuestions()
        
        // Setup TextView delegate
        userAnswer.delegate = self
        userAnswer.isEditable = false
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
        userAnswer.isEditable = false
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
        // Set loading state
        isLoadingQuestions = true
        answerButton.isEnabled = false
        answerButton.tintColor = .systemGray
        
        // Force refresh script first
        qna_dataController.updateScript()
        
        // Debug print to check script content
        
    }
    
    // MARK: - Setup Methods
    private func setupSpeechRecognition() {
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                switch authStatus {
                case .authorized:
                    self.answerButton.isEnabled = true
                case .denied:
                    self.showAlert(title: "Speech Recognition Denied", message: "Please enable speech recognition in Settings.")
                case .restricted:
                    self.showAlert(title: "Speech Recognition Restricted", message: "Speech recognition is not available on this device.")
                case .notDetermined:
                    self.showAlert(title: "Speech Recognition Not Determined", message: "Speech recognition is not yet authorized.")
                @unknown default:
                    self.showAlert(title: "Speech Recognition Error", message: "Unknown authorization status.")
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Button Actions
    @IBAction func answerButtonTapped(_ sender: Any) {
        guard !isLoadingQuestions else { return }
        
        if !isRecording {
            // Starting recording
            do {
                try startRecording()
                recordingStartTime = Date()
                answerButton.setImage(UIImage(systemName: "stop.circle.fill"), for: .normal)
                answerButton.tintColor = .systemRed
                isRecording = true
                userAnswer.isEditable = true
                userAnswer.backgroundColor = .systemBackground
                userAnswer.alpha = 1.0
            } catch {
                print("❌ Recording failed to start: \(error)")
                showAlert(title: "Recording Error", message: error.localizedDescription)
            }
        } else {
            // Stopping recording
            let duration = Date().timeIntervalSince(recordingStartTime ?? Date())
            stopRecording(withFinalText: userAnswer.text, duration: duration)
            answerButton.setImage(UIImage(systemName: "waveform.circle"), for: .normal)
            answerButton.tintColor = .systemBlue
            isRecording = false
            userAnswer.isEditable = false
        }
    }
    
    private func startRecording() throws {
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw NSError(domain: "Speech", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to create recognition request"])
        }
        recognitionRequest.shouldReportPartialResults = true
        
        // Start recognition task
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                let transcribedText = result.bestTranscription.formattedString
                DispatchQueue.main.async {
                    self.userAnswer.text = transcribedText
                    self.lastTranscribedText = transcribedText
                }
            }
            
            if error != nil {
                self.stopRecording(withFinalText: self.lastTranscribedText, duration: 0)
            }
        }
        
        // Configure audio engine
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    private func stopRecording(withFinalText finalText: String, duration: TimeInterval) {
        // Stop audio engine and remove tap
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        // End recognition request
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        // Cancel recognition task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Update data model
        qna_dataController.updateUserAnswer(
            at: currentQuestionIndex,
            with: finalText,
            timeTaken: duration
        )
        
        // Update UI
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.sumbitedButton.tintColor = .systemGreen
            self.redoButton.isEnabled = true
            self.redoButton.tintColor = .systemBlue
        }
    }
}

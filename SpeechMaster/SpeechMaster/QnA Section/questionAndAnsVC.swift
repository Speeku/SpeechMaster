import UIKit
import Speech

class questionAndAnsVC: UIViewController, SFSpeechRecognizerDelegate {
    
    @IBOutlet var questionProgressBar: UIProgressView!
    @IBOutlet var questions: UILabel!
    @IBOutlet var userAnswer: UITextView!
    @IBOutlet var backwardButton: UIButton!
    @IBOutlet var forwardButton: UIButton!
    @IBOutlet var answerButton: UIButton!
    
    private var isAnimating = false
    
    // Speech recognition properties
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Question 1"
        updateUI()
        userAnswer.text = ""
        setupSpeechRecognition()
    }
    
    private func setupSpeechRecognition() {
        speechRecognizer.delegate = self
        answerButton.setTitle("Start Speaking", for: .normal)
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.answerButton.isEnabled = true
                case .denied:
                    self.answerButton.isEnabled = false
                    self.showAlert(message: "Speech recognition access denied")
                case .restricted:
                    self.answerButton.isEnabled = false
                    self.showAlert(message: "Speech recognition restricted on this device")
                case .notDetermined:
                    self.answerButton.isEnabled = false
                    self.showAlert(message: "Speech recognition not authorized")
                @unknown default:
                    fatalError("Unknown authorization status")
                }
            }
        }
    }
    
    var currentQuestionIndex = 0
    
    func updateUI() {
        questions.text = questionsList[currentQuestionIndex].questionText
        let progress = Float(currentQuestionIndex + 1) / Float(questionsList.count)
        questionProgressBar.progress = progress
        self.navigationItem.title = "Question \(currentQuestionIndex + 1)"
        backwardButton.isHidden = currentQuestionIndex == 0
    }
    
    @IBAction func answerButton(_ sender: Any) {
        if audioEngine.isRunning {
            stopRecording()
            isRecording = false
            answerButton.setImage(UIImage(systemName: "waveform.circle"), for: .normal)
            answerButton.setTitle("Start Speaking", for: .normal)
        } else {
            startRecording()
            isRecording = true
            answerButton.setImage(UIImage(systemName: "waveform.circle.fill"), for: .normal)
            answerButton.setTitle("Stop Recording", for: .normal)
        }
    }
    
    private func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            showAlert(message: "Audio session setup failed")
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else {
            showAlert(message: "Unable to create recognition request")
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                self.userAnswer.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.answerButton.isEnabled = true
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            showAlert(message: "Audio engine failed to start")
        }
    }
    
    private func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Speech Recognition Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @IBAction func forwardButton(_ sender: Any) {
        guard currentQuestionIndex < questionsList.count - 1 else { return }
        
        // Stop recording if it's currently recording
        if audioEngine.isRunning {
            stopRecording()
            answerButton.setTitle("Start Speaking", for: .normal)
            isRecording = false
        }
        
        // Clear the text view
        userAnswer.text = ""
        
        // Move to next question
        currentQuestionIndex += 1
        updateUI()
        backwardButton.isHidden = false
    }
    
    @IBAction func backwardButton(_ sender: Any) {
        guard currentQuestionIndex > 0 else { return }
        
        // Stop recording if it's currently recording
        if audioEngine.isRunning {
            stopRecording()
            answerButton.setTitle("Start Speaking", for: .normal)
            isRecording = false
        }
        //questionsList[currentQuestionIndex].answerText = userAnswer.text
        // Clear the text view
        userAnswer.text = ""
        
        // Move to previous question
        currentQuestionIndex -= 1
        updateUI()
    }
}

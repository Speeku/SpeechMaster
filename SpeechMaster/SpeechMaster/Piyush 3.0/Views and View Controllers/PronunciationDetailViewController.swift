import UIKit
import AVFoundation
import Speech

class PronunciationDetailViewController: UIViewController, UITextFieldDelegate {
    private let pronunciationErrors: [SpeechAnalysisResult.PronunciationError]
    private let synthesizer = AVSpeechSynthesizer()
    private let indianVoice = AVSpeechSynthesisVoice(language: "en-IN")
    private var selectedWord: String?
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsHorizontalScrollIndicator = true
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceHorizontal = true
        return sv
    }()
    
    private let wordsStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.spacing = 12
        return sv
    }()
    
    private let practiceContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let selectedWordLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let practiceTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Enter a word to practice"
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 16)
        tf.clearButtonMode = .whileEditing
        return tf
    }()
    
    private let practiceButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Practice Pronunciation", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let speedSwitch: UISwitch = {
        let sw = UISwitch()
        sw.translatesAutoresizingMaskIntoConstraints = false
        return sw
    }()
    
    private let speedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Slow Mode"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let mouthView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(systemName: "mouth")
        iv.tintColor = .label
        return iv
    }()
    
    private let mouthContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let recordButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 44, weight: .semibold)
        button.setImage(UIImage(systemName: "mic.circle.fill")?.withConfiguration(config), for: .normal)
        button.tintColor = .systemBlue
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.layer.cornerRadius = 35
        return button
    }()
    
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Tap the button to practice"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let recordingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.isHidden = true
        view.alpha = 0
        return view
    }()
    
    private let recordingMicImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(systemName: "mic.fill")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let recordingWordLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 48, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-IN"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = 20
        return sv
    }()
    
    init(pronunciationErrors: [SpeechAnalysisResult.PronunciationError]) {
        self.pronunciationErrors = pronunciationErrors
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        addPronunciationErrors()
        
        // Add tap gesture recognizer to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // Setup text field delegate
        practiceTextField.delegate = self
        practiceTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    private func setupUI() {
        title = "Pronunciation Practice"
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(dismissVC)
        )
        
        view.addSubview(scrollView)
        scrollView.addSubview(wordsStackView)
        view.addSubview(practiceContainer)
        
        practiceContainer.addSubview(practiceTextField)
        practiceContainer.addSubview(selectedWordLabel)
        practiceContainer.addSubview(practiceButton)
        practiceContainer.addSubview(speedSwitch)
        practiceContainer.addSubview(speedLabel)
        practiceContainer.addSubview(mouthContainer)
        
        mouthContainer.addSubview(mouthView)
        
        view.addSubview(recordButton)
        view.addSubview(instructionLabel)
        view.addSubview(recordingView)
        recordingView.addSubview(recordingMicImageView)
        recordingView.addSubview(recordingWordLabel)
        recordingView.addSubview(scoreLabel)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scrollView.heightAnchor.constraint(equalToConstant: 50),
            
            wordsStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            wordsStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            wordsStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            wordsStackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            
            practiceContainer.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 24),
            practiceContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            practiceContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            practiceContainer.heightAnchor.constraint(equalToConstant: 260),
            
            practiceTextField.topAnchor.constraint(equalTo: practiceContainer.topAnchor, constant: 20),
            practiceTextField.leadingAnchor.constraint(equalTo: practiceContainer.leadingAnchor, constant: 20),
            practiceTextField.trailingAnchor.constraint(equalTo: practiceContainer.trailingAnchor, constant: -20),
            practiceTextField.heightAnchor.constraint(equalToConstant: 40),
            
            selectedWordLabel.topAnchor.constraint(equalTo: practiceTextField.bottomAnchor, constant: 16),
            selectedWordLabel.centerXAnchor.constraint(equalTo: practiceContainer.centerXAnchor),
            
            practiceButton.topAnchor.constraint(equalTo: selectedWordLabel.bottomAnchor, constant: 16),
            practiceButton.centerXAnchor.constraint(equalTo: practiceContainer.centerXAnchor),
            practiceButton.widthAnchor.constraint(equalToConstant: 200),
            practiceButton.heightAnchor.constraint(equalToConstant: 44),
            
            speedSwitch.topAnchor.constraint(equalTo: practiceButton.bottomAnchor, constant: 20),
            speedSwitch.leadingAnchor.constraint(equalTo: practiceContainer.leadingAnchor, constant: 20),
            
            speedLabel.centerYAnchor.constraint(equalTo: speedSwitch.centerYAnchor),
            speedLabel.leadingAnchor.constraint(equalTo: speedSwitch.leadingAnchor, constant: 57),
            
            mouthContainer.topAnchor.constraint(equalTo: practiceContainer.bottomAnchor, constant: 10),
            mouthContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mouthContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            mouthContainer.heightAnchor.constraint(equalToConstant: 100),
            
            mouthView.topAnchor.constraint(equalTo: mouthContainer.topAnchor, constant: 40),
            mouthView.centerXAnchor.constraint(equalTo: mouthContainer.centerXAnchor),
            mouthView.widthAnchor.constraint(equalToConstant: 140),
            mouthView.heightAnchor.constraint(equalToConstant: 80),
            
            recordButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            recordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            recordButton.widthAnchor.constraint(equalToConstant: 70),
            recordButton.heightAnchor.constraint(equalToConstant: 70),
            
            instructionLabel.trailingAnchor.constraint(equalTo: recordButton.leadingAnchor, constant: -12),
            instructionLabel.centerYAnchor.constraint(equalTo: recordButton.centerYAnchor),
            instructionLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            
            recordingView.topAnchor.constraint(equalTo: view.topAnchor),
            recordingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            recordingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            recordingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            recordingMicImageView.centerXAnchor.constraint(equalTo: recordingView.centerXAnchor),
            recordingMicImageView.centerYAnchor.constraint(equalTo: recordingView.centerYAnchor),
            recordingMicImageView.widthAnchor.constraint(equalToConstant: 80),
            recordingMicImageView.heightAnchor.constraint(equalToConstant: 80),
            
            recordingWordLabel.topAnchor.constraint(equalTo: recordingMicImageView.bottomAnchor, constant: 20),
            recordingWordLabel.centerXAnchor.constraint(equalTo: recordingView.centerXAnchor),
            recordingWordLabel.leadingAnchor.constraint(equalTo: recordingView.leadingAnchor, constant: 20),
            recordingWordLabel.trailingAnchor.constraint(equalTo: recordingView.trailingAnchor, constant: -20),
            
            scoreLabel.centerXAnchor.constraint(equalTo: recordingView.centerXAnchor),
            scoreLabel.centerYAnchor.constraint(equalTo: recordingView.centerYAnchor)
        ])
        
        practiceButton.addTarget(self, action: #selector(practiceButtonTapped), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        
        setupWordButtons()
        updatePracticeContainer(nil)
    }
    
    private func setupWordButtons() {
        // Create a Set of unique words from pronunciation errors
        let uniqueWords = Set(pronunciationErrors.map { $0.word })
        
        // Create buttons for unique words
        uniqueWords.forEach { word in
            let button = UIButton(type: .system)
            button.setTitle(word, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 16)
            button.backgroundColor = .systemGray5
            button.setTitleColor(.label, for: .normal)
            button.layer.cornerRadius = 8
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            button.addTarget(self, action: #selector(wordButtonTapped(_:)), for: .touchUpInside)
            wordsStackView.addArrangedSubview(button)
        }
    }
    
    private func updatePracticeContainer(_ word: String?) {
        selectedWordLabel.text = word ?? "Select a word to practice"
        selectedWordLabel.font = word != nil ? .systemFont(ofSize: 32, weight: .bold) : .systemFont(ofSize: 24, weight: .regular)
        practiceButton.isEnabled = word != nil
        practiceButton.alpha = word != nil ? 1.0 : 0.5
    }
    
    @objc private func wordButtonTapped(_ sender: UIButton) {
        guard let word = sender.title(for: .normal) else { return }
        
        // Reset all buttons to default state
        wordsStackView.arrangedSubviews.forEach { view in
            if let button = view as? UIButton {
                button.backgroundColor = .systemGray5
                button.setTitleColor(.label, for: .normal)
            }
        }
        
        // Highlight selected button
        sender.backgroundColor = .systemBlue
        sender.setTitleColor(.white, for: .normal)
        
        selectedWord = word
        practiceTextField.text = "" // Clear text field when word is selected
        updatePracticeContainer(word)
        
        // Pronounce the selected word
        let utterance = AVSpeechUtterance(string: word)
        utterance.voice = indianVoice
        utterance.rate = speedSwitch.isOn ? 0.4 : 0.7
        utterance.pitchMultiplier = 1.0
        synthesizer.speak(utterance)
        
        // Animate mouth for the selected word
        animateMouth(for: word)
    }
    
    @objc private func practiceButtonTapped() {
        let wordToPractice = selectedWord ?? ""
        guard !wordToPractice.isEmpty else { return }
        
        let utterance = AVSpeechUtterance(string: wordToPractice)
        utterance.voice = indianVoice
        utterance.rate = speedSwitch.isOn ? 0.4 : 0.7
        utterance.pitchMultiplier = 1.0
        synthesizer.speak(utterance)
        
        // Animate mouth for the word
        animateMouth(for: wordToPractice)
    }
    
    private func animateMouth(for word: String) {
        let phonemes = PhoneticMapping.getPhonemes(for: word)
        animateMouthSequence(phonemes: phonemes)
    }
    
    private func animateMouthSequence(phonemes: [Phoneme]) {
        guard !phonemes.isEmpty else {
            mouthView.image = Phoneme.neutral.mouthImage
            return
        }
        
        let duration = speedSwitch.isOn ? 0.4 : 0.2
        mouthView.image = phonemes[0].mouthImage
        
        UIView.animate(withDuration: duration, animations: {
            self.mouthView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: duration) {
                self.mouthView.transform = .identity
            } completion: { _ in
                let remainingPhonemes = Array(phonemes.dropFirst())
                if !remainingPhonemes.isEmpty {
                    self.animateMouthSequence(phonemes: remainingPhonemes)
                } else {
                    self.mouthView.image = Phoneme.neutral.mouthImage
                }
            }
        }
    }
    
    @objc private func dismissVC() {
        dismiss(animated: true)
    }
    
    @objc private func recordButtonTapped() {
        guard let word = selectedWordLabel.text else { return }
        
        if audioEngine.isRunning {
            stopRecording()
        } else {
            startRecording(word: word)
        }
    }
    
    private func startRecording(word: String) {
        // Reset views to initial state
        recordingMicImageView.isHidden = false
        recordingWordLabel.isHidden = false
        scoreLabel.isHidden = true
        recordingWordLabel.text = word
        
        // Show recording view
        recordingView.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.recordingView.alpha = 1
            self.recordButton.tintColor = .systemRed
        }
        
        // Setup speech recognition
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            if let result = result {
                let spokenWord = result.bestTranscription.formattedString.lowercased()
                let score = self.calculatePronunciationScore(original: word.lowercased(), spoken: spokenWord)
                self.showScore(score)
            }
        }
        
        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
    }
    
    private func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        UIView.animate(withDuration: 0.3) {
            self.recordingView.alpha = 0
            self.recordButton.tintColor = .systemBlue
        } completion: { _ in
            self.recordingView.isHidden = true
            // Reset the recognition task and request
            self.recognitionTask = nil
            self.recognitionRequest = nil
        }
    }
    
    private func calculatePronunciationScore(original: String, spoken: String) -> Int {
        // Simple scoring based on string similarity
        if original == spoken {
            return 100
        }
        
        let distance = levenshteinDistance(original, spoken)
        let maxLength = max(original.count, spoken.count)
        let similarity = 1.0 - Double(distance) / Double(maxLength)
        return Int(similarity * 100)
    }
    
    private func showScore(_ score: Int) {
        recordingMicImageView.isHidden = true
        recordingWordLabel.isHidden = true
        scoreLabel.isHidden = false
        scoreLabel.text = "\(score)%"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.stopRecording()
        }
    }
    
    // Helper function to calculate string similarity
    private func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let empty = Array(repeating: 0, count: s2.count + 1)
        var last = Array(0...s2.count)
        
        for (i, c1) in s1.enumerated() {
            var cur = [i + 1] + empty
            for (j, c2) in s2.enumerated() {
                cur[j + 1] = c1 == c2 ? last[j] : min(last[j], last[j + 1], cur[j]) + 1
            }
            last = cur
        }
        return last[s2.count]
    }
    
    private func setupNavigationBar() {
        // Implementation of setupNavigationBar method
    }
    
    private func addPronunciationErrors() {
        // Implementation of addPronunciationErrors method
    }
    
    // Add text field change handler
    @objc private func textFieldDidChange(_ textField: UITextField) {
        let word = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        selectedWord = word.isEmpty ? selectedWord : word
        updatePracticeContainer(selectedWord)
    }
    
    // Add method to dismiss keyboard
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Implement text field delegate method to dismiss keyboard on return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// Update the Phoneme enum and PhoneticMapping
private enum Phoneme {
    case ae      // as in "cat"
    case cdgkn   // as in "key", "dog", "go"
    case r       // as in "red"
    case bmp     // as in "boy", "mom", "pop"
    case th      // as in "think"
    case o       // as in "go"
    case qw      // as in "queen", "wet"
    case l       // as in "light"
    case fv      // as in "five", "very"
    case neutral // default position
    
    var mouthImage: UIImage? {
        switch self {
        case .ae:
            return UIImage(named: "AE")
        case .cdgkn:
            return UIImage(named: "CDGKNSTXYZ")
        case .r:
            return UIImage(named: "R")
        case .bmp:
            return UIImage(named: "BMP")
        case .th:
            return UIImage(named: "TH")
        case .o:
            return UIImage(named: "O")
        case .qw:
            return UIImage(named: "QW")
        case .l:
            return UIImage(named: "L")
        case .fv:
            return UIImage(named: "FV")
        case .neutral:
            return UIImage(named: "CDGKNSTXYZ") // Using this as neutral position
        }
    }
}

private struct PhoneticMapping {
    static let phonemeMap: [String: [Phoneme]] = [
        "a": [.ae],
        "e": [.ae],
        "i": [.ae],
        "c": [.cdgkn],
        "d": [.cdgkn],
        "g": [.cdgkn],
        "k": [.cdgkn],
        "n": [.cdgkn],
        "s": [.cdgkn],
        "t": [.cdgkn],
        "x": [.cdgkn],
        "y": [.cdgkn],
        "z": [.cdgkn],
        "r": [.r],
        "b": [.bmp],
        "m": [.bmp],
        "p": [.bmp],
        "th": [.th],
        "o": [.o],
        "q": [.qw],
        "w": [.qw],
        "l": [.l],
        "f": [.fv],
        "v": [.fv]
    ]
    
    static func getPhonemes(for word: String) -> [Phoneme] {
        var phonemes: [Phoneme] = []
        let letters = Array(word.lowercased())
        
        var i = 0
        while i < letters.count {
            if i < letters.count - 1 {
                let pair = String(letters[i...i+1])
                if let pairPhonemes = phonemeMap[pair] {
                    phonemes.append(contentsOf: pairPhonemes)
                    i += 2
                    continue
                }
            }
            
            if let letterPhonemes = phonemeMap[String(letters[i])] {
                phonemes.append(contentsOf: letterPhonemes)
            } else {
                phonemes.append(.neutral)
            }
            i += 1
        }
        
        return phonemes.isEmpty ? [.neutral] : phonemes
    }
}

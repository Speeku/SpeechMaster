import UIKit
import AVFoundation

class MissingWordsDetailViewController: UIViewController {
    private let missingWords: [SpeechAnalysisResult.MissingWord]
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = 24
        return sv
    }()
    
    private let synthesizer = AVSpeechSynthesizer()
    private var selectedWord: String?
    
    init(missingWords: [SpeechAnalysisResult.MissingWord]) {
        self.missingWords = missingWords
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Missing Words Analysis"
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(dismissVC)
        )
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
        
        addMissingWordsBreakdown()
        addSuggestions()
    }
    
    private func addMissingWordsBreakdown() {
        let titleLabel = UILabel()
        titleLabel.text = "Missed Words from Script"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        stackView.addArrangedSubview(titleLabel)
        
        missingWords.forEach { missingWord in
            let container = createMissingWordView(word: missingWord.word, context: missingWord.context)
            stackView.addArrangedSubview(container)
        }
    }
    
    private func addSuggestions() {
        let titleLabel = UILabel()
        titleLabel.text = "Suggestions for Improvement"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        stackView.addArrangedSubview(titleLabel)
        
        let suggestions = [
            "Review your script thoroughly before speaking",
            "Practice the complete script multiple times",
            "Mark key words or phrases for emphasis",
            "Break down complex sentences into smaller parts",
            "Record yourself and compare with the script"
        ]
        
        suggestions.forEach { suggestion in
            let label = UILabel()
            label.text = "• \(suggestion)"
            label.font = .systemFont(ofSize: 16)
            label.numberOfLines = 0
            stackView.addArrangedSubview(label)
        }
    }
    
    private func createMissingWordView(word: String, context: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 12
        
        let wordLabel = UILabel()
        wordLabel.text = "\"\(word)\""
        wordLabel.font = .systemFont(ofSize: 18, weight: .medium)
        
        let contextLabel = UILabel()
        contextLabel.text = "in \"\(context)\""
        contextLabel.font = .systemFont(ofSize: 16)
        contextLabel.textColor = .secondaryLabel
        contextLabel.numberOfLines = 2
        
        [wordLabel, contextLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            wordLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            wordLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            
            contextLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            contextLabel.topAnchor.constraint(equalTo: wordLabel.bottomAnchor, constant: 4),
            contextLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            contextLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])
        
        return container
    }
    
    @objc private func dismissVC() {
        dismiss(animated: true)
    }
    
    @objc private func practicePronunciation() {
        guard let word = selectedWord else { return }
        let utterance = AVSpeechUtterance(string: word)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-IN")
        utterance.rate = 0.4
        utterance.pitchMultiplier = 1.1
        utterance.volume = 1.0
        synthesizer.speak(utterance)
    }
} 
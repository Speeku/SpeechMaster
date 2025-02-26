import UIKit
import AVFoundation

class MissingWordsDetailViewController: UIViewController {
    private let missingWords: [SpeechAnalysisResult.MissingWord]
    private let script = HomeViewModel.shared.uploadedScriptText
    
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
        titleLabel.text = "Script with Missing Words"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        stackView.addArrangedSubview(titleLabel)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .clear
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowOpacity = 0.15
        
        let scriptTextView = UITextView()
        scriptTextView.translatesAutoresizingMaskIntoConstraints = false
        scriptTextView.isEditable = false
        scriptTextView.isSelectable = true
        scriptTextView.backgroundColor = .systemGray6
        scriptTextView.layer.cornerRadius = 12
        scriptTextView.layer.borderWidth = 1
        scriptTextView.layer.borderColor = UIColor.systemGray4.cgColor
        scriptTextView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        scriptTextView.layer.masksToBounds = true
        
        containerView.addSubview(scriptTextView)
        stackView.addArrangedSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200),
            
            scriptTextView.topAnchor.constraint(equalTo: containerView.topAnchor),
            scriptTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            scriptTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            scriptTextView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        let fontSize: CGFloat = 20
        scriptTextView.font = .systemFont(ofSize: fontSize)
        scriptTextView.textContainer.lineFragmentPadding = 0
        scriptTextView.textContainer.lineBreakMode = .byWordWrapping
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        
        let attributedScript = NSMutableAttributedString(
            string: script,
            attributes: [
                .font: UIFont.systemFont(ofSize: fontSize),
                .paragraphStyle: paragraphStyle
            ]
        )
        
        missingWords.forEach { missingWord in
            let ranges = script.ranges(of: missingWord.word)
            for range in ranges {
                let nsRange = NSRange(range, in: script)
                attributedScript.addAttributes([
                    .foregroundColor: UIColor.systemRed,
                    .font: UIFont.systemFont(ofSize: fontSize, weight: .medium)
                ], range: nsRange)
            }
        }
        
        scriptTextView.attributedText = attributedScript
    }
    
    private func addSuggestions() {
        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 16
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 6
        container.layer.shadowOpacity = 0.1
        
        let titleView = UIView()
        titleView.backgroundColor = .systemBlue
        titleView.layer.cornerRadius = 16
        titleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        let titleLabel = UILabel()
        titleLabel.text = "💡 Tips for Success"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        
        let suggestions = [
            (icon: "📝", title: "Preparation is Key", message: "Review your script thoroughly before speaking"),
            (icon: "🔄", title: "Practice Makes Perfect", message: "Practice the complete script multiple times"),
            (icon: "⭐️", title: "Highlight Important Points", message: "Mark key words or phrases for emphasis"),
            (icon: "🎯", title: "Break it Down", message: "Break down complex sentences into smaller parts"),
            (icon: "🎤", title: "Record and Review", message: "Record yourself and compare with the script")
        ]
        
        let suggestionsStackView = UIStackView()
        suggestionsStackView.axis = .vertical
        suggestionsStackView.spacing = 16
        suggestionsStackView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        suggestionsStackView.isLayoutMarginsRelativeArrangement = true
        
        [container, titleView, titleLabel, suggestionsStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        container.addSubview(titleView)
        titleView.addSubview(titleLabel)
        container.addSubview(suggestionsStackView)
        stackView.addArrangedSubview(container)
        
        suggestions.forEach { suggestion in
            let suggestionView = createSuggestionView(
                icon: suggestion.icon,
                title: suggestion.title,
                message: suggestion.message
            )
            suggestionsStackView.addArrangedSubview(suggestionView)
        }
        
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            
            titleView.topAnchor.constraint(equalTo: container.topAnchor),
            titleView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            titleView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -16),
            
            suggestionsStackView.topAnchor.constraint(equalTo: titleView.bottomAnchor),
            suggestionsStackView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            suggestionsStackView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            suggestionsStackView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }
    
    private func createSuggestionView(icon: String, title: String, message: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 12
        
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: 30)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .label
        
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.font = .systemFont(ofSize: 15)
        messageLabel.textColor = .secondaryLabel
        messageLabel.numberOfLines = 0
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, messageLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        
        [container, iconLabel, textStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        container.addSubview(iconLabel)
        container.addSubview(textStack)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            iconLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            iconLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: 40),
            
            textStack.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            textStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            textStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])
        
        return container
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

// Add String extension for word ranges
private extension String {
    func ranges(of substring: String) -> [Range<String.Index>] {
        var ranges: [Range<String.Index>] = []
        var searchRange = self.startIndex..<self.endIndex
        
        while let range = self.range(of: "\\b\(substring)\\b",
                                   options: [.regularExpression, .caseInsensitive],
                                   range: searchRange) {
            ranges.append(range)
            searchRange = range.upperBound..<self.endIndex
        }
        
        return ranges
    }
}

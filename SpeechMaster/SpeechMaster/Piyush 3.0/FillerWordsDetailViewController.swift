import UIKit

class FillerWordsDetailViewController: UIViewController {
    private let fillerWords: [SpeechAnalysisResult.FillerWord]
    
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
    
    init(fillerWords: [SpeechAnalysisResult.FillerWord]) {
        self.fillerWords = fillerWords
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
        title = "Filler Words Analysis"
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
        
        addFillerWordsBreakdown()
        addSuggestions()
    }
    
    private func addFillerWordsBreakdown() {
        let titleLabel = UILabel()
        titleLabel.text = "Detected Filler Words"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        stackView.addArrangedSubview(titleLabel)
        
        fillerWords.forEach { fillerWord in
            let container = createFillerWordView(word: fillerWord.word, count: fillerWord.count)
            stackView.addArrangedSubview(container)
        }
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
        titleLabel.text = "💡 Tips for Improvement"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        
        let suggestions = [
            (icon: "🎯", title: "Pause and Think", message: "Take a moment to gather your thoughts instead of using filler words"),
            (icon: "🔄", title: "Replace with Silence", message: "Practice replacing filler words with brief, confident pauses"),
            (icon: "📝", title: "Prepare Transitions", message: "Plan your transitions between key points in advance"),
            (icon: "🎤", title: "Record and Review", message: "Record yourself and note when you use filler words most"),
            (icon: "⚡️", title: "Stay Confident", message: "Remember that occasional pauses show thoughtfulness")
        ]
        
        let suggestionsStackView = UIStackView()
        suggestionsStackView.axis = .vertical
        suggestionsStackView.spacing = 16
        suggestionsStackView.layoutMargins = UIEdgeInsets(top: 24, left: 16, bottom: 24, right: 16)
        suggestionsStackView.isLayoutMarginsRelativeArrangement = true
        
        [titleView, titleLabel, suggestionsStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        container.addSubview(titleView)
        titleView.addSubview(titleLabel)
        container.addSubview(suggestionsStackView)
        
        NSLayoutConstraint.activate([
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
        
        suggestions.forEach { suggestion in
            let suggestionView = createSuggestionView(
                icon: suggestion.icon,
                title: suggestion.title,
                message: suggestion.message
            )
            suggestionsStackView.addArrangedSubview(suggestionView)
        }
        
        stackView.addArrangedSubview(container)
    }
    
    private func createFillerWordView(word: String, count: Int) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 12
        
        let wordLabel = UILabel()
        wordLabel.text = "\"\(word)\""
        wordLabel.font = .systemFont(ofSize: 18, weight: .medium)
        
        let countLabel = UILabel()
        countLabel.text = "Used \(count) times"
        countLabel.font = .systemFont(ofSize: 16)
        countLabel.textColor = .secondaryLabel
        
        [wordLabel, countLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 60),
            
            wordLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            wordLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            countLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            countLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
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
    
    @objc private func dismissVC() {
        dismiss(animated: true)
    }
}

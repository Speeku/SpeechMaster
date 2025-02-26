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
        let titleLabel = UILabel()
        titleLabel.text = "Suggestions for Improvement"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        stackView.addArrangedSubview(titleLabel)
        
        let suggestions = [
            "Take a pause instead of using filler words",
            "Practice being comfortable with silence",
            "Prepare and rehearse your key points",
            "Record yourself to identify patterns",
            "Focus on speaking more slowly and deliberately"
        ]
        
        suggestions.forEach { suggestion in
            let label = UILabel()
            label.text = "• \(suggestion)"
            label.font = .systemFont(ofSize: 16)
            label.numberOfLines = 0
            stackView.addArrangedSubview(label)
        }
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
    
    @objc private func dismissVC() {
        dismiss(animated: true)
    }
} 
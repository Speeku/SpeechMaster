import UIKit

class OverallProgressCell: UICollectionViewCell {
    
    var dataSource = HomeViewModel.shared
    // MARK: - UI Elements
    private let circularProgressView: MultiColorCircularProgressView = {
        let view = MultiColorCircularProgressView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let overallPercentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.text = "0%"
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Overall Improvement"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    // Define a consistent color scheme at the top of the class
    private struct Colors {
        static let fillers = UIColor(hex: "1C1B4D")      // Navy blue
        static let missing = UIColor(hex: "B80E65")      // Pink/Magenta
        static let pronunciation = UIColor(hex: "1791B1") // Light blue
        
        static let background = UIColor.systemGray6.withAlphaComponent(0.2)
        static let improvement = UIColor.systemGreen
        static let decline = UIColor.systemRed
    }
    
    // Labels with colors
    private let fillersLabel: UILabel = createLabel(text: "Fillers", color: Colors.fillers)
    private let missingWordsLabel: UILabel = createLabel(text: "Missing Words", color: Colors.missing)
    private let pronunciationLabel: UILabel = createLabel(text: "Pronunciation", color: Colors.pronunciation)
    
    // Progress Views
    private let fillersProgressView = createProgressView(color: Colors.fillers)
    private let missingWordsProgressView = createProgressView(color: Colors.missing)
    private let pronunciationProgressView = createProgressView(color: Colors.pronunciation)
    
    // Value Labels
    private let fillersValueLabel = createValueLabel()
    private let missingWordsValueLabel = createValueLabel()
    private let pronunciationValueLabel = createValueLabel()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // MARK: - Setup
    private static func createLabel(text: String, color: UIColor) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = color
        return label
    }
    
    private static func createProgressView(color: UIColor) -> UIProgressView {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = color
        progressView.trackTintColor = Colors.background
        progressView.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)
        progressView.layer.cornerRadius = 2
        progressView.clipsToBounds = true
        return progressView
    }
    
    private static func createValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .right
        label.text = "0%"
        return label
    }
    
    private func setupViews() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 16
        
        [titleLabel, circularProgressView, overallPercentLabel,
         fillersLabel, fillersProgressView, fillersValueLabel,
         missingWordsLabel, missingWordsProgressView, missingWordsValueLabel,
         pronunciationLabel, pronunciationProgressView, pronunciationValueLabel
        ].forEach { contentView.addSubview($0) }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Title and circle
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            circularProgressView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            circularProgressView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            circularProgressView.widthAnchor.constraint(equalToConstant: 150),
            circularProgressView.heightAnchor.constraint(equalToConstant: 150),
            
            overallPercentLabel.centerXAnchor.constraint(equalTo: circularProgressView.centerXAnchor),
            overallPercentLabel.centerYAnchor.constraint(equalTo: circularProgressView.centerYAnchor),
            
            // Fillers section
            fillersLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 35),
            fillersLabel.leadingAnchor.constraint(equalTo: circularProgressView.trailingAnchor, constant: 24),
            
            fillersValueLabel.centerYAnchor.constraint(equalTo: fillersLabel.centerYAnchor),
            fillersValueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            fillersValueLabel.widthAnchor.constraint(equalToConstant: 60),
            
            fillersProgressView.topAnchor.constraint(equalTo: fillersLabel.bottomAnchor, constant: 4),
            fillersProgressView.leadingAnchor.constraint(equalTo: fillersLabel.leadingAnchor),
            fillersProgressView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            fillersProgressView.heightAnchor.constraint(equalToConstant: 6),
            
            // Missing Words section
            missingWordsLabel.topAnchor.constraint(equalTo: fillersProgressView.bottomAnchor, constant: 12),
            missingWordsLabel.leadingAnchor.constraint(equalTo: fillersLabel.leadingAnchor),
            
            missingWordsValueLabel.centerYAnchor.constraint(equalTo: missingWordsLabel.centerYAnchor),
            missingWordsValueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            missingWordsValueLabel.widthAnchor.constraint(equalToConstant: 60),
            
            missingWordsProgressView.topAnchor.constraint(equalTo: missingWordsLabel.bottomAnchor, constant: 4),
            missingWordsProgressView.leadingAnchor.constraint(equalTo: missingWordsLabel.leadingAnchor),
            missingWordsProgressView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            missingWordsProgressView.heightAnchor.constraint(equalToConstant: 6),
            
            // Pronunciation section
            pronunciationLabel.topAnchor.constraint(equalTo: missingWordsProgressView.bottomAnchor, constant: 12),
            pronunciationLabel.leadingAnchor.constraint(equalTo: fillersLabel.leadingAnchor),
            
            pronunciationValueLabel.centerYAnchor.constraint(equalTo: pronunciationLabel.centerYAnchor),
            pronunciationValueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            pronunciationValueLabel.widthAnchor.constraint(equalToConstant: 60),
            
            pronunciationProgressView.topAnchor.constraint(equalTo: pronunciationLabel.bottomAnchor, constant: 4),
            pronunciationProgressView.leadingAnchor.constraint(equalTo: pronunciationLabel.leadingAnchor),
            pronunciationProgressView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            pronunciationProgressView.heightAnchor.constraint(equalToConstant: 6),
        ])
    }
    
    // MARK: - Public Methods
    private func updateValueLabel(_ label: UILabel, improvement: Double) {
        let percentage = improvement * 100
        if percentage > 0 {
            label.text = String(format: "+%.0f%%", percentage)
            label.textColor = Colors.improvement
        } else {
            label.text = String(format: "%.0f%%", percentage)
            label.textColor = Colors.decline
        }
    }
    
    func updateProgress(currentSession: PerformanceReport?, previousSession: PerformanceReport?) {
        guard let current = currentSession, let previous = previousSession else {
            setEmptyState()
            return
        }
        
        // Calculate improvements - Note the negative sign for fillers and missing words
        let fillerImprovement = -calculateImprovement(  // Added negative sign
            current: current.fillerWords.count,
            previous: previous.fillerWords.count,
            maxValue: 30,
            lowerIsBetter: true
        )
        
        let missingImprovement = -calculateImprovement(  // Added negative sign
            current: current.missingWords.count,
            previous: previous.missingWords.count,
            maxValue: 20,
            lowerIsBetter: true
        )
        
        let pronunciationImprovement = 0.7 // Example value (positive is good)
        
        // Update progress views with animation
        UIView.animate(withDuration: 0.5) {
            self.fillersProgressView.progress = Float(abs(fillerImprovement))    // Use absolute value for progress
            self.missingWordsProgressView.progress = Float(abs(missingImprovement))
            self.pronunciationProgressView.progress = Float(pronunciationImprovement)
        }
        
        // Update improvement percentages (will show - for worse performance)
        updateValueLabel(fillersValueLabel, improvement: fillerImprovement)
        updateValueLabel(missingWordsValueLabel, improvement: missingImprovement)
        updateValueLabel(pronunciationValueLabel, improvement: pronunciationImprovement)
        
        // Update circular progress with absolute values
        circularProgressView.setSegmentValues(
            fillers: Int(abs(fillerImprovement) * 100),
            missing: Int(abs(missingImprovement) * 100),
            pronunciation: Int(pronunciationImprovement * 100)
        )
        
        // Calculate and display overall improvement
        let overallImprovement = (fillerImprovement + missingImprovement + pronunciationImprovement) / 3.0
        overallPercentLabel.text = String(format: "%.0f%%", abs(overallImprovement * 100))
    }
    
    private func calculateImprovement(current: Int, previous: Int, maxValue: Int, lowerIsBetter: Bool) -> Double {
        let currentNormalized = Double(current) / Double(maxValue)
        let previousNormalized = Double(previous) / Double(maxValue)
        
        if lowerIsBetter {
            return 1.0 - currentNormalized
        } else {
            return currentNormalized
        }
    }
    
    private func setEmptyState() {
        fillersProgressView.progress = 0
        missingWordsProgressView.progress = 0
        pronunciationProgressView.progress = 0
        
        fillersValueLabel.text = "0%"
        missingWordsValueLabel.text = "0%"
        pronunciationValueLabel.text = "0%"
        
        overallPercentLabel.text = "0%"
        circularProgressView.setSegmentValues(fillers: 0, missing: 0, pronunciation: 0)
    }
    
    func testWithSimpleValues() {
        // Update progress bars with actual values
        fillersProgressView.progress = 0.7     // 70% for fillers (green)
        missingWordsProgressView.progress = 0.1 // 10% for missing words (yellow)
        pronunciationProgressView.progress = 0.1 // 10% for pronunciation (blue)
        
        // Update percentage labels with same values
        updateValueLabel(fillersValueLabel, improvement: 0.7)     // +70%
        updateValueLabel(missingWordsValueLabel, improvement: 0.7) // +10%
        updateValueLabel(pronunciationValueLabel, improvement: 0.7) // +10%
        
        // Calculate overall improvement (average)
        let overallImprovement = dataSource.calculateOverallImprovement(for: dataSource.currentScriptID)
        overallPercentLabel.text = String(format: "%.0f%%", overallImprovement)
        
        // Update the circle with actual proportional values
        circularProgressView.setSegmentValues(
            fillers: 70,    // This will take up most of the circle since it's 70%
            missing: 70,    // Small segment for 10%
            pronunciation: 70 // Small segment for 10%
        )
    }
} 

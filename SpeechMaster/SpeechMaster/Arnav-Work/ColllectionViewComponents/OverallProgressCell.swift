import UIKit

class OverallProgressCell: UICollectionViewCell {
    
    var dataSource: HomeViewModel!
    var scriptId: UUID!
    
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
        
        // Dark mode versions of the colors (lighter versions for better visibility)
        static let fillersDark = UIColor(hex: "6B6AD6")    // Lighter navy blue
        static let missingDark = UIColor(hex: "FF5CA5")    // Lighter pink/magenta
        static let pronunciationDark = UIColor(hex: "67D5F5") // Lighter blue
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
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
        // Loading data will happen when dataSource and scriptId are set
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
        // Get the current trait collection to check for dark mode
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        
        // Set cell background color based on mode
        backgroundColor = isDarkMode ? UIColor(white: 0.2, alpha: 1.0) : .systemBackground
        
        // Apply corner radius to both the cell and content view
        layer.cornerRadius = 16
        contentView.layer.cornerRadius = 16
        
        // Ensure clipping is enabled for the content view as well
        layer.masksToBounds = true
        contentView.clipsToBounds = true
        
        // Fix for corner radius in dark mode - ensure frame is set properly
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        // Update label colors based on dark mode
        updateColorsForTraitCollection()
        
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
    
    // Add a method to handle color updates when dark mode changes
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColorsForTraitCollection()
        }
    }
    
    private func updateColorsForTraitCollection() {
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        
        // Update cell background - match the exact color used in CompareCollectionViewCell
        backgroundColor = isDarkMode ? UIColor(white: 0.22, alpha: 1.0) : .systemBackground
        
        // Update label colors
        titleLabel.textColor = isDarkMode ? .white : .black
        overallPercentLabel.textColor = isDarkMode ? .white : .black
        
        // Update metric labels with appropriate colors for dark/light mode
        fillersLabel.textColor = isDarkMode ? Colors.fillersDark : Colors.fillers
        missingWordsLabel.textColor = isDarkMode ? Colors.missingDark : Colors.missing
        pronunciationLabel.textColor = isDarkMode ? Colors.pronunciationDark : Colors.pronunciation
        
        // Also update progress view colors
        fillersProgressView.progressTintColor = isDarkMode ? Colors.fillersDark : Colors.fillers
        missingWordsProgressView.progressTintColor = isDarkMode ? Colors.missingDark : Colors.missing
        pronunciationProgressView.progressTintColor = isDarkMode ? Colors.pronunciationDark : Colors.pronunciation
        
        // Update value labels
        updateColorsForValueLabels()
    }
    
    private func updateColorsForValueLabels() {
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        
        // Only update color if not already set by improvement/decline logic
        if let text = fillersValueLabel.text, text == "0%" {
            fillersValueLabel.textColor = isDarkMode ? .lightGray : .darkGray
        }
        
        if let text = missingWordsValueLabel.text, text == "0%" {
            missingWordsValueLabel.textColor = isDarkMode ? .lightGray : .darkGray
        }
        
        if let text = pronunciationValueLabel.text, text == "0%" {
            pronunciationValueLabel.textColor = isDarkMode ? .lightGray : .darkGray
        }
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
        
        updateColorsForValueLabels()
        
        overallPercentLabel.text = "0%"
        overallPercentLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .white : .black
        
        circularProgressView.setSegmentValues(fillers: 0, missing: 0, pronunciation: 0)
    }
    
    func loadImprovementData() {
        // Make sure we have the required data
        guard dataSource != nil && scriptId != nil else {
            print("Cannot load improvement data: dataSource or scriptId is nil")
            return
        }
        
        Task {
            do {
                // Fetch all improvement metrics asynchronously
                let fillerImprovement = await dataSource.calculateFillerWordsImprovement(for: scriptId)
                let missingImprovement = await dataSource.calculateMissingWordsImprovement(for: scriptId)
                let pronunciationImprovement = await dataSource.calculatePronunciationImprovement(for: scriptId)
                let overallImprovement = await dataSource.calculateOverallImprovement(for: scriptId)
                
                // Update UI on main thread
                await MainActor.run {
                    // Update percentage labels with actual improvement values
                    updateValueLabel(fillersValueLabel, improvement: fillerImprovement / 100)
                    updateValueLabel(missingWordsValueLabel, improvement: missingImprovement / 100)
                    updateValueLabel(pronunciationValueLabel, improvement: pronunciationImprovement / 100)
                    
                    // Update overall percentage
                    overallPercentLabel.text = String(format: "%.0f%%", overallImprovement)
                    
                    // Update the circle with actual proportional values
                    circularProgressView.setSegmentValues(
                        fillers: Int(abs(fillerImprovement)),
                        missing: Int(abs(missingImprovement)),
                        pronunciation: Int(abs(pronunciationImprovement))
                    )
                    
                    // Update progress bars
                    fillersProgressView.progress = Float(abs(fillerImprovement) / 100)
                    missingWordsProgressView.progress = Float(abs(missingImprovement) / 100)
                    pronunciationProgressView.progress = Float(abs(pronunciationImprovement) / 100)
                }
            } catch {
                print("Error loading improvement data: \(error)")
            }
        }
    }
} 

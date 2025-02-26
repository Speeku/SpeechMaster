import UIKit
import AVFoundation
import AVKit
import Photos

class PerformanceResultsViewController: UIViewController {
    let ds = HomeViewModel.shared
    var scriptId: UUID = HomeViewModel.shared.currentScriptID // Add this property to store the script ID
    var sessionName: String = ""
    private let results: SpeechAnalysisResult
    private let videoURL: URL?
    
    // Add motivational quotes
    private let motivationalQuotes = [
        "Every speech is a chance to make an impact.",
        "Progress is better than perfection.",
        "Great speakers are made, not born.",
        "Your voice has power. Use it wisely.",
        "Each practice brings you closer to mastery.",
        "Confidence comes from preparation.",
        "Your story matters. Tell it well.",
        "Small improvements lead to big results.",
        "Every great speaker was once a beginner.",
        "Your next speech will be even better."
    ]
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = 20
        sv.alignment = .fill
        return sv
    }()
    
    private let videoPlayerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let quoteView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemIndigo
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let quoteLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let quoteIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .white.withAlphaComponent(0.3)
        imageView.contentMode = .scaleAspectFit
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        imageView.image = UIImage(systemName: "quote.bubble.fill", withConfiguration: config)
        return imageView
    }()
    
    private let videoThumbnailButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        return button
    }()
    
    // MARK: - Video Player Properties
    private var videoPlayer: AVPlayer?
    private var videoPlayerLayer: AVPlayerLayer?
    
    // MARK: - Initialization
    init(results: SpeechAnalysisResult, videoURL: URL?) {
        self.results = results
        self.videoURL = videoURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1.0) // #F2F2F7
        scrollView.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1.0)
        setupNavigationBar()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPlayerLayer?.frame = videoPlayerView.bounds
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Performance Results"
        view.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1.0) // #F2F2F7
        scrollView.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1.0)
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        // Reduce spacing between stack view items
        stackView.spacing = 12 // Reduced from 24 to 12
        
        // Setup quote view
        setupQuoteView()
        
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
        
        // Add video player view with proper constraints
        if videoURL != nil {
            setupVideoPlayer()
            stackView.addArrangedSubview(videoPlayerView)
            
            // Increase video height
            NSLayoutConstraint.activate([
                videoPlayerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2), 
                videoPlayerView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
                videoPlayerView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
            ])
        }
        
        // Add views to stack in the correct order
        stackView.insertArrangedSubview(quoteView, at: 0)
        stackView.setCustomSpacing(12, after: quoteView) // Reduced from 24 to 12
        
        addSummarySection()
        addFillerWordsSection()
        addMissingWordsSection()
        addPaceSection()
        addPronunciationSection()
        
        // Add Pitch Analysis Section
        let pitchGraphView = PitchGraphView(duration: results.totalDuration)
        pitchGraphView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(pitchGraphView)
        
        NSLayoutConstraint.activate([
            pitchGraphView.heightAnchor.constraint(equalToConstant: 280),
            pitchGraphView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            pitchGraphView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
        ])
        
        // Add shadow and border to pitch graph view
        pitchGraphView.layer.shadowColor = UIColor.black.cgColor
        pitchGraphView.layer.shadowOffset = CGSize(width: 0, height: 2)
        pitchGraphView.layer.shadowRadius = 4
        pitchGraphView.layer.shadowOpacity = 0.1
        
        // Make sure it's added in the correct order (after pace meter)
        stackView.setCustomSpacing(24, after: pitchGraphView)
    }
    
    private func setupQuoteView() {
        quoteView.addSubview(quoteIconImageView)
        quoteView.addSubview(quoteLabel)
        
        NSLayoutConstraint.activate([
            quoteView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            quoteIconImageView.topAnchor.constraint(equalTo: quoteView.topAnchor, constant: 16),
            quoteIconImageView.leadingAnchor.constraint(equalTo: quoteView.leadingAnchor, constant: 16),
            quoteIconImageView.widthAnchor.constraint(equalToConstant: 40),
            quoteIconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            quoteLabel.topAnchor.constraint(equalTo: quoteView.topAnchor, constant: 16),
            quoteLabel.leadingAnchor.constraint(equalTo: quoteIconImageView.trailingAnchor, constant: 12),
            quoteLabel.trailingAnchor.constraint(equalTo: quoteView.trailingAnchor, constant: -16),
            quoteLabel.bottomAnchor.constraint(equalTo: quoteView.bottomAnchor, constant: -16)
        ])
        
        // Set random quote
        quoteLabel.text = motivationalQuotes.randomElement()
    }
    
    private func setupVideoPlayer() {
        guard let videoURL = videoURL,
              FileManager.default.fileExists(atPath: videoURL.path) else { 
            print("Video file not found at path")
            return 
        }
        
        // Create AVPlayer and AVPlayerLayer
        videoPlayer = AVPlayer(url: videoURL)
        videoPlayerLayer = AVPlayerLayer(player: videoPlayer)
        videoPlayerLayer?.videoGravity = .resizeAspect
        
        if let layer = videoPlayerLayer {
            videoPlayerView.layer.addSublayer(layer)
            layer.frame = videoPlayerView.bounds
            
            // Add thumbnail button over the video view
            videoPlayerView.addSubview(videoThumbnailButton)
            NSLayoutConstraint.activate([
                videoThumbnailButton.topAnchor.constraint(equalTo: videoPlayerView.topAnchor),
                videoThumbnailButton.leadingAnchor.constraint(equalTo: videoPlayerView.leadingAnchor),
                videoThumbnailButton.trailingAnchor.constraint(equalTo: videoPlayerView.trailingAnchor),
                videoThumbnailButton.bottomAnchor.constraint(equalTo: videoPlayerView.bottomAnchor)
            ])
            
            videoThumbnailButton.addTarget(self, action: #selector(openFullScreenVideo), for: .touchUpInside)
            
            // Create play button with larger size
            let playButton = UIButton()
            playButton.translatesAutoresizingMaskIntoConstraints = false
            let config = UIImage.SymbolConfiguration(pointSize: 60, weight: .medium)
            playButton.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: config), for: .normal)
            playButton.tintColor = .white
            playButton.addTarget(self, action: #selector(togglePlayback), for: .touchUpInside)
            
            videoPlayerView.addSubview(playButton)
            NSLayoutConstraint.activate([
                playButton.centerXAnchor.constraint(equalTo: videoPlayerView.centerXAnchor),
                playButton.centerYAnchor.constraint(equalTo: videoPlayerView.centerYAnchor),
                playButton.widthAnchor.constraint(equalToConstant: 80),
                playButton.heightAnchor.constraint(equalToConstant: 80)
            ])
            
            // Add observer for video end
            NotificationCenter.default.addObserver(self,
                                                 selector: #selector(videoDidEnd),
                                                 name: .AVPlayerItemDidPlayToEndTime,
                                                 object: videoPlayer?.currentItem)
        }
    }
    
    @objc private func videoDidEnd() {
        // Reset video to beginning when it ends
        videoPlayer?.seek(to: .zero)
        videoPlayer?.pause()
    }
    
    @objc private func togglePlayback() {
        if videoPlayer?.rate == 0 {
            videoPlayer?.play()
        } else {
            videoPlayer?.pause()
        }
    }
    
    @objc private func openFullScreenVideo() {
        guard let videoURL = videoURL else { return }
        
        let fullScreenPlayer = AVPlayerViewController()
        fullScreenPlayer.player = AVPlayer(url: videoURL)
        
        // Configure player settings
        fullScreenPlayer.showsPlaybackControls = true
        fullScreenPlayer.videoGravity = .resizeAspect
        fullScreenPlayer.allowsPictureInPicturePlayback = true
        
        // Present the full screen player
        present(fullScreenPlayer, animated: true) {
            fullScreenPlayer.player?.play()
        }
    }
    
    // MARK: - Section Helpers
    private func addSummarySection() {
        let summaryView = createSummaryView(
            totalTime: formatDuration(results.totalDuration),
            expectedTime: formatDuration(results.expectedDuration)
        )
        stackView.addArrangedSubview(summaryView)
    }
    
    private func addFillerWordsSection() {
        let totalCount = results.fillerWords.reduce(0) { $0 + $1.count }
        let container = createFillerWordsView(count: totalCount)
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(fillerWordsSectionTapped))
        container.addGestureRecognizer(tapGesture)
        container.isUserInteractionEnabled = true
        
        stackView.addArrangedSubview(container)
    }
    
    private func addMissingWordsSection() {
        let container = createMissingWordsView(count: results.missingWords.count)
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(missingWordsSectionTapped))
        container.addGestureRecognizer(tapGesture)
        container.isUserInteractionEnabled = true
        
        stackView.addArrangedSubview(container)
    }
    
    private func addPronunciationSection() {
        let container = createPronunciationView(errors: results.pronunciationErrors)
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pronunciationSectionTapped))
        container.addGestureRecognizer(tapGesture)
        container.isUserInteractionEnabled = true
        
        stackView.addArrangedSubview(container)
    }
    
    private func addPaceSection() {
        let paceView = createPaceView(
            wordsPerMinute: results.averageWordsPerMinute,
            spokenWords: results.spokenWordCount,
            scriptWords: results.scriptWordCount
        )
        stackView.addArrangedSubview(paceView)
    }
    
    // MARK: - UI Component Factories
    private func createSummaryView(totalTime: String, expectedTime: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.systemGray4.cgColor
        
        let titleLabel = UILabel()
        titleLabel.text = "Summary"
        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let totalTimeLabel = createDetailLabel(title: "Total Time", value: totalTime)
        let expectedTimeLabel = createDetailLabel(title: "Expected Time", value: expectedTime)
        
        let detailsStack = UIStackView(arrangedSubviews: [totalTimeLabel, expectedTimeLabel])
        detailsStack.axis = .vertical
        detailsStack.spacing = 4 // Reduced spacing between time labels
        detailsStack.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(titleLabel)
        container.addSubview(detailsStack)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            detailsStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            detailsStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            detailsStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            detailsStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])
        
        return container
    }
    
    private func createDetailLabel(title: String, value: String) -> UIView {
        let container = UIView()
        container.heightAnchor.constraint(equalToConstant: 28).isActive = true // Reduced height
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.textColor = .secondaryLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 16, weight: .medium)
        valueLabel.textAlignment = .right
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(titleLabel)
        container.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 16)
        ])
        
        return container
    }
    
    private func createDetailView(title: String, items: [(String, String)]) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.systemGray4.cgColor
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        
        [titleLabel, stackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview($0)
        }
        
        items.forEach { item in
            let rowStack = UIStackView()
            rowStack.spacing = 8
            
            let keyLabel = UILabel()
            keyLabel.text = item.0
            keyLabel.font = .systemFont(ofSize: 16)
            
            let valueLabel = UILabel()
            valueLabel.text = item.1
            valueLabel.font = .systemFont(ofSize: 16, weight: .medium)
            valueLabel.textAlignment = .right
            
            [keyLabel, valueLabel].forEach { rowStack.addArrangedSubview($0) }
            stackView.addArrangedSubview(rowStack)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
        
        return container
    }
    
    private func createListView(title: String, items: [String]) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.systemGray4.cgColor
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        
        [titleLabel, stackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview($0)
        }
        
        if items.isEmpty {
            let noneLabel = UILabel()
            noneLabel.text = "None detected"
            noneLabel.font = .systemFont(ofSize: 16)
            noneLabel.textColor = .systemGray
            stackView.addArrangedSubview(noneLabel)
        } else {
            items.forEach { item in
                let itemLabel = UILabel()
                itemLabel.text = "• \(item)"
                itemLabel.font = .systemFont(ofSize: 16)
                itemLabel.numberOfLines = 0
                stackView.addArrangedSubview(itemLabel)
            }
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
        
        return container
    }
    
    private func createFillerWordsView(count: Int) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.systemGray4.cgColor
        
        let titleLabel = UILabel()
        titleLabel.text = "Filler Words"
        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        
        let countLabel = UILabel()
        countLabel.text = "\(count) detected"
        countLabel.font = .systemFont(ofSize: 16)
        countLabel.textColor = count > 0 ? .systemRed : .systemGreen
        
        let arrowImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrowImageView.tintColor = .systemGray3
        
        [titleLabel, countLabel, arrowImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            countLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            countLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -8),
            
            arrowImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            arrowImageView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            arrowImageView.widthAnchor.constraint(equalToConstant: 12),
            arrowImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        return container
    }
    
    private func createMissingWordsView(count: Int) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.systemGray4.cgColor
        
        let titleLabel = UILabel()
        titleLabel.text = "Missing Words"
        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        
        let countLabel = UILabel()
        countLabel.text = "\(count) detected"
        countLabel.font = .systemFont(ofSize: 16)
        countLabel.textColor = count > 0 ? .systemRed : .systemGreen
        
        let arrowImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrowImageView.tintColor = .systemGray3
        
        [titleLabel, countLabel, arrowImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            countLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            countLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -8),
            
            arrowImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            arrowImageView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            arrowImageView.widthAnchor.constraint(equalToConstant: 12),
            arrowImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        return container
    }
    
    private func createPaceView(wordsPerMinute: Double, spokenWords: Int, scriptWords: Int) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.systemGray4.cgColor
        
        let titleLabel = UILabel()
        titleLabel.text = "Pace"
        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let paceMeterView = PaceMeterView(wordsPerMinute: Int(wordsPerMinute))
        paceMeterView.translatesAutoresizingMaskIntoConstraints = false
        
        let statsStack = createPaceStatsStack(spokenWords: spokenWords, scriptWords: scriptWords)
        statsStack.translatesAutoresizingMaskIntoConstraints = false
        
        [titleLabel, paceMeterView, statsStack].forEach { container.addSubview($0) }
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 240),
            
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            
            paceMeterView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            paceMeterView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            paceMeterView.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.8),
            paceMeterView.heightAnchor.constraint(equalTo: paceMeterView.widthAnchor, multiplier: 0.5),
            
            statsStack.topAnchor.constraint(equalTo: paceMeterView.bottomAnchor, constant: 16),
            statsStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            statsStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            statsStack.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -16)
        ])
        
        return container
    }
    
    private func createPaceStatsStack(spokenWords: Int, scriptWords: Int) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        
        let spokenWordsLabel = createStatLabel(title: "Total Words Spoken", value: "\(spokenWords)")
        let scriptWordsLabel = createStatLabel(title: "Script Word Count", value: "\(scriptWords)")
        
        [spokenWordsLabel, scriptWordsLabel].forEach { stack.addArrangedSubview($0) }
        
        return stack
    }
    
    private func createStatLabel(title: String, value: String) -> UIView {
        let container = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.textColor = .secondaryLabel
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 16, weight: .medium)
        valueLabel.textAlignment = .right
        
        [titleLabel, valueLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            container.heightAnchor.constraint(equalToConstant: 28)
        ])
        
        return container
    }
    
    private func createPronunciationView(errors: [SpeechAnalysisResult.PronunciationError]) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.systemGray4.cgColor
        
        let titleLabel = UILabel()
        titleLabel.text = "Pronunciation"
        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        
        // Get unique error count
        let uniqueErrors = Set(errors.map { $0.word })
        let countLabel = UILabel()
        countLabel.text = "\(uniqueErrors.count) detected"
        countLabel.font = .systemFont(ofSize: 16)
        countLabel.textColor = uniqueErrors.count > 0 ? .systemRed : .systemGreen
        
        let arrowImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrowImageView.tintColor = .systemGray3
        
        [titleLabel, countLabel, arrowImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            countLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            countLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -8),
            
            arrowImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            arrowImageView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            arrowImageView.widthAnchor.constraint(equalToConstant: 12),
            arrowImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        return container
    }
    
    @objc private func fillerWordsSectionTapped() {
        let vc = FillerWordsDetailViewController(fillerWords: results.fillerWords)
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    
    @objc private func missingWordsSectionTapped() {
        let vc = MissingWordsDetailViewController(missingWords: results.missingWords)
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    
    @objc private func pronunciationSectionTapped() {
        let vc = PronunciationDetailViewController(pronunciationErrors: results.pronunciationErrors)
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    
    // MARK: - Helpers
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    deinit {
        // Remove observer when view controller is deallocated
        NotificationCenter.default.removeObserver(self)
        videoPlayer?.pause()
        videoPlayer = nil
        videoPlayerLayer = nil
    }
    
    private func setupNavigationBar() {
        let saveButton = UIBarButtonItem(
            title: "Save",
            style: .done,
            target: self,
            action: #selector(saveReportTapped)
        )
        navigationItem.rightBarButtonItem = saveButton
    }
    
    @objc private func saveReportTapped() {
        // Create alert controller for name input
        let alert = UIAlertController(
            title: "Save Performance Report",
            message: "Enter a name for this practice session",
            preferredStyle: .alert
        )
        
        // Add text field for name input
        alert.addTextField { textField in
            textField.placeholder = "Session Name"
        }
        
        // Add save action
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self,
                  let name = alert.textFields?.first?.text,
                  !name.isEmpty else { return }
            
            // First, request photo library permission
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] status in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    switch status {
                    case .authorized, .limited:
                        self.saveVideoAndReport(name: name)
                    default:
                        self.showError("Permission to save video was denied. Please enable access to Photos in Settings.")
                    }
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func saveVideoAndReport(name: String) {
        // Set the session name
        self.sessionName = name
        
        guard let videoURL = self.videoURL else {
            // Save report without video if no video URL is available
            saveReportOnly(name: name)
            return
        }
        
        // Save video to Photos
        PHPhotoLibrary.shared().performChanges {
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .video, fileURL: videoURL, options: nil)
        } completionHandler: { [weak self] success, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if success {
                    // Delete the video file from app storage
                    do {
                        try FileManager.default.removeItem(at: videoURL)
                        print("Successfully deleted video file from app storage")
                    } catch {
                        print("Error deleting video file: \(error.localizedDescription)")
                    }
                    // Create a new session
                    let newSession = PracticeSession(id: UUID(),
                                                   scriptId: self.scriptId,
                                                   createdAt: Date(),
                                                   title: self.sessionName)
                    // Create and save the report without video URL
                    let newReport = PerformanceReport(sessionID: newSession.id, wordsPerMinute: Int(self.results.averageWordsPerMinute), fillerWords: self.results.fillerWords, missingWords: self.results.missingWords, pronunciationErrors: self.results.pronunciationErrors, duration: self.results.totalDuration, videoURL: nil)
                    
                    // Save Session and Report
                    self.ds.addSession(newSession)
                    self.ds.addPerformanceReport(newReport)
                    self.showSuccessAndDismiss(message: "Performance report and video saved to Photos")
                } else {
                    self.showError("Failed to save video: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    private func saveReportOnly(name: String) {
        // Set the session name
        self.sessionName = name
        
        let newSession = PracticeSession(id: UUID(),
                                       scriptId: self.scriptId,
                                       createdAt: Date(),
                                       title: self.sessionName)
        // Create and save the report without video URL
        let newReport = PerformanceReport(sessionID: newSession.id, wordsPerMinute: Int(self.results.averageWordsPerMinute), fillerWords: self.results.fillerWords, missingWords: self.results.missingWords, pronunciationErrors: self.results.pronunciationErrors, duration: self.results.totalDuration, videoURL: nil)
        
        // Save Session and Report
        self.ds.addSession(newSession)
        self.ds.addPerformanceReport(newReport)
        
        showSuccessAndDismiss(message: "Performance report saved successfully")
    }
    
    private func showSuccessAndDismiss(message: String) {
        let successAlert = UIAlertController(
            title: "Success",
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            // Pop to root view controller
            self?.navigationController?.popToRootViewController(animated: true)
        }
        
        successAlert.addAction(okAction)
        present(successAlert, animated: true)
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
} 

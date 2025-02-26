import UIKit
import AVFoundation
import QuickLook

class PerformanceViewController: UIViewController, QLPreviewControllerDataSource, PerformanceSettingsDelegate, AVCaptureFileOutputRecordingDelegate {
    private var ds = HomeViewModel.shared
    private var keynotePreviewController: QLPreviewController?
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .monospacedDigitSystemFont(ofSize: 20, weight: .medium)
        label.text = "00:00"
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .label
        return button
    }()
    
    private let cameraView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()
    
    private let bottomBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black.withAlphaComponent(0.3)
        return view
    }()
    
    private let controlsStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.distribution = .equalSpacing
        sv.alignment = .center
        sv.spacing = 20
        return sv
    }()
    
    private lazy var settingsButton: UIButton = createControlButton(
        icon: "gearshape.fill",
        action: #selector(settingsTapped)
    )
    
    private lazy var scriptButton: UIButton = {
        let button = createControlButton(
            icon: "doc.text.fill",
            action: #selector(scriptTapped)
        )
        return button
    }()
    
    private lazy var recordButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "record.circle.fill"), for: .normal)
        button.tintColor = .systemRed
        button.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 64),
            button.heightAnchor.constraint(equalToConstant: 64)
        ])
        return button
    }()
    
    private lazy var pauseButton: UIButton = createControlButton(
        icon: "pause.fill",
        action: #selector(pauseTapped)
    )
    
    private lazy var coachButton: UIButton = createControlButton(
        icon: "person.fill",
        action: #selector(coachTapped)
    )
    
    private var isRecording = false
    private var isPaused = false
    private var timer: Timer?
    private var elapsedTime: TimeInterval = 0
    private var speechAnalyzer: SpeechAnalyzer?
    
    private let scriptTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = .systemFont(ofSize: 18)
        tv.isEditable = false
        tv.backgroundColor = .systemBackground
        tv.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        return tv
    }()
    
    private let keynoteContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let scriptPreviewGradientView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // Create gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.3).cgColor
        ]
        gradientLayer.locations = [0.0, 0.5]
        view.layer.addSublayer(gradientLayer)
        
        return view
    }()
    
    private let scriptPreviewTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = .systemFont(ofSize: 26, weight: .medium)
        tv.backgroundColor = .clear
        tv.textColor = .white
        tv.isEditable = false
        tv.isScrollEnabled = true
        tv.textAlignment = .center
        tv.contentInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        tv.showsVerticalScrollIndicator = false
        return tv
    }()
    
    private let settingsPopupView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 8
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.isHidden = true
        view.alpha = 0
        return view
    }()
    
    private let scriptSizeSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 16
        slider.maximumValue = 40
        slider.value = 26 // Default font size
        return slider
    }()
    
    private let scrollSpeedSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 1
        slider.maximumValue = 10
        slider.value = 5 // Default speed
        return slider
    }()
    
    private let autoScrollSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    
    // Add this property to track the current height constraint
    private var keynoteHeightConstraint: NSLayoutConstraint?
    
    // Add this property to track script visibility
    private var isScriptVisible: Bool = true {
        didSet {
            updateScriptButtonIcon()
            scriptPreviewTextView.isHidden = !isScriptVisible
            scriptPreviewGradientView.isHidden = !isScriptVisible
        }
    }
    
    // Add these properties
    private var scrollTimer: Timer?
    private var scrollSpeed: Float = 5.0 // Default speed
    private var videoOutputURL: URL?
    private var videoWriter: AVAssetWriter?
    private var videoWriterInput: AVAssetWriterInput?
    private var isAutoScrollEnabled: Bool = false
    
    // Add properties
    private var coachView: CoachView?
    private var isCoachEnabled = false
    private var speechMonitorTimer: Timer?
    private var currentWordCount = 0
    private var lastUpdateTime = Date()
    
    // Add property to track words for accurate pace calculation
    private var wordCount = 0
    private var speakingStartTime: Date?
    
    // Add these properties
    private struct SettingsKeys {
        static let scriptSize = "scriptSize"
        static let scrollSpeed = "scrollSpeed"
        static let autoScroll = "autoScroll"
        static let previewRatio = "previewRatio"
    }
    
    // Add property to track current ratio if not already present
    private var currentPreviewRatio: PreviewRatio = .thirty70 {
        didSet {
            UserDefaults.standard.set(currentPreviewRatio.rawValue, forKey: SettingsKeys.previewRatio)
        }
    }
    
    // Add these properties at the top of PerformanceViewController
    private var videoRecordingOutput: AVCaptureMovieFileOutput?
    private var recordedVideoURL: URL? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent("performance_recording.mp4")
    }
    
    var currentKeynoteURL: URL?
    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSavedSettings()
        // Set timer as navigation title
        navigationItem.titleView = timerLabel
        setupUI()
        setupCamera()
        loadKeynote()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update video preview layer frame
        videoPreviewLayer?.frame = cameraView.bounds
        
        // Update gradient layer frame
        if let gradientLayer = scriptPreviewGradientView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = scriptPreviewGradientView.bounds
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Remove back button since we're using navigation bar's back button
        // [cameraView, keynoteContainerView, bottomBackgroundView, controlsStackView, backButton, timerLabel]
        [cameraView, keynoteContainerView, bottomBackgroundView, scriptPreviewGradientView, scriptPreviewTextView, controlsStackView, settingsPopupView].forEach {
            view.addSubview($0)
        }
        
        // Add control buttons to stack view
        [settingsButton, scriptButton, recordButton, pauseButton, coachButton].forEach {
            controlsStackView.addArrangedSubview($0)
        }
        
        let scriptSizeLabel = createSettingLabel(text: "Script Size")
        let scrollSpeedLabel = createSettingLabel(text: "Scroll Speed")
        let autoScrollLabel = createSettingLabel(text: "Auto Scroll (Voice Match)")
        
        [scriptSizeLabel, scriptSizeSlider, scrollSpeedLabel, scrollSpeedSlider, 
         autoScrollLabel, autoScrollSwitch].forEach {
            settingsPopupView.addSubview($0)
        }
        
        // Update the keynote container constraint setup
        keynoteHeightConstraint = keynoteContainerView.heightAnchor.constraint(
            equalTo: view.heightAnchor, 
            multiplier: 0.3
        )
        
        NSLayoutConstraint.activate([
            // Keynote container - edge to edge, just below navigation bar
            keynoteContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            keynoteContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keynoteContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keynoteHeightConstraint!,  // Use the stored constraint
            
            // Camera view - edge to edge and fills remaining space
            cameraView.topAnchor.constraint(equalTo: keynoteContainerView.bottomAnchor),
            cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Gradient view constraints - same frame as scriptPreviewTextView
            scriptPreviewGradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scriptPreviewGradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scriptPreviewGradientView.bottomAnchor.constraint(equalTo: controlsStackView.topAnchor, constant: -6),
            scriptPreviewGradientView.heightAnchor.constraint(equalToConstant: 80),
            
            // Script preview text view constraints
            scriptPreviewTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scriptPreviewTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scriptPreviewTextView.bottomAnchor.constraint(equalTo: controlsStackView.topAnchor, constant: -6),
            scriptPreviewTextView.heightAnchor.constraint(equalToConstant: 80), // Height for approximately 2 lines
            
            // Controls stack view - moved to absolute bottom
            controlsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            controlsStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            
            // Bottom black background for buttons - adjusted to match new button position
            bottomBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomBackgroundView.heightAnchor.constraint(equalToConstant: 100),
            
            // Settings popup constraints
            settingsPopupView.leadingAnchor.constraint(equalTo: settingsButton.leadingAnchor, constant: -16),
            settingsPopupView.bottomAnchor.constraint(equalTo: settingsButton.topAnchor, constant: -8),
            settingsPopupView.widthAnchor.constraint(equalToConstant: 280),
            
            // Settings controls constraints
            scriptSizeLabel.topAnchor.constraint(equalTo: settingsPopupView.topAnchor, constant: 16),
            scriptSizeLabel.leadingAnchor.constraint(equalTo: settingsPopupView.leadingAnchor, constant: 16),
            
            scriptSizeSlider.topAnchor.constraint(equalTo: scriptSizeLabel.bottomAnchor, constant: 8),
            scriptSizeSlider.leadingAnchor.constraint(equalTo: settingsPopupView.leadingAnchor, constant: 16),
            scriptSizeSlider.trailingAnchor.constraint(equalTo: settingsPopupView.trailingAnchor, constant: -16),
            
            scrollSpeedLabel.topAnchor.constraint(equalTo: scriptSizeSlider.bottomAnchor, constant: 16),
            scrollSpeedLabel.leadingAnchor.constraint(equalTo: settingsPopupView.leadingAnchor, constant: 16),
            
            scrollSpeedSlider.topAnchor.constraint(equalTo: scrollSpeedLabel.bottomAnchor, constant: 8),
            scrollSpeedSlider.leadingAnchor.constraint(equalTo: settingsPopupView.leadingAnchor, constant: 16),
            scrollSpeedSlider.trailingAnchor.constraint(equalTo: settingsPopupView.trailingAnchor, constant: -16),
            
            autoScrollLabel.topAnchor.constraint(equalTo: scrollSpeedSlider.bottomAnchor, constant: 16),
            autoScrollLabel.leadingAnchor.constraint(equalTo: settingsPopupView.leadingAnchor, constant: 16),
            
            autoScrollSwitch.centerYAnchor.constraint(equalTo: autoScrollLabel.centerYAnchor),
            autoScrollSwitch.trailingAnchor.constraint(equalTo: settingsPopupView.trailingAnchor, constant: -16),
        ])
        
        // Update regular control buttons with smaller size
        let buttonConfigs = [
            (settingsButton, "gearshape.fill"),
            (scriptButton, "doc.text.fill"),
            (pauseButton, "pause.fill"),
            (coachButton, "person.fill")
        ]
        
        buttonConfigs.forEach { (button, iconName) in
            button.tintColor = .white
            let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
            let image = UIImage(systemName: iconName)?.withConfiguration(config)
            button.setImage(image, for: .normal)
            button.adjustsImageWhenHighlighted = false
            
            // Create fixed size constraints for regular buttons (smaller size)
            let widthConstraint = button.widthAnchor.constraint(equalToConstant: 44)
            let heightConstraint = button.heightAnchor.constraint(equalToConstant: 44)
            widthConstraint.priority = .required
            heightConstraint.priority = .required
            NSLayoutConstraint.activate([widthConstraint, heightConstraint])
        }
        
        // Configure record button with larger size
        let recordConfig = UIImage.SymbolConfiguration(pointSize: 44, weight: .semibold)
        let recordImage = UIImage(systemName: "record.circle.fill")?.withConfiguration(recordConfig)
        recordButton.setImage(recordImage, for: .normal)
        recordButton.adjustsImageWhenHighlighted = false
        
        // Create fixed size constraints for record button (larger size)
        let recordWidthConstraint = recordButton.widthAnchor.constraint(equalToConstant: 88)
        let recordHeightConstraint = recordButton.heightAnchor.constraint(equalToConstant: 88)
        recordWidthConstraint.priority = .required
        recordHeightConstraint.priority = .required
        NSLayoutConstraint.activate([recordWidthConstraint, recordHeightConstraint])
        
        recordButton.tintColor = .systemRed
        
        // Set the script content
        scriptPreviewTextView.text = ds.getScriptText(for: ds.currentScriptID)
        
        // Add gesture recognizer for preview size adjustment
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePreviewResize(_:)))
        view.addGestureRecognizer(panGesture)
        
        // Add targets for settings controls
        scriptSizeSlider.addTarget(self, action: #selector(scriptSizeChanged(_:)), for: .valueChanged)
        scrollSpeedSlider.addTarget(self, action: #selector(scrollSpeedChanged(_:)), for: .valueChanged)
        autoScrollSwitch.addTarget(self, action: #selector(autoScrollToggled(_:)), for: .valueChanged)
    }
    
    private func createControlButton(icon: String, action: Selector) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
        let image = UIImage(systemName: icon)?.withConfiguration(config)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: action, for: .touchUpInside)
        button.adjustsImageWhenHighlighted = false  // Disable size change on tap
        return button
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }
        
        // Configure capture session for high quality video
        captureSession.sessionPreset = .high
        
        // Get front camera
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, 
                                                       for: .video,
                                                       position: .front) else {
            print("Front camera not available")
            return
        }
        
        // Get microphone
        guard let microphone = AVCaptureDevice.default(for: .audio) else {
            print("Microphone not available")
            return
        }
        
        do {
            // Add video input
            let videoInput = try AVCaptureDeviceInput(device: frontCamera)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }
            
            // Add audio input
            let audioInput = try AVCaptureDeviceInput(device: microphone)
            if captureSession.canAddInput(audioInput) {
                captureSession.addInput(audioInput)
            }
            
            // Setup video preview layer
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            if let videoPreviewLayer = videoPreviewLayer {
                videoPreviewLayer.videoGravity = .resizeAspectFill
                videoPreviewLayer.frame = cameraView.bounds
                cameraView.layer.addSublayer(videoPreviewLayer)
            }
            
            // Setup video recording output
            videoRecordingOutput = AVCaptureMovieFileOutput()
            if let videoRecordingOutput = videoRecordingOutput,
               captureSession.canAddOutput(videoRecordingOutput) {
                captureSession.addOutput(videoRecordingOutput)
            }
            
            // Start running the session in background
            DispatchQueue.global(qos: .userInitiated).async {
                captureSession.startRunning()
            }
            
        } catch {
            showError(error)
        }
    }
    
    private func loadKeynote() {
        //guard script.hasKeynote else { return }
        
        let previewController = QLPreviewController()
        previewController.dataSource = self
        previewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Remove default navigation bar from QLPreviewController
        previewController.navigationItem.rightBarButtonItem = nil
        previewController.navigationController?.setNavigationBarHidden(true, animated: false)
        
        addChild(previewController)
        keynoteContainerView.addSubview(previewController.view)
        previewController.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            previewController.view.topAnchor.constraint(equalTo: keynoteContainerView.topAnchor),
            previewController.view.leadingAnchor.constraint(equalTo: keynoteContainerView.leadingAnchor),
            previewController.view.trailingAnchor.constraint(equalTo: keynoteContainerView.trailingAnchor),
            previewController.view.bottomAnchor.constraint(equalTo: keynoteContainerView.bottomAnchor)
        ])
        
        self.keynotePreviewController = previewController
        
        // Load keynote URL
        KeynoteManager.shared.loadKeynote { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let url):
                    // Store URL and reload preview
                    self?.currentKeynoteURL = url
                    self?.keynotePreviewController?.reloadData()
                case .failure(let error):
                    self?.showError(error)
                }
            }
        }
    }
    
    // MARK: - QLPreviewControllerDataSource
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return currentKeynoteURL != nil ? 1 : 0
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        guard let url = currentKeynoteURL else {
            fatalError("No keynote URL available")
        }
        return url as QLPreviewItem
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func backButtonTapped() {
        // Remove this method as we're using navigation bar's back button
    }
    
    @objc private func settingsTapped() {
        let settingsVC = PerformanceSettingsViewController(
            scriptSize: scriptSizeSlider.value,
            scrollSpeed: scrollSpeedSlider.value,
            autoScroll: autoScrollSwitch.isOn,
            ratio: currentPreviewRatio
        )
        settingsVC.delegate = self
        settingsVC.modalPresentationStyle = .pageSheet
        
        if let sheet = settingsVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 12
        }
        
        // Remove black background
        settingsVC.view.backgroundColor = .clear
        settingsVC.modalTransitionStyle = .crossDissolve
        
        present(settingsVC, animated: true)
    }
    
    @objc private func scriptTapped() {
        isScriptVisible.toggle()
        
        // Animate the visibility change
        UIView.animate(withDuration: 0.3) {
            self.scriptPreviewTextView.alpha = self.isScriptVisible ? 1.0 : 0.0
            self.scriptPreviewGradientView.alpha = self.isScriptVisible ? 1.0 : 0.0
        }
    }
    
    @objc private func recordTapped() {
        if !isRecording {
            startRecordingSession()
            updateRecordButtonUI(isRecording: true)
        } else {
            stopRecordingSession()
            updateRecordButtonUI(isRecording: false)
        }
    }
    
    private func updateRecordButtonUI(isRecording: Bool) {
        self.isRecording = isRecording
        let icon = isRecording ? "stop.circle.fill" : "record.circle.fill"
        let config = UIImage.SymbolConfiguration(pointSize: 44, weight: .semibold)
        recordButton.setImage(UIImage(systemName: icon)?.withConfiguration(config), for: .normal)
        recordButton.tintColor = isRecording ? .systemRed : .systemGray
    }
    
    private func startRecordingSession() {
        speechAnalyzer = SpeechAnalyzer()
        // Start video recording
        if let videoURL = recordedVideoURL {
            // Remove existing recording if any
            try? FileManager.default.removeItem(at: videoURL)
            videoRecordingOutput?.startRecording(to: videoURL, recordingDelegate: self)
        }
        
        Task {
            do {
                try await speechAnalyzer?.startRecording()
                // Start timer
                timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                    self?.elapsedTime += 1
                    self?.updateTimerLabel()
                }
                
                // Reset script to top when starting new recording
                scriptPreviewTextView.setContentOffset(.zero, animated: false)
                if autoScrollSwitch.isOn {
                    isAutoScrollEnabled = true
                    startAutoScroll()
                }
            } catch {
                showError(error)
                isRecording = false
                updateRecordButtonUI(isRecording: false)
            }
        }
    }
    
    private func stopRecordingSession() {
        // Stop video recording
        videoRecordingOutput?.stopRecording()
        
        // Stop timer
        timer?.invalidate()
        timer = nil
        elapsedTime = 0
        updateTimerLabel()
        
        // Stop auto-scroll
        stopAutoScroll()
        
        Task {
            guard let analyzer = speechAnalyzer else { return }
            do {
                let results = try await analyzer.stopRecording()
                showResults(results)
            } catch {
                showError(error)
            }
        }
    }
    
    deinit {
        // Cleanup when view controller is deallocated
        if isRecording {
            stopRecordingSession()
        }
        
        // Stop and cleanup video capture
        videoRecordingOutput?.stopRecording()
        captureSession?.stopRunning()
        captureSession = nil
        
        // Remove any observers
        NotificationCenter.default.removeObserver(self)
        
        // Cleanup timers
        timer?.invalidate()
        timer = nil
        scrollTimer?.invalidate()
        scrollTimer = nil
    }
    
    @objc private func pauseTapped() {
        isPaused.toggle()
        
        if isPaused {
            pauseRecording()
        } else {
            resumeRecording()
        }
        
        let icon = isPaused ? "play.fill" : "pause.fill"
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
        pauseButton.setImage(UIImage(systemName: icon)?.withConfiguration(config), for: .normal)
    }
    
    @objc private func coachTapped() {
        isCoachEnabled.toggle()
        
        if isCoachEnabled {
            setupCoachView()
            startSpeechMonitoring()
        } else {
            removeCoachView()
            stopSpeechMonitoring()
        }
    }
    
    private func pauseRecording() {
        isPaused = true
        timer?.invalidate()
        timer = nil
        stopAutoScroll()
        pauseVideoRecording()
        
        Task {
            do {
                if let result = try await speechAnalyzer?.stopRecording() {
                    // Don't show results when pausing
                    // Store interim results if needed
                }
            } catch {
                showError(error)
            }
        }
    }
    
    private func resumeRecording() {
        isPaused = false
        startTimer()
        if isAutoScrollEnabled {
            startAutoScroll()
        }
        resumeVideoRecording()
        
        Task {
            do {
                try await speechAnalyzer?.startRecording()
            } catch {
                showError(error)
            }
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.elapsedTime += 1
            self?.updateTimerLabel()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        elapsedTime = 0
        updateTimerLabel()
    }
    
    private func updateTimerLabel() {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func createSettingLabel(text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }
    
    @objc private func scriptSizeChanged(_ slider: UISlider) {
        scriptPreviewTextView.font = .systemFont(ofSize: CGFloat(slider.value), weight: .medium)
    }
    
    @objc private func scrollSpeedChanged(_ slider: UISlider) {
        scrollSpeed = slider.value
        if isRecording && !isPaused && isAutoScrollEnabled {
            startAutoScroll()
        }
    }
    
    @objc private func autoScrollToggled(_ toggle: UISwitch) {
        isAutoScrollEnabled = toggle.isOn
        if isRecording && !isPaused {
            if toggle.isOn {
                startAutoScroll()
            } else {
                stopAutoScroll()
            }
        }
    }
    
    @objc private func handlePreviewResize(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: view)
        
        // Only handle if touch is near the boundary between previews
        let boundaryY = keynoteContainerView.frame.maxY
        let tolerance: CGFloat = 30
        
        guard abs(location.y - boundaryY) < tolerance else { return }
        
        switch gesture.state {
        case .changed:
            let multiplier = location.y / view.frame.height
            let clampedMultiplier = min(max(multiplier, 0.2), 0.6) // Limit between 20% and 60%
            
            // Deactivate old constraint
            keynoteHeightConstraint?.isActive = false
            
            // Create and store new constraint
            keynoteHeightConstraint = keynoteContainerView.heightAnchor.constraint(
                equalTo: view.heightAnchor, 
                multiplier: clampedMultiplier
            )
            keynoteHeightConstraint?.isActive = true
            
            view.layoutIfNeeded()
            
        default:
            break
        }
    }
    
    // Add delegate methods
    func didUpdateScriptSize(_ size: CGFloat) {
        scriptPreviewTextView.font = .systemFont(ofSize: size, weight: .medium)
        UserDefaults.standard.set(Float(size), forKey: SettingsKeys.scriptSize)
        scriptSizeSlider.value = Float(size) // Update slider value
    }
    
    func didUpdateScrollSpeed(_ speed: Float) {
        scrollSpeed = speed
        UserDefaults.standard.set(speed, forKey: SettingsKeys.scrollSpeed)
        scrollSpeedSlider.value = speed // Update slider value
    }
    
    func didUpdateAutoScroll(_ enabled: Bool) {
        isAutoScrollEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: SettingsKeys.autoScroll)
        autoScrollSwitch.isOn = enabled // Update switch state
        if isRecording && !isPaused {
            if enabled {
                startAutoScroll()
            } else {
                stopAutoScroll()
            }
        }
    }
    
    func didSelectPreviewRatio(_ ratio: PreviewRatio) {
        currentPreviewRatio = ratio
        UserDefaults.standard.set(ratio.rawValue, forKey: SettingsKeys.previewRatio)
        
        // Update layout
        keynoteHeightConstraint?.isActive = false
        keynoteHeightConstraint = keynoteContainerView.heightAnchor.constraint(
            equalTo: view.heightAnchor,
            multiplier: ratio.keynoteMultiplier
        )
        keynoteHeightConstraint?.isActive = true
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    // Add method to update script button icon
    private func updateScriptButtonIcon() {
        let iconName = isScriptVisible ? "doc.text.fill" : "doc.text"
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
        let image = UIImage(systemName: iconName)?.withConfiguration(config)
        scriptButton.setImage(image, for: .normal)
    }
    
    private func showResults(_ results: SpeechAnalysisResult) {
        let resultsVC = PerformanceResultsViewController(
            results: results, 
            videoURL: recordedVideoURL
        )
        navigationController?.pushViewController(resultsVC, animated: true)
    }
    
    // Add auto-scroll methods
    private func startAutoScroll() {
        stopAutoScroll() // Clear any existing timer
        
        scrollTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let currentOffset = self.scriptPreviewTextView.contentOffset
            let newOffset = CGPoint(x: currentOffset.x, 
                                  y: currentOffset.y + CGFloat(self.scrollSpeed) * 0.1)
            
            // Check if we've reached the bottom
            let maxOffset = self.scriptPreviewTextView.contentSize.height - self.scriptPreviewTextView.bounds.height
            if newOffset.y <= maxOffset {
                self.scriptPreviewTextView.setContentOffset(newOffset, animated: false)
            }
        }
        
        RunLoop.current.add(scrollTimer!, forMode: .common)
    }
    
    private func stopAutoScroll() {
        scrollTimer?.invalidate()
        scrollTimer = nil
    }
    
    // Add video recording methods
    private func setupVideoRecording() {
        guard let videoRecordingOutput = videoRecordingOutput,
              let videoURL = recordedVideoURL else { return }
        
        // Remove existing recording if any
        try? FileManager.default.removeItem(at: videoURL)
        
        // Start recording
        videoRecordingOutput.startRecording(to: videoURL, recordingDelegate: self)
    }
    
    private func pauseVideoRecording() {
        // Implementation for pausing video recording
        videoWriterInput?.markAsFinished()
    }
    
    private func resumeVideoRecording() {
        // Implementation for resuming video recording
        setupVideoRecording()
    }
    
    private func setupCoachView() {
        coachView = CoachView(frame: CGRect(x: 16, y: 16, width: 80, height: 80))
        if let coachView = coachView {
            cameraView.addSubview(coachView)
        }
    }
    
    private func removeCoachView() {
        coachView?.removeFromSuperview()
        coachView = nil
    }
    
    private func startSpeechMonitoring() {
        currentWordCount = 0
        lastUpdateTime = Date()
        
        speechMonitorTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.analyzeSpeechMetrics()
        }
    }
    
    private func stopSpeechMonitoring() {
        speechMonitorTimer?.invalidate()
        speechMonitorTimer = nil
    }
    
    private func analyzeSpeechMetrics() {
        guard let speechAnalyzer = speechAnalyzer else { return }
        
        let volume = speechAnalyzer.getCurrentVolume()
        
        // Detect if user is speaking
        if volume > 0.1 {
            if speakingStartTime == nil {
                speakingStartTime = Date()
                wordCount = 0
            }
            
            // Update word count from speech analyzer
            wordCount = speechAnalyzer.getCurrentWordCount()
            
            // Calculate speaking rate only if we have been speaking for at least 3 seconds
            if let startTime = speakingStartTime, 
               Date().timeIntervalSince(startTime) >= 3.0 && wordCount > 0 {
                
                let duration = Date().timeIntervalSince(startTime)
                let wordsPerMinute = Double(wordCount) / duration * 60.0
                
                // Provide simplified pace feedback
                if wordsPerMinute > 160 {
                    coachView?.showSuggestion("Slow down", type: .speedWarning)
                } else if wordsPerMinute < 120 && wordCount > 5 {
                    coachView?.showSuggestion("Speed up", type: .speedWarning)
                } else if wordCount > 5 {
                    coachView?.showSuggestion("Good pace", type: .goodPace)
                }
            }
        } else {
            // Reset if not speaking for more than 1 second
            if let lastTime = speakingStartTime, Date().timeIntervalSince(lastTime) > 1.0 {
                speakingStartTime = nil
                wordCount = 0
            }
        }
    }
    
    private func loadSavedSettings() {
        // Load saved settings
        let scriptSize = UserDefaults.standard.float(forKey: SettingsKeys.scriptSize)
        let scrollSpeed = UserDefaults.standard.float(forKey: SettingsKeys.scrollSpeed)
        let autoScroll = UserDefaults.standard.bool(forKey: SettingsKeys.autoScroll)
        let ratioRawValue = UserDefaults.standard.string(forKey: SettingsKeys.previewRatio) ?? PreviewRatio.thirty70.rawValue
        
        // Apply saved settings or defaults
        scriptSizeSlider.value = scriptSize != 0 ? scriptSize : 26
        scrollSpeedSlider.value = scrollSpeed != 0 ? scrollSpeed : 5
        autoScrollSwitch.isOn = autoScroll
        currentPreviewRatio = PreviewRatio(rawValue: ratioRawValue) ?? .thirty70
        
        // Apply initial values
        scriptPreviewTextView.font = .systemFont(ofSize: CGFloat(scriptSizeSlider.value), weight: .medium)
        self.scrollSpeed = scrollSpeedSlider.value
        self.isAutoScrollEnabled = autoScroll
    }
    
    // Add these delegate methods
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error recording video: \(error.localizedDescription)")
            return
        }
        
        // Video recording finished successfully
        print("Video recording completed: \(outputFileURL.path)")
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        // Video recording started
        print("Started recording video to: \(fileURL.path)")
    }
} 

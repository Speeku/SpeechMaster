//import UIKit
//import AVFoundation
//
//class MemorizationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
//    
//    // MARK: - Properties
//    var scriptId: UUID = UUID()
//    var scriptTitle: String = ""
//    private let dataSource = HomeViewModel.shared
//    private var currentSession: MemorizationSession?
//    private var sections: [MemorizationSection] = []
//    private var selectedTechnique: MemorizationTechnique = .chunking
//    
//    // Audio recording
//    private var audioRecorder: AVAudioRecorder?
//    private var audioPlayer: AVAudioPlayer?
//    private var recordingURL: URL?
//    
//    // MARK: - UI Elements
//    private let headerView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .systemGroupedBackground
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.layer.cornerRadius = 16
//        view.clipsToBounds = true
//        return view
//    }()
//    
//    private let techniqueLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Memorization Technique"
//        label.font = .systemFont(ofSize: 16, weight: .semibold)
//        label.textColor = .label
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let techniqueSegmentedControl: UISegmentedControl = {
//        let techniques = MemorizationTechnique.allCases.map { $0.rawValue }
//        let segmentedControl = UISegmentedControl(items: techniques)
//        segmentedControl.selectedSegmentIndex = 0
//        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
//        return segmentedControl
//    }()
//    
//    private let techniqueDescriptionLabel: UILabel = {
//        let label = UILabel()
//        label.numberOfLines = 0
//        label.font = .systemFont(ofSize: 14)
//        label.textColor = .secondaryLabel
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let progressContainerView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .systemGroupedBackground
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.layer.cornerRadius = 16
//        view.clipsToBounds = true
//        return view
//    }()
//    
//    private let progressTitleLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Memorization Progress"
//        label.font = .systemFont(ofSize: 16, weight: .semibold)
//        label.textColor = .label
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let progressView: UIProgressView = {
//        let progressView = UIProgressView(progressViewStyle: .default)
//        progressView.translatesAutoresizingMaskIntoConstraints = false
//        progressView.progressTintColor = .systemGreen
//        progressView.trackTintColor = .systemGray5
//        progressView.layer.cornerRadius = 4
//        progressView.clipsToBounds = true
//        progressView.layer.sublayers?[1].cornerRadius = 4
//        progressView.subviews[1].clipsToBounds = true
//        progressView.heightAnchor.constraint(equalToConstant: 8).isActive = true
//        return progressView
//    }()
//    
//    private let progressLabel: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 14, weight: .bold)
//        label.textAlignment = .center
//        label.textColor = .secondaryLabel
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let sectionsLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Script Sections"
//        label.font = .systemFont(ofSize: 20, weight: .bold)
//        label.textColor = .label
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let tableView: UITableView = {
//        let tableView = UITableView(frame: .zero, style: .insetGrouped)
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        tableView.register(MemorizationSectionCell.self, forCellReuseIdentifier: "MemorizationSectionCell")
//        tableView.backgroundColor = .systemBackground
//        tableView.separatorStyle = .singleLine
//        tableView.layer.cornerRadius = 16
//        tableView.clipsToBounds = true
//        return tableView
//    }()
//    
//    private let startButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Start Memorizing", for: .normal)
//        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
//        button.backgroundColor = .systemBlue
//        button.setTitleColor(.white, for: .normal)
//        button.layer.cornerRadius = 14
//        button.translatesAutoresizingMaskIntoConstraints = false
//        
//        // Add shadow
//        button.layer.shadowColor = UIColor.black.cgColor
//        button.layer.shadowOffset = CGSize(width: 0, height: 2)
//        button.layer.shadowRadius = 4
//        button.layer.shadowOpacity = 0.1
//        
//        return button
//    }()
//    
//    // MARK: - Lifecycle Methods
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        setupUI()
//        setupConstraints()
//        setupActions()
//        
//        // Load existing session or prepare to create a new one
//        loadExistingSession()
//        
//        // Update UI with initial technique
//        updateTechniqueDescription()
//    }
//    
//    // MARK: - Setup Methods
//    private func setupUI() {
//        view.backgroundColor = .systemBackground
//        title = "Memorize: \(scriptTitle)"
//        
//        // Add subviews
//        view.addSubview(headerView)
//        headerView.addSubview(techniqueLabel)
//        headerView.addSubview(techniqueSegmentedControl)
//        headerView.addSubview(techniqueDescriptionLabel)
//        
//        view.addSubview(progressContainerView)
//        progressContainerView.addSubview(progressTitleLabel)
//        progressContainerView.addSubview(progressView)
//        progressContainerView.addSubview(progressLabel)
//        
//        view.addSubview(sectionsLabel)
//        view.addSubview(tableView)
//        view.addSubview(startButton)
//        
//        // Setup table view
//        tableView.delegate = self
//        tableView.dataSource = self
//    }
//    
//    private func setupConstraints() {
//        NSLayoutConstraint.activate([
//            // Header view
//            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
//            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            
//            // Technique label
//            techniqueLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
//            techniqueLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
//            techniqueLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
//            
//            // Technique segmented control
//            techniqueSegmentedControl.topAnchor.constraint(equalTo: techniqueLabel.bottomAnchor, constant: 8),
//            techniqueSegmentedControl.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
//            techniqueSegmentedControl.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
//            
//            // Technique description
//            techniqueDescriptionLabel.topAnchor.constraint(equalTo: techniqueSegmentedControl.bottomAnchor, constant: 12),
//            techniqueDescriptionLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
//            techniqueDescriptionLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
//            techniqueDescriptionLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16),
//            
//            // Progress container view
//            progressContainerView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
//            progressContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            progressContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            
//            // Progress title label
//            progressTitleLabel.topAnchor.constraint(equalTo: progressContainerView.topAnchor, constant: 16),
//            progressTitleLabel.leadingAnchor.constraint(equalTo: progressContainerView.leadingAnchor, constant: 16),
//            progressTitleLabel.trailingAnchor.constraint(equalTo: progressContainerView.trailingAnchor, constant: -16),
//            
//            // Progress view
//            progressView.topAnchor.constraint(equalTo: progressTitleLabel.bottomAnchor, constant: 12),
//            progressView.leadingAnchor.constraint(equalTo: progressContainerView.leadingAnchor, constant: 16),
//            progressView.trailingAnchor.constraint(equalTo: progressContainerView.trailingAnchor, constant: -16),
//            
//            // Progress label
//            progressLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 8),
//            progressLabel.centerXAnchor.constraint(equalTo: progressContainerView.centerXAnchor),
//            progressLabel.bottomAnchor.constraint(equalTo: progressContainerView.bottomAnchor, constant: -16),
//            
//            // Sections label
//            sectionsLabel.topAnchor.constraint(equalTo: progressContainerView.bottomAnchor, constant: 24),
//            sectionsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            sectionsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            
//            // Table view
//            tableView.topAnchor.constraint(equalTo: sectionsLabel.bottomAnchor, constant: 8),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -24),
//            
//            // Start button
//            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
//            startButton.heightAnchor.constraint(equalToConstant: 56)
//        ])
//    }
//    
//    private func setupActions() {
//        techniqueSegmentedControl.addTarget(self, action: #selector(techniqueChanged), for: .valueChanged)
//        startButton.addTarget(self, action: #selector(startMemorizing), for: .touchUpInside)
//    }
//    
//    // MARK: - Data Loading
//    private func loadExistingSession() {
//        let sessions = dataSource.getMemorizationSessions(for: scriptId)
//        
//        if let existingSession = sessions.first {
//            // Use the most recent session
//            currentSession = existingSession
//            sections = existingSession.sections
//            
//            // Update UI
//            let progress = dataSource.calculateMemorizationProgress(for: existingSession)
//            updateProgress(progress)
//            
//            // Set the technique
//            if let index = MemorizationTechnique.allCases.firstIndex(of: existingSession.technique) {
//                techniqueSegmentedControl.selectedSegmentIndex = index
//                selectedTechnique = existingSession.technique
//                updateTechniqueDescription()
//            }
//            
//            // Update button title
//            startButton.setTitle("Continue Memorizing", for: .normal)
//        } else {
//            // No existing session, prepare to create a new one
//            startButton.setTitle("Start Memorizing", for: .normal)
//            updateProgress(0)
//        }
//        
//        tableView.reloadData()
//    }
//    
//    // MARK: - Actions
//    @objc private func techniqueChanged() {
//        let index = techniqueSegmentedControl.selectedSegmentIndex
//        selectedTechnique = MemorizationTechnique.allCases[index]
//        updateTechniqueDescription()
//    }
//    
//    @objc private func startMemorizing() {
//        if currentSession == nil {
//            // Create a new session
//            currentSession = dataSource.createMemorizationSession(for: scriptId, technique: selectedTechnique)
//            sections = currentSession?.sections ?? []
//            tableView.reloadData()
//            
//            // Update button title
//            startButton.setTitle("Continue Memorizing", for: .normal)
//        }
//        
//        // Start the memorization process based on the technique
//        switch selectedTechnique {
//        case .chunking:
//            showChunkingView()
//        case .recordAndListen:
//            showRecordAndListenView()
//        }
//    }
//    
//    // MARK: - UI Updates
//    private func updateTechniqueDescription() {
//        techniqueDescriptionLabel.text = selectedTechnique.description
//    }
//    
//    private func updateProgress(_ progress: Double) {
//        progressView.progress = Float(progress)
//        let percentage = Int(progress * 100)
//        progressLabel.text = "\(percentage)% Memorized"
//    }
//    
//    // MARK: - Memorization Techniques
//    private func showChunkingView() {
//        guard let session = currentSession else { return }
//        
//        let chunkingVC = ChunkingViewController()
//        chunkingVC.session = session
//        chunkingVC.delegate = self
//        navigationController?.pushViewController(chunkingVC, animated: true)
//    }
//    
//    private func showRecordAndListenView() {
//        guard let session = currentSession else { return }
//        
//        let recordVC = RecordAndListenViewController()
//        recordVC.session = session
//        recordVC.delegate = self
//        navigationController?.pushViewController(recordVC, animated: true)
//    }
//    
//    // MARK: - TableView DataSource & Delegate
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return sections.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "MemorizationSectionCell", for: indexPath) as! MemorizationSectionCell
//        
//        let section = sections[indexPath.row]
//        cell.configure(with: section, index: indexPath.row + 1)
//        
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        
//        // Show section detail
//        let section = sections[indexPath.row]
//        let detailVC = SectionDetailViewController()
//        detailVC.section = section
//        detailVC.delegate = self
//        navigationController?.pushViewController(detailVC, animated: true)
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 80
//    }
//}
//
//// MARK: - MemorizationDelegate
//extension MemorizationViewController: MemorizationDelegate {
//    func didUpdateSession(_ session: MemorizationSession) {
//        currentSession = session
//        sections = session.sections
//        
//        // Update progress
//        let progress = dataSource.calculateMemorizationProgress(for: session)
//        updateProgress(progress)
//        
//        // Update session in data source
//        dataSource.updateMemorizationSession(session)
//        
//        // Reload table view
//        tableView.reloadData()
//    }
//}
//
//// MARK: - MemorizationSectionCell
//class MemorizationSectionCell: UITableViewCell {
//    
//    private let sectionLabel: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 16, weight: .bold)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let previewLabel: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 14)
//        label.textColor = .gray
//        label.numberOfLines = 2
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let statusImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFit
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageView
//    }()
//    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        
//        setupUI()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func setupUI() {
//        contentView.addSubview(sectionLabel)
//        contentView.addSubview(previewLabel)
//        contentView.addSubview(statusImageView)
//        
//        NSLayoutConstraint.activate([
//            sectionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
//            sectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            sectionLabel.trailingAnchor.constraint(equalTo: statusImageView.leadingAnchor, constant: -8),
//            
//            previewLabel.topAnchor.constraint(equalTo: sectionLabel.bottomAnchor, constant: 4),
//            previewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            previewLabel.trailingAnchor.constraint(equalTo: statusImageView.leadingAnchor, constant: -8),
//            previewLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12),
//            
//            statusImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            statusImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            statusImageView.widthAnchor.constraint(equalToConstant: 24),
//            statusImageView.heightAnchor.constraint(equalToConstant: 24)
//        ])
//    }
//    
//    func configure(with section: MemorizationSection, index: Int) {
//        sectionLabel.text = "Section \(index)"
//        
//        // Truncate preview text if too long
//        let previewText = section.text.count > 100 ? section.text.prefix(100) + "..." : section.text
//        previewLabel.text = previewText
//        
//        // Set status image based on mastered state
//        if section.mastered {
//            statusImageView.image = UIImage(systemName: "checkmark.circle.fill")
//            statusImageView.tintColor = .systemGreen
//        } else {
//            statusImageView.image = UIImage(systemName: "circle")
//            statusImageView.tintColor = .systemGray
//        }
//    }
//}
//
//// MARK: - MemorizationDelegate Protocol
//protocol MemorizationDelegate: AnyObject {
//    func didUpdateSession(_ session: MemorizationSession)
//}
//
//// MARK: - Placeholder View Controllers for Memorization Techniques
//// These would be implemented fully in a real app
//
//class ChunkingViewController: UIViewController {
//    var session: MemorizationSession!
//    weak var delegate: MemorizationDelegate?
//    
//    // Current section being practiced
//    private var currentSectionIndex = 0
//    private var isShowingAnswer = false
//    
//    // UI Elements
//    private let headerView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .systemGroupedBackground
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.layer.cornerRadius = 16
//        view.clipsToBounds = true
//        return view
//    }()
//    
//    private let progressView: UIProgressView = {
//        let progressView = UIProgressView(progressViewStyle: .default)
//        progressView.translatesAutoresizingMaskIntoConstraints = false
//        progressView.progressTintColor = .systemGreen
//        progressView.trackTintColor = .systemGray5
//        progressView.layer.cornerRadius = 4
//        progressView.clipsToBounds = true
//        progressView.layer.sublayers?[1].cornerRadius = 4
//        progressView.subviews[1].clipsToBounds = true
//        progressView.heightAnchor.constraint(equalToConstant: 8).isActive = true
//        return progressView
//    }()
//    
//    private let progressLabel: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 14, weight: .bold)
//        label.textAlignment = .center
//        label.textColor = .secondaryLabel
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let sectionTitleLabel: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 20, weight: .bold)
//        label.textAlignment = .left
//        label.textColor = .label
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let textContainerView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .systemBackground
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.layer.cornerRadius = 16
//        view.layer.borderWidth = 1
//        view.layer.borderColor = UIColor.systemGray5.cgColor
//        view.clipsToBounds = true
//        return view
//    }()
//    
//    private let textView: UITextView = {
//        let textView = UITextView()
//        textView.font = .systemFont(ofSize: 18)
//        textView.isEditable = false
//        textView.translatesAutoresizingMaskIntoConstraints = false
//        textView.backgroundColor = .clear
//        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
//        return textView
//    }()
//    
//    private let buttonStackView: UIStackView = {
//        let stackView = UIStackView()
//        stackView.axis = .vertical
//        stackView.spacing = 12
//        stackView.distribution = .fillEqually
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        return stackView
//    }()
//    
//    private let showHideButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Show Text", for: .normal)
//        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
//        button.backgroundColor = .systemBlue
//        button.setTitleColor(.white, for: .normal)
//        button.layer.cornerRadius = 14
//        button.translatesAutoresizingMaskIntoConstraints = false
//        
//        // Add shadow
//        button.layer.shadowColor = UIColor.black.cgColor
//        button.layer.shadowOffset = CGSize(width: 0, height: 2)
//        button.layer.shadowRadius = 4
//        button.layer.shadowOpacity = 0.1
//        
//        return button
//    }()
//    
//    // Mastered checkbox container
//    private let masteredContainerView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .systemGroupedBackground
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.layer.cornerRadius = 16
//        view.clipsToBounds = true
//        return view
//    }()
//    
//    private let masteredLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Mark section as mastered"
//        label.font = .systemFont(ofSize: 16, weight: .medium)
//        label.textColor = .label
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let masteredCheckbox: UIButton = {
//        let button = UIButton(type: .system)
//        button.setImage(UIImage(systemName: "square"), for: .normal)
//        button.tintColor = .systemGreen
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//    
//    private let navigationStackView: UIStackView = {
//        let stackView = UIStackView()
//        stackView.axis = .horizontal
//        stackView.distribution = .fillEqually
//        stackView.spacing = 16
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        return stackView
//    }()
//    
//    private let previousButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
//        button.setTitle("Previous", for: .normal)
//        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
//        button.tintColor = .systemBlue
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.contentHorizontalAlignment = .leading
//        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
//        return button
//    }()
//    
//    private let nextButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Next", for: .normal)
//        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
//        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
//        button.tintColor = .systemBlue
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.contentHorizontalAlignment = .trailing
//        button.semanticContentAttribute = .forceRightToLeft
//        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
//        return button
//    }()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//        title = "Chunking Technique"
//        
//        setupUI()
//        setupConstraints()
//        setupActions()
//        updateUI()
//    }
//    
//    private func setupUI() {
//        // Add subviews
//        view.addSubview(headerView)
//        headerView.addSubview(progressView)
//        headerView.addSubview(progressLabel)
//        
//        view.addSubview(sectionTitleLabel)
//        
//        view.addSubview(textContainerView)
//        textContainerView.addSubview(textView)
//        
//        view.addSubview(buttonStackView)
//        buttonStackView.addArrangedSubview(showHideButton)
//        
//        view.addSubview(masteredContainerView)
//        masteredContainerView.addSubview(masteredLabel)
//        masteredContainerView.addSubview(masteredCheckbox)
//        
//        view.addSubview(navigationStackView)
//        navigationStackView.addArrangedSubview(previousButton)
//        navigationStackView.addArrangedSubview(nextButton)
//    }
//    
//    private func setupConstraints() {
//        NSLayoutConstraint.activate([
//            // Header view
//            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
//            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            
//            // Progress view
//            progressView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
//            progressView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
//            progressView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
//            
//            // Progress label
//            progressLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 8),
//            progressLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
//            progressLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16),
//            
//            // Section title label
//            sectionTitleLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 24),
//            sectionTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            sectionTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            
//            // Text container view
//            textContainerView.topAnchor.constraint(equalTo: sectionTitleLabel.bottomAnchor, constant: 12),
//            textContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            textContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            
//            // Text view
//            textView.topAnchor.constraint(equalTo: textContainerView.topAnchor),
//            textView.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor),
//            textView.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor),
//            textView.bottomAnchor.constraint(equalTo: textContainerView.bottomAnchor),
//            
//            // Button stack view (now only contains showHideButton)
//            buttonStackView.topAnchor.constraint(equalTo: textContainerView.bottomAnchor, constant: 24),
//            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            showHideButton.heightAnchor.constraint(equalToConstant: 56),
//            
//            // Mastered container view
//            masteredContainerView.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 16),
//            masteredContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            masteredContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            masteredContainerView.heightAnchor.constraint(equalToConstant: 56),
//            
//            // Mastered label and checkbox
//            masteredLabel.centerYAnchor.constraint(equalTo: masteredContainerView.centerYAnchor),
//            masteredLabel.leadingAnchor.constraint(equalTo: masteredContainerView.leadingAnchor, constant: 16),
//            
//            masteredCheckbox.centerYAnchor.constraint(equalTo: masteredContainerView.centerYAnchor),
//            masteredCheckbox.trailingAnchor.constraint(equalTo: masteredContainerView.trailingAnchor, constant: -16),
//            masteredCheckbox.widthAnchor.constraint(equalToConstant: 30),
//            masteredCheckbox.heightAnchor.constraint(equalToConstant: 30),
//            
//            // Navigation stack view
//            navigationStackView.topAnchor.constraint(equalTo: masteredContainerView.bottomAnchor, constant: 24),
//            navigationStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            navigationStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 195),
//            navigationStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
//            
//            // Height constraints
//            textContainerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.35)
//        ])
//    }
//    
//    private func setupActions() {
//        showHideButton.addTarget(self, action: #selector(toggleTextVisibility), for: .touchUpInside)
//        masteredCheckbox.addTarget(self, action: #selector(toggleMastered), for: .touchUpInside)
//        previousButton.addTarget(self, action: #selector(showPreviousSection), for: .touchUpInside)
//        nextButton.addTarget(self, action: #selector(showNextSection), for: .touchUpInside)
//    }
//    
//    private func updateUI() {
//        guard !session.sections.isEmpty else { return }
//        
//        // Update progress
//        let masteredCount = session.sections.filter { $0.mastered }.count
//        let progress = Float(masteredCount) / Float(session.sections.count)
//        progressView.progress = progress
//        progressLabel.text = "\(masteredCount)/\(session.sections.count) Sections Mastered"
//        
//        // Update section title
//        sectionTitleLabel.text = "Section \(currentSectionIndex + 1) of \(session.sections.count)"
//        
//        // Update text visibility
//        if isShowingAnswer {
//            textView.text = session.sections[currentSectionIndex].text
//            showHideButton.setTitle("Hide Text", for: .normal)
//        } else {
//            textView.text = "[Text hidden. Try to recall this section from memory.]"
//            showHideButton.setTitle("Show Text", for: .normal)
//        }
//        
//        // Update mastered checkbox
//        let isMastered = session.sections[currentSectionIndex].mastered
//        let checkboxImage = isMastered ? UIImage(systemName: "checkmark.square.fill") : UIImage(systemName: "square")
//        masteredCheckbox.setImage(checkboxImage, for: .normal)
//        
//        // Update navigation buttons
//        previousButton.isEnabled = currentSectionIndex > 0
//        nextButton.isEnabled = currentSectionIndex < session.sections.count - 1
//    }
//    
//    // MARK: - Actions
//    @objc private func toggleTextVisibility() {
//        isShowingAnswer.toggle()
//        updateUI()
//    }
//    
//    @objc private func toggleMastered() {
//        // Toggle mastered state
//        guard var updatedSession = session else { return }
//        updatedSession.sections[currentSectionIndex].mastered.toggle()
//        updatedSession.sections[currentSectionIndex].lastPracticed = Date()
//        
//        // Update session
//        session = updatedSession
//        delegate?.didUpdateSession(updatedSession)
//        
//        // Update UI
//        updateUI()
//    }
//    
//    @objc private func showPreviousSection() {
//        guard currentSectionIndex > 0 else { return }
//        
//        currentSectionIndex -= 1
//        isShowingAnswer = false
//        updateUI()
//    }
//    
//    @objc private func showNextSection() {
//        guard currentSectionIndex < session.sections.count - 1 else { return }
//        
//        currentSectionIndex += 1
//        isShowingAnswer = false
//        updateUI()
//    }
//}
//
//class RecordAndListenViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
//    var session: MemorizationSession!
//    weak var delegate: MemorizationDelegate?
//    
//    // Current section being practiced
//    private var currentSectionIndex = 0
//    
//    // Audio recording
//    private var audioRecorder: AVAudioRecorder?
//    private var audioPlayer: AVAudioPlayer?
//    private var recordingURL: URL?
//    private var isRecording = false
//    private var isPlaying = false
//    
//    // UI Elements
//    private let containerView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .systemBackground
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.layer.cornerRadius = 16
//        view.clipsToBounds = true
//        view.layer.shadowColor = UIColor.black.cgColor
//        view.layer.shadowOffset = CGSize(width: 0, height: 2)
//        view.layer.shadowRadius = 6
//        view.layer.shadowOpacity = 0.1
//        return view
//    }()
//    
//    private let headerView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .systemGroupedBackground
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.layer.cornerRadius = 16
//        view.clipsToBounds = true
//        return view
//    }()
//    
//    private let instructionLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Record yourself reading the script, then listen to it repeatedly to memorize."
//        label.numberOfLines = 0
//        label.textAlignment = .center
//        label.font = .systemFont(ofSize: 16)
//        label.textColor = .secondaryLabel
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let sectionTitleLabel: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 18, weight: .bold)
//        label.textAlignment = .center
//        label.textColor = .label
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let scriptContainerView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .systemBackground
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.layer.cornerRadius = 16
//        view.layer.borderWidth = 1
//        view.layer.borderColor = UIColor.systemGray5.cgColor
//        view.clipsToBounds = true
//        return view
//    }()
//    
//    private let scriptTextView: UITextView = {
//        let textView = UITextView()
//        textView.font = .systemFont(ofSize: 18)
//        textView.isEditable = false
//        textView.translatesAutoresizingMaskIntoConstraints = false
//        textView.backgroundColor = .clear
//        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
//        return textView
//    }()
//    
//    private let timerContainerView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .systemGroupedBackground
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.layer.cornerRadius = 16
//        view.clipsToBounds = true
//        return view
//    }()
//    
//    private let timerLabel: UILabel = {
//        let label = UILabel()
//        label.text = "00:00"
//        label.font = .systemFont(ofSize: 32, weight: .bold)
//        label.textAlignment = .center
//        label.textColor = .label
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    // Horizontal stack view for record and play buttons
//    private let controlButtonsStackView: UIStackView = {
//        let stackView = UIStackView()
//        stackView.axis = .horizontal
//        stackView.spacing = 16
//        stackView.distribution = .fillEqually
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        return stackView
//    }()
//    
//    private let recordButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Record", for: .normal)
//        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
//        button.backgroundColor = .systemRed
//        button.setTitleColor(.white, for: .normal)
//        button.layer.cornerRadius = 14
//        button.translatesAutoresizingMaskIntoConstraints = false
//        
//        // Add icon
//        let micImage = UIImage(systemName: "mic.fill")
//        button.setImage(micImage, for: .normal)
//        button.tintColor = .white
//        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
//        
//        // Add shadow
//        button.layer.shadowColor = UIColor.black.cgColor
//        button.layer.shadowOffset = CGSize(width: 0, height: 2)
//        button.layer.shadowRadius = 4
//        button.layer.shadowOpacity = 0.1
//        
//        return button
//    }()
//    
//    private let playButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Play", for: .normal)
//        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
//        button.backgroundColor = .systemBlue
//        button.setTitleColor(.white, for: .normal)
//        button.layer.cornerRadius = 14
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.isEnabled = false
//        
//        // Add icon
//        let playImage = UIImage(systemName: "play.fill")
//        button.setImage(playImage, for: .normal)
//        button.tintColor = .white
//        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
//        
//        // Add shadow
//        button.layer.shadowColor = UIColor.black.cgColor
//        button.layer.shadowOffset = CGSize(width: 0, height: 2)
//        button.layer.shadowRadius = 4
//        button.layer.shadowOpacity = 0.1
//        
//        return button
//    }()
//    
//    // Mastered checkbox container
//    private let masteredContainerView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .systemGroupedBackground
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.layer.cornerRadius = 16
//        view.clipsToBounds = true
//        return view
//    }()
//    
//    private let masteredLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Mark section as mastered"
//        label.font = .systemFont(ofSize: 16, weight: .medium)
//        label.textColor = .label
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let masteredCheckbox: UIButton = {
//        let button = UIButton(type: .system)
//        button.setImage(UIImage(systemName: "square"), for: .normal)
//        button.tintColor = .systemGreen
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//    
//    private let navigationStackView: UIStackView = {
//        let stackView = UIStackView()
//        stackView.axis = .horizontal
//        stackView.distribution = .fillEqually
//        stackView.spacing = 16
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        return stackView
//    }()
//    
//    private let previousButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
//        button.setTitle("Previous", for: .normal)
//        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
//        button.tintColor = .systemBlue
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.contentHorizontalAlignment = .leading
//        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
//        return button
//    }()
//    
//    private let nextButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Next", for: .normal)
//        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
//        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
//        button.tintColor = .systemBlue
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.contentHorizontalAlignment = .trailing
//        button.semanticContentAttribute = .forceRightToLeft
//        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
//        return button
//    }()
//    
//    private var timer: Timer?
//    private var elapsedTime: TimeInterval = 0
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//        title = "Record & Listen"
//        
//        setupUI()
//        setupConstraints()
//        setupActions()
//        setupAudioSession()
//        loadScriptText()
//        updateUI()
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        // Stop recording or playing if active
//        if isRecording {
//            stopRecording()
//        }
//        
//        if isPlaying {
//            stopPlaying()
//        }
//    }
//    
//    private func setupUI() {
//        // Add subviews
//        view.addSubview(containerView)
//        
//        containerView.addSubview(headerView)
//        headerView.addSubview(instructionLabel)
//        
//        containerView.addSubview(sectionTitleLabel)
//        
//        containerView.addSubview(scriptContainerView)
//        scriptContainerView.addSubview(scriptTextView)
//        
//        containerView.addSubview(timerContainerView)
//        timerContainerView.addSubview(timerLabel)
//        
//        // Add control buttons in horizontal stack
//        containerView.addSubview(controlButtonsStackView)
//        controlButtonsStackView.addArrangedSubview(recordButton)
//        controlButtonsStackView.addArrangedSubview(playButton)
//        
//        // Add mastered checkbox container
//        containerView.addSubview(masteredContainerView)
//        masteredContainerView.addSubview(masteredLabel)
//        masteredContainerView.addSubview(masteredCheckbox)
//        
//        containerView.addSubview(navigationStackView)
//        navigationStackView.addArrangedSubview(previousButton)
//        navigationStackView.addArrangedSubview(nextButton)
//    }
//    
//    private func setupConstraints() {
//        NSLayoutConstraint.activate([
//            // Container view
//            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
//            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
//            
//            // Header view
//            headerView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
//            headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
//            headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
//            
//            // Instruction label
//            instructionLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
//            instructionLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
//            instructionLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
//            instructionLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16),
//            
//            // Section title label
//            sectionTitleLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
//            sectionTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
//            sectionTitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
//            
//            // Script container view
//            scriptContainerView.topAnchor.constraint(equalTo: sectionTitleLabel.bottomAnchor, constant: 8),
//            scriptContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
//            scriptContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
//            scriptContainerView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.35),
//            
//            // Script text view
//            scriptTextView.topAnchor.constraint(equalTo: scriptContainerView.topAnchor),
//            scriptTextView.leadingAnchor.constraint(equalTo: scriptContainerView.leadingAnchor),
//            scriptTextView.trailingAnchor.constraint(equalTo: scriptContainerView.trailingAnchor),
//            scriptTextView.bottomAnchor.constraint(equalTo: scriptContainerView.bottomAnchor),
//            
//            // Timer container view
//            timerContainerView.topAnchor.constraint(equalTo: scriptContainerView.bottomAnchor, constant: 16),
//            timerContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
//            timerContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
//            
//            // Timer label
//            timerLabel.topAnchor.constraint(equalTo: timerContainerView.topAnchor, constant: 16),
//            timerLabel.leadingAnchor.constraint(equalTo: timerContainerView.leadingAnchor, constant: 16),
//            timerLabel.trailingAnchor.constraint(equalTo: timerContainerView.trailingAnchor, constant: -16),
//            timerLabel.bottomAnchor.constraint(equalTo: timerContainerView.bottomAnchor, constant: -16),
//            
//            // Control buttons stack view (horizontal)
//            controlButtonsStackView.topAnchor.constraint(equalTo: timerContainerView.bottomAnchor, constant: 16),
//            controlButtonsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
//            controlButtonsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
//            recordButton.heightAnchor.constraint(equalToConstant: 56),
//            playButton.heightAnchor.constraint(equalToConstant: 56),
//            
//            // Mastered container view
//            masteredContainerView.topAnchor.constraint(equalTo: controlButtonsStackView.bottomAnchor, constant: 16),
//            masteredContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
//            masteredContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
//            
//            // Mastered label and checkbox
//            masteredLabel.centerYAnchor.constraint(equalTo: masteredContainerView.centerYAnchor),
//            masteredLabel.leadingAnchor.constraint(equalTo: masteredContainerView.leadingAnchor, constant: 16),
//            
//            masteredCheckbox.centerYAnchor.constraint(equalTo: masteredContainerView.centerYAnchor),
//            masteredCheckbox.trailingAnchor.constraint(equalTo: masteredContainerView.trailingAnchor, constant: -16),
//            masteredCheckbox.widthAnchor.constraint(equalToConstant: 30),
//            masteredCheckbox.heightAnchor.constraint(equalToConstant: 30),
//            
//            masteredContainerView.heightAnchor.constraint(equalToConstant: 56),
//            
//            // Navigation stack view
//            navigationStackView.topAnchor.constraint(equalTo: masteredContainerView.bottomAnchor, constant: 16),
//            navigationStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
//            navigationStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 195),
//            navigationStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
//        ])
//    }
//    
//    private func setupActions() {
//        recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
//        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
//        masteredCheckbox.addTarget(self, action: #selector(masteredCheckboxTapped), for: .touchUpInside)
//        previousButton.addTarget(self, action: #selector(showPreviousSection), for: .touchUpInside)
//        nextButton.addTarget(self, action: #selector(showNextSection), for: .touchUpInside)
//    }
//    
//    private func loadScriptText() {
//        guard !session.sections.isEmpty else {
//            scriptTextView.text = "No script text available."
//            return
//        }
//        
//        // Load the current section text
//        scriptTextView.text = session.sections[currentSectionIndex].text
//        
//        // Update section title
//        sectionTitleLabel.text = "Section \(currentSectionIndex + 1) of \(session.sections.count)"
//    }
//    
//    private func setupAudioSession() {
//        let audioSession = AVAudioSession.sharedInstance()
//        
//        do {
//            try audioSession.setCategory(.playAndRecord, mode: .default)
//            try audioSession.setActive(true)
//            
//            // Request permission to record
//            audioSession.requestRecordPermission { [weak self] allowed in
//                DispatchQueue.main.async {
//                    self?.recordButton.isEnabled = allowed
//                    if !allowed {
//                        self?.showRecordingPermissionAlert()
//                    }
//                }
//            }
//        } catch {
//            print("Failed to set up audio session: \(error.localizedDescription)")
//        }
//    }
//    
//    private func updateUI() {
//        guard !session.sections.isEmpty else { return }
//        
//        // Update section title
//        sectionTitleLabel.text = "Section \(currentSectionIndex + 1) of \(session.sections.count)"
//        
//        // Update mastered checkbox
//        let isMastered = session.sections[currentSectionIndex].mastered
//        let checkboxImage = isMastered ? UIImage(systemName: "checkmark.square.fill") : UIImage(systemName: "square")
//        masteredCheckbox.setImage(checkboxImage, for: .normal)
//        
//        // Update navigation buttons
//        previousButton.isEnabled = currentSectionIndex > 0
//        nextButton.isEnabled = currentSectionIndex < session.sections.count - 1
//    }
//    
//    // MARK: - Navigation Methods
//    @objc private func showPreviousSection() {
//        guard currentSectionIndex > 0 else { return }
//        
//        // Stop any ongoing recording or playback
//        if isRecording {
//            stopRecording()
//        }
//        
//        if isPlaying {
//            stopPlaying()
//        }
//        
//        currentSectionIndex -= 1
//        loadScriptText()
//        updateUI()
//    }
//    
//    @objc private func showNextSection() {
//        guard currentSectionIndex < session.sections.count - 1 else { return }
//        
//        // Stop any ongoing recording or playback
//        if isRecording {
//            stopRecording()
//        }
//        
//        if isPlaying {
//            stopPlaying()
//        }
//        
//        currentSectionIndex += 1
//        loadScriptText()
//        updateUI()
//    }
//    
//    // MARK: - Recording Methods
//    private func startRecording() {
//        // Create recording URL in temporary directory
//        let documentsPath = FileManager.default.temporaryDirectory
//        let identifier = UUID().uuidString
//        recordingURL = documentsPath.appendingPathComponent("\(identifier).m4a")
//        
//        guard let url = recordingURL else { return }
//        
//        // Recording settings
//        let settings: [String: Any] = [
//            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
//            AVSampleRateKey: 44100.0,
//            AVNumberOfChannelsKey: 2,
//            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
//        ]
//        
//        do {
//            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
//            audioRecorder?.delegate = self
//            audioRecorder?.prepareToRecord()
//            audioRecorder?.record()
//            
//            // Update UI
//            isRecording = true
//            recordButton.setTitle("Stop", for: .normal)
//            recordButton.backgroundColor = .systemRed
//            
//            // Start timer
//            startTimer()
//        } catch {
//            print("Failed to start recording: \(error.localizedDescription)")
//        }
//    }
//    
//    private func stopRecording() {
//        audioRecorder?.stop()
//        audioRecorder = nil
//        
//        // Update UI
//        isRecording = false
//        recordButton.setTitle("Record", for: .normal)
//        recordButton.backgroundColor = .systemRed
//        playButton.isEnabled = recordingURL != nil
//        
//        // Stop timer
//        stopTimer()
//    }
//    
//    private func startPlaying() {
//        guard let url = recordingURL else { return }
//        
//        do {
//            audioPlayer = try AVAudioPlayer(contentsOf: url)
//            audioPlayer?.delegate = self
//            audioPlayer?.play()
//            
//            // Update UI
//            isPlaying = true
//            playButton.setTitle("Stop", for: .normal)
//            playButton.backgroundColor = .systemOrange
//            
//            // Start timer
//            startTimer()
//        } catch {
//            print("Failed to play recording: \(error.localizedDescription)")
//        }
//    }
//    
//    private func stopPlaying() {
//        audioPlayer?.stop()
//        audioPlayer = nil
//        
//        // Update UI
//        isPlaying = false
//        playButton.setTitle("Play", for: .normal)
//        playButton.backgroundColor = .systemBlue
//        
//        // Stop timer
//        stopTimer()
//    }
//    
//    // MARK: - Timer Methods
//    private func startTimer() {
//        elapsedTime = 0
//        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
//    }
//    
//    private func stopTimer() {
//        timer?.invalidate()
//        timer = nil
//    }
//    
//    @objc private func updateTimer() {
//        elapsedTime += 0.1
//        
//        // Format time
//        let minutes = Int(elapsedTime) / 60
//        let seconds = Int(elapsedTime) % 60
//        let tenths = Int(elapsedTime * 10) % 10
//        
//        timerLabel.text = String(format: "%02d:%02d.%d", minutes, seconds, tenths)
//    }
//    
//    // MARK: - Actions
//    @objc private func recordButtonTapped() {
//        if isRecording {
//            stopRecording()
//        } else {
//            startRecording()
//        }
//    }
//    
//    @objc private func playButtonTapped() {
//        if isPlaying {
//            stopPlaying()
//        } else {
//            startPlaying()
//        }
//    }
//    
//    @objc private func masteredCheckboxTapped() {
//        guard var updatedSession = session, !updatedSession.sections.isEmpty else { return }
//        
//        // Toggle mastered state for the current section
//        updatedSession.sections[currentSectionIndex].mastered.toggle()
//        updatedSession.sections[currentSectionIndex].lastPracticed = Date()
//        
//        // Update session
//        session = updatedSession
//        delegate?.didUpdateSession(updatedSession)
//        
//        // Update UI
//        updateUI()
//    }
//    
//    // MARK: - Alerts
//    private func showRecordingPermissionAlert() {
//        let alert = UIAlertController(
//            title: "Microphone Access Required",
//            message: "Please enable microphone access in Settings to use the recording feature.",
//            preferredStyle: .alert
//        )
//        
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
//            if let url = URL(string: UIApplication.openSettingsURLString) {
//                UIApplication.shared.open(url)
//            }
//        })
//        
//        present(alert, animated: true)
//    }
//    
//    // MARK: - AVAudioRecorderDelegate
//    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
//        if !flag {
//            print("Recording failed")
//        }
//        
//        isRecording = false
//        recordButton.setTitle("Record", for: .normal)
//        recordButton.backgroundColor = .systemRed
//        playButton.isEnabled = flag
//    }
//    
//    // MARK: - AVAudioPlayerDelegate
//    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        isPlaying = false
//        playButton.setTitle("Play", for: .normal)
//        playButton.backgroundColor = .systemBlue
//        stopTimer()
//    }
//}
//
//class SectionDetailViewController: UIViewController {
//    var section: MemorizationSection!
//    weak var delegate: MemorizationDelegate?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//        title = "Section Detail"
//        
//        // Placeholder UI
//        setupPlaceholderUI()
//    }
//    
//    private func setupPlaceholderUI() {
//        let textView = UITextView()
//        textView.text = section.text
//        textView.font = .systemFont(ofSize: 16)
//        textView.isEditable = false
//        textView.translatesAutoresizingMaskIntoConstraints = false
//        
//        view.addSubview(textView)
//        
//        NSLayoutConstraint.activate([
//            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
//        ])
//    }
//} 

import UIKit

protocol PerformanceSettingsDelegate: AnyObject {
    func didUpdateScriptSize(_ size: CGFloat)
    func didUpdateScrollSpeed(_ speed: Float)
    func didUpdateAutoScroll(_ enabled: Bool)
    func didSelectPreviewRatio(_ ratio: PreviewRatio)
}

enum PreviewRatio: String {
    case thirty70 = "thirty70"
    case fifty50 = "fifty50"
    case twenty80 = "twenty80"
    case zero100 = "zero100"
    
    var keynoteMultiplier: CGFloat {
        switch self {
        case .thirty70: return 0.3
        case .fifty50: return 0.5
        case .twenty80: return 0.2
        case .zero100: return 0.0
        }
    }
}

class PerformanceSettingsViewController: UIViewController {
    weak var delegate: PerformanceSettingsDelegate?
    
    // Add SettingsKeys struct
    private struct SettingsKeys {
        static let scriptSize = "scriptSize"
        static let scrollSpeed = "scrollSpeed"
        static let autoScroll = "autoScroll"
        static let previewRatio = "previewRatio"
    }
    
    // Add properties to store initial values
    private let initialScriptSize: Float
    private let initialScrollSpeed: Float
    private let initialAutoScroll: Bool
    private let initialRatio: PreviewRatio
    
    // Update init to accept initial values
    init(scriptSize: Float, scrollSpeed: Float, autoScroll: Bool, ratio: PreviewRatio) {
        self.initialScriptSize = scriptSize
        self.initialScrollSpeed = scrollSpeed
        self.initialAutoScroll = autoScroll
        self.initialRatio = ratio
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Performance Settings"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let scriptSizeSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 16
        slider.maximumValue = 40
        slider.value = 26
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private let scrollSpeedSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 1
        slider.maximumValue = 10
        slider.value = 5
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private let autoScrollSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    
    private lazy var ratioSegmentedControl: UISegmentedControl = {
        let items = ["30:70", "50:50", "20:80", "0:100"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear // Remove black background
        setupUI()
        
        // Set initial values
        scriptSizeSlider.value = initialScriptSize
        scrollSpeedSlider.value = initialScrollSpeed
        autoScrollSwitch.isOn = initialAutoScroll
        
        // Set initial ratio segment
        switch initialRatio {
        case .thirty70:
            ratioSegmentedControl.selectedSegmentIndex = 0
        case .fifty50:
            ratioSegmentedControl.selectedSegmentIndex = 1
        case .twenty80:
            ratioSegmentedControl.selectedSegmentIndex = 2
        case .zero100:
            ratioSegmentedControl.selectedSegmentIndex = 3
        }
        
        // Add value change handlers
        scriptSizeSlider.addTarget(self, action: #selector(scriptSizeChanged), for: .valueChanged)
        scrollSpeedSlider.addTarget(self, action: #selector(scrollSpeedChanged), for: .valueChanged)
        autoScrollSwitch.addTarget(self, action: #selector(autoScrollToggled), for: .valueChanged)
        ratioSegmentedControl.addTarget(self, action: #selector(ratioChanged), for: .valueChanged)
    }
    
    private func setupUI() {
        view.backgroundColor = .black.withAlphaComponent(0.5)
        
        view.addSubview(containerView)
        
        let scriptSizeLabel = createLabel(text: "Script Size")
        let scrollSpeedLabel = createLabel(text: "Scroll Speed")
        let autoScrollLabel = createLabel(text: "Auto Scroll")
        let ratioLabel = createLabel(text: "Preview Ratio")
        
        [titleLabel, scriptSizeLabel, scriptSizeSlider, 
         scrollSpeedLabel, scrollSpeedSlider,
         autoScrollLabel, autoScrollSwitch,
         ratioLabel, ratioSegmentedControl].forEach {
            containerView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 400),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            scriptSizeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            scriptSizeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            
            scriptSizeSlider.topAnchor.constraint(equalTo: scriptSizeLabel.bottomAnchor, constant: 8),
            scriptSizeSlider.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            scriptSizeSlider.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            scrollSpeedLabel.topAnchor.constraint(equalTo: scriptSizeSlider.bottomAnchor, constant: 24),
            scrollSpeedLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            
            scrollSpeedSlider.topAnchor.constraint(equalTo: scrollSpeedLabel.bottomAnchor, constant: 8),
            scrollSpeedSlider.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            scrollSpeedSlider.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            autoScrollLabel.topAnchor.constraint(equalTo: scrollSpeedSlider.bottomAnchor, constant: 24),
            autoScrollLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            
            autoScrollSwitch.centerYAnchor.constraint(equalTo: autoScrollLabel.centerYAnchor),
            autoScrollSwitch.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            ratioLabel.topAnchor.constraint(equalTo: autoScrollLabel.bottomAnchor, constant: 24),
            ratioLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            
            ratioSegmentedControl.topAnchor.constraint(equalTo: ratioLabel.bottomAnchor, constant: 8),
            ratioSegmentedControl.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            ratioSegmentedControl.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20)
        ])
    }
    
    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    @objc private func scriptSizeChanged() {
        delegate?.didUpdateScriptSize(CGFloat(scriptSizeSlider.value))
       // UserDefaults.standard.set(scriptSizeSlider.value, forKey: SettingsKeys.scriptSize)
    }
    
    @objc private func scrollSpeedChanged() {
        delegate?.didUpdateScrollSpeed(scrollSpeedSlider.value)
       // UserDefaults.standard.set(scrollSpeedSlider.value, forKey: SettingsKeys.scrollSpeed)
    }
    
    @objc private func autoScrollToggled() {
        delegate?.didUpdateAutoScroll(autoScrollSwitch.isOn)
       // UserDefaults.standard.set(autoScrollSwitch.isOn, forKey: SettingsKeys.autoScroll)
    }
    
    @objc private func ratioChanged() {
        let ratio: PreviewRatio
        switch ratioSegmentedControl.selectedSegmentIndex {
        case 0: ratio = .thirty70
        case 1: ratio = .fifty50
        case 2: ratio = .twenty80
        case 3: ratio = .zero100
        default: ratio = .thirty70
        }
        delegate?.didSelectPreviewRatio(ratio)
       // UserDefaults.standard.set(ratio.rawValue, forKey: SettingsKeys.previewRatio)
    }
}

extension PerformanceSettingsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == view
    }
} 

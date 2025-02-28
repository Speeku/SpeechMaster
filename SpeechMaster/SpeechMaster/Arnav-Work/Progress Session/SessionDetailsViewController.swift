import UIKit
import Charts

class SessionDetailsViewController: UIViewController {
    private let session: Session
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = 20
        sv.alignment = .fill
        return sv
    }()
    
    init(session: Session) {
        self.session = session
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateSessionData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Session Details"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }
    
    private func populateSessionData() {
        // Session Overview Card
        let overviewCard = createCard(title: "Session Overview") {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.spacing = 16
            
            // Basic session info
            stack.addArrangedSubview(createMetricView(
                title: "Duration",
                value: session.formattedDuration,
                icon: "clock.fill"
            ))
            
            stack.addArrangedSubview(createMetricView(
                title: "Date",
                value: formatDate(session.createdAt),
                icon: "calendar"
            ))
            
            return stack
        }
        contentStackView.addArrangedSubview(overviewCard)
        
        // Performance Metrics Card
        let metricsCard = createCard(title: "Performance Metrics") {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.spacing = 16
            
            if session.performanceMetrics.isEmpty {
                let noDataLabel = UILabel()
                noDataLabel.text = "No performance data available"
                noDataLabel.textColor = .secondaryLabel
                noDataLabel.textAlignment = .center
                noDataLabel.font = .systemFont(ofSize: 16)
                stack.addArrangedSubview(noDataLabel)
            } else {
                // Add metrics
                for (metric, value) in session.performanceMetrics {
                    stack.addArrangedSubview(createMetricView(
                        title: metric,
                        value: formatMetricValue(metric, value),
                        icon: iconForMetric(metric)
                    ))
                }
            }
            
            return stack
        }
        contentStackView.addArrangedSubview(metricsCard)
    }
    
    private func createCard(title: String, content: () -> UIView) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .systemBackground
        
        // Add shadow and corner radius for card-like appearance
        container.layer.cornerRadius = 16
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 6
        container.layer.shadowOpacity = 0.1
        
        // Create title label with updated styling
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let contentView = content()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subtle background tint
        let backgroundTintView = UIView()
        backgroundTintView.translatesAutoresizingMaskIntoConstraints = false
        backgroundTintView.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        backgroundTintView.layer.cornerRadius = 16
        
        container.addSubview(backgroundTintView)
        container.addSubview(titleLabel)
        container.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            // Background tint constraints
            backgroundTintView.topAnchor.constraint(equalTo: container.topAnchor),
            backgroundTintView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            backgroundTintView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            backgroundTintView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            // Title constraints
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            
            // Content constraints
            contentView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            contentView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            contentView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            contentView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20)
        ])
        
        return container
    }
    
    private func createMetricView(title: String, value: String, icon: String) -> UIView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        
        // Create circular background for icon
        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.backgroundColor = .systemBlue.withAlphaComponent(0.2)
        iconContainer.layer.cornerRadius = 20
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .systemBlue
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        iconContainer.addSubview(iconView)
        
        NSLayoutConstraint.activate([
            iconContainer.widthAnchor.constraint(equalToConstant: 40),
            iconContainer.heightAnchor.constraint(equalToConstant: 40),
            
            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.spacing = 4
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .secondaryLabel
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        valueLabel.textColor = .label
        
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(valueLabel)
        
        stack.addArrangedSubview(iconContainer)
        stack.addArrangedSubview(textStack)
        
        return stack
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func iconForMetric(_ metric: String) -> String {
        switch metric {
        case "Filler Words": return "text.bubble.fill"
        case "Missing Words": return "doc.text.fill"
        case "Pronunciation": return "waveform.path"
        case "Pace": return "speedometer"
        default: return "chart.bar.fill"
        }
    }
    
    private func formatMetricValue(_ metric: String, _ value: Double) -> String {
        switch metric {
        case "Duration":
            let minutes = Int(value) / 60
            let seconds = Int(value) % 60
            return String(format: "%d:%02d", minutes, seconds)
        case "Words/Min":
            return String(format: "%.0f WPM", value)
        default:
            return String(format: "%.0f", value)
        }
    }
} 
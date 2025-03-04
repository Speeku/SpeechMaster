import UIKit

class PitchGraphView: UIView {
    private let graphLayer = CAShapeLayer()
    private let targetLayer = CAShapeLayer()
    private var pitchValues: [Double] = []
    private let duration: TimeInterval
    private var targetZoneHeight: CGFloat = 0
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Pitch"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Low pitch variation will make your audience lose interest. Try increasing the tone for your key points."
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let targetLabel: UILabel = {
        let label = UILabel()
        label.text = "Target"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let monotoneLabel: UILabel = {
        let label = UILabel()
        label.text = "Monotone"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    // Add time labels container
    private let timeLabelsStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        return stack
    }()
    
    init(duration: TimeInterval) {
        self.duration = duration
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray4.cgColor
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.05
        
        [titleLabel, descriptionLabel, targetLabel, monotoneLabel, timeLabelsStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        // Update label colors and styles
        targetLabel.textColor = .white
        targetLabel.backgroundColor = .clear
        monotoneLabel.textColor = .black
        
        createTimeLabels()
        
        layer.addSublayer(targetLayer)
        layer.addSublayer(graphLayer)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            // Increase overall height
            heightAnchor.constraint(equalToConstant: 300),
            
            timeLabelsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            timeLabelsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            timeLabelsStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    private func createTimeLabels() {
        // Remove existing labels
        timeLabelsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Create 4 evenly spaced time labels
        let numberOfLabels = 4
        for i in 0..<numberOfLabels {
            let timeLabel = UILabel()
            timeLabel.font = .systemFont(ofSize: 12)
            timeLabel.textColor = .secondaryLabel
            
            let time = duration * Double(i) / Double(numberOfLabels - 1)
            timeLabel.text = formatTime(time)
            
            timeLabelsStack.addArrangedSubview(timeLabel)
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        drawGraph()
    }
    
    private func drawGraph() {
        let graphRect = CGRect(x: 16,
                             y: descriptionLabel.frame.maxY + 20,
                             width: bounds.width - 32,
                             height: 160)
        
        // Draw target zone (blue zone at top)
        let targetZoneY = graphRect.minY
        targetZoneHeight = graphRect.height * 0.3
        let targetPath = UIBezierPath(rect: CGRect(x: graphRect.minX, 
                                                  y: targetZoneY,
                                                  width: graphRect.width,
                                                  height: targetZoneHeight))
        
        targetLayer.path = targetPath.cgPath
        targetLayer.fillColor = UIColor.systemBlue.withAlphaComponent(0.15).cgColor
        targetLayer.strokeColor = nil
        
        // Position target label in top-left of blue zone
        targetLabel.frame = CGRect(x: graphRect.minX + 4,
                                 y: targetZoneY + 4,
                                 width: 45,
                                 height: 20)
        targetLabel.textColor = .black
        
        monotoneLabel.frame = CGRect(x: graphRect.minX + 4,
                                    y: targetZoneY + targetZoneHeight + 4,
                                    width: 80,
                                    height: 20)
        
        // Draw pitch line
        let path = UIBezierPath()
        let startY = graphRect.minY + graphRect.height * 0.7
        path.move(to: CGPoint(x: graphRect.minX, y: startY))
        
        let points = generateWavePoints(in: graphRect)
        points.forEach { point in
            path.addLine(to: point)
        }
        
        graphLayer.path = path.cgPath
        graphLayer.strokeColor = UIColor.systemBlue.cgColor
        graphLayer.fillColor = nil
        graphLayer.lineWidth = 1.5
    }
    
    private func generateWavePoints(in rect: CGRect) -> [CGPoint] {
        var points: [CGPoint] = []
        let segments = 60
        let segmentWidth = rect.width / CGFloat(segments)
        
        // Calculate the available vertical space for the wave
        let waveCenter = rect.minY + rect.height * 0.65
        let maxAmplitude = rect.height * 0.15
        
        for i in 0...segments {
            let x = rect.minX + (CGFloat(i) * segmentWidth)
            
            let progress = CGFloat(i) / CGFloat(segments)
            let baseVariation = sin(progress * .pi * 3) * maxAmplitude
            let randomVariation = CGFloat.random(in: -maxAmplitude/3...maxAmplitude/3)
            let totalVariation = baseVariation + randomVariation
            
            let y = waveCenter + totalVariation
            let minY = rect.minY + targetZoneHeight
            let maxY = rect.maxY - 4
            let clampedY = min(max(y, minY), maxY)
            points.append(CGPoint(x: x, y: clampedY))
        }
        
        return points
    }
}
import UIKit

class MultiColorCircularProgressView: UIView {
    // MARK: - Properties
    private let trackLayer = CAShapeLayer()
    private var segments: [CAShapeLayer] = []
    
    private struct Colors {
        static let fillers = UIColor(hex: "1C1B4D")      // Navy blue
        static let missing = UIColor(hex: "B80E65")      // Pink/Magenta
        static let pronunciation = UIColor(hex: "1791B1") // Light blue
        static let background = UIColor.systemGray4.withAlphaComponent(0.4)
    }
    
    var progress: CGFloat = 0 {
        didSet {
            updateSegments()
        }
    }
    
    // Add properties for individual segment values
    private var fillerProgress: CGFloat = 0
    private var missingProgress: CGFloat = 0
    private var pronunciationProgress: CGFloat = 0
    
    // Make the circle slightly larger
    private let circleLineWidth: CGFloat = 12 // Increased from 15
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    // MARK: - Setup
    private func setupLayers() {
        // Full gray circle background
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = Colors.background.cgColor
        trackLayer.lineWidth = circleLineWidth
        trackLayer.lineCap = .round
        
        // Create full circle path for track
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - circleLineWidth/2
        let trackPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -CGFloat.pi / 2,
            endAngle: 3 * CGFloat.pi / 2,  // Complete circle
            clockwise: true
        )
        trackLayer.path = trackPath.cgPath
        layer.addSublayer(trackLayer)
        
        // Colored segments on top
        let colors = [Colors.fillers, Colors.missing, Colors.pronunciation]
        for (index, _) in (0..<3).enumerated() {
            let segmentLayer = CAShapeLayer()
            segmentLayer.fillColor = UIColor.clear.cgColor
            segmentLayer.strokeColor = colors[index].cgColor
            segmentLayer.lineWidth = circleLineWidth
            segmentLayer.lineCap = .round
            segmentLayer.strokeEnd = 0
            layer.addSublayer(segmentLayer)
            segments.append(segmentLayer)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - 10  // Adjust radius to fit within bounds
        
        // Create circular paths for each segment
        for (index, segment) in segments.enumerated() {
            let startAngle = -CGFloat.pi / 2 + (2 * CGFloat.pi / CGFloat(segments.count)) * CGFloat(index)
            let endAngle = startAngle + (2 * CGFloat.pi / CGFloat(segments.count))
            
            let path = UIBezierPath(
                arcCenter: center,
                radius: radius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: true
            )
            
            segment.path = path.cgPath
        }
        
        // Create track path (complete circle)
        let trackPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -CGFloat.pi / 2,
            endAngle: 3 * CGFloat.pi / 2,
            clockwise: true
        )
        
        trackLayer.path = trackPath.cgPath
    }
    
    // MARK: - Progress Update
    private func updateSegments() {
        // Divide the progress among three segments
        let segmentLength = 1.0 / CGFloat(segments.count)
        
        for (index, segment) in segments.enumerated() {
            let startPosition = CGFloat(index) * segmentLength
            let endPosition = CGFloat(index + 1) * segmentLength
            
            let segmentProgress = min(max(0, (progress - startPosition) / segmentLength), 1)
            
            segment.strokeStart = startPosition
            segment.strokeEnd = startPosition + (segmentLength * segmentProgress)
        }
    }
    
    // MARK: - Public Methods
    func setProgress(_ value: CGFloat, animated: Bool = true) {
        let newProgress = min(max(0, value), 1)
        
        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = progress
            animation.toValue = newProgress
            animation.duration = 0.5
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            for segment in segments {
                segment.add(animation, forKey: "progressAnimation")
            }
        }
        
        progress = newProgress
    }
    
    func setSegmentColors() {
        segments[0].strokeColor = Colors.fillers.cgColor
        segments[1].strokeColor = Colors.missing.cgColor
        segments[2].strokeColor = Colors.pronunciation.cgColor
    }
    
    // Update setSegmentValues to make segments proportional to their values
    func setSegmentValues(fillers: Int, missing: Int, pronunciation: Int) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.5)
        
        // Reset segments
        segments.forEach { segment in
            segment.strokeEnd = 0
            segment.removeAllAnimations()
        }
        
        // Set up the full circle path for each segment
        var startAngle = -CGFloat.pi / 2  // Start from top
        let values = [fillers, missing, pronunciation]
        
        for (index, segment) in segments.enumerated() {
            let endAngle = startAngle + (2 * CGFloat.pi / 3.0)  // Divide circle into 3 equal parts
            
            let path = UIBezierPath(
                arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                radius: min(bounds.width, bounds.height) / 2 - circleLineWidth/2,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: true
            )
            
            segment.path = path.cgPath
            // Fill each segment according to its improvement percentage
            segment.strokeEnd = CGFloat(values[index]) / 100.0  // Convert percentage to 0-1 range
            
            startAngle = endAngle
        }
        
        CATransaction.commit()
    }
}

// Add the same UIColor extension if not already present
extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

//// Helper extension for safe array access
//private extension Array {
//    subscript(safe index: Int) -> Element? {
//        return indices.contains(index) ? self[index] : nil
//    }


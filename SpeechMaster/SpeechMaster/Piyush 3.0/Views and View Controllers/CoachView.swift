import UIKit

class CoachView: UIView {
    private let circleLayer = CAShapeLayer()
    private let suggestionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .left
        label.numberOfLines = 2
        label.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.isHidden = true
        return label
    }()
    
    private var isAnimating = false
    private let size: CGFloat = 50
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        // Setup circle
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: size/2, y: size/2),
            radius: size/2 - 2,
            startAngle: 0,
            endAngle: 2 * .pi,
            clockwise: true
        )
        
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = UIColor.systemBlue.cgColor
        circleLayer.lineWidth = 8
        layer.addSublayer(circleLayer)
        
        // Add suggestion label to the right of the circle
        addSubview(suggestionLabel)
        NSLayoutConstraint.activate([
            suggestionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: size + 8),
            suggestionLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            suggestionLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 200),
            suggestionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 32)
        ])
        
        // Update frame to accommodate suggestion label
        frame.size.width = size + 216
        
        startAnimation()
    }
    
    private func startAnimation() {
        isAnimating = true
        
        // Simple pulse animation
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.1
        pulseAnimation.duration = 1.0
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        circleLayer.add(pulseAnimation, forKey: "pulse")
    }
    
    func showSuggestion(_ text: String, type: CoachSuggestionType) {
        // Add padding to label text
        suggestionLabel.text = "  \(text)  "
        suggestionLabel.isHidden = false
        
        // Update circle color based on suggestion type
        let color = type.color
        circleLayer.strokeColor = color.cgColor
        
        // Fade in animation for suggestion label
        suggestionLabel.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.suggestionLabel.alpha = 1
        }
        
        // Hide suggestion after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            UIView.animate(withDuration: 0.3) {
                self.suggestionLabel.alpha = 0
            } completion: { _ in
                self.suggestionLabel.isHidden = true
            }
        }
    }
}

enum CoachSuggestionType {
    case speedWarning
    case volumeWarning
    case goodPace
    case goodVolume
    case fillerWordWarning
    
    var color: UIColor {
        switch self {
        case .speedWarning, .volumeWarning, .fillerWordWarning:
            return .systemRed
        case .goodPace, .goodVolume:
            return .systemGreen
        }
    }
} 

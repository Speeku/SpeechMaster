import UIKit

class PaceMeterView: UIView {
    private let wordsPerMinute: Int
    private let meterLayer = CAShapeLayer()
    private let backgroundLayer = CAShapeLayer()
    
    private let wpmLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let wpmSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "words/min"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let slowLabel: UILabel = {
        let label = UILabel()
        label.text = "Slow"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let fastLabel: UILabel = {
        let label = UILabel()
        label.text = "Fast"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(wordsPerMinute: Int) {
        self.wordsPerMinute = wordsPerMinute
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        wpmLabel.text = "\(wordsPerMinute)"
        
        [wpmLabel, wpmSubtitleLabel, slowLabel, fastLabel].forEach { addSubview($0) }
        
        NSLayoutConstraint.activate([
            wpmLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            wpmLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            wpmSubtitleLabel.topAnchor.constraint(equalTo: wpmLabel.bottomAnchor, constant: 4),
            wpmSubtitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            slowLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            slowLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 3),
            
            fastLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            fastLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 3)
        ])
        
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(meterLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let yOffset: CGFloat = 26
        let center = CGPoint(x: bounds.midX, y: bounds.maxY - yOffset)
        let radius = min(bounds.width, bounds.height) * 0.8
        let startAngle = Double.pi
        let endAngle = 0.0
        
        let path = UIBezierPath(arcCenter: center,
                               radius: radius,
                               startAngle: startAngle,
                               endAngle: endAngle,
                               clockwise: true)
        
        backgroundLayer.path = path.cgPath
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeColor = UIColor.systemGray5.cgColor
        backgroundLayer.lineWidth = 24
        backgroundLayer.lineCap = .square
        
        meterLayer.path = path.cgPath
        meterLayer.fillColor = UIColor.clear.cgColor
        meterLayer.strokeColor = UIColor.systemBlue.cgColor
        meterLayer.lineWidth = 24
        meterLayer.lineCap = .square
        
        let progress = calculateProgress(wordsPerMinute)
        meterLayer.strokeEnd = progress
    }
    
    private func calculateProgress(_ wpm: Int) -> CGFloat {
        // Define the range (80-160 wpm)
        let minWPM: CGFloat = 80
        let maxWPM: CGFloat = 160
        let idealLow: CGFloat = 120
        let idealHigh: CGFloat = 140
        
        let progress = CGFloat(wpm - Int(minWPM)) / (maxWPM - minWPM)
        return min(max(progress, 0), 1)
    }
} 

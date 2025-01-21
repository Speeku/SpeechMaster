//
//  PaceMeterView.swift
//  SpeechMaster
//
//  Created by Piyush on 19/01/25.
//

import UIKit


class PaceMeterView: UIView {

    private let maxValue: CGFloat = 200.0
    private let startAngle: CGFloat = .pi
    private let endAngle: CGFloat = 0
    
    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private let valueLabel = UILabel()
    private let wordsPerMinLabel = UILabel()
//    private let slowLabel = UILabel()
//    private let fastLabel = UILabel()
    
    var value: CGFloat = 0 {
        didSet {
            updateProgress(animated: true)
            valueLabel.text = "\(Int(value))"
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        // Setup track layer
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor.systemGray5.cgColor
        trackLayer.lineWidth = 20
        trackLayer.lineCap = .square
        layer.addSublayer(trackLayer)
        
        // Setup progress layer
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.systemBlue.cgColor
        progressLayer.lineWidth = 20
        progressLayer.lineCap = .square
        layer.addSublayer(progressLayer)
        
        // Setup value label
        valueLabel.font = .systemFont(ofSize: 36, weight: .bold)
        valueLabel.textAlignment = .center
        addSubview(valueLabel)
        
        // Setup words/min label
        wordsPerMinLabel.text = "words/min"
        wordsPerMinLabel.font = .systemFont(ofSize: 14)
        wordsPerMinLabel.textAlignment = .center
        wordsPerMinLabel.textColor = .gray
        addSubview(wordsPerMinLabel)
        
        // Setup "Slow" label
//        slowLabel.text = "Slow"
//        slowLabel.font = .systemFont(ofSize: 14)
//        slowLabel.textAlignment = .left
//        addSubview(slowLabel)
//        
//        // Setup "Fast" label
//        fastLabel.text = "Fast"
//        fastLabel.font = .systemFont(ofSize: 14)
//        fastLabel.textAlignment = .right
//        addSubview(fastLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - 20
        
        // Create arc path
        let path = UIBezierPath(arcCenter: center,
                               radius: radius,
                               startAngle: startAngle,
                               endAngle: endAngle,
                               clockwise: true)
        
        trackLayer.path = path.cgPath
        progressLayer.path = path.cgPath
        
        // Position labels
        valueLabel.frame = CGRect(x: center.x - 50,
                                y: center.y - 30,
                                width: 100,
                                height: 40)
        
        wordsPerMinLabel.frame = CGRect(x: center.x - 50,
                                      y: center.y + 10,
                                      width: 100,
                                      height: 20)
//        
//        slowLabel.frame = CGRect(x: 20,
//                               y: bounds.height - 30,
//                               width: 50,
//                               height: 20)
//        
//        fastLabel.frame = CGRect(x: bounds.width - 70,
//                               y: bounds.height - 30,
//                               width: 50,
//                               height: 20)
        
        updateProgress(animated: false)
    }
    
    private func updateProgress(animated: Bool) {
        let progress = value / maxValue
        progressLayer.strokeEnd = min(max(progress, 0), 1)
        
        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = 0.3
            animation.fromValue = progressLayer.presentation()?.strokeEnd ?? 0
            animation.toValue = progress
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            progressLayer.add(animation, forKey: "progressAnimation")
        }
    }
   }


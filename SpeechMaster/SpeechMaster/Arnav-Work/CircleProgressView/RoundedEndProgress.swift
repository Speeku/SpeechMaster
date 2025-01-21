//
//  RoundedEndProgress.swift
//  SpeechMaster
//
//  Created by Arnav Chauhan on 21/01/25.
//

import UIKit

class RoundedEndProgress: UIView {

    private let trackLayer = CAShapeLayer()
        private let progressLayer = CAShapeLayer()
        
        var progress: CGFloat = 0 {
            didSet {
                updateProgress()
            }
        }
        
    var progressColor: UIColor = .systemBlue {
            didSet {
                progressLayer.strokeColor = progressColor.cgColor
            }
        }
        
    var trackColor: UIColor = .clear {
            didSet {
                trackLayer.strokeColor = trackColor.cgColor
            }
        }
        
        var lineWidth: CGFloat = 15 {
            didSet {
                setupLayers()
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupLayers()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupLayers()
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            setupLayers()
        }
        
        private func setupLayers() {
            // Create path for the line
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: bounds.midY))
            path.addLine(to: CGPoint(x: bounds.width, y: bounds.midY))
            
            // Setup track layer
            trackLayer.path = path.cgPath
            trackLayer.strokeColor = trackColor.cgColor
            trackLayer.lineWidth = lineWidth
            trackLayer.lineCap = .round // This makes the right end round
            trackLayer.fillColor = nil
            
            // Setup progress layer
            progressLayer.path = path.cgPath
            progressLayer.strokeColor = progressColor.cgColor
            progressLayer.lineWidth = lineWidth
            progressLayer.lineCap = .round // This makes the right end round
            progressLayer.fillColor = nil
            progressLayer.strokeEnd = progress
            
            // Add layers to view
            layer.addSublayer(trackLayer)
            layer.addSublayer(progressLayer)
        }
    
        
        private func updateProgress() {
            progressLayer.strokeEnd = progress
        }

}

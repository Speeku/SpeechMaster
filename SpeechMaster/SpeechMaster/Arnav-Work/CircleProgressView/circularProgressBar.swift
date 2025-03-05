//
//  circularProgressBar.swift
//  app1
//
//  Created by Arnav Chauhan on 13/01/25.
//

import UIKit

class circularProgressBar: UIView {
    

        // Properties
        var progress: CGFloat = 0.5 { // Value between 0 and 1
            didSet {
                setNeedsDisplay() // Redraw when progress changes
            }
        }
        var progressColor: UIColor = .systemBlue
        var trackColor: UIColor = .white
        var lineWidth: CGFloat = 10.0

        // Drawing the progress bar
        override func draw(_ rect: CGRect) {
            let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
            let radius = min(rect.width, rect.height) / 2 - lineWidth / 2

            // Draw the track (background circle)
            let trackPath = UIBezierPath(
                arcCenter: center,
                radius: radius,
                startAngle: -CGFloat.pi / 2,
                endAngle: CGFloat.pi * 2 - CGFloat.pi / 2,
                clockwise: true
            )
            trackPath.lineWidth = lineWidth
            trackColor.setStroke()
            trackPath.stroke()

            // Draw the progress (foreground circle)
            let progressPath = UIBezierPath(
                arcCenter: center,
                radius: radius,
                startAngle: -CGFloat.pi / 2,
                endAngle: (-CGFloat.pi / 2) + (progress * 2 * CGFloat.pi),
                clockwise: true
            )
            progressPath.lineWidth = lineWidth
            progressColor.setStroke()
            
            progressPath.stroke()
        }
    }

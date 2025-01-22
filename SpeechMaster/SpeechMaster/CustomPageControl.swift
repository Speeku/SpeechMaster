//
//  CustomPageControl.swift
//  SpeechMaster
//
//  Created by Abuzar Siddiqui on 22/01/25.
//

import Foundation
import UIKit

protocol CustomPageControlDelegate: AnyObject {
    func pageControl(_ pageControl: CustomPageControl, didSelectPageAt index: Int)
}

class CustomPageControl: UIView {
    var numberOfPages: Int = 0 {
        didSet {
            setupDots()
        }
    }
    var currentPage: Int = 0 {
        didSet {
            updateDotAppearance()
        }
    }
    var dotColor: UIColor = .lightGray
    var selectedDotColor: UIColor = .systemBlue
    var dotSize: CGSize = CGSize(width: 20, height: 10)
    var spacing: CGFloat = 8

    weak var delegate: CustomPageControlDelegate?

    private var dots: [UIView] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGesture()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGesture()
    }

    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }

    private func setupDots() {
        // Remove existing dots
        dots.forEach { $0.removeFromSuperview() }
        dots.removeAll()

        // Add new dots
        for _ in 0..<numberOfPages {
            let dot = UIView()
            dot.layer.cornerRadius = dotSize.height / 2
            dot.backgroundColor = dotColor
            dots.append(dot)
            addSubview(dot)
        }
        layoutDots()
        updateDotAppearance()
    }

    private func layoutDots() {
        let totalWidth = CGFloat(numberOfPages) * dotSize.width + CGFloat(numberOfPages - 1) * spacing
        let startX = (bounds.width - totalWidth) / 2
        let centerY = bounds.height / 2

        for (index, dot) in dots.enumerated() {
            let x = startX + CGFloat(index) * (dotSize.width + spacing)
            dot.frame = CGRect(x: x, y: centerY - dotSize.height / 2, width: dotSize.width, height: dotSize.height)
        }
    }

    private func updateDotAppearance() {
        for (index, dot) in dots.enumerated() {
            dot.backgroundColor = index == currentPage ? selectedDotColor : dotColor
        }
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)

        // Find which dot was tapped
        for (index, dot) in dots.enumerated() {
            if dot.frame.contains(location) {
                currentPage = index
                delegate?.pageControl(self, didSelectPageAt: index)
                break
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutDots()
    }
}

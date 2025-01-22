import UIKit

class SiriWaveView: UIView {
    private var displayLink: CADisplayLink?
    private var waveLayer: CAShapeLayer = CAShapeLayer()
    private var phase: CGFloat = 0
    private var amplitude: CGFloat = 10
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupWaveLayer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupWaveLayer()
    }
    
    private func setupWaveLayer() {
        waveLayer.fillColor = UIColor.clear.cgColor
        waveLayer.strokeColor = UIColor.systemBlue.cgColor
        waveLayer.lineWidth = 2
        layer.addSublayer(waveLayer)
    }
    
    func startAnimating() {
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(updateWave))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    func stopAnimating() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func updateWave() {
        phase += 0.1
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: bounds.midY))
        
        for x in stride(from: 0, through: bounds.width, by: 1) {
            let frequency: CGFloat = 0.9
            let y = bounds.midY + amplitude * sin(frequency * x + phase)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        waveLayer.path = path.cgPath
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        waveLayer.frame = bounds
    }
}

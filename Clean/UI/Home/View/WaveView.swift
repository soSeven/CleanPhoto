//
//  WaveView.swift
//  Clean
//
//  Created by liqi on 2020/10/26.
//

import UIKit

private let PI_Circle: CGFloat = CGFloat.pi * 2

class WaveLayer: CAShapeLayer {
    
    /// 相对偏移差 0~1
    var offsetScale: CGFloat = 0
    /// 波浪高度
    var height: CGFloat = 50
    /// 波浪深度
    var waveDeepHeight: CGFloat = 30
}

class WaveView: UIView {
    
    private var waveLink: CADisplayLink?
    private var waves = [WaveLayer]()
    private var currentPhase: CGFloat = 0
    private var horizontalStep: CGFloat = 0.05
    private var cycleCount: CGFloat = 0.5
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        start()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        waveLink?.invalidate()
        waveLink = nil
    }
    
    // MARK: - Set up
    
    private func setup() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(stop), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(start), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        alpha = 0.17
//        backgroundColor = .red
    }
    
    // MARK: - Draw Wave
    
    private func draw(wave: WaveLayer) {
        
        let width = bounds.size.width
        
        func angleInRadians(at x: CGFloat) -> CGFloat {
            return x / width * (PI_Circle * cycleCount)
        }
        
        func point(at i: Int) -> CGPoint {
            let x = CGFloat(i)
            let angle = angleInRadians(at: x)
            let y = ((sin(angle + currentPhase + CGFloat.pi/2.0 * wave.offsetScale) + 1)) * wave.height / 2 + wave.waveDeepHeight
            return CGPoint(x: x, y: bounds.height - y)
        }
        
        let path = UIBezierPath()
        path.move(to: point(at: 0))
        for i in 1...Int(width) {
            path.addLine(to: point(at: i))
        }
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
        path.addLine(to: CGPoint(x: 0, y: bounds.maxY))
        path.close()
        wave.path = path.cgPath
        
        currentPhase += horizontalStep
        if currentPhase > PI_Circle {
            currentPhase -= PI_Circle
        } else if currentPhase < PI_Circle {
            currentPhase += PI_Circle
        }
        
    }
    
    // MARK: - Start & Stop
    
    @objc func start() {
        
        waveLink?.invalidate()
        waveLink = nil
        
        waveLink = CADisplayLink(target: self, selector: #selector(waveLinkRefresh))
        waveLink?.add(to: .current, forMode: RunLoop.Mode.default)
    }
    
    @objc func stop() {
        waveLink?.invalidate()
        waveLink = nil
    }
    
    // MARK: - Add & Remove
    
    func add(wave: WaveLayer) {
        waves.append(wave)
        
        let underWave = CAGradientLayer()
        underWave.frame = bounds
        underWave.colors = [UIColor(hex: "#ffffff").alpha(1).cgColor,
                            UIColor(hex: "#ffffff").alpha(0).cgColor]
        layer.addSublayer(underWave)
        underWave.mask = wave
        layer.addSublayer(underWave)
    }
    
    func removeAllWaves() {
        waves.removeAll()
        layer.sublayers?.forEach{$0.removeFromSuperlayer()}
    }
    
    // MARK: - Refresh
    
    @objc
    private func waveLinkRefresh() {
        for w in waves {
            draw(wave: w)
//            w.offsetX += w.speedX
        }
    }
    
}


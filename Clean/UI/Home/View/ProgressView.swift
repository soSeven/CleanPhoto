//
//  ProgressView.swift
//  Clean
//
//  Created by liqi on 2020/10/26.
//

import UIKit
import RxCocoa
import RxSwift

class ProgressView: UIView {
    
    private var waveLink: CADisplayLink?
    private let btnShape = CAShapeLayer()
    let btn = UIButton()
    private var startX = -100.uiX
    
    private let startLbl = UILabel()
    private let progressLbl = UILabel()
    private let numberLbl = UILabel()
    private let spaceLbl = UILabel()
    private let shape = CAShapeLayer()
    private let btnMaskImgView = UIImageView()
    private let endStack = UIStackView()
    
    var checkBlock: (()->())?
    var cleanBlock: (()->())?
    var btnDisposeBag = DisposeBag()
    
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
        
        let bgImg = UIImage.create("jd-icon")
        let bgImgView = UIImageView(image: bgImg)
        bgImgView.size = bgImg.snpSize
        bgImgView.x = (width - bgImgView.width)/2.0
        bgImgView.y = (height - bgImgView.height)/2.0
        addSubview(bgImgView)
        
        let bgW = 162.5.uiX
        let bgH = 162.5.uiX
        let bgX = (width - bgW)/2.0
        let bgY = (height - bgH)/2.0
        let bgView = UIView()
        bgView.frame = CGRect(x: bgX, y: bgY, width: bgW, height: bgH)

        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(hex: "#ffffff").cgColor,
            UIColor(hex: "#53D9D8").cgColor
        ]
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0.0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        gradient.frame = bgView.bounds
        bgView.layer.addSublayer(gradient)
        addSubview(bgView)

        let lineWidth: CGFloat = 11.5.uiX
        let arcCenter: CGPoint = .init(x: bgW/2.0, y: bgH/2.0)
        let radius = (bgView.width - lineWidth)/2.0
        let path = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: CGFloat.pi/2.0, endAngle: CGFloat.pi*5.0/2.0, clockwise: true)
        shape.path = path.cgPath
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.red.cgColor
        shape.strokeEnd = 1
        shape.strokeStart = 0
        shape.lineWidth = lineWidth

        gradient.mask = shape
        
        let btnImg = UIImage.create("sy-ljsm-an")
        btn.size = btnImg.snpSize
        btn.x = (width - btn.width)/2.0
        btn.y = 150.5.uiX
        btn.setBackgroundImage(btnImg, for: .normal)
        addSubview(btn)
        
        let btnMaskImg = UIImage.create("gx-icon")
        btnMaskImgView.image = btnMaskImg
        btnMaskImgView.size = btnImg.snpSize
        btnMaskImgView.x = (width - btnMaskImgView.width)/2.0
        btnMaskImgView.y = 150.5.uiX
        addSubview(btnMaskImgView)
        
        btnShape.fillColor = UIColor.red.cgColor
        btnMaskImgView.layer.mask = btnShape
        
        startLbl.textColor = .init(hex: "#FFFFFF")
        startLbl.font = .init(style: .medium, size: 27.uiX)
        startLbl.text = "智能\n扫描"
        startLbl.numberOfLines = 2
        addSubview(startLbl)
        startLbl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10.uiX)
        }
        
        progressLbl.textColor = .init(hex: "#FFFFFF")
        progressLbl.font = .init(style: .medium, size: 27.uiX)
        progressLbl.text = "0%"
        addSubview(progressLbl)
        progressLbl.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        numberLbl.textColor = .init(hex: "#FFFFFF")
        numberLbl.font = .init(style: .medium, size: 18.uiX)
        numberLbl.text = "0张可清理"
        
        spaceLbl.textColor = .init(hex: "#FFFFFF")
        spaceLbl.font = .init(style: .regular, size: 13.uiX)
        spaceLbl.text = "占用空间0%"
        
        endStack.addArrangedSubviews([numberLbl, spaceLbl])
        endStack.axis = .vertical
        endStack.distribution = .equalSpacing
        endStack.alignment = .center
        addSubview(endStack)
        endStack.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10.uiX)
        }
        
        setupProgress(type: .check)
        
    }
    
    func setupProgress(type: PhotoManager.ProgressType) {
        
        btnDisposeBag = DisposeBag()
        
        switch type {
        case .check:
            startLbl.isHidden = false
            endStack.isHidden = true
            progressLbl.isHidden = true
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            shape.strokeEnd = 1
            CATransaction.commit()
            btn.isHidden = false
            btn.setBackgroundImage(.create("sy-ljsm-an"), for: .normal)
            btnMaskImgView.isHidden = false
            btn.rx.tap.subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.checkBlock?()
            }).disposed(by: btnDisposeBag)
        case .start(_, _):
            startLbl.isHidden = true
            progressLbl.isHidden = false
            progressLbl.text = "0%"
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            shape.strokeEnd = 0
            CATransaction.commit()
            btn.isHidden = true
            btnMaskImgView.isHidden = true
            endStack.isHidden = true
        case let .progress(p, total):
            startLbl.isHidden = true
            progressLbl.isHidden = false
            btn.isHidden = true
            btnMaskImgView.isHidden = true
            endStack.isHidden = true
            let progress: Float = Float(p)/Float(total)
            progressLbl.text = String(format: "%.f%%", progress * 100)
            shape.strokeEnd = CGFloat(progress)
        case let .end(_, _, cleanCount, totalBytes):
            startLbl.isHidden = true
            progressLbl.isHidden = true
            shape.strokeEnd = 1
            btn.isHidden = false
            
            btnMaskImgView.isHidden = false
            endStack.isHidden = false
            if cleanCount == 0 {
                btn.setBackgroundImage(.create("sy-ljsm-an"), for: .normal)
                numberLbl.textColor = .init(hex: "#FFFFFF")
                numberLbl.font = .init(style: .regular, size: 16.uiX)
                numberLbl.text = "暂无可清理照片"
                spaceLbl.isHidden = true
                btn.rx.tap.subscribe(onNext: { [weak self] in
                    guard let self = self else { return }
                    self.checkBlock?()
                }).disposed(by: btnDisposeBag)
            } else {
                btn.setBackgroundImage(.create("ljql-an"), for: .normal)
                numberLbl.textColor = .init(hex: "#FFFFFF")
                numberLbl.font = .init(style: .medium, size: 18.uiX)
                numberLbl.text = "\(cleanCount)张可清理"
                spaceLbl.isHidden = false
                let scale = Double(totalBytes)/Double(UIDevice.getTotalDiskSize())
                let n = NumberFormatter()
                n.maximumFractionDigits = 2
                n.minimumIntegerDigits = 1
                let s = n.string(from: NSNumber(value: scale * 100)) ?? "0"
                spaceLbl.text = String(format: "占用空间%@%%", s)
                btn.rx.tap.subscribe(onNext: { [weak self] in
                    guard let self = self else { return }
                    self.cleanBlock?()
                }).disposed(by: btnDisposeBag)
            }
            
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
    
    // MARK: - Refresh
    
    @objc
    private func waveLinkRefresh() {
        
        let width1 = 12.5.uiX
        let width2 = 2.5.uiX
        let width3 = 2.uiX
        let skip = 25.uiX
        let layerHeight = btn.height
        let layerMaxWidth = btn.width
        
        startX += 2.uiX
        if startX >  layerMaxWidth + 100.uiX {
            startX = -100.uiX
        }
        
        let btnPath = UIBezierPath(from: .init(x: skip + startX + width1, y: 0), to: .init(x: startX + skip, y: 0))
        btnPath.addLine(to: .init(x: startX, y: layerHeight))
        btnPath.addLine(to: .init(x: startX + width1, y: layerHeight))
        btnPath.addLine(to: .init(x: skip + startX + width1, y: 0))
        btnPath.addLine(to: .init(x: skip + startX + width1 + width2, y: 0))
        btnPath.addLine(to: .init(x: startX + width1 + width2, y: layerHeight))
        btnPath.addLine(to: .init(x: startX + width1 + width2 + width3, y: layerHeight))
        btnPath.addLine(to: .init(x: skip + startX + width1 + width2 + width3, y: 0))
        btnPath.addLine(to: .init(x: skip + startX + width1 + width2, y: 0))
        btnShape.path = btnPath.cgPath
    }
}

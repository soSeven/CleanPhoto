//
//  TimePopView.swift
//  Clean
//
//  Created by liqi on 2020/11/5.
//

import SwiftEntryKit

class TimePopView: UIView {
    
    lazy var rightBtn: UIButton = {
        let b = MusicButton()
        let att: [NSAttributedString.Key:Any] = [
            .font: UIFont(style: .regular, size: 15.uiX),
            .foregroundColor: UIColor(hex: "#333333"),
        ]
        b.setAttributedTitle(.init(string: "完成", attributes: att), for: .normal)
        return b
    }()
    
    init(max: (Int, Int), min: (Int, Int), current: (Int, Int)) {
        super.init(frame: .zero)
        setupUI(max: max, min: min, current: current)
    }
    
    var completion: (((Int, Int)) -> ())?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    private func setupUI(max: (Int, Int), min: (Int, Int), current: (Int, Int)) {
        
        let topView = UIView()
        addSubview(topView)
        topView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(42.4.uiX)
        }
        
        topView.addSubview(rightBtn)
        rightBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-15.uiX)
        }
        
        let datePicker = DatePickerView()
        datePicker.backgroundColor = .init(hex: "#F5F5F5")
        datePicker.minYear = min.0
        datePicker.maxYear = max.0
        datePicker.selectCurrent(year: current.0, month: current.1)
        addSubview(datePicker)
        datePicker.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        rightBtn.rx.tap.subscribe(onNext: {[weak self] in
            guard let self = self else { return }
            SwiftEntryKit.dismiss()
            self.completion?(datePicker.currentDate)
        }).disposed(by: rx.disposeBag)
    }
    
    
    // MARK: - Show
    
    func show() {
        
        var attributes = EKAttributes.bottomFloat
        
        attributes.positionConstraints = .fullWidth
        attributes.positionConstraints.safeArea = .overridden
        attributes.screenBackground = .color(color: .init(.init(white: 0, alpha: 0.6)))
        attributes.entryBackground = .color(color: .init(.white))
        attributes.screenInteraction = .dismiss
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .disabled
        attributes.displayDuration = .infinity
        attributes.roundCorners = .all(radius: 0)
        
        attributes.entranceAnimation = .translation
        attributes.exitAnimation = .translation
        
        SwiftEntryKit.display(entry: self, using: attributes)
    }
    
}


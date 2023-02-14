//
//  PhotoManagerHeaderView.swift
//  Clean
//
//  Created by liqi on 2020/11/5.
//

import UIKit
import RxSwift
import RxCocoa

class PhotoManagerHeaderView: UIView {
    
    lazy var titleLbl: UILabel = {
        let lbl = UILabel()
        lbl.font = .init(style: .regular, size: 15.uiX)
        lbl.textColor = .init(hex: "#808080")
        lbl.text = "设置清理时间段并选择类别"
        return lbl
    }()
    
    lazy var startLbl: UILabel = {
        let lbl = UILabel()
        lbl.font = .init(style: .medium, size: 17.uiX)
        lbl.textColor = .init(hex: "#009CFF")
        lbl.text = "0000年00月"
        return lbl
    }()
    
    lazy var endLbl: UILabel = {
        let lbl = UILabel()
        lbl.font = .init(style: .medium, size: 17.uiX)
        lbl.textColor = .init(hex: "#009CFF")
        lbl.text = "0000年00月"
        return lbl
    }()
    
    private var minDate = (2000, 1)
    private var maxDate = (2020, 12)
    
    private var currentMinDate = (2000, 1)
    private var currentMaxDate = (2020, 12)
    
    let timeRelay = PublishRelay<(Date, Date)>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let v1 = getBgView()
        v1.addSubview(startLbl)
        startLbl.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        v1.snp.makeConstraints { make in
            make.width.equalTo(155.uiX)
            make.height.equalTo(49.uiX)
        }
        v1.rx.tap().subscribe(onNext: {[weak self] in
            guard let self = self else { return }
            self.showPicker(true)
        }).disposed(by: rx.disposeBag)
        
        let v2 = getBgView()
        v2.addSubview(endLbl)
        endLbl.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        v2.snp.makeConstraints { make in
            make.width.equalTo(155.uiX)
            make.height.equalTo(49.uiX)
        }
        v2.rx.tap().subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.showPicker(false)
        }).disposed(by: rx.disposeBag)
        
        let m = UIView()
        m.backgroundColor = .init(hex: "#4D4D4D")
        m.cornerRadius = 1.5.uiX
        m.snp.makeConstraints { make in
            make.width.equalTo(19.uiX)
            make.height.equalTo(3.uiX)
        }
        
        let stack = UIStackView(arrangedSubviews: [v1, m, v2], axis: .horizontal, spacing: 8.uiX, alignment: .center, distribution: .equalSpacing)
        
        addSubview(titleLbl)
        addSubview(stack)
        
        titleLbl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(25.uiX)
        }
        stack.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLbl.snp.bottom).offset(15.uiX)
        }
    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func getBgView() -> UIView {
        let v = UIView()
        v.backgroundColor = .white
        v.cornerRadius = 10.uiX
        return v
    }
    
    private func showPicker(_ isMin: Bool) {
        var current = self.currentMaxDate
        if isMin {
            current = self.currentMinDate
        }
        let pop = TimePopView(max: self.maxDate, min: self.minDate, current: current)
        pop.completion = { [weak self] result in
            guard let self = self else { return }
            var min = self.minDate
            var max = self.maxDate
            if result.0 > max.0 || result.0 < min.0 {
                return
            }
            if result.0 == max.0, result.1 > max.1 {
                return
            }
            if result.0 == min.0, result.1 < min.1 {
                return
            }
            
            if isMin {
                max = self.currentMaxDate
                if result.0 > max.0 {
                    return
                }
                if result.0 == max.0, result.1 > max.1 {
                    return
                }
                min = result
            } else {
                min = self.currentMinDate
                if result.0 < min.0 {
                    return
                }
                if result.0 == min.0, result.1 < min.1 {
                    return
                }
                max = result
            }
            self.setupCurrentDate(max: max, min: min)
            
            let formatter = DateFormatter()
            formatter.locale = .current
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            formatter.dateFormat = "yyyy:MM"
            
            let str1 = String(format: "%.4d:%.2d", max.0, max.1)
            let date1 = formatter.date(from: str1)!
            
            let str2 = String(format: "%.4d:%.2d", min.0, min.1)
            let date2 = formatter.date(from: str2)!
            
            self.timeRelay.accept((date2, date1))
        }
        pop.show()
    }
    
    func setupDate(max: (Int, Int), min: (Int, Int)) {

        maxDate = max
        minDate = min
        
        setupCurrentDate(max: max, min: min)
    }
    
    private func setupCurrentDate(max: (Int, Int), min: (Int, Int)) {

        currentMaxDate = max
        currentMinDate = min
        
        startLbl.text = String(format: "%.4d年%.2d月", min.0, min.1)
        endLbl.text = String(format: "%.4d年%.2d月", max.0, max.1)
    }
    
}

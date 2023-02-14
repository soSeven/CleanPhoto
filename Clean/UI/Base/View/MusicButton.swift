//
//  MusicButton.swift
//  CrazyMusic
//
//  Created by LiQi on 2020/8/22.
//  Copyright © 2020 LQ. All rights reserved.
//

import UIKit

class MusicButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        rx.tap.subscribe(onNext: { _ in
//            YBPlayAudio.click()
        }).disposed(by: rx.disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var bounds = self.bounds
        let deltaW = CGFloat.maximum(44 - bounds.width, 0)
        let deltaH = CGFloat.maximum(44 - bounds.height, 0)
        bounds = bounds.insetBy(dx: -deltaW * 0.5, dy: -deltaH * 0.5)
        return bounds.contains(point)
    }
    
}

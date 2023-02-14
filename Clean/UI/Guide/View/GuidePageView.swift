//
//  GuidePageView.swift
//  Dingweibao
//
//  Created by LiQi on 2020/6/9.
//  Copyright © 2020 Qire. All rights reserved.
//

import UIKit

class GuidePageView: UIView {
    
    let imgView = UIImageView()
    let btn = UIButton()
    
    init(image: UIImage) {
        super.init(frame: .zero)
        backgroundColor = .clear
        clipsToBounds = true
        
        imgView.contentMode = .scaleAspectFit
        imgView.image = image
        addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(UIDevice.statusBarHeight + 47.uiX)
            make.centerX.equalToSuperview()
            make.size.equalTo(image.snpSize)
        }
        
        let btnImg = UIImage.create("ljkq-an")
        btn.setBackgroundImage(btnImg, for: .normal)
        addSubview(btn)
        btn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(btnImg.snpSize)
            make.bottom.equalToSuperview().offset(-(UIDevice.safeAreaBottom + 37.uiX))
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isShowPushImgView = false
    
    func showPushImgView() {
        
//        if isShowPushImgView {
//            return
//        }
//        isShowPushImgView = true
//        pushImgView.isHidden = false
//        UIView.animate(withDuration: 0.25) {
//            self.pushImgView.transform = .identity
//        }
    }
    
    func hidePushImgView() {
        
//        if !isShowPushImgView {
//            return
//        }
//        isShowPushImgView = false
//        UIView.animate(withDuration: 0.25) {
//            let w: CGFloat = UIDevice.screenWidth - 40.uiX
//            let h: CGFloat = self.pushImgView.image!.snpScale * w
//            self.pushImgView.transform = .init(translationX: 0, y: -(UIDevice.statusBarHeight + 24.uiX + h))
//        }
    }
    
}

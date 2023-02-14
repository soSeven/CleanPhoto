//
//  GuideViewController.swift
//  Dingweibao
//
//  Created by LiQi on 2020/6/9.
//  Copyright © 2020 Qire. All rights reserved.
//

import UIKit
import SwiftEntryKit
import RxCocoa
import RxSwift

protocol GuideViewControllerDelegate: AnyObject {
    
    func guideClickDimiss(controller: GuideViewController)
    
}

class GuideViewController: ViewController {
    
    var delegate: GuideViewControllerDelegate?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bgImgView = UIImageView()
        bgImgView.image = .create("ydybj")
        view.addSubview(bgImgView)
        bgImgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let progressView = UIPageControl()
        progressView.numberOfPages = 3
        progressView.currentPageIndicatorTintColor = .init(hex: "#80FFFB")
        progressView.pageIndicatorTintColor = .init(hex: "#000000")
        view.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-(UIDevice.safeAreaBottom + 45.uiX))
        }
        
        let contentView = UIView()
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        let page1 = GuidePageView(image: .create("zdy-1"))
        page1.btn.isHidden = true
        contentView.addSubview(page1)
        page1.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(UIDevice.screenWidth)
        }
        
        let page2 = GuidePageView(image: .create("ydy-2"))
        page2.btn.isHidden = true
        contentView.addSubview(page2)
        page2.snp.makeConstraints { make in
            make.left.equalTo(page1.snp.right)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(UIDevice.screenWidth)
        }
        
        let page3 = GuidePageView(image: .create("ydy-3"))
        page3.btn.rx.tap.subscribe(onNext: {[weak self] _ in
            guard let self = self else { return }
            self.delegate?.guideClickDimiss(controller: self)
        }).disposed(by: rx.disposeBag)
        contentView.addSubview(page3)
        page3.snp.makeConstraints { make in
            make.left.equalTo(page2.snp.right)
            make.right.top.bottom.equalToSuperview()
            make.width.equalTo(UIDevice.screenWidth)
        }
        
        let merge = Observable.merge(scrollView.rx.didEndDecelerating.asObservable(), scrollView.rx.didEndScrollingAnimation.asObservable())
        merge.subscribe(onNext: { [weak scrollView] _ in
            guard let scrollView = scrollView else { return }
            let x = Int(scrollView.contentOffset.x / UIDevice.screenWidth)
            progressView.currentPage = x
            if x >= 2 {
                progressView.isHidden = true
            } else {
                progressView.isHidden = false
            }
        }).disposed(by: rx.disposeBag)
    }
    
    override func onceWhenViewDidAppear(_ animated: Bool) {
        
        
        
    }

}

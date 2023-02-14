//
//  ViewController.swift
//  WallPaper
//
//  Created by LiQi on 2020/4/13.
//  Copyright © 2020 Qire. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
//import MBProgressHUD

class ViewController: UIViewController {
    
    private var isFirst = true
    
    var emptyImageName: String?
    var emptyTitle: String?
    var emptyBtnTitle: String?
    var emptyBtnTap = PublishRelay<Void>()
    var isHideEmptyBtn = true
    var emptyView: EmptyView?

    var errorBtnTap = PublishRelay<Void>()
    var errorView: ErrorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11, *) {
            
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        hbd_barTintColor = .white
        hbd_barShadowHidden = true
        
        view.backgroundColor = .white

        hbd_titleTextAttributes = [
            NSAttributedString.Key.font: UIFont(style: .medium, size: 18),
            NSAttributedString.Key.foregroundColor : UIColor(hex: "#1A1A1A")
        ]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirst {
            onceWhenViewDidAppear(animated)
            isFirst = false
        }
    }
    
    func onceWhenViewDidAppear(_ animated: Bool) {
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}

extension Reactive where Base: ViewController {

    func showEmptyView(imageName: String = "search_img_default",
                       title: String = "呜呜，没有相关内容",
                       btnTitle: String? = nil,
                       btnTap: PublishRelay<Void>? = nil,
                       inset: UIEdgeInsets = .zero,
                       addBottom: Bool = false) -> Binder<Bool> {
        return Binder(self.base) { controller, show in
            if show {
                let emptyView = EmptyView()
                emptyView.imgView.image = UIImage(named: imageName)
                emptyView.label.text = title
                if let t = btnTitle, !t.isEmpty {
                    emptyView.btn.isHidden = false
                    emptyView.btn.setTitle(t, for: .normal)
                    if let tap = btnTap {
                        emptyView.btn.rx.tap.bind(to: tap).disposed(by: controller.rx.disposeBag)
                    }
                } else {
                    emptyView.btn.isHidden = true
                }
                if addBottom {
                    controller.view.insertSubview(emptyView, at: 0)
                } else {
                    controller.view.addSubview(emptyView)
                }
                emptyView.snp.makeConstraints { make in
                    make.edges.equalToSuperview().inset(inset)
                }
                controller.emptyView = emptyView
            } else {
                controller.emptyView?.removeFromSuperview()
            }
        }
    }

    func showErrorView(inset: UIEdgeInsets = .zero) -> Binder<Bool> {
        return Binder(self.base) { controller, show in
            if show {
                let errorView = ErrorView()
                errorView.btn.rx.tap.bind(to: controller.errorBtnTap).disposed(by: controller.rx.disposeBag)
                controller.view.addSubview(errorView)
                errorView.snp.makeConstraints { make in
                    make.edges.equalToSuperview().inset(inset)
                }
                controller.errorView = errorView
            } else {
                controller.errorView?.removeFromSuperview()
            }
        }
    }
}


//
//  NavigationController.swift
//  WallPaper
//
//  Created by LiQi on 2020/4/9.
//  Copyright © 2020 Qire. All rights reserved.
//

import UIKit
import HBDNavigationBar

class NavigationController: HBDNavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        if let pre = presentedViewController {
            return pre.preferredStatusBarStyle
        }
        if let top = topViewController {
            if let pre = top.presentedViewController {
                return pre.preferredStatusBarStyle
            }
            return top.preferredStatusBarStyle
        }
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        if let top = topViewController {
            return top.prefersStatusBarHidden
        }
        return false
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {

        let backBtn = UIButton()
        backBtn.addTarget(self, action: #selector(onClickBack), for: .touchUpInside)
        backBtn.setImage(UIImage(named: "fh-icon"), for: .normal)
        backBtn.frame = .init(x: 0, y: 0, width: 40, height: 40)
        backBtn.contentHorizontalAlignment = .left
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        if viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }

    @objc
    func onClickBack() {
        popViewController(animated: true)
    }
}



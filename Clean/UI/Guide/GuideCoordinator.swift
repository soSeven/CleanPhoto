//
//  GuideCoordinator.swift
//  Dingweibao
//
//  Created by LiQi on 2020/6/9.
//  Copyright © 2020 Qire. All rights reserved.
//

import Foundation
import Swinject
import RxSwift

protocol GuideCoordinatorDelegate: AnyObject {
    
    func guideCoordinatorDimiss(coordinator: GuideCoordinator)
    
}

class GuideCoordinator: Coordinator {
    
    var container: Container
    var window: UIWindow
    var navigationController: UINavigationController!
    
    weak var delegate: GuideCoordinatorDelegate?
    
    init(window: UIWindow, container: Container) {
        self.window = window
        self.container = container
    }
    
    func start() {
        let page1 = GuideViewController()
        page1.delegate = self
        window.rootViewController = page1
    }
    
}

extension GuideCoordinator: GuideViewControllerDelegate {
    
    func guideClickDimiss(controller: GuideViewController) {
        delegate?.guideCoordinatorDimiss(coordinator: self)
    }
    
}


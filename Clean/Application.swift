//
//  Application.swift
//  WallPaper
//
//  Created by LiQi on 2020/4/9.
//  Copyright © 2020 Qire. All rights reserved.
//

import UIKit
import Swinject
import RxCocoa
import RxSwift

enum ApplicationChildCoordinator {
    case home
    case guide
    case launch
}

final class Application: NSObject {
    
    static let shared = Application()
    internal let container = Container()
    private var childCoordinator = [ApplicationChildCoordinator:Coordinator]()
    var window: UIWindow!
    
    func configureDependencies() {
        
        container.register(HomeViewModel.self) { r in
            let v = HomeViewModel()
            return v
        }
        container.register(HomeViewController.self) { r in
            let c = HomeViewController()
            c.viewModel = r.resolve(HomeViewModel.self)!
            return c
        }
        
        container.register(CleanListViewController.self) { r in
            let c = CleanListViewController()
            return c
        }
        
        container.register(PhotoListViewController.self) { r in
            let c = PhotoListViewController()
            return c
        }
        
        container.register(PhotoPreviewViewController.self) { r in
            let c = PhotoPreviewViewController()
            return c
        }
        
        container.register(SecretSpaceViewController.self) { r in
            let c = SecretSpaceViewController()
            return c
        }
        
        container.register(SecretPhotoViewModel.self) { r in
            return SecretPhotoViewModel()
        }
        container.register(SecretPhotoViewController.self) { r in
            let c = SecretPhotoViewController()
            c.viewModel = r.resolve(SecretPhotoViewModel.self)!
            return c
        }
        
        container.register(PhotoAblumViewModel.self) { r in
            let v = PhotoAblumViewModel()
            return v
        }
        container.register(PhotoAlbumViewController.self) { r in
            let c = PhotoAlbumViewController()
            c.viewModel = r.resolve(PhotoAblumViewModel.self)!
            return c
        }
        
        container.register(DeletePhotosViewController.self) { r in
            let c = DeletePhotosViewController()
            c.viewModel = r.resolve(SecretPhotoViewModel.self)!
            return c
        }
        
        container.register(SettingViewModel.self) { r in
            let v = SettingViewModel()
            return v
        }
        container.register(SettingViewController.self) { r in
            let c = SettingViewController()
            c.viewModel = r.resolve(SettingViewModel.self)!
            return c
        }
        
        container.register(SettingPasswordViewController.self) { r in
            let c = SettingPasswordViewController()
            return c
        }
        
        container.register(PhotoMangerViewController.self) { r in
            let c = PhotoMangerViewController()
            return c
        }
        
        container.register(AddressAblumViewModel.self) { r in
            let v = AddressAblumViewModel()
            return v
        }
        container.register(AddressAlbumViewController.self) { r in
            let c = AddressAlbumViewController()
            c.viewModel = r.resolve(AddressAblumViewModel.self)!
            return c
        }
        
        container.register(SimilarDeleteViewController.self) { r in
            let c = SimilarDeleteViewController()
            return c
        }
        
        container.register(PayViewModel.self) { r in
            let v = PayViewModel()
            return v
        }
        container.register(PayViewController.self) { r in
            let c = PayViewController()
            c.viewModel = r.resolve(PayViewModel.self)!
            return c
        }
        
        container.register(LaunchViewController.self) { r in
            let c = LaunchViewController()
            return c
        }
        
        container.register(WebViewController.self) { r in
            let c = WebViewController()
            return c
        }
    }
    
    func configureMainInterface(in window: UIWindow) {
        
        self.window = window
        
        if !UserManager.shared.isLogin {
            showLaunch()
        } else {
            UserManager.shared.updateUser()
            showGuide()
        }
        
        UserManager.shared.login.subscribe(onNext: {[weak self] (u, s) in
            guard let self = self else { return }
            if s == .loginOut {
                self.showLaunch()
            }
        }).disposed(by: rx.disposeBag)
        
    }
    
    private func showLaunch() {
        let launch = container.resolve(LaunchViewController.self)!
        launch.completion = {[weak self] in
            guard let self = self else { return }
            self.showGuide()
        }
        window.rootViewController = launch
    }
    
    private func showGuide() {
        if let _ = UserDefaults.standard.object(forKey: "showGuide") {
            showHome()
            return
        }
        UserDefaults.standard.setValue("showGuide", forKey: "showGuide")
        let guideCoordinator = GuideCoordinator(window: window, container: container)
        guideCoordinator.start()
        guideCoordinator.delegate = self
        childCoordinator[.guide] = guideCoordinator
    }
    
    private func showHome() {
        let nav = NavigationController()
        let appCoordinator = HomeCoordinator(container: self.container, navigationController: nav)
        appCoordinator.start()
        window.rootViewController = nav
        childCoordinator[.home] = appCoordinator
    }
    
}

extension Application: GuideCoordinatorDelegate {
    
    func guideCoordinatorDimiss(coordinator: GuideCoordinator) {
        childCoordinator[.guide] = nil
        showHome()
    }
    
}

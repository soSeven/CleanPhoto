//
//  HomeCoordinator.swift
//  Chengyujielong
//
//  Created by yellow on 2020/9/8.
//  Copyright © 2020 Kaka. All rights reserved.
//

import Foundation
import Swinject

class HomeCoordinator: NavigationCoordinator {
    
    var navigationController: UINavigationController
    var container: Container
    
    init(container: Container, navigationController: UINavigationController) {
        self.container = container
        self.navigationController = navigationController
    }
    
    func start() {
        let home = container.resolve(HomeViewController.self)!
        home.delegate = self
        navigationController.pushViewController(home, animated: true)
    }
    
}

extension HomeCoordinator: HomeViewControllerDelegate {
    
    func homeDidClickVIP(controller: HomeViewController) {
        let vip = container.resolve(PayViewController.self)!
        vip.delegate = self
        let nav = NavigationController(rootViewController: vip)
        nav.modalPresentationStyle = .overCurrentContext
        navigationController.present(nav, animated: true, completion: nil)
    }
    
    func homeDidClickSetting(controller: HomeViewController) {
        let setting = container.resolve(SettingViewController.self)!
        setting.delegate = self
        navigationController.pushViewController(setting, animated: true)
    }
    
    func homeDidClickItem(controller: HomeViewController, item: HomeType) {
        switch item {
        case .secret:
            MobClick.event("photo_click")
            if UserConfigure.shared.isHasPassword {
                let p = PasswordPopView(needCancel: true)
                p.successAction = { [weak self] in
                    guard let self = self else { return }
                    let secret = self.container.resolve(SecretSpaceViewController.self)!
                    secret.delegate = self
                    self.navigationController.pushViewController(secret, animated: true)
                }
                p.show()
            } else {
                let secret = container.resolve(SecretSpaceViewController.self)!
                secret.delegate = self
                navigationController.pushViewController(secret, animated: true)
            }
        case .photos:
            MobClick.event("private_space_click")
            let photoManager = container.resolve(PhotoMangerViewController.self)!
            photoManager.delegate = self
            navigationController.pushViewController(photoManager, animated: true)
        default:
            break
        }
        
    }
    
    func homeDidClickClean(controller: HomeViewController) {
        let list = container.resolve(CleanListViewController.self)!
        list.delegate = self
        navigationController.pushViewController(list, animated: true)
    }
    
}

extension HomeCoordinator: PayViewControllerDelegate {
    
    func payShowProtocol(controller: PayViewController, type: NetHtmlAPI) {
        let web = container.resolve(WebViewController.self)!
        web.url = type.url
        controller.navigationController?.pushViewController(web)
    }
    
}

extension HomeCoordinator: PhotoMangerViewControllerDelegate {
    
    func photoManagerDidClickItem(controller: PhotoMangerViewController, item: Album) {
        switch item.type {
        case .addressPhoto:
            MobClick.event("photo_with_address")
            let address = container.resolve(AddressAlbumViewController.self)!
            address.delegate = self
            item.rangePhotos.bind(to: address.itemsRelay).disposed(by: address.rx.disposeBag)
            navigationController.pushViewController(address)
        case .similarPhoto, .similarVideo, .livePhoto, .similarMostPhoto:
            let delete = container.resolve(SimilarDeleteViewController.self)!
            if item.type == .similarMostPhoto {
                delete.mbDeleteAll = "delete_selection_similar_continuous"
                delete.mbStayTimeEvent = "continuous_shooting"
                MobClick.event("similar_continuous_shooting")
            } else if item.type == .similarVideo {
                delete.mbDeleteAll = "delete_selection_similar_video"
                delete.mbStayTimeEvent = "similar_video_stay"
                MobClick.event("similar_video_1")
            } else if item.type == .similarPhoto {
                delete.mbDeleteAll = "delete_selection_same_photo"
                delete.mbStayTimeEvent = "similar_pages_stay"
                MobClick.event("same_photo_1")
            }
            delete.delegate = self
            delete.navigationItem.title = item.type.title
            item.rangePhotosAlbum.bind(to: delete.itemsRelay).disposed(by: delete.rx.disposeBag)
            navigationController.pushViewController(delete)
        default:
            let delete = container.resolve(DeletePhotosViewController.self)!
            if item.type == .snapPhoto {
                delete.mbDeleteAll = "delete_selection_screenshots"
                delete.mbStayTimeEvent = "screen_capture_page_stay"
                MobClick.event("screenshots_1")
            } else if item.type == .badPhoto {
                delete.mbDeleteAll = "delete_selection_blurred"
                delete.mbStayTimeEvent = "blurred_page_stay"
                MobClick.event("blurred_photo")
            }
            delete.navigationItem.title = item.type.title
            delete.delegate = self
            item.rangePhotos.bind(to: delete.itemsRelay).disposed(by: delete.rx.disposeBag)
    //        delete.deleteRelay.bind(to: controller.deleteRelay).disposed(by: delete.rx.disposeBag)
            navigationController.pushViewController(delete)
        }
    }
    
}

extension HomeCoordinator: AddressAlbumViewControllerDelegate {
    
    func addressDidClickDelete(controller: AddressAlbumViewController, photos: [PhotoModel]) {
        let delete = container.resolve(DeletePhotosViewController.self)!
        delete.navigationItem.title = photos.first?.address
        delete.mbStayTimeEvent = "address_stay"
        delete.mbDeleteAll = "delete_selection_address"
        delete.delegate = self
        delete.itemsRelay.accept(photos)
//        .bind(to: delete.itemsRelay).disposed(by: delete.rx.disposeBag)
        navigationController.pushViewController(delete)
    }
    
}

extension HomeCoordinator: SimilarDeleteViewControllerDelegate {
    
    func similarDeleteDidClickItem(controller: SimilarDeleteViewController, photos: [PhotoModel], index: Int) {
        let preview = container.resolve(PhotoPreviewViewController.self)!
        preview.currentIndex = index
        preview.photosRelay.accept(photos)
        preview.deleteRelay.bind(to: controller.deleteRelay).disposed(by: preview.rx.disposeBag)
        navigationController.pushViewController(preview, animated: true)
    }
    
}

extension HomeCoordinator: SettingViewControllerDelegate {
    
    func settingDidUsePassword(controller: SettingViewController) {
        
        if UserConfigure.shared.isHasPassword {
            let p = PasswordPopView(needCancel: true)
            p.successAction = {
                UserConfigure.shared.password.accept(nil)
            }
            p.show()
        } else {
            let c = SettingPasswordViewController()
            navigationController.pushViewController(c)
        }
        
    }
    
    func settingDidChangePassword(controller: SettingViewController) {
        
        if UserConfigure.shared.isHasPassword {
            let p = PasswordPopView(needCancel: true)
            p.successAction = { [weak self] in
                guard let self = self else { return }
                let c = SettingPasswordViewController()
                self.navigationController.pushViewController(c)
            }
            p.show()
        } else {
            let c = SettingPasswordViewController()
            navigationController.pushViewController(c)
        }
    }
    
    func settingDidClickQuestion(controller: SettingViewController) {
        let web = container.resolve(WebViewController.self)!
        web.url = NetHtmlAPI.question.url
        navigationController.pushViewController(web)
    }
    
    func settingDidClickPrivacy(controller: SettingViewController) {
        let web = container.resolve(WebViewController.self)!
        web.url = NetHtmlAPI.privacy.url
        navigationController.pushViewController(web)
    }
    
    func settingDidClickUserProtocol(controller: SettingViewController) {
        let web = container.resolve(WebViewController.self)!
        web.url = NetHtmlAPI.userProtocol.url
        navigationController.pushViewController(web)
    }
    
}

extension HomeCoordinator: SecretSpaceViewControllerDelegate {
    
    func secretSpaceDidClickItem(controller: SecretSpaceViewController, item: SecretType) {
        let photo = container.resolve(SecretPhotoViewController.self)!
        photo.delegate = self
        navigationController.pushViewController(photo, animated: true)
    }
    
}

extension HomeCoordinator: SecretPhotoViewControllerDelegate {
    
    func secretPhotoDidClickDelete(controller: SecretPhotoViewController, photos: [PhotoModel]) {
        let delete = container.resolve(DeletePhotosViewController.self)!
        delete.navigationItem.title = "私密空间"
        delete.mbDeleteAll = "delete_selected"
        delete.mbEventSelectedAll = "select_all"
        delete.delegate = self
        delete.itemsRelay.accept(photos)
        delete.deleteRelay.bind(to: controller.deleteRelay).disposed(by: delete.rx.disposeBag)
        navigationController.pushViewController(delete)
    }
    
    func secretPhotoDidClickItem(controller: SecretPhotoViewController, photos: [PhotoModel], index: Int) {
        let preview = container.resolve(PhotoPreviewViewController.self)!
        preview.currentIndex = index
        preview.photosRelay.accept(photos)
        preview.deleteRelay.bind(to: controller.deleteRelay).disposed(by: preview.rx.disposeBag)
        navigationController.pushViewController(preview, animated: true)
    }
    
    func secretPhotoDidClickAblum(controller: SecretPhotoViewController) {
        let picker = container.resolve(PhotoAlbumViewController.self)!
        picker.selectedRelay.bind(to: controller.addItemsRelay).disposed(by: picker.rx.disposeBag)
        let nav = NavigationController(rootViewController: picker)
        nav.modalPresentationStyle = .overCurrentContext
        navigationController.present(nav, animated: true, completion: nil)
    }
    
}

extension HomeCoordinator: DeletePhotosViewControllerDelegate {
    
    func secretPhotoDidClickItem(controller: DeletePhotosViewController, photos: [PhotoModel], index: Int) {
        let preview = container.resolve(PhotoPreviewViewController.self)!
        preview.currentIndex = index
        preview.photosRelay.accept(photos)
        preview.deleteRelay.bind(to: controller.deleteRelay).disposed(by: preview.rx.disposeBag)
        navigationController.pushViewController(preview, animated: true)
    }
    
}

extension HomeCoordinator: CleanListViewControllerDelegate {
    
    func cleanListDidClickItem(controller: CleanListViewController, item: Album) {
        switch item.type {
        case .addressPhoto:
            let address = container.resolve(AddressAlbumViewController.self)!
            address.delegate = self
            item.rangePhotos.bind(to: address.itemsRelay).disposed(by: address.rx.disposeBag)
            navigationController.pushViewController(address)
        case .similarPhoto, .similarVideo, .livePhoto, .similarMostPhoto:
            if item.type == .similarPhoto {
                MobClick.event("similar_photos")
            } else if item.type == .similarVideo {
                MobClick.event("similar_video")
            } else if item.type == .livePhoto {
                MobClick.event("similar_dynamic_photos")
            }
            let delete = container.resolve(SimilarDeleteViewController.self)!
            delete.delegate = self
            delete.navigationItem.title = item.type.title
            item.rangePhotosAlbum.bind(to: delete.itemsRelay).disposed(by: delete.rx.disposeBag)
            navigationController.pushViewController(delete)
        default:
            if item.type == .snapPhoto {
                MobClick.event("screenshots")
            }
            let delete = container.resolve(DeletePhotosViewController.self)!
            delete.navigationItem.title = item.type.title
            delete.delegate = self
            item.rangePhotos.bind(to: delete.itemsRelay).disposed(by: delete.rx.disposeBag)
    //        delete.deleteRelay.bind(to: controller.deleteRelay).disposed(by: delete.rx.disposeBag)
            navigationController.pushViewController(delete)
        }
    }
    
}

extension HomeCoordinator: PhotoListViewControllerDelegate {
    
    func photoListDidClickItem(controller: PhotoListViewController) {
        let preview = container.resolve(PhotoPreviewViewController.self)!
        navigationController.pushViewController(preview, animated: true)
    }
    
}



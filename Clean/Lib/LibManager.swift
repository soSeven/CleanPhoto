//
//  LibManager.swift
//  CrazyMusic
//
//  Created by LiQi on 2020/8/11.
//  Copyright © 2020 LQ. All rights reserved.
//

import Foundation
import BUAdSDK
import AppTrackingTransparency
import Hue
import RxCocoa
import RxSwift
import SwifterSwift
import NSObject_Rx

class LibManager: NSObject {
    
    static let shared = LibManager()
    
    var deviceToken = ""
    private var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    
    func register(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
//        setupBUAdSDK()
//        setupGDAdSDK()
        self.launchOptions = launchOptions
        UserManager.shared.login.subscribe(onNext: {[weak self] (u, s) in
            guard let self = self else { return }
            guard let u = u else { return }
            if s != .login {
                return
            }
            self.setupUMSDK(channel: u.channel)
        }).disposed(by: rx.disposeBag)
    }
    
//    private func setupBUAdSDK() {
//        BUAdSDKManager.setAppID("5109137")
//        if AppDefine.isDebug {
//            BUAdSDKManager.setLoglevel(.debug)
//        }
//
//        if #available(iOS 14, *) {
//            ATTrackingManager.requestTrackingAuthorization { status in
//                print(status)
//            }
//        }
//
//        /// 预加载广告视频
//        _ = RewardVideoSingleAd.shared
//    }
//
//    private func setupGDAdSDK() {
//        GDTSDKConfig.registerAppId("1110965636")
//        GDTSDKConfig.setChannel(14)
//    }
//
    private func setupUMSDK(channel: String) {
        let umAppkey = "5faf3a09aef73e17b3a57973"
//        let wechatAppkey = "wx17c2e0b58cb23307"
//        let wechatAppSecret = "84570326699ee53f40d54af98ec42c01"

        UMCommonLogManager.setUp()
        if AppDefine.isDebug {
            UMConfigure.setLogEnabled(true)
        }
        UMConfigure.initWithAppkey(umAppkey, channel: channel)
        if AppDefine.isNeedCrashDebug {
            MobClick.setCrashReportEnabled(true)
        }
//        UMSocialGlobal.shareInstance()?.universalLinkDic = [
//            1 : "https://api.ynxxhy.com/"
//        ]
//        UMSocialManager.default()?.setPlaform(.wechatSession, appKey: wechatAppkey, appSecret: wechatAppSecret, redirectURL: "")

//        let entity = UMessageRegisterEntity()
//        entity.types = Int(UMessageAuthorizationOptions.badge.rawValue|UMessageAuthorizationOptions.sound.rawValue|UMessageAuthorizationOptions.alert.rawValue)
//        UNUserNotificationCenter.current().delegate = self
//        UMessage.setBadgeClear(true)
//        UMessage.registerForRemoteNotifications(launchOptions: launchOptions, entity: entity) { (granted, error) in
//            if granted {
//                print("注册通知成功")
//            } else {
//                print("注册通知失败: %@", error as Any)
//            }
//        }
    }

}

//extension LibManager: UNUserNotificationCenterDelegate {
//
//    //iOS10新增：处理前台收到通知的代理方法
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        let userInfo = notification.request.content.userInfo
//        if (notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self))! {
//            let info = userInfo as NSDictionary
//            print(info)
//            //应用处于前台时的远程推送接受
//            UMessage.setAutoAlert(false)
//            UMessage.didReceiveRemoteNotification(userInfo)
//        }else {
//            //应用处于前台时的远程推送接受
//        }
//        completionHandler(.sound)
//    }
//
//    //iOS10新增：处理后台点击通知的代理方法
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        let userInfo = response.notification.request.content.userInfo
//        if (response.notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self))! {
////            let info = userInfo as NSDictionary
////            print(info)
//            //应用处于后台时的远程推送接受
//            UMessage.didReceiveRemoteNotification(userInfo)
//        }else{
//            //应用处于前台时的远程推送接受
//        }
//        completionHandler()
//    }
//
//}

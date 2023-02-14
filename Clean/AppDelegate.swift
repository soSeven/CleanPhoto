//
//  AppDelegate.swift
//  Clean
//
//  Created by liqi on 2020/10/26.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Application.shared.configureDependencies()
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        LibManager.shared.register(launchOptions: launchOptions)
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = .white
        self.window = window
        Application.shared.configureMainInterface(in: window)

        self.window?.makeKeyAndVisible()
        
        let payManager = PayManager.shared
        payManager.completeTransactionsWhenAppStart()
        
        return true
    }



}


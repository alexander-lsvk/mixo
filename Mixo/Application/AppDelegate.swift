//
//  AppDelegate.swift
//  Mixo
//
//  Created by Alexander Lisovik on 5/19/19.
//  Copyright © 2019 Alexander Lisovik. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import SwiftRater

@UIApplicationMain
final class AppDelegate: UIResponder {
    var window: UIWindow?

    private var mainTabPresenter: MainTabPresenter?
}

extension AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        SwiftRater.usesUntilPrompt = 0
        SwiftRater.daysBeforeReminding = 1
        SwiftRater.showLaterButton = true
        SwiftRater.appLaunched()

        let mainTabPresenter = MainTabPresenter()
        self.mainTabPresenter = mainTabPresenter

        FirebaseApp.configure()

        window = UIWindow(frame: UIScreen.main.bounds)
        window!.rootViewController = MainTabViewController(presenter: mainTabPresenter)
        window!.makeKeyAndVisible()

        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)

        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        SearchPresenter.spotifyLoginPresenter.open(app, open: url, options: options)
        ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        return true
    }
}


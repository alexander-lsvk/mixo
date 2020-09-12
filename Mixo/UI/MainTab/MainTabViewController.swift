//
//  TabBarViewController.swift
//  Mixo
//
//  Created by Alexander Lisovik on 12.09.2020.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import UIKit
import SwiftMessages

final class MainTabViewController: BaseViewController<MainTabPresenter> {
    var selectedViewController: UIViewController? {
        return tabController.selectedViewController
    }

    private let tabController = UITabBarController()

    override var tabBarController: UITabBarController? {
        return tabController
    }

    override func viewDidLoad() {
        presenter.mainTabViewHandler = MainTabViewHandler(setupTabs: { [weak self] mainTab in
            guard let self = self else {
                return
            }
            self.tabController.viewControllers = mainTab.map { self.prepareTabController($0.controller, title: $0.title, icon: $0.icon) }
            self.tabController.tabBar.barTintColor = .white
            self.tabController.tabBar.isTranslucent = false

        }, presentSpotifyLoginViewController: { [weak self] presenter in
            let spotifyLoginViewController = SpotifyLoginViewController(presenter: presenter)
            let swiftMessagesSegue = SwiftMessagesSegue(identifier: nil, source: self!, destination: spotifyLoginViewController)
            swiftMessagesSegue.interactiveHide = false
            swiftMessagesSegue.configure(layout: .centered)
            swiftMessagesSegue.messageView.layoutMarginAdditions = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
            swiftMessagesSegue.dimMode = .blur(style: .light, alpha: 1.0, interactive: false)
            swiftMessagesSegue.perform()
        })

        addChildController(tabController, in: view)

        super.viewDidLoad()

        tabController.tabBar.tintColor = UIColor(red: 35.0/255.0, green: 37.0/255.0, blue: 90.0/255.0, alpha: 1.0)
    }
}

extension MainTabViewController {
    private func prepareTabController(_ controller: UIViewController, title: String, icon: UIImage) -> UIViewController {
        let tabItem = UITabBarItem(title: title, image: icon, selectedImage: icon)
        controller.tabBarItem = tabItem

        let navigationController = UINavigationController(rootViewController: controller)
        return navigationController
    }
}

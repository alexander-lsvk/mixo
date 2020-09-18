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

    private var playerViewContainer = UIView()

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
            self?.addChildController(spotifyLoginViewController, in: self!.view)

        }, showPlayerViewController: { [weak self] presenter in
            let playerViewController = PlayerViewController(presenter: presenter)
            self?.addChildController(playerViewController, in: self!.playerViewContainer)
        })

        addChildController(tabController, in: view)

        super.viewDidLoad()

        tabController.tabBar.tintColor = UIColor(red: 35.0/255.0, green: 37.0/255.0, blue: 90.0/255.0, alpha: 1.0)

        view.addSubview(playerViewContainer)
        playerViewContainer.isUserInteractionEnabled = true
        playerViewContainer.backgroundColor = .clear
        playerViewContainer.addConstraints([equal(\.heightAnchor, to: 60.0),
                                            equal(tabBarController!.tabBar, to: \.leadingAnchor, constant: 0.0),
                                            equal(tabBarController!.tabBar, to: \.trailingAnchor, constant: 0.0),
                                            equal(tabBarController!.tabBar, to: \.topAnchor, constant: -60.0)])
        view.bringSubviewToFront(playerViewContainer)
        view.insertSubview(playerViewContainer, aboveSubview: tabController.tabBar)
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

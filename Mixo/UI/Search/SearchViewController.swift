//
//  ViewController.swift
//  Mixo
//
//  Created by Alexander Lisovik on 5/19/19.
//  Copyright © 2019 Alexander Lisovik. All rights reserved.
//

import UIKit
import Kingfisher
import SwiftMessages

class SearchViewController: BaseViewController<SearchPresenter> {
    private let searchView = SearchView.loadViewFromXib()

    private var mixesItem: UIBarButtonItem?

    override func loadView() {
        view = searchView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    override func viewDidLoad() {
        presenter.searchViewHandler = SearchViewHandler(setSearchBarHandler: { [weak self] handler in
            self?.searchView.setSearchBarHandler(handler)
            
        }, setViewModels: { [weak self] viewModels in
            self?.searchView.update(with: viewModels)

        }, presentRecommendationsViewController: { [weak self] recommendationsPresenter in
            let recommendationsViewController = RecommendationsViewController(presenter: recommendationsPresenter)
            recommendationsViewController.navigationItem.rightBarButtonItem = self?.mixesItem

            self?.navigationController?.pushViewController(recommendationsViewController, animated: true)

        }, presentMixesViewController: { [weak self] mixesPresenter in
            let mixesViewController = MixesViewController(presenter: mixesPresenter)
            let navigationController = UINavigationController(rootViewController: mixesViewController)

            self?.present(navigationController, animated: true)

        }, presentSpotifyLoginViewController: { [weak self] presenter in
            let spotifyLoginViewController = SpotifyLoginViewController(presenter: presenter)
            let swiftMessagesSegue = SwiftMessagesSegue(identifier: nil, source: self!, destination: spotifyLoginViewController)
            swiftMessagesSegue.interactiveHide = false
            swiftMessagesSegue.configure(layout: .centered)
            swiftMessagesSegue.messageView.layoutMarginAdditions = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
            swiftMessagesSegue.dimMode = .blur(style: .light, alpha: 1.0, interactive: false)
            swiftMessagesSegue.perform()

        }, becomeFirstResponder: { [weak self] in
            self?.searchView.becomeSearchFirstResponder()
        })

        super.viewDidLoad()
    }
}

// MARK: - Private methods
extension SearchViewController {
    private func setupNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true

        mixesItem = UIBarButtonItem(title:"🎛️", style: .plain, target: self, action: #selector(presentMixes))
        navigationItem.rightBarButtonItem = mixesItem

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    @objc
    private func presentMixes() {
        presenter.prepareMixesPresenter()
    }
}

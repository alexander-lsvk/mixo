//
//  RecommendationsViewController.swift
//  Mixo
//
//  Created by Alexander Lisovik on 5/28/19.
//  Copyright © 2019 Alexander Lisovik. All rights reserved.
//

import UIKit
import SwiftMessages
import StatusAlert

final class RecommendationsViewController: BaseViewController<RecommendationsPresenter> {
    private let recommendationsView = RecommendationsView.loadViewFromXib()
    
    override func loadView() {
        view = recommendationsView
    }

    override func viewDidLoad() {
        presenter.recommendationsViewHandler = RecommendationsViewHandler(showBackToSearchButton: { [weak self] show in
            self?.recommendationsView.showBackToSearchButton(show)

        }, setCurrentTrackViewModel: { [weak self] viewModel in
            self?.recommendationsView.setCurrentTrackViewModel(with: viewModel)
            
        }, setSortViewModel: { [weak self] viewModel in
            self?.recommendationsView.setSortViewModel(viewModel)

        }, setViewModels: { [weak self] viewModels, animated in
            self?.recommendationsView.setTableHeaderView()
            self?.recommendationsView.setRecommendationViewModels(viewModels, animated: animated)

        }, showMixesViewController: { [weak self] presenter in
            let mixesViewController = MixesViewController(presenter: presenter)
            let swiftMessagesSegue = SwiftMessagesSegue(identifier: nil, source: self!, destination: mixesViewController)
            swiftMessagesSegue.configure(layout: .bottomCard)
            swiftMessagesSegue.perform()

        }, presentRecommendationsViewController: { [weak self] presenter in
            let recommendationsViewController = RecommendationsViewController(presenter: presenter)
            recommendationsViewController.navigationItem.rightBarButtonItem = self?.navigationItem.rightBarButtonItem
            self?.navigationController?.pushViewController(recommendationsViewController, animated: true)

        }, popToRootViewController: { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)

        }, showAddedToMix: {
            let statusAlert = StatusAlert()
            if #available(iOS 13.0, *) {
                statusAlert.image = UIImage(systemName: "checkmark")
            }
            statusAlert.title = "Added to the mix"
            statusAlert.appearance.blurStyle = .extraLight
            statusAlert.alertShowingDuration = 1
            statusAlert.canBePickedOrDismissed = true

            statusAlert.showInKeyWindow()
        })

        super.viewDidLoad()

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        
        navigationController?.navigationBar.tintColor = .white

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        recommendationsView.viewDidLayoutSubviews()
    }
}

// MARK: - Private methods
extension RecommendationsViewController {
    @objc
    private func dismissMixesViewController() {
        self.dismiss(animated: true)
    }
}

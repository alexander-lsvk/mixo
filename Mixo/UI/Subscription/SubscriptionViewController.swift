//
//  SubscriptionViewController.swift
//  Mixo
//
//  Created by Alexander Lisovik on 9/5/19.
//  Copyright © 2019 Alexander Lisovik. All rights reserved.
//

import Foundation

final class SubscriptionViewController: BaseViewController<SubscriptionPresenter> {
    private let subscriptionView = SubscriptionView()

    override func loadView() {
        view = subscriptionView
    }

    override func viewDidLoad() {
        presenter.subscriptionViewHandler = SubscriptionViewHandler(setViewModel: { [weak self] viewModel in
            self?.subscriptionView.update(with: viewModel)

        }, dismiss: { [weak self] in
            self?.dismiss(animated: true)
        })

        super.viewDidLoad()
    }

   
}

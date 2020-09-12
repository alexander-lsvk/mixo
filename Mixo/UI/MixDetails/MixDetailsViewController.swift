//
//  MixDetailsViewController.swift
//  Mixo
//
//  Created by Alexander Lisovik on 1/13/20.
//  Copyright (c) 2020 Alexander Lisovik. All rights reserved.
//

import UIKit

final class MixDetailsViewController: BaseViewController<MixDetailsPresenter> {
    private let mixDetailsView = MixDetailsView.loadViewFromXib()

    override func loadView() {
        view = mixDetailsView
    }
    
    override func viewDidLoad() {
        presenter.mixDetailsViewHandler = MixDetailsViewHandler(setViewModels: { [weak self] viewModels in
            self?.mixDetailsView.update(with: viewModels)

        }, setReorderListHandler: { [weak self] reorderListHandler in
            self?.mixDetailsView.setReorderListHandler(reorderListHandler)

        }, presentRecommendationsViewController: { [weak self] presenter in
            let recommendationsViewController = RecommendationsViewController(presenter: presenter)
            self?.navigationController?.pushViewController(recommendationsViewController, animated: true)
        })

        super.viewDidLoad()

        setupNavigationBarItem()
    }
}

extension MixDetailsViewController {
    private func setupNavigationBarItem() {
        let dismissButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(dismissMixesViewController))

        navigationItem.rightBarButtonItem = dismissButton

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    @objc
    private func dismissMixesViewController() {
        self.dismiss(animated: true)
    }
}

//
//  MixesViewController.swift
//  Mixo
//
//  Created by Alexander Lisovik on 1/11/20.
//  Copyright (c) 2020 Alexander Lisovik. All rights reserved.
//

import UIKit
import RLBAlertsPickers
import SwiftMessages

final class MixesViewController: BaseViewController<MixesPresenter> {
    private var mixesView = MixesView.loadViewFromXib()

    override func loadView() {
        view = mixesView
    }
    
    override func viewDidLoad() {
        presenter.mixesViewHandler = MixesViewHandler(setViewModel: { [weak self] viewModel in
            self?.mixesView.update(with: viewModel)

        }, showAddToNewMixButton: { [weak self] in
            self?.mixesView.showAddToNewMixButton()

        }, presentMixDetails: { [weak self] presenter in
            let mixDetailsViewController = MixDetailsViewController(presenter: presenter)
            self?.navigationController?.pushViewController(mixDetailsViewController, animated: true)

        }, presentEditMixInfo: { [weak self] presenter in
            let editMixInfoViewController = EditMixInfoViewController(presenter: presenter)
            let swiftMessagesSegue = SwiftMessagesSegue(identifier: nil, source: self!, destination: editMixInfoViewController)
            swiftMessagesSegue.configure(layout: .centered)
            swiftMessagesSegue.perform()

        }, dismiss: { [weak self] in
            self?.dismiss(animated: true)
        })

        super.viewDidLoad()

        setupNavigationBarItem()
    }
}

extension MixesViewController {
    private func setupNavigationBarItem() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        let addMixButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddMixButtonTap))
        addMixButton.tintColor = .white

        let dismissButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(dismissMixesViewController))

        navigationItem.rightBarButtonItem = addMixButton
        navigationItem.leftBarButtonItem = dismissButton

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    @objc
    private func handleAddMixButtonTap() {
        presenter.addNewMix()
    }

    @objc
    private func dismissMixesViewController() {
        self.dismiss(animated: true)
    }
}



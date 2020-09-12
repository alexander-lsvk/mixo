//
//  EditMixInfoViewController.swift
//  Mixo
//
//  Created by Alexander on 15.04.2020.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import Foundation

final class EditMixInfoViewController: BaseViewController<EditMixInfoPresenter> {
    private var editMixInfoView = EditMixInfoView.loadViewFromXib()

    override func loadView() {
        view = editMixInfoView
    }

    override func viewDidLoad() {
        presenter.editMixInfoViewHandler = EditMixInfoViewHandler(setViewModel: { [weak self] viewModel in
            self?.editMixInfoView.update(with: viewModel)

        }, dismiss: { [weak self] in
            self?.dismiss(animated: true)
        })

        super.viewDidLoad()
    }
}

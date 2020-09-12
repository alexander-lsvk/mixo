//
//  EditMixInfoView.swift
//  Mixo
//
//  Created by Alexander on 15.04.2020.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import Foundation

final class EditMixInfoView: UIView, XibLoadable {
    @IBOutlet private var nameTextField: UITextField!
    @IBAction private func didTapSaveButton() { didTapSaveButtonHandler?(nameTextField.text ?? "") }

    var didTapSaveButtonHandler: ((_ name: String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        nameTextField.becomeFirstResponder()
    }

    func update(with viewModel: EditMixInfoViewModel) {
        nameTextField.text = viewModel.oldName
        didTapSaveButtonHandler = viewModel.didTapSaveButtonHandler
    }
}

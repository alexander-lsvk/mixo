//
//  EditMixInfoPresenter.swift
//  Mixo
//
//  Created by Alexander on 15.04.2020.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import Foundation

struct EditMixInfoViewHandler {
    let setViewModel: (_ viewModel: EditMixInfoViewModel) -> Void
    let dismiss: () -> Void
}

struct EditMixInfoPresenter: Presenter {
    var baseViewHandler: BaseViewHandler?
    var editMixInfoViewHandler: EditMixInfoViewHandler?

    let oldName: String
    let updateMixNameHandler: (_ name: String) -> Void

    init(oldName: String, updateMixNameHandler: @escaping (_ name: String) -> Void) {
        self.oldName = oldName
        self.updateMixNameHandler = updateMixNameHandler
    }

    func didBindController() {
        editMixInfoViewHandler?.setViewModel(EditMixInfoViewModel(oldName: oldName, didTapSaveButtonHandler: { name in
            self.updateMixNameHandler(name)
            self.editMixInfoViewHandler?.dismiss()
        }))
    }
}

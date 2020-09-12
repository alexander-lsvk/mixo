//
//  EditMixInfoViewModel.swift
//  Mixo
//
//  Created by Alexander on 15.04.2020.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import Foundation

struct EditMixInfoViewModel {
    let oldName: String
    let didTapSaveButtonHandler: (_ name: String) -> Void
}

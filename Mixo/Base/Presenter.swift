//
//  Presenter.swift
//  Mixo
//
//  Created by Alexander Lisovik on 5/22/19.
//  Copyright © 2019 Alexander Lisovik. All rights reserved.
//

import Foundation

struct BaseViewHandler {
    let setTitle: (String) -> Void
    let showStatus: (_ status: Status, _ animated: Bool) -> Void
    let hideStatus: (_ animated: Bool) -> Void
    let showMessage: (_ message: Message, _ body: String) -> Void

    init(setTitle: @escaping (String) -> Void,
         showStatus: @escaping (_ status: Status, _ animated: Bool) -> Void,
         hideStatus: @escaping (_ animated: Bool) -> Void,
         showMessage: @escaping (_ message: Message, _ body: String) -> Void) {
        self.setTitle = setTitle
        self.showStatus = showStatus
        self.hideStatus = hideStatus
        self.showMessage = showMessage
    }
}

protocol Presenter {
    var baseViewHandler: BaseViewHandler? { get set }
    func didBindController()
    func viewWillAppear()
    func viewWillDisappear()
}

extension Presenter {
    func viewWillAppear() {}
    func viewWillDisappear() {}
}

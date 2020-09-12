//
//  MixViewModel.swift
//  Mixo
//
//  Created by Alexander Lisovik on 1/11/20.
//  Copyright (c) 2020 Alexander Lisovik. All rights reserved.
//

import Foundation

struct MixesViewModel {
    let mixViewModels: [MixViewModel]?
    let addToNewMixHandler: (() -> Void)
    let editMixNameHandler: ((_ mixId: String, _ oldName: String) -> Void)
}

final class MixViewModel {
    let id: String
    var name: String
    let numberOfTracks: Int
    let imageUrl: URL?

    var didUpdateMixName: ((_ newName: String) -> Void)?

    var didSelectHandler: (() -> Void)?
    let didRemoveItemHandler: (_ mixesCount: Int) -> Void
    let didEditItemHandler: (_ name: String) -> Void

    init(id: String,
         name: String,
         numberOfTracks: Int,
         imageUrl: URL?,
         didRemoveItemHandler: @escaping (_ mixesCount: Int) -> Void,
         didEditItemHandler: @escaping (String) -> Void,
         didSelectHandler: (() -> Void)? = nil) {
        self.id = id
        self.name = name
        self.numberOfTracks = numberOfTracks
        self.imageUrl = imageUrl
        self.didRemoveItemHandler = didRemoveItemHandler
        self.didEditItemHandler = didEditItemHandler
        self.didSelectHandler = didSelectHandler
    }
}


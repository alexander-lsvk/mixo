//
//  PlayerViewModel.swift
//  Mixo
//
//  Created by Alexander Lisovik on 13.09.2020.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import Foundation

struct PlayerViewModel {
    let artist: String
    let name: String
    let imageUrl: URL?

    let didTapPlayButtonHandler: () -> Void
}

//
//  MixesDisplayMode.swift
//  Mixo
//
//  Created by Alexander on 05.04.2020.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import Foundation

enum MixesDisplayMode {
    case add(track: MixTrack, completionHandler: () -> Void)
    case `default`
}

extension MixesDisplayMode: Equatable {
    static func == (lhs: MixesDisplayMode, rhs: MixesDisplayMode) -> Bool {
        switch (lhs, rhs) {
        case (.add, .add):          return true
        case (.default, .default):  return false
        default:                    return false
        }
    }
}

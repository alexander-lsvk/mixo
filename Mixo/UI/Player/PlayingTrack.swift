//
//  PlayingTrack.swift
//  Mixo
//
//  Created by Alexander Lisovik on 15.09.2020.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import Foundation

struct PlayingTrack {
    var id: String?
    var status: PlayingStatus

    enum PlayingStatus: Int, CaseIterable {
        case playing
        case stopped

        mutating func next() {
            let allCases = type(of: self).allCases
            self = allCases[(allCases.firstIndex(of: self)! + 1) % allCases.count]
        }
    }
}

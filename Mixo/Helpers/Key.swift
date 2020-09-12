//
//  Key.swift
//  Mixo
//
//  Created by Alexander Lisovik on 6/9/19.
//  Copyright © 2019 Alexander Lisovik. All rights reserved.
//

import Foundation

struct Key {
    let chord: Chord?
    let mode: Mode?

    init(rawChord: Int, rawMode: Int) {
        chord = Chord(rawValue: rawChord)
        mode = Mode(rawValue: rawMode)
    }

    init(chord: Chord?, mode: Mode?) {
        self.chord = chord
        self.mode = mode
    }
}

// MARK: - Equtable
extension Key: Equatable {
    static func ==(lhs: Key, rhs: Key) -> Bool {
        return lhs.chord == rhs.chord && lhs.mode == rhs.mode
    }
}

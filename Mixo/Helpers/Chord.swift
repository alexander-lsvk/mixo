//
//  Key.swift
//  Mixo
//
//  Created by Alexander Lisovik on 5/28/19.
//  Copyright © 2019 Alexander Lisovik. All rights reserved.
//

import Foundation

enum Chord: Int {
    case C
    case Cs
    case D
    case Ds
    case E
    case F
    case Fs
    case G
    case Gs
    case A
    case As
    case B
}

extension Chord {
    var description: String {
        switch self {
        case .C:
            return "C"
        case .Cs:
            return "C#"
        case .D:
            return "D"
        case .Ds:
            return "D#"
        case .E:
            return "E"
        case .F:
            return "F"
        case .Fs:
            return "F#"
        case .G:
            return "G"
        case .Gs:
            return "G#"
        case .A:
            return "A"
        case .As:
            return "A#"
        case .B:
            return "B"
        }
    }
}

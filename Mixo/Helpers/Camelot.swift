//
//  Camelot.swift
//  Mixo
//
//  Created by Alexander Lisovik on 6/9/19.
//  Copyright © 2019 Alexander Lisovik. All rights reserved.
//

import Foundation

enum Camelot: CaseIterable {
    case a1
    case b1
    case a2
    case b2
    case a3
    case b3
    case a4
    case b4
    case a5
    case b5
    case a6
    case b6
    case a7
    case b7
    case a8
    case b8
    case a9
    case b9
    case a10
    case b10
    case a11
    case b11
    case a12
    case b12
    
    static func index(of camelot: Camelot) -> Int {
        return Camelot.allCases.firstIndex(of: camelot)!
    }
    
    static func leftElement(at index: Int) -> Camelot {
        if index == 0 {
            return Camelot.allCases[Camelot.allCases.count - 2]
        } else if index == 1 {
            return Camelot.allCases[Camelot.allCases.count - 1]
        } else {
            return Camelot.allCases[index - 2]
        }
    }
    
    static func rightElement(at index: Int) -> Camelot {
        if index == Camelot.allCases.count - 2 {
            return Camelot.allCases[0]
        } else if index == Camelot.allCases.count - 1 {
            return Camelot.allCases[1]
        } else {
            return Camelot.allCases[index + 2]
        }
    }
}

extension Camelot {
    init(key: String) {
        switch key {
        case "Gsm": self = .a1
        case "B": self = .b1
        case "Dsm": self = .a2
        case "Fs": self = .b2
        case "Asm": self = .a3
        case "Cs": self = .b3
        case "Fm": self = .a4
        case "Gs": self = .b4
        case "Cm": self = .a5
        case "Ds": self = .b5
        case "Gm": self = .a6
        case "As": self = .b6
        case "Dm": self = .a7
        case "F": self = .b7
        case "Am": self = .a8
        case "C": self = .b8
        case "Em": self = .a9
        case "G": self = .b9
        case "Bm": self = .a10
        case "D": self = .b10
        case "Fsm": self = .a11
        case "A": self = .b11
        case "Csm": self = .a12
        case "E": self = .b12
        
        default:
            self = .a1
        }
    }
    
    var harmonicKeys: [Key] {
        let modeChangeIndex = (self.key.mode == .major ? (Camelot.index(of: self) - 1) : (Camelot.index(of: self) + 1))
        return [self.key,
                Camelot.leftElement(at: Camelot.index(of: self)).key,
                Camelot.rightElement(at: Camelot.index(of: self)).key,
                Camelot.allCases[modeChangeIndex].key]
    }

    var key: Key {
        switch self {
        case .a1:   return   Key(chord: .Gs, mode: .minor)
        case .b1:   return   Key(chord: .B, mode: .major)
        case .a2:   return   Key(chord: .Ds, mode: .minor)
        case .b2:   return   Key(chord: .Fs, mode: .major)
        case .a3:   return   Key(chord: .As, mode: .minor)
        case .b3:   return   Key(chord: .Cs, mode: .major)
        case .a4:   return   Key(chord: .F, mode: .minor)
        case .b4:   return   Key(chord: .Gs, mode: .major)
        case .a5:   return   Key(chord: .C, mode: .minor)
        case .b5:   return   Key(chord: .Ds, mode: .major)
        case .a6:   return   Key(chord: .G, mode: .minor)
        case .b6:   return   Key(chord: .As, mode: .major)
        case .a7:   return   Key(chord: .D, mode: .minor)
        case .b7:   return   Key(chord: .F, mode: .major)
        case .a8:   return   Key(chord: .A, mode: .minor)
        case .b8:   return   Key(chord: .C, mode: .major)
        case .a9:   return   Key(chord: .E, mode: .minor)
        case .b9:   return   Key(chord: .G, mode: .major)
        case .a10:  return   Key(chord: .B, mode: .minor)
        case .b10:  return   Key(chord: .D, mode: .major)
        case .a11:  return   Key(chord: .Fs, mode: .minor)
        case .b11:  return   Key(chord: .A, mode: .major)
        case .a12:  return   Key(chord: .Cs, mode: .minor)
        case .b12:  return   Key(chord: .E, mode: .major)
        }
    }
}

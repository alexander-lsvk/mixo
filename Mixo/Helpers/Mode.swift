//
//  Mode.swift
//  Mixo
//
//  Created by Alexander Lisovik on 5/28/19.
//  Copyright © 2019 Alexander Lisovik. All rights reserved.
//

import Foundation

enum Mode: Int {
    case minor
    case major
}

extension Mode {
    var description: String {
        switch self {
        case .minor:
            return "m"
        case .major:
            return ""
        }
    }
}

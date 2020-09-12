//
//  Message.swift
//  Mixo
//
//  Created by Alexander Lisovik on 1/23/20.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import Foundation

public enum Message {
    case error
    case success

    var title: String {
        switch self {
        case .error:     return "Error"
        case .success:   return "Success"
        }
    }
}

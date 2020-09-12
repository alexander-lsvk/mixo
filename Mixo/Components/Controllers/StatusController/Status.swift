//
//  Status.swift
//  Mixo
//
//  Created by Alexander on 16.04.2020.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import Foundation

public enum Status {
    case loading
    case empty(title: String, description: String? = nil)
}

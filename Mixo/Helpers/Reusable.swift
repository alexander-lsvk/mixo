//
//  Reusable.swift
//  Mixo
//
//  Created by Alexander Lisovik on 1/11/20.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import Foundation

protocol Reusable: class {
    static var reuseId: String { get }
}

extension Reusable where Self: UITableViewCell {
    static var reuseId: String {
        return String(describing: self)
    }
}

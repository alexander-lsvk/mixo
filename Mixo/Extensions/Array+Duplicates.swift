//
//  Array+Duplicates.swift
//  Mixo
//
//  Created by Alexander Lisovik on 1/8/20.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

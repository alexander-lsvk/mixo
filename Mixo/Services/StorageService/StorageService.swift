//
//  StorageService.swift
//  Mixo
//
//  Created by Alexander on 09.03.2020.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import Foundation

protocol StorageService {
    /// Retrieves a value from storage service identified by a key.
    ///
    /// - Parameter key: identifier for the value to be retrieved
    /// - Returns: An object of the specified `DataType` or `nil` if not found or data is corrupted
    func retrieveValue<DataType: Codable>(for key: String) -> DataType?

    /// Stores a value of the specified DataType for the given identifier.
    ///
    /// - Parameters:
    ///   - value: The value to be stored
    ///   - key: The storage identifier for the value
    func storeValue<DataType: Codable>(_ value: DataType, for key: String)

    /// Removes any possible stored value for the specified key
    ///
    /// - Parameter key: The storage identifier for the value to be removed
    func removeValue(for key: String)
}

extension StorageService {
    /// Helper get method to return a default value in case value is not found in storage
    func retrieveValue<DataType: Codable>(for key: String, default: DataType) -> DataType {
        return retrieveValue(for: key) ?? `default`
    }
}

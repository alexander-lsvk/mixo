//
//  SecuredStorageService.swift
//  Mixo
//
//  Created by Alexander on 14.04.2020.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import Foundation
import KeychainSwift

struct SecuredStorageService: StorageService {
    private let keychain = KeychainSwift()

    func retrieveValue<DataType>(for key: String) -> DataType? where DataType: Decodable, DataType: Encodable {
        let decoder = JSONDecoder()
        guard let data = keychain.getData(key) else {
            return nil
        }
        if let decoded = try? decoder.decode(DataType.self, from: data) {
            return decoded
        }
        return nil
    }

    func storeValue<DataType>(_ value: DataType, for key: String) where DataType: Decodable, DataType: Encodable {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(value) {
            keychain.set(encoded, forKey: key)
        }
    }

    func removeValue(for key: String) {
        keychain.delete(key)
    }
}

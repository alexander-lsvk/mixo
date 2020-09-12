//
//  FileStorageService.swift
//  Mixo
//
//  Created by Alexander on 09.03.2020.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import Foundation

public struct FileStorageService: StorageService {
    private let fileManager: FileManager
    private let searchPathDirectory: FileManager.SearchPathDirectory

    public init(fileManager: FileManager = FileManager.default,
                searchPathDirectory: FileManager.SearchPathDirectory = .documentDirectory) {
        self.fileManager = fileManager
        self.searchPathDirectory = searchPathDirectory
    }

    public func retrieveValue<DataType: Codable>(for key: String) -> DataType? {
        do {
            guard let data = try? Data(contentsOf: filePath(for: key)) else {
                // Value doesn't exist/not chached
                return nil
            }
            return try JSONDecoder().decode([DataType].self, from: data).first
        } catch {
            print(error)
            return nil
        }
    }

    public func storeValue<DataType: Codable>(_ value: DataType, for key: String) {
        do {
            // Simple values (Int/String etc) are not json-convertible - they need to be wrapped in a root array or dictionary
            // So all values should be stored (and retrieved) encapsulated in an array
            let data = try JSONEncoder().encode([value])
            try data.write(to: filePath(for: key), options: .atomicWrite)
        } catch {
            print(error)
        }
    }

    public func removeValue(for key: String) {
        do {
            guard fileManager.fileExists(atPath: try filePath(for: key).path) else {
                return
            }
            try fileManager.removeItem(at: filePath(for: key))
        } catch {
            print(error)
        }
    }
}

// MARK: - Private methods
extension FileStorageService {
    private func filePath(for key: String) throws -> URL {
        let documentsURL = try fileManager.url(for: searchPathDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        return documentsURL.appendingPathComponent(key)
    }
}

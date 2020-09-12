//
//  ErrorResponse.swift
//  Mixo
//
//  Created by Alexander on 12.04.2020.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import Foundation

struct ErrorResponse: Decodable {
    let status: Int
    let message: String

    enum CodingKeys: String, CodingKey {
        case error
        case status
        case message
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let response = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .error)

        status = try response.decode(Int.self, forKey: .status)
        message = try response.decode(String.self, forKey: .message)
    }
}


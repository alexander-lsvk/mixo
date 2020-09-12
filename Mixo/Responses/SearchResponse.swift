//
//  SearchResponse.swift
//  Mixo
//
//  Created by Alexander Lisovik on 5/22/19.
//  Copyright © 2019 Alexander Lisovik. All rights reserved.
//

import Foundation

struct SearchResponse: Decodable {
    var items: [Track]
    
    enum CodingKeys: String, CodingKey {
        case tracks
        case items
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let response = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .tracks)
        self.items = try response.decode([Track].self, forKey: .items)
    }
}

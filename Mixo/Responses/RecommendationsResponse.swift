//
//  RecommendationsResponse.swift
//  Mixo
//
//  Created by Alexander Lisovik on 5/28/19.
//  Copyright © 2019 Alexander Lisovik. All rights reserved.
//

import Foundation

struct RecommendationsResponse: Decodable {
    var items: [Track]
    
    enum CodingKeys: String, CodingKey {
        case tracks
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.items = try container.decode([Track].self, forKey: .tracks)
    }
}

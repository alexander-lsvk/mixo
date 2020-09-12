//
//  AudioFeaturesResponse.swift
//  Mixo
//
//  Created by Alexander Lisovik on 5/28/19.
//  Copyright © 2019 Alexander Lisovik. All rights reserved.
//

import Foundation

struct AudioFeaturesResponse: Decodable {
    let audioFeatures: [AudioFeatures]
    
    enum CodingKeys: String, CodingKey {
        case audioFeatures = "audio_features"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.audioFeatures = try container.decode([AudioFeatures].self, forKey: .audioFeatures)
    }
}

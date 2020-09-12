//
//  Mix.swift
//  Mixo
//
//  Created by Alexander Lisovik on 1/11/20.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import Foundation

struct Mix: Codable {
    let id: String
    var name: String
    var imageUrl: URL?
    var tracks: [MixTrack?]
}


//
//  MixTrack.swift
//  Mixo
//
//  Created by Alexander Lisovik on 1/11/20.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct MixTrack: Codable, TrackConvertible {
    let id: String
    let name: String
    let artists: [Track.Artist]
    let album: Track.Album
    let previewUrl: URL?
    let key: Int
    let mode: Int
    let tempo: Float
    let energy: Float
    let danceability: Float
    var timestamp: Timestamp?

    init(with track: TrackConvertible, and features: AudioFeatures) {
        self.id = track.id
        self.name = track.name
        self.artists = track.artists
        self.album = track.album
        self.previewUrl = track.previewUrl
        self.key = features.key
        self.mode = features.mode
        self.tempo = features.tempo
        self.energy = features.energy
        self.danceability = features.danceability
    }
}

// MARK: - Equatable
extension MixTrack: Equatable {
    static func == (lhs: MixTrack, rhs: MixTrack) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension MixTrack: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


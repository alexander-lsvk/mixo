//
//  AudioFeatures.swift
//  Mixo
//
//  Created by Alexander Lisovik on 6/10/19.
//  Copyright © 2019 Alexander Lisovik. All rights reserved.
//

import Foundation

struct AudioFeatures: Decodable {
    let id: String
    let key: Int
    let mode: Int
    let tempo: Float
    let energy: Float
    let danceability: Float
}

// MARK: - JSON
//{
//  "duration_ms" : 255349,
//  "key" : 5,
//  "mode" : 0,
//  "time_signature" : 4,
//  "acousticness" : 0.514,
//  "danceability" : 0.735,
//  "energy" : 0.578,
//  "instrumentalness" : 0.0902,
//  "liveness" : 0.159,
//  "loudness" : -11.840,
//  "speechiness" : 0.0461,
//  "valence" : 0.624,
//  "tempo" : 98.002,
//  "id" : "06AKEBrKUckW0KREUWRnvT",
//  "uri" : "spotify:track:06AKEBrKUckW0KREUWRnvT",
//  "track_href" : "https://api.spotify.com/v1/tracks/06AKEBrKUckW0KREUWRnvT",
//  "analysis_url" : "https://api.spotify.com/v1/audio-analysis/06AKEBrKUckW0KREUWRnvT",
//  "type" : "audio_features"
//}

//
//  Track.swift
//  Mixo
//
//  Created by Alexander Lisovik on 5/28/19.
//  Copyright © 2019 Alexander Lisovik. All rights reserved.
//

import Foundation
import FirebaseFirestore

protocol TrackConvertible {
    var id: String { get }
    var name: String { get }
    var artists: [Track.Artist] { get }
    var album: Track.Album { get }
    var previewUrl: URL? { get }
    var timestamp: Timestamp? { get }
}

extension TrackConvertible {
    var artistsIds: String? {
        if artists.count > 3 {
            return artists.dropLast(artists.count - 3).map { $0.id }.joined(separator: ",")
        } else {
            return artists.map { $0.id }.joined(separator: ",")
        }
    }
}

struct Track: TrackConvertible {
    let id: String
    let name: String
    let artists: [Artist]
    let album: Album
    let previewUrl: URL?
    var timestamp: Timestamp?
    
    struct Artist: Codable {
        let id: String
        let name: String
    }
    
    struct Album: Codable {
        let images: [Image]
        
        struct Image: Codable {
            let url: URL
        }
    }
}

// MARK: - Decodable
extension Track: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case artists
        case album
        case previewUrl = "preview_url"
    }
}

// MARK: - Equatable
extension Track: Equatable {
    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension Track: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - JSON
//{
//  "album": {
//    "album_type": "single",
//    "artists": [
//      {
//        "external_urls": {
//          "spotify": "https://open.spotify.com/artist/6sFIWsNpZYqfjUpaCgueju"
//        },
//        "href": "https://api.spotify.com/v1/artists/6sFIWsNpZYqfjUpaCgueju",
//        "id": "6sFIWsNpZYqfjUpaCgueju",
//        "name": "Carly Rae Jepsen",
//        "type": "artist",
//        "uri": "spotify:artist:6sFIWsNpZYqfjUpaCgueju"
//      }
//    ],
//    "available_markets": [],
//    "external_urls": {
//      "spotify": "https://open.spotify.com/album/0tGPJ0bkWOUmH7MEOR77qc"
//    },
//    "href": "https://api.spotify.com/v1/albums/0tGPJ0bkWOUmH7MEOR77qc",
//    "id": "0tGPJ0bkWOUmH7MEOR77qc",
//    "images": [
//      {
//        "height": 640,
//        "url": "https://i.scdn.co/image/966ade7a8c43b72faa53822b74a899c675aaafee",
//        "width": 640
//      },
//      {
//        "height": 300,
//        "url": "https://i.scdn.co/image/107819f5dc557d5d0a4b216781c6ec1b2f3c5ab2",
//        "width": 300
//      },
//      {
//        "height": 64,
//        "url": "https://i.scdn.co/image/5a73a056d0af707b4119a883d87285feda543fbb",
//        "width": 64
//      }
//    ],
//    "name": "Cut To The Feeling",
//    "release_date": "2017-05-26",
//    "release_date_precision": "day",
//    "type": "album",
//    "uri": "spotify:album:0tGPJ0bkWOUmH7MEOR77qc"
//  },
//  "artists": [
//    {
//      "external_urls": {
//        "spotify": "https://open.spotify.com/artist/6sFIWsNpZYqfjUpaCgueju"
//      },
//      "href": "https://api.spotify.com/v1/artists/6sFIWsNpZYqfjUpaCgueju",
//      "id": "6sFIWsNpZYqfjUpaCgueju",
//      "name": "Carly Rae Jepsen",
//      "type": "artist",
//      "uri": "spotify:artist:6sFIWsNpZYqfjUpaCgueju"
//    }
//  ],
//  "available_markets": [],
//  "disc_number": 1,
//  "duration_ms": 207959,
//  "explicit": false,
//  "external_ids": {
//    "isrc": "USUM71703861"
//  },
//  "external_urls": {
//    "spotify": "https://open.spotify.com/track/11dFghVXANMlKmJXsNCbNl"
//  },
//  "href": "https://api.spotify.com/v1/tracks/11dFghVXANMlKmJXsNCbNl",
//  "id": "11dFghVXANMlKmJXsNCbNl",
//  "is_local": false,
//  "name": "Cut To The Feeling",
//  "popularity": 63,
//  "preview_url": "https://p.scdn.co/mp3-preview/3eb16018c2a700240e9dfb8817b6f2d041f15eb1?cid=774b29d4f13844c495f206cafdad9c86",
//  "track_number": 1,
//  "type": "track",
//  "uri": "spotify:track:11dFghVXANMlKmJXsNCbNl"
//}

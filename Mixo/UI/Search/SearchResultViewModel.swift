//
//  SearchResultViewModel.swift
//  
//
//  Created by Alexander Lisovik on 5/22/19.
//

import Foundation

struct SearchResultViewModel: TrackViewModel {
    let trackId: String
    let artistIds: String
    let name: String
    let artist: String
    let imageURL: URL?
    let key: Key?
    let tempo: Float
    let place: TrackPlace = .search
    let isMostHarmonic = false

    var isPlaying = false
    var updateIsPlayingHandler: ((Bool) -> Void)?

    var didSelectHandler: ((TrackViewModel) -> Void)
    var addToMixHandler: (() -> Void)?
    var showRecommendationsHandler: (() -> Void)?
    
    init(with track: Track,
         key: Key? = nil,
         tempo: Float? = nil,
         didSelectHandler: @escaping ((TrackViewModel) -> Void)) {
        self.trackId = track.id
        
        if track.artists.count > 3 {
            self.artistIds = track.artists.dropLast(track.artists.count - 3).map { $0.id }.joined(separator: ",")
        } else {
            self.artistIds = track.artists.map { $0.id }.joined(separator: ",")
        }
        
        self.name = track.name
        self.artist = track.artists.map { $0.name }.joined(separator: ", ")
        self.imageURL = track.album.images.first?.url
        self.key = key
        self.tempo = tempo!

        self.didSelectHandler = didSelectHandler
    }
}

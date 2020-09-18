//
//  RecommendationViewModel.swift
//  Mixo
//
//  Created by Alexander Lisovik on 5/28/19.
//  Copyright © 2019 Alexander Lisovik. All rights reserved.
//

import Foundation

final class RecommendationViewModel: TrackViewModel {
    let trackId: String
    let artist: String
    let name: String
    let imageURL: URL?
    let key: Key?
    let tempo: Float
    let isMostHarmonic: Bool
    let place: TrackPlace = .recommendations

    var isPlaying = false
    var updateIsPlayingHandler: (((_ isPlaying: Bool) -> Void))?

    var addToMixHandler: (() -> Void)?
    var backToSearchHandler: (() -> Void)?
    var showRecommendationsHandler: (() -> Void)?

    var didSelectHandler: ((TrackViewModel) -> Void)
    
    init(with track: TrackConvertible,
         key: Key? = nil,
         tempo: Float,
         isMostHarmonic: Bool,
         didSelectHandler: @escaping ((TrackViewModel) -> Void)) {
        self.trackId = track.id
        self.artist = track.artists.map { $0.name }.joined(separator: ", ")
        self.name = track.name
        self.imageURL = track.album.images.first?.url
        self.key = key
        self.tempo = tempo
        self.isMostHarmonic = isMostHarmonic

        self.didSelectHandler = didSelectHandler
    }
}

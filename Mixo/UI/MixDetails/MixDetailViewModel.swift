//
//  MixDetailViewModel.swift
//  Mixo
//
//  Created by Alexander Lisovik on 1/13/20.
//  Copyright (c) 2020 Alexander Lisovik. All rights reserved.
//

import Foundation

struct MixDetailViewModel {
    let trackId: String
    let artist: String
    let name: String
    let imageURL: URL?
    let key: Key?
    let tempo: Float?

    let didRemoveItemHandler: (_ tracksCount: Int) -> Void
    var didSelectHandler: (MixDetailViewModel) -> Void
    var showRecommendationsHandler: (() -> Void)?

    var isPlaying = false

    init(_ mixTrack: MixTrack, didRemoveItemHandler: @escaping (_ tracksCount: Int) -> Void, didSelectHandler: @escaping (MixDetailViewModel) -> Void,
        showRecommendationsHandler: @escaping () -> Void) {
        self.trackId = mixTrack.id
        self.artist = mixTrack.artists.map { $0.name }.joined(separator: ", ")
        self.name = mixTrack.name
        self.imageURL = mixTrack.album.images.first?.url
        self.key = Key(chord: Chord(rawValue: mixTrack.key)!, mode: Mode(rawValue: mixTrack.mode)!)
        self.tempo = mixTrack.tempo

        self.didRemoveItemHandler = didRemoveItemHandler
        self.didSelectHandler = didSelectHandler

        self.showRecommendationsHandler = showRecommendationsHandler
    }
}

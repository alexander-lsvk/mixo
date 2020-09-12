//
//  SearchResultViewModel.swift
//  
//
//  Created by Alexander Lisovik on 5/22/19.
//

import Foundation

struct SearchResultViewModel {
    let trackId: String
    let artistIds: String
    let name: String
    let artist: String
    let imageURL: URL?
    let key: Key?
    let tempo: Float?

    var didSelectHandler: ((SearchResultViewModel) -> Void)
    
    init(with track: Track, key: Key? = nil, tempo: Float? = nil, didSelectHandler: @escaping ((SearchResultViewModel) -> Void)) {
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
        self.tempo = tempo

        self.didSelectHandler = didSelectHandler
    }
}

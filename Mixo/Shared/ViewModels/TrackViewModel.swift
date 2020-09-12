//
//  TrackViewModel.swift
//  Mixo
//
//  Created by user on 12.09.2020.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import Foundation

enum TrackPlace {
    case search
    case recommendations
    case mixDetails
}

protocol TrackViewModel {
    var trackId: String      { get }
    var artist: String       { get }
    var name: String         { get }
    var imageURL: URL?       { get }
    var key: Key?            { get }
    var tempo: Float         { get }
    var isMostHarmonic: Bool { get }
    var place: TrackPlace    { get }
    
    var addToMixHandler: (() -> Void)?               { get set }
    var showRecommendationsHandler: (() -> Void)?    { get set }
    var didSelectHandler: ((TrackViewModel) -> Void) { get set }
    
    var isPlaying: Bool { get set }
}

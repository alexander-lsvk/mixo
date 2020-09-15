//
//  PlayerPresenter.swift
//  Mixo
//
//  Created by Alexander Lisovik on 12.09.2020.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import Foundation

enum PlayerEvent {
    static let didStartPlayTrack = Event<Track>()
    static let didStopPlayTrack = Event<Void>()
}

struct PlayerViewHandler {
    let setViewModel: (_ viewModel: PlayerViewModel) -> Void
    let updatePlayButton: (_ isPlaying: Bool) -> Void
}

final class PlayerPresenter: Presenter {
    var baseViewHandler: BaseViewHandler?
    var playerViewHandler: PlayerViewHandler?

    private var playingTrack = PlayingTrack(id: nil, status: .stopped) {
        didSet {
            playerViewHandler?.updatePlayButton(playingTrack.status.rawValue == 0)
        }
    }

    private let eventsService: EventsService
    private let networkService: NetworkService
    private let audioPreviewService: AudioPreviewService

    init(eventsService: EventsService = .default,
         networkService: NetworkService = ProductionNetworkService(),
         audioPreviewService: AudioPreviewService = AudioPreviewService.shared) {
        self.eventsService = eventsService
        self.networkService = networkService
        self.audioPreviewService = audioPreviewService
    }

    func didBindController() {
        eventsService.enableLogging = true
        eventsService.register(self, for: PlayerEvent.didStartPlayTrack) { [weak self] track in
            guard let self = self else {
                return
            }
            let playerViewModel = PlayerViewModel(artist: track.artists.map { $0.name }.joined(separator: ", "),
                                                  name: track.name,
                                                  imageUrl: track.album.images.first?.url,
                                                  didTapPlayButtonHandler: { [weak self] in
                                                      self?.didTapPlayButton(track.id)
                                                  })
            self.playerViewHandler?.setViewModel(playerViewModel)
            self.playAudioPreview(track.id)
        }
    }
}

// MARK: - Private functions
extension PlayerPresenter {
    private func didTapPlayButton(_ trackId: String?) {
        playAudioPreview(trackId)
    }

    private func playAudioPreview(_ trackId: String?) {
        audioPreviewService.status = .stopped
        playingTrack.status = .stopped
        // If the same track is selected reset the player
        guard let trackId = trackId, playingTrack.id != trackId else {
            playingTrack.id = nil
            return
        }

        playingTrack.id = trackId
        playingTrack.status = .playing

        getAudioPreviewUrl(for: trackId) { [weak self] url in
            guard let url = url else {
                return
            }
            self?.audioPreviewService.play(url: url) { status in
                switch status {
                case .playing:  print("Player play")
                case .stopped:  print("Player stop")
                }
            }
        }
    }

    private func getAudioPreviewUrl(for id: String, completion: @escaping (_ url: URL?) -> Void) {
        networkService.requestDecodable(.tracks(id: id)) { (result: Result<Track, Error>) in
            switch result {
            case .success(let response):    completion(response.previewUrl)
            case .failure(let error):       self.baseViewHandler?.showMessage(.error, error.localizedDescription)
            }
        }
    }
}

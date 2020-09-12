//
//  MixDetailsPresenter.swift
//  Mixo
//
//  Created by Alexander Lisovik on 1/13/20.
//  Copyright (c) 2020 Alexander Lisovik. All rights reserved.
//

import Foundation

struct MixDetailsViewHandler {
    let setViewModels: ([MixDetailViewModel]) -> Void
    let setReorderListHandler: (@escaping (_ sourceIndex: Int, _ destinationIndex: Int) -> Void) -> Void
    let presentRecommendationsViewController: (_ presenter: RecommendationsPresenter) -> Void
}

final class MixDetailsPresenter: Presenter {
    var baseViewHandler: BaseViewHandler?
    var mixDetailsViewHandler: MixDetailsViewHandler?

    private var mix: Mix

    private var playingTrackId: String?

    private var mixDetailViewModels = [MixDetailViewModel]()

    private let didUpdateTracks: () -> Void

    private let mixesService: MixesService
    private let networkService: NetworkService
    private let audioPreviewService: AudioPreviewService
    
    init(mix: Mix,
         didUpdateTracks: @escaping () -> Void,
         networkService: NetworkService = ProductionNetworkService(),
         audioPreviewService: AudioPreviewService = AudioPreviewService.shared,
         mixesService: MixesService = AnonymousMixesService.shared) {
        self.mix = mix
        self.didUpdateTracks = didUpdateTracks
        self.mixesService = mixesService
        self.networkService = networkService
        self.audioPreviewService = audioPreviewService
    }
    
    func didBindController() {
        baseViewHandler?.setTitle(mix.name)
        setViewModel()
    }

    func viewWillDisappear() {
        if let playingTrackId = playingTrackId {
            playAudioPreview(for: playingTrackId)
        }
    }
}

// MARK: - Private methods
extension MixDetailsPresenter {
    private func setViewModel() {
        let mixDetailViewModels = mix.tracks.map { track in
            MixDetailViewModel(track!, didRemoveItemHandler: { [weak self] tracksCount in
                self?.removeTrack(track!, tracksCount: tracksCount)

            }, didSelectHandler: { [weak self] viewModel in
                self?.playAudioPreview(for: viewModel.trackId)

            }, showRecommendationsHandler: { [weak self] in
                guard let track = track else {
                    return
                }
                let recommendationsPresenter = RecommendationsPresenter(currentTrack: track)
                self?.mixDetailsViewHandler?.presentRecommendationsViewController(recommendationsPresenter)
            })
        }
        self.mixDetailViewModels = mixDetailViewModels

        if mixDetailViewModels.isEmpty {
            self.baseViewHandler?.showStatus(.empty(title: "No tracks", description: "Start adding tracks to your mix right from the recommendations"), true)
        }

        mixDetailsViewHandler?.setViewModels(self.mixDetailViewModels)
        mixDetailsViewHandler?.setReorderListHandler({ [weak self] sourceIndex, destinationIndex in
            guard let self = self else {
                return
            }
            let track = self.mix.tracks[sourceIndex]
            self.mix.tracks.remove(at: sourceIndex)
            self.mix.tracks.insert(track, at: destinationIndex)

            self.mixesService.update(mix: self.mix)
        })
    }

    private func removeTrack(_ track: MixTrack, tracksCount: Int) {
        mixesService.removeFromMix(track: track, mixId: mix.id)
        if tracksCount == 1 {
            baseViewHandler?.showStatus(.empty(title: "No tracks", description: "Start adding tracks to your mix right from the recommendations"), true)
        }
        didUpdateTracks()
    }

    private func playAudioPreview(for id: String) {
        audioPreviewService.status = .stopped

         // If some track is playing
        if playingTrackId != nil {
            var mixDetailViewModels = self.mixDetailViewModels
            guard let index = mixDetailViewModels.firstIndex(where: { $0.trackId == playingTrackId }) else {
                return
            }
            mixDetailViewModels[index].isPlaying = false
            mixDetailsViewHandler?.setViewModels(mixDetailViewModels)

            if playingTrackId == id {
                playingTrackId = nil
                return
            }
        }

        getAudioPreviewUrl(for: id) { [weak self] url in
            guard let url = url else {
                self?.baseViewHandler?.showMessage(.error, "Preview is unavailable for the selected track")
                return
            }

            self?.audioPreviewService.play(url: url) { status in
                var mixDetailViewModels = self?.mixDetailViewModels
                guard let self = self, let index = mixDetailViewModels?.firstIndex(where: { $0.trackId == id }) else {
                    return
                }
                switch status {
                case .playing:
                    self.playingTrackId = id
                    mixDetailViewModels?[index].isPlaying = true
                case .stopped:
                    mixDetailViewModels?[index].isPlaying = false
                    self.playingTrackId = nil
                }
                self.mixDetailsViewHandler?.setViewModels(mixDetailViewModels ?? [])
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

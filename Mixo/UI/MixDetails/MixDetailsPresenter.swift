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
    private let eventsService: EventsService
    private let networkService: NetworkService
    private let audioPreviewService: AudioPreviewService
    
    init(mix: Mix,
         didUpdateTracks: @escaping () -> Void,
         networkService: NetworkService = ProductionNetworkService(),
         audioPreviewService: AudioPreviewService = AudioPreviewService.shared,
         mixesService: MixesService = AnonymousMixesService.shared,
         eventsService: EventsService = EventsService.default) {
        self.mix = mix
        self.didUpdateTracks = didUpdateTracks
        self.mixesService = mixesService
        self.networkService = networkService
        self.eventsService = eventsService
        self.audioPreviewService = audioPreviewService
    }
    
    func didBindController() {
        baseViewHandler?.setTitle(mix.name)
        setViewModel()
    }
}

// MARK: - Private methods
extension MixDetailsPresenter {
    private func setViewModel() {
        let mixDetailViewModels = mix.tracks.map { track in
            MixDetailViewModel(track!, didRemoveItemHandler: { [weak self] tracksCount in
                self?.removeTrack(track!, tracksCount: tracksCount)

            }, didSelectHandler: { [weak self] viewModel in
                self?.didSelectTrackHandler(track: track)

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

    private func didSelectTrackHandler(track: MixTrack?) {
        guard let track = track else {
            return
        }
        eventsService.post(eventType: PlayerEvent.didStartPlayTrack, value: track)

        guard let viewModel = mixDetailViewModels.first(where: { $0.trackId == track.id }), !viewModel.isPlaying else {
            return
        }

        mixDetailViewModels.forEach {
            $0.updateIsPlayingHandler?(false)
            $0.isPlaying = false
        }
        viewModel.updateIsPlayingHandler?(true)
        viewModel.isPlaying = true
    }

    private func removeTrack(_ track: MixTrack, tracksCount: Int) {
        mixesService.removeFromMix(track: track, mixId: mix.id)
        if tracksCount == 1 {
            baseViewHandler?.showStatus(.empty(title: "No tracks", description: "Start adding tracks to your mix right from the recommendations"), true)
        }
        didUpdateTracks()
    }
}

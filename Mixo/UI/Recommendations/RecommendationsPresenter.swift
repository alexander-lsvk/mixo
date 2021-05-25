//
//  RecommendationsPresenter.swift
//  Mixo
//
//  Created by Alexander Lisovik on 5/28/19.
//  Copyright © 2019 Alexander Lisovik. All rights reserved.
//

import UIKit
import SwiftRater
import FirebaseFirestore
import FirebaseAuth

struct RecommendationsViewHandler {
    let showBackToSearchButton: (_ show: Bool) -> Void
    let setCurrentTrackViewModel: (_ viewModel: RecommendationViewModel) -> Void
    let setSortViewModel: (_ viewModel: RecommendationsSortViewModel) -> Void
    let setViewModels: (_ viewModels: [RecommendationViewModel]?, _ animated: Bool) -> Void
    let setPremiumContentHandler: (_ handler: @escaping () -> Void) -> Void
    let showMixesViewController: (_ presenter: MixesPresenter) -> Void
    let presentRecommendationsViewController: (_ presenter: RecommendationsPresenter) -> Void
    let presentSubscriptionViewController: (_ presenter: SubscriptionPresenter) -> Void
    let popToRootViewController: () -> Void
    let showAddedToMix: () -> Void
}

final class RecommendationsPresenter: Presenter {
    var baseViewHandler: BaseViewHandler?
    var recommendationsViewHandler: RecommendationsViewHandler?
    
    private let currentTrack: TrackConvertible
    private var currentTrackFeatures: AudioFeatures?
    private var currentTrackViewModel: RecommendationViewModel?
    
    private var recommendations = [Track]()
    private var recommendationsAudioFeatures = [AudioFeatures]()
    private var recommendationsViewModels = [RecommendationViewModel]()

    private var harmonicKeys: [Key]?
    
    private let dispatchGroup = DispatchGroup()

    private let showBackToSearchButton: Bool

    private let eventsService: EventsService
    private let networkService: NetworkService
    private let audioPreviewService: AudioPreviewService
    
    init(currentTrack: TrackConvertible,
         showBackToSearchButton: Bool = false,
         eventsService: EventsService = .default,
         networkService: NetworkService = ProductionNetworkService(),
         audioPreviewService: AudioPreviewService = AudioPreviewService.shared) {
        self.currentTrack = currentTrack
        self.showBackToSearchButton = showBackToSearchButton
        self.eventsService = eventsService
        self.networkService = networkService
        self.audioPreviewService = audioPreviewService
    }
    
    func didBindController() {
        recommendationsViewHandler?.showBackToSearchButton(showBackToSearchButton)
        recommendationsViewHandler?.setViewModels(nil, false)
        recommendationsViewHandler?.setSortViewModel(RecommendationsSortViewModel() { [weak self] sortOption in
            guard let self = self else {
                return
            }
            switch sortOption {
            case .best:             self.sortByBest(self.recommendationsViewModels)
            case .bpmAscending:     self.sortByBpm(self.recommendationsViewModels, ascending: true)
            case .bpmDescending:    self.sortByBpm(self.recommendationsViewModels, ascending: false)
            }
        })
        loadCurrentTrackFeatures(id: currentTrack.id)

        recommendationsViewHandler?.setPremiumContentHandler({ [weak self] in
            let subscriptionPresenter = SubscriptionPresenter()
            self?.recommendationsViewHandler?.presentSubscriptionViewController(subscriptionPresenter)
        })
    }

    func viewWillAppear() {
        // Check if we still need to show a track as playing
        let commonViewModels = recommendationsViewModels + [currentTrackViewModel]
        if let track = commonViewModels.first(where: { audioPreviewService.trackId == $0?.trackId }) {
            if track?.isPlaying ?? false {
                return
            } else {
                stopAllTracks(withCurrent: true)
            }
        } else {
            stopAllTracks(withCurrent: true)
        }
    }
}

// MARK: - Private methods
extension RecommendationsPresenter {
    private func loadCurrentTrackFeatures(id: String) {
        networkService.requestDecodable(.audioFeatures(ids: [currentTrack.id])) { (result: Result<AudioFeaturesResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let currentTrackFeatures = response.audioFeatures.first {
                        self.currentTrackFeatures = currentTrackFeatures
                    }

                    self.setCurrentTrackViewModel()
                    self.determineHarmonicKeys()

                    // Load recommendations for each suitable key
                    guard let harmonicKeys = self.harmonicKeys else {
                        return
                    }
                    
                    for key in harmonicKeys {
                        self.loadRecommendations(targetKey: key.chord!.rawValue,
                                                 targetMode: key.mode!.rawValue)
                    }

                    self.dispatchGroup.notify(queue: .main) {
                        self.recommendations.removeDuplicates()
                        self.loadRecommendedTracksFeatures(ids: self.recommendations.prefix(100).map { $0.id })
                    }

                case .failure(let error):
                    self.baseViewHandler?.showMessage(.error, error.localizedDescription)
                }
            }
        }
    }

    private func loadRecommendations(targetKey: Int, targetMode: Int) {
        dispatchGroup.enter()

        networkService.requestDecodable(.recommendations(seedArtists: currentTrack.artistsIds ?? "",
                                                         seedTracks: currentTrack.id,
                                                         targetKey: targetKey,
                                                         targetMode: targetMode,
                                                         targetTempo: currentTrackFeatures?.tempo ?? 100.0)) { (result: Result<RecommendationsResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):    self.recommendations += response.items
                case .failure(let error):       self.baseViewHandler?.showMessage(.error, error.localizedDescription)
                }
                self.dispatchGroup.leave()
            }
        }
    }

    private func loadRecommendedTracksFeatures(ids: [String]) {
        networkService.requestDecodable(.audioFeatures(ids: ids)) { (result: Result<AudioFeaturesResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.recommendationsAudioFeatures = response.audioFeatures.compactMap { $0 }

                    var recommendationsViewModels = [RecommendationViewModel]()

                    for track in self.recommendations {
                        guard let trackFeatures = self.recommendationsAudioFeatures.first(where: { $0.id == track.id }) else {
                            continue
                        }

                        let key = Key(rawChord: trackFeatures.key, rawMode: trackFeatures.mode)
                        let tempo = trackFeatures.tempo

                        let recommendationViewModel = RecommendationViewModel(with: track,
                                                                              key: key,
                                                                              tempo: tempo,
                                                                              isMostHarmonic: self.isMostHarmonic(key),
                                                                              didSelectHandler: { [weak self] viewModel in
                                                                                  self?.didSelectTrackHandler(track: track)
                                                                              })
                        recommendationViewModel.addToMixHandler = { [weak self] in self?.addRecommendationToMix(recommendationViewModel) }
                        recommendationViewModel.backToSearchHandler = { [weak self] in self?.recommendationsViewHandler?.popToRootViewController() }
                        recommendationViewModel.showRecommendationsHandler = { [weak self] in self?.showRecommendations(for: recommendationViewModel) }

                        recommendationsViewModels.append(recommendationViewModel)
                    }

                    self.sortByBest(recommendationsViewModels)

                case .failure(let error):
                    self.baseViewHandler?.showMessage(.error, error.localizedDescription)
                }
            }
        }
    }

    private func isMostHarmonic(_ key: Key?) -> Bool {
        harmonicKeys?.contains { $0.chord == key?.chord && $0.mode == key?.mode } ?? false
    }

    private func sortByBest(_ viewModels: [RecommendationViewModel]) {
        recommendationsViewModels = viewModels.sorted {
            if $0.isMostHarmonic == $1.isMostHarmonic {
                return $0.tempo < $1.tempo
            }
            return $0.isMostHarmonic && !$1.isMostHarmonic
        }

        recommendationsViewHandler?.setViewModels(recommendationsViewModels, true)
    }

    private func sortByBpm(_ viewModels: [RecommendationViewModel], ascending: Bool) {
        if ascending {
            recommendationsViewModels = viewModels.sorted { $0.tempo < $1.tempo }
        } else {
            recommendationsViewModels = viewModels.sorted { $0.tempo > $1.tempo }
        }

        recommendationsViewHandler?.setViewModels(recommendationsViewModels, true)
    }

    private func determineHarmonicKeys() {
        guard let currentTrackFeatures = currentTrackFeatures else {
            return
        }

        let key = Key(rawChord: currentTrackFeatures.key, rawMode: currentTrackFeatures.mode)

        guard let chord = key.chord, let mode = key.mode else {
            return
        }

        let camelot = Camelot(key: "\(chord)\(mode.description)")
        harmonicKeys = camelot.harmonicKeys
    }

    private func setCurrentTrackViewModel() {
        let key = Key(chord: Chord(rawValue: self.currentTrackFeatures!.key)!, mode: Mode(rawValue: self.currentTrackFeatures!.mode)!)

        let recommendationViewModel = RecommendationViewModel(with: self.currentTrack,
                                                              key: key,
                                                              tempo: currentTrackFeatures?.tempo ?? 0,
                                                              isMostHarmonic: isMostHarmonic(key),
                                                              didSelectHandler: { [weak self] viewModel in
                                                                  self?.didSelectTrackHandler(track: self?.currentTrack)
                                                              })
        recommendationViewModel.backToSearchHandler = { [weak self] in self?.recommendationsViewHandler?.popToRootViewController() }
        recommendationViewModel.addToMixHandler = { [weak self] in self?.addSeedTrackToMix(recommendationViewModel) }

        currentTrackViewModel = recommendationViewModel

        recommendationsViewHandler?.setCurrentTrackViewModel(recommendationViewModel)
    }

    private func didSelectTrackHandler(track: TrackConvertible?) {
        let commonAudioFeatures = recommendationsAudioFeatures + [currentTrackFeatures]

        guard let track = track as? Track,
              let audioFeatures = commonAudioFeatures.first(where: { $0?.id == track.id }) else {
            return
        }

        let mixTrack = MixTrack(with: track, and: audioFeatures!)
        eventsService.post(eventType: PlayerEvent.didStartPlayTrack, value: mixTrack)

        if track.id == currentTrack.id {
            stopAllTracks()
            return
        }

        guard let viewModel = recommendationsViewModels.first(where: { $0.trackId == track.id }), !viewModel.isPlaying else {
            return
        }

        stopAllTracks(withCurrent: true)
        viewModel.updateIsPlayingHandler?(true)
        viewModel.isPlaying = true
    }

    private func addRecommendationToMix(_ recommendationViewModel: RecommendationViewModel) {
        guard let track = recommendations.first(where: { $0.id == recommendationViewModel.trackId }),
              let audioFeatures = recommendationsAudioFeatures.first(where: { $0.id == recommendationViewModel.trackId }) else {
                return
        }
        let mixTrack = MixTrack(with: track, and: audioFeatures)
        recommendationsViewHandler?.showMixesViewController(MixesPresenter(displayMode: .add(track: mixTrack,
                                                                                             completionHandler: { [weak self] in
                                                                                                self?.recommendationsViewHandler?.showAddedToMix()
                                                                                                SwiftRater.check()
                                                                                             })))
    }

    private func addSeedTrackToMix(_ recommendationViewModel: RecommendationViewModel) {
        guard let seedTrackFeatures = currentTrackFeatures else {
            return
        }

        let mixTrack = MixTrack(with: currentTrack, and: seedTrackFeatures)
        recommendationsViewHandler?.showMixesViewController(MixesPresenter(displayMode: .add(track: mixTrack,
                                                                                             completionHandler: { [weak self] in
                                                                                                self?.recommendationsViewHandler?.showAddedToMix()
                                                                                             })))
    }

    private func showRecommendations(for recommendationViewModel: RecommendationViewModel) {
        guard let track = recommendations.first(where: { $0.id == recommendationViewModel.trackId }) else {
            return
        }
        let recommendationsPresenter = RecommendationsPresenter(currentTrack: track, showBackToSearchButton: showBackToSearchButton)
        recommendationsViewHandler?.presentRecommendationsViewController(recommendationsPresenter)
    }

    private func stopAllTracks(withCurrent: Bool = false) {
        recommendationsViewModels.forEach {
            $0.updateIsPlayingHandler?(false)
            $0.isPlaying = false
        }
        if withCurrent {
            currentTrackViewModel?.updateIsPlayingHandler?(false)
        }
    }
}

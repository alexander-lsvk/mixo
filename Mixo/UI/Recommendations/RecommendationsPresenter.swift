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
    let showMixesViewController: (_ presenter: MixesPresenter) -> Void
    let presentRecommendationsViewController: (_ presenter: RecommendationsPresenter) -> Void
    let popToRootViewController: () -> Void
    let showAddedToMix: () -> Void
}

final class RecommendationsPresenter: Presenter {
    var baseViewHandler: BaseViewHandler?
    var recommendationsViewHandler: RecommendationsViewHandler?
    
    private let currentTrack: TrackConvertible
    private var currentTrackFeatures: AudioFeatures?
    
    private var recommendations = [Track]()
    private var recommendationsAudioFeatures = [AudioFeatures]()
    private var recommendationsViewModels = [RecommendationViewModel]()

    private var harmonicKeys: [Key]?
    
    private let dispatchGroup = DispatchGroup()

    private var playingTrackId: String?

    private let showBackToSearchButton: Bool

    private let mixesService: MixesService
    private let eventsService: EventsService
    private let networkService: NetworkService
    
    init(currentTrack: TrackConvertible,
         showBackToSearchButton: Bool = false,
         eventsService: EventsService = .default,
         networkService: NetworkService = ProductionNetworkService(),
         mixesService: MixesService = AnonymousMixesService.shared) {
        self.currentTrack = currentTrack
        self.showBackToSearchButton = showBackToSearchButton
        self.eventsService = eventsService
        self.networkService = networkService
        self.mixesService = mixesService
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
                    self.recommendationsAudioFeatures = response.audioFeatures

                    var recommendationsViewModels = [RecommendationViewModel]()

                    for track in self.recommendations {
                        guard let trackFeatures = self.recommendationsAudioFeatures.first(where: { $0.id == track.id }) else {
                            continue
                        }

                        let key = Key(rawChord: trackFeatures.key, rawMode: trackFeatures.mode)
                        let tempo = trackFeatures.tempo

                        var recommendationViewModel = RecommendationViewModel(with: track,
                                                                              key: key,
                                                                              tempo: tempo,
                                                                              isMostHarmonic: self.isMostHarmonic(key),
                                                                              didSelectHandler: { [weak self] viewModel in
                                                                                  self?.didSelectTrackHandler(viewModel: viewModel, track: track)
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

    private func setCurrentTrackViewModel(isPlaying: Bool = false) {
        let key = Key(chord: Chord(rawValue: self.currentTrackFeatures!.key)!, mode: Mode(rawValue: self.currentTrackFeatures!.mode)!)

        var recommendationViewModel = RecommendationViewModel(with: self.currentTrack,
                                                              key: key,
                                                              tempo: currentTrackFeatures?.tempo ?? 0,
                                                              isMostHarmonic: isMostHarmonic(key),
                                                              didSelectHandler: { [weak self] viewModel in
                                                                  self?.didSelectTrackHandler(viewModel: viewModel, track: self?.currentTrack)
                                                              })

        recommendationViewModel.isPlaying = isPlaying
        recommendationViewModel.backToSearchHandler = { [weak self] in self?.recommendationsViewHandler?.popToRootViewController() }
        recommendationViewModel.addToMixHandler = { [weak self] in self?.addSeedTrackToMix(recommendationViewModel) }

        recommendationsViewHandler?.setCurrentTrackViewModel(recommendationViewModel)
    }

    private func didSelectTrackHandler(viewModel: TrackViewModel, track: TrackConvertible?) {
        if let track = track as? Track {
            eventsService.post(eventType: PlayerEvent.didStartPlayTrack, value: track)
        }
    }

    private func addRecommendationToMix(_ recommendationViewModel: RecommendationViewModel) {
        guard let track = recommendations.first(where: { $0.id == recommendationViewModel.trackId }),
              let audioFeatures = recommendationsAudioFeatures.first(where: { $0.id == recommendationViewModel.trackId }) else {
                return
        }
        let mixTrack = MixTrack(with: track, and: audioFeatures)
        recommendationsViewHandler?.showMixesViewController(MixesPresenter(displayMode: .add(track: mixTrack,
                                                                                             completionHandler: { [weak self] in
                                                                                                self?.updateLastAction()
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

    private func updateLastAction() {
        let firestore = Firestore.firestore()
        firestore.collection("users").whereField("id", isEqualTo: Auth.auth().currentUser?.uid as Any).getDocuments() { querySnapshot, error in
            guard let userDocumentId = querySnapshot?.documents.first?.documentID else {
                return
            }
            let userReference = firestore.collection("users").document(userDocumentId)
            userReference.updateData(["lastAction": Timestamp(date: Date())])
        }
    }
}

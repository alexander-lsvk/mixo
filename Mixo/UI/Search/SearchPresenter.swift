//
//  SearchPresenter.swift
//  Mixo
//
//  Created by Alexander Lisovik on 5/22/19.
//  Copyright © 2019 Alexander Lisovik. All rights reserved.
//

import Foundation
import SwiftRater
import FirebaseAuth
import FirebaseFirestore
import CodableFirebase

struct SearchViewHandler {
    let presentSpotifyLoginViewController: (_ presenter: SpotifyLoginPresenter) -> Void
    let setSearchBarHandler: (_ handler: @escaping (_ query: String) -> Void) -> Void
    let setViewModels: (_ viewModels: [SearchResultViewModel]?) -> Void
    let presentRecommendationsViewController: (_ presenter: RecommendationsPresenter) -> Void
    let presentMixesViewController: (_ presenter: MixesPresenter) -> Void
    let showAddedToMix: () -> Void
    let becomeFirstResponder: () -> Void
}

final class SearchPresenter: Presenter {
    var baseViewHandler: BaseViewHandler?
    var searchViewHandler: SearchViewHandler?

    private var tracks: [Track]?
    private var audioFeatures = [AudioFeatures]()

    static let spotifyLoginPresenter = SpotifyLoginPresenter()

    private let networkService: NetworkService
    private let authenticationService: AuthenticationService

    init(networkService: NetworkService = ProductionNetworkService(),
         authenticationService: AuthenticationService = MixoAuthenticationService.shared) {
        self.networkService = networkService
        self.authenticationService = authenticationService
    }
    
    func didBindController() {
        testLogoutFirebase(false)
        testLogoutSpotify(false)

        searchViewHandler?.setViewModels([])
        searchViewHandler?.setSearchBarHandler( { [weak self] query in self?.performSearch(with: query) } )

        // baseViewHandler?.showStatus(.empty(title: "No results", description: "Please check your query or search again"), true)

        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously() { authenticationResult, error in
                guard let user = authenticationResult?.user else {
                    return
                }
                Firestore.firestore().collection("users").addDocument(data: ["id": user.uid,
                                                                             "uuid": UUID().uuidString,
                                                                             "createdAt": Timestamp(date: Date()),
                                                                             "device": UIDevice().name,
                                                                             "lastAction": Timestamp(date: Date())])
            }
        }

        SearchPresenter.spotifyLoginPresenter.completionHandler = { [weak self] in
            self?.baseViewHandler?.hideStatus(true)
        }

        if !authenticationService.isLoggedIn {
            searchViewHandler?.presentSpotifyLoginViewController(SearchPresenter.spotifyLoginPresenter)
        } else if authenticationService.tokenNeedsRefresh {
            baseViewHandler?.showStatus(.loading, true)
            SearchPresenter.spotifyLoginPresenter.updateSession()
        } else {
            searchViewHandler?.becomeFirstResponder()
        }
    }

    func prepareMixesPresenter() {
        let mixesPresenter = MixesPresenter(displayMode: .default)
        searchViewHandler?.presentMixesViewController(mixesPresenter)
    }
}

// MARK: - Private methods
extension SearchPresenter {
    private func performSearch(with query: String) {
        guard !query.isEmpty else {
            searchViewHandler?.setViewModels([])
            // baseViewHandler?.showStatus(.empty(title: "No results", description: "Please check your query or search again"), true)
            return
        }
        baseViewHandler?.hideStatus(true)
        searchViewHandler?.setViewModels(nil)

        networkService.requestDecodable(.search(query: query)) { (result: Result<SearchResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.tracks = response.items

                    if response.items.isEmpty {
                        self.searchViewHandler?.setViewModels([])
                        // self.baseViewHandler?.showStatus(.empty(title: "No results", description: "Please check your query or search again"), true)
                    } else {
                        self.baseViewHandler?.hideStatus(true)
                        self.loadFoundTracksFeatures(ids: response.items.map { $0.id }, tracks: response.items)
                    }
                    
                case .failure(let error):
                    self.baseViewHandler?.showMessage(.error, error.localizedDescription)
                }
            }
        }
    }
    
    private func loadFoundTracksFeatures(ids: [String], tracks: [Track]) {
        networkService.requestDecodable(.audioFeatures(ids: ids)) { (result: Result<AudioFeaturesResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    var searchResultViewModels = [SearchResultViewModel]()
                    self.audioFeatures = response.audioFeatures.compactMap({ $0 })
                    
                    for track in tracks {
                        guard let trackFeatures = self.audioFeatures.first(where: { $0.id == track.id }) else {
                            continue
                        }


                        var searchResultViewModel = SearchResultViewModel(with: track,
                                                                          key: Key(rawChord: trackFeatures.key, rawMode: trackFeatures.mode),
                                                                          tempo: trackFeatures.tempo,
                                                                          didSelectHandler: { [weak self] searchResultViewModel in
                                                                            self?.prepareRecommendationsPresenter(for: track)
                        })
                        searchResultViewModel.addToMixHandler = { [weak self] in self?.addTrackToMix(searchResultViewModel) }
                        searchResultViewModels.append(searchResultViewModel)
                    }

                    self.searchViewHandler?.setViewModels(searchResultViewModels)
                    
                case .failure(let error):
                    self.baseViewHandler?.showMessage(.error, error.localizedDescription)
                }
            }
        }
    }

    private func prepareRecommendationsPresenter(for track: Track) {
        var popularSearch = track
        popularSearch.timestamp = Timestamp(date: Date())
        let popularSearchData = try! FirestoreEncoder().encode(popularSearch)
        Firestore.firestore().collection("popularSearches").document().setData(popularSearchData)

        Firestore.firestore().collection("popularSearches").getDocuments { querySnapshot, error in
            guard var documents = querySnapshot?.documents else {
                return
            }
            if documents.count > 5 {
                documents.removeFirst(5)
                documents.forEach { $0.reference.delete() }
            }
        }

        // Prepare recommendations presenter
        guard let track = tracks?.first(where: { $0.id == track.id }) else {
            return
        }
        let recommendationsPresenter = RecommendationsPresenter(currentTrack: track, showBackToSearchButton: true)
        searchViewHandler?.presentRecommendationsViewController(recommendationsPresenter)
    }
    
    private func addTrackToMix(_ searchViewModel: SearchResultViewModel) {
        guard let track = tracks?.first(where: { $0.id == searchViewModel.trackId }),
              let audioFeatures = audioFeatures.first(where: { $0.id == searchViewModel.trackId }) else {
                return
        }
        let mixTrack = MixTrack(with: track, and: audioFeatures)
        searchViewHandler?.presentMixesViewController(MixesPresenter(displayMode: .add(track: mixTrack,
                                                                                       completionHandler: { [weak self] in
                                                                                           self?.updateLastAction()
                                                                                           self?.searchViewHandler?.showAddedToMix()
                                                                                           SwiftRater.check()
                                                                                       })))
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

    private func testLogoutFirebase(_ test: Bool) {
        if test {
            try! Auth.auth().signOut()
            authenticationService.removeAccountInfo()
        }
    }

    private func testLogoutSpotify(_ test: Bool) {
        if test {
            authenticationService.removeAccountInfo()
        }
    }
}

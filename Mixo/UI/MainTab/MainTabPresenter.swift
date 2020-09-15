//
//  MainTabPresenter.swift
//  Mixo
//
//  Created by Alexander Lisovik on 12.09.2020.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import Foundation

enum MainTab: Int, CaseIterable {
    case search
    case mixes

    var title: String {
        switch self {
        case .search:   return ""
        case .mixes:    return ""
        }
    }

    var icon: UIImage {
        switch self {
        case .search:   return UIImage(systemName: "magnifyingglass", withConfiguration: UIImage.SymbolConfiguration(weight: .heavy))!
        case .mixes:    return UIImage(systemName: "headphones", withConfiguration: UIImage.SymbolConfiguration(weight: .heavy))!
        }
    }

    var controller: UIViewController {
        switch self {
        case .search:   return SearchViewController(presenter: SearchPresenter())
        case .mixes:    return MixesViewController(presenter: MixesPresenter(displayMode: .default))
        }
    }
}

struct MainTabViewHandler {
    let setupTabs: (_ tabs: [MainTab]) -> Void
    let presentSpotifyLoginViewController: (_ presenter: SpotifyLoginPresenter) -> Void
    let showPlayerViewController: (_ presenter: PlayerPresenter) -> Void
}

final class MainTabPresenter: Presenter {
    var baseViewHandler: BaseViewHandler?
    var mainTabViewHandler: MainTabViewHandler?

    var spotifyLoginPresenter: SpotifyLoginPresenter?

    private let authenticationService: AuthenticationService

    init(authenticationService: AuthenticationService = MixoAuthenticationService.shared) {
        self.authenticationService = authenticationService
    }

    func didBindController() {
        // Setup tabs
        mainTabViewHandler?.setupTabs(MainTab.allCases)
        mainTabViewHandler?.showPlayerViewController(PlayerPresenter())

        if let spotifyLoginPresenter = spotifyLoginPresenter {
            if !authenticationService.isLoggedIn {
                mainTabViewHandler?.presentSpotifyLoginViewController(spotifyLoginPresenter)
            } else if authenticationService.tokenNeedsRefresh {
                baseViewHandler?.showStatus(.loading, true)
                spotifyLoginPresenter.updateSession { [weak self] in
                    self?.baseViewHandler?.hideStatus(true)
                }
            }
            return
        }
    }
}

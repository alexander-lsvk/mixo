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
    let presentPlayerViewController: (_ presenter: PlayerPresenter) -> Void
    let showPlayerContainer: (_ show: Bool) -> Void
}

final class MainTabPresenter: Presenter {
    var baseViewHandler: BaseViewHandler?
    var mainTabViewHandler: MainTabViewHandler?

    func didBindController() {
        // Setup tabs
        mainTabViewHandler?.setupTabs(MainTab.allCases)

        let playerPresenter = PlayerPresenter()
        playerPresenter.delegate = self
        mainTabViewHandler?.presentPlayerViewController(playerPresenter)
    }
}

// MARK: - PlayerVisibilityDelegate
extension MainTabPresenter: PlayerVisibilityDelegate {
    func showPlayer(_ show: Bool) {
        mainTabViewHandler?.showPlayerContainer(show)
    }
}

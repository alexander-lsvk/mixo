//
//  SpotifyPresenter.swift
//  Mixo
//
//  Created by Alexander on 02.05.2020.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import Foundation

final class SpotifyLoginViewController: BaseViewController<SpotifyLoginPresenter> {
    private let spotifyLoginView = SpotifyLoginView.loadViewFromXib()

    override func loadView() {
        view = spotifyLoginView
    }

    override func viewDidLoad() {
        presenter.spotifyLoginViewHandler = SpotifyLoginViewHandler(setTapLoginWithSpotifyButtonHandler: { [weak self] handler in
            self?.spotifyLoginView.setSpotifyLoginButtonHandler(handler)

        }, dismiss: { [weak self] in
            DispatchQueue.main.async {
                self?.dismiss(animated: true)
            }
        })

        super.viewDidLoad()
    }
}

//
//  PlayerViewController.swift
//  Mixo
//
//  Created by Alexander Lisovik on 12.09.2020.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import Foundation

final class PlayerViewController: BaseViewController<PlayerPresenter> {
    private let playerView = PlayerView.loadViewFromXib()

    override func loadView() {
        view = playerView
    }

    override func viewDidLoad() {
        presenter.playerViewHandler = PlayerViewHandler(setViewModel: { [weak self] viewModel in
            self?.playerView.update(with: viewModel)

        }, updatePlayButton: { [weak self] isPlaying in
            self?.playerView.updatePlayButton(isPlaying: isPlaying)
        })

        super.viewDidLoad()
    }
}

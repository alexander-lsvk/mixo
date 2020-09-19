//
//  PlayerViewController.swift
//  Mixo
//
//  Created by Alexander Lisovik on 12.09.2020.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import Foundation
import SwiftMessages
import StatusAlert

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

        }, showMixesViewController: { [weak self] presenter in
            let mixesViewController = MixesViewController(presenter: presenter)
            let swiftMessagesSegue = SwiftMessagesSegue(identifier: nil, source: self!, destination: mixesViewController)
            swiftMessagesSegue.configure(layout: .bottomCard)
            swiftMessagesSegue.perform()

        }, showAddedToMix: {
            let statusAlert = StatusAlert()
            if #available(iOS 13.0, *) {
                statusAlert.image = UIImage(systemName: "checkmark")
            }
            statusAlert.title = "Added to the mix"
            statusAlert.appearance.blurStyle = .extraLight
            statusAlert.alertShowingDuration = 1
            statusAlert.canBePickedOrDismissed = true

            statusAlert.showInKeyWindow()
        })

        super.viewDidLoad()
    }
}

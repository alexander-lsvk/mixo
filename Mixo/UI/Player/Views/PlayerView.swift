//
//  PlayerView.swift
//  Mixo
//
//  Created by Alexander Lisovik on 12.09.2020.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import UIKit

final class PlayerView: UIView, XibLoadable {
    @IBOutlet private var trackImageView: UIImageView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var artistLabel: UILabel!

    @IBOutlet private var playButton: UIButton!

    @IBAction private func didTapPlayButton() { didTapPlayButtonHandler?() }
    @IBAction private func didTapAddToMixButton() { didTapAddToMixButtonHandler?() }

    private var didTapPlayButtonHandler: (() -> Void)?
    private var didTapAddToMixButtonHandler: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        playButton.setImage(UIImage(systemName: "play.fill",
                                    withConfiguration: UIImage.SymbolConfiguration(weight: .bold))!, for: .normal)
    }

    func update(with viewModel: PlayerViewModel) {
        artistLabel.text = viewModel.artist
        nameLabel.text = viewModel.name
        trackImageView.kf.setImage(with: viewModel.imageUrl)

        didTapPlayButtonHandler = viewModel.didTapPlayButtonHandler
        didTapAddToMixButtonHandler = viewModel.didTapAddToMixButtonHandler
    }

    func updatePlayButton(isPlaying: Bool) {
        if isPlaying {
            playButton.setImage(UIImage(systemName: "pause.fill",
                                        withConfiguration: UIImage.SymbolConfiguration(weight: .bold))!, for: .normal)
        } else {
            playButton.setImage(UIImage(systemName: "play.fill",
                                        withConfiguration: UIImage.SymbolConfiguration(weight: .bold))!, for: .normal)
        }
    }
}

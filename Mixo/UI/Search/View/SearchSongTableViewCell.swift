//
//  SearchSongTableViewCell.swift
//  Mixo
//
//  Created by Alexander Lisovik on 28.05.19.
//  Copyright © 2019 Alexander Lisovik. All rights reserved.
//

import UIKit
import SkeletonView

final class SearchSongTableViewCell: UITableViewCell, XibLoadable, Reusable {
    @IBOutlet private var trackImageView: UIImageView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var artistsLabel: UILabel!
    @IBOutlet private var tempoLabel: UILabel!
    @IBOutlet private var keyLabel: UILabel!

    func update(with viewModel: SearchResultViewModel?) {
        showSkeletonLoading()

        guard let viewModel = viewModel else {
            return
        }
        hideSkeletonLoading()

        nameLabel.text = viewModel.name
        artistsLabel.text = viewModel.artist
        trackImageView.kf.setImage(with: viewModel.imageURL)
        tempoLabel.text = "🥁 \(Int(viewModel.tempo!))"

        if let key = viewModel.key {
            keyLabel.text = "🎹 \(key.chord?.description ?? "")\(key.mode?.description ?? "")"
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        trackImageView.image = nil
    }
}

// MARK: - Private methods
extension SearchSongTableViewCell {
    private func hideSkeletonLoading() {
        hideSkeleton(transition: .none)
    }

    private func showSkeletonLoading() {
        showAnimatedGradientSkeleton(transition: .none)
    }
}

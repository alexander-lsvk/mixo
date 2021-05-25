//
//  MixTableViewCell.swift
//  Mixo
//
//  Created by Alexander Lisovik on 1/11/20.
//  Copyright (c) 2020 Alexander Lisovik. All rights reserved.
//

import UIKit
import SwipeCellKit

final class MixTableViewCell: SwipeTableViewCell, XibLoadable, Reusable {
    @IBOutlet private var mixImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var numberOfTracksLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        showSkeletonLoading()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    func update(with viewModel: MixViewModel?) {
        guard let viewModel = viewModel else {
            return
        }
        hideSkeletonLoading()
        
        titleLabel.text = viewModel.name
        numberOfTracksLabel.text = "\(viewModel.numberOfTracks) tracks"
        mixImageView.kf.setImage(with: viewModel.imageUrl)
    }
}

// MARK: - Private methods
extension MixTableViewCell {
    private func hideSkeletonLoading() {
        hideSkeleton()
    }

    private func showSkeletonLoading() {
        showAnimatedGradientSkeleton(transition: .none)
    }
}

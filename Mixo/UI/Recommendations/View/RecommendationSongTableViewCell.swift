//
//  RecommendationSongTableViewCell.swift
//  Mixo
//
//  Created by Alexander Lisovik on 5/28/19.
//  Copyright © 2019 Alexander Lisovik. All rights reserved.
//

import UIKit
import AudioIndicatorBars
import Kingfisher

final class RecommendationSongTableViewCell: UITableViewCell, XibLoadable, Reusable {
    @IBOutlet private var mostHarmonicView: UIView!
    @IBOutlet private var trackImageView: UIImageView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var artistLabel: UILabel!
    @IBOutlet private var keyLabel: UILabel!
    @IBOutlet private var bpmLabel: UILabel!
    @IBOutlet private var audioIndicatorView: UIView!

    @IBAction private func didTapAddToMixButton() { addToMixHandler?() }
    @IBAction private func didTapShowRecommendationsButton() { showRecommendationsHandler?() }

    private var indicatorBarsView: AudioIndicatorBarsView?

    private var addToMixHandler: (() -> Void)?
    private var showRecommendationsHandler: (() -> Void)?

    override func awakeFromNib() {
        showSkeletonLoading()
        mostHarmonicView.layer.addShadow()
    }

    func update(with viewModel: RecommendationViewModel?) {
        guard let viewModel = viewModel else {
            return
        }
        hideSkeletonLoading()

        artistLabel.text = viewModel.artist
        nameLabel.text = viewModel.name
        trackImageView.kf.setImage(with: viewModel.imageURL)
        bpmLabel.text = "🥁 \(Int(viewModel.tempo))"
        mostHarmonicView.isHidden = !viewModel.isMostHarmonic

        if let key = viewModel.key {
            keyLabel.text = "🎹 \(key.chord?.description ?? "")\(key.mode?.description ?? "")"
        }

        addToMixHandler = viewModel.addToMixHandler
        showRecommendationsHandler = viewModel.showRecommendationsHandler

        setPlayingStatus(viewModel.isPlaying)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        trackImageView.image = nil
    }
}


// MARK: - Private methods
extension RecommendationSongTableViewCell {
    private func hideSkeletonLoading() {
        hideSkeleton(transition: .none)
    }

    private func showSkeletonLoading() {
        showAnimatedGradientSkeleton(transition: .none)
    }

    private func setPlayingStatus(_ playing: Bool) {
        if playing {
            indicatorBarsView = AudioIndicatorBarsView(audioIndicatorView.frame, 4, 1.0, UIColor(red: 35.0 / 255.0, green: 37.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0))
            guard let indicatorBarsView = indicatorBarsView else {
                return
            }
            audioIndicatorView.addSubview(indicatorBarsView, with: equalToSuperview())
            audioIndicatorView.isHidden = false
            indicatorBarsView.start()
        } else {
            audioIndicatorView.isHidden = true
            indicatorBarsView?.stop()
            indicatorBarsView?.removeFromSuperview()
            indicatorBarsView = nil
        }
    }
}

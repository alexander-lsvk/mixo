//
//  TrackTableViewCell.swift
//  Mixo
//
//  Created by Alexander Lisovik on 5/28/19.
//  Copyright © 2019 Alexander Lisovik. All rights reserved.
//

import UIKit
import Kingfisher
import SwipeCellKit

final class TrackTableViewCell: SwipeTableViewCell, XibLoadable, Reusable {
    @IBOutlet private var mostHarmonicView: UIView!
    @IBOutlet private var trackImageView: UIImageView!
    @IBOutlet private var blurView: UIVisualEffectView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var artistLabel: UILabel!
    @IBOutlet private var keyLabel: UILabel!
    @IBOutlet private var bpmLabel: UILabel!
    @IBOutlet private var audioIndicatorView: UIView!
    @IBOutlet private var showRecommendationsButton: UIButton!
    @IBOutlet private var addTrackToMixButton: UIButton!
    
    @IBAction private func didTapAddToMixButton() { addToMixHandler?() }
    @IBAction private func didTapShowRecommendationsButton() { showRecommendationsHandler?() }

    private var indicatorBarsView: AudioIndicatorBarsView?

    private var addToMixHandler: (() -> Void)?
    private var showRecommendationsHandler: (() -> Void)?

    override func awakeFromNib() {
        showSkeletonLoading()
        mostHarmonicView.layer.addShadow()
        blurView.effect = nil
    }

    func update(with viewModel: TrackViewModel?) {
        guard var viewModel = viewModel else {
            return
        }
        hideSkeletonLoading()
        
        switch viewModel.place {
        case .search:           showRecommendationsButton.isHidden = true
        case .mixDetails:       addTrackToMixButton.isHidden = true
        case .recommendations:  break
        }

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

        viewModel.updateIsPlayingHandler = { [weak self] isPlaying in
            self?.setPlayingStatus(isPlaying)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        trackImageView.image = nil
    }
}


// MARK: - Private methods
extension TrackTableViewCell {
    private func hideSkeletonLoading() {
        hideSkeleton(transition: .none)
    }

    private func showSkeletonLoading() {
        showAnimatedGradientSkeleton(transition: .none)
    }

    private func setPlayingStatus(_ playing: Bool) {
        if playing {
            indicatorBarsView = AudioIndicatorBarsView(audioIndicatorView.frame, 4, 1.0, .white)
            guard let indicatorBarsView = indicatorBarsView else {
                return
            }

            audioIndicatorView.addSubview(indicatorBarsView, with: equalToSuperview())
            audioIndicatorView.isHidden = false

            indicatorBarsView.start()

            blurView.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.blurView.effect = UIBlurEffect(style: UIBlurEffect.Style.regular)
            }
        } else {
            guard blurView.effect != nil else {
                hidePlayingIndicators()
                return
            }

            UIView.animate(withDuration: 0.2, animations: {
                self.blurView.effect = nil
            }, completion: { _ in
                self.blurView.isHidden = true
                self.hidePlayingIndicators()
            })
        }
    }

    private func hidePlayingIndicators() {
        audioIndicatorView.isHidden = true
        indicatorBarsView?.stop()
        indicatorBarsView?.removeFromSuperview()
        indicatorBarsView = nil
    }
}

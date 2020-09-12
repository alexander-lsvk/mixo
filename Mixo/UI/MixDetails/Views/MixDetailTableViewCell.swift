//
//  MixDetailTableViewCell.swift
//  Mixo
//
//  Created by Alexander Lisovik on 1/13/20.
//  Copyright (c) 2020 Alexander Lisovik. All rights reserved.
//

import UIKit
import AudioIndicatorBars
import SwipeCellKit

final class MixDetailTableViewCell: SwipeTableViewCell, XibLoadable, Reusable {
    @IBOutlet var trackImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var artistLabel: UILabel!
    @IBOutlet var keyLabel: UILabel!
    @IBOutlet var bpmLabel: UILabel!
    @IBOutlet private var audioIndicatorView: UIView!

    @IBAction private func didTapShowRecommendationsButton() { showRecommendationsHandler?() }

    private var indicatorBarsView: AudioIndicatorBarsView?

    private var showRecommendationsHandler: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func update(with viewModel: MixDetailViewModel) {
        artistLabel.text = viewModel.artist
        nameLabel.text = viewModel.name
        trackImageView.kf.setImage(with: viewModel.imageURL)
        bpmLabel.text = "🥁 \(Int(viewModel.tempo!))"

        if let key = viewModel.key {
            keyLabel.text = "🎹 \(key.chord?.description ?? "")\(key.mode?.description ?? "")"
        }

        showRecommendationsHandler = viewModel.showRecommendationsHandler

        setPlayingStatus(viewModel.isPlaying)
    }
}

extension MixDetailTableViewCell {
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

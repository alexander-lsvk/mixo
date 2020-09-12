//
//  SpotifyLoginView.swift
//  Mixo
//
//  Created by Alexander on 02.05.2020.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import Foundation

final class SpotifyLoginView: UIView, XibLoadable {
    @IBOutlet private var spotifyLoginButton: UIButton!

    private var tapSpotifyLoginButtonHandler: (() -> Void)?

    @IBAction private func didTapSpotifyLoginButton() { tapSpotifyLoginButtonHandler?() }

    override func awakeFromNib() {
        super.awakeFromNib()

        spotifyLoginButton.layer.addShadow(color: UIColor(red: 30.0/255.0, green: 215.0/255.0, blue: 96.0/255.0, alpha: 1.0), radius: 6.0, opacity: 0.3)
    }

    func setSpotifyLoginButtonHandler(_ handler: @escaping () -> Void) {
        tapSpotifyLoginButtonHandler = handler
    }
}

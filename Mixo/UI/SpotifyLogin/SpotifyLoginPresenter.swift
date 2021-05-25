//
//  SpotifyLoginPresenter.swift
//  Mixo
//
//  Created by Alexander on 02.05.2020.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

import Foundation

struct SpotifyLoginViewHandler {
    let setTapLoginWithSpotifyButtonHandler: ((_ tapLoginWithSpotifyButtonHandler: @escaping () -> Void) -> Void)
    let dismiss: () -> Void
}

final class SpotifyLoginPresenter: NSObject, Presenter {
    var baseViewHandler: BaseViewHandler?
    var spotifyLoginViewHandler: SpotifyLoginViewHandler?

    private let spotifyClientId = "f91212eed9d64dc4abf66c2a83857c94"
    private let spotifyRedirectUrl = URL(string: "mixo://")!

    private let authenticationService: AuthenticationService

    var completionHandler: (() -> Void)?

    lazy private var configuration = SPTConfiguration(
        clientID: spotifyClientId,
        redirectURL: spotifyRedirectUrl
    )

    lazy private var sessionManager: SPTSessionManager = {
        configuration.tokenSwapURL = URL(string: "https://mixoapp.herokuapp.com/api/token")
        configuration.tokenRefreshURL = URL(string: "https://mixoapp.herokuapp.com/api/refresh_token")

        let manager = SPTSessionManager(configuration: self.configuration, delegate: self)
        return manager
    }()

    init(authenticationService: AuthenticationService = MixoAuthenticationService.shared) {
        self.authenticationService = authenticationService
    }

    func didBindController() {
        spotifyLoginViewHandler?.setTapLoginWithSpotifyButtonHandler({ [weak self] in
            guard let self = self else {
                return
            }
            self.baseViewHandler?.showStatus(.loading, true)

            let requestedScopes: SPTScope = [.streaming]

            self.sessionManager.initiateSession(with: requestedScopes, options: .default)
        })
    }

    func updateSession() {
        sessionManager.session = authenticationService.spotifySession
        sessionManager.renewSession()
    }

    func open(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) {
        sessionManager.application(app, open: url, options: options)
    }
}

extension SpotifyLoginPresenter: SPTSessionManagerDelegate {
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        let token = Token(token: session.accessToken, refreshToken: session.refreshToken, expirationDate: session.expirationDate)

        authenticationService.storeTokenInfo(token)
        authenticationService.storeSpotifySession(session)

        spotifyLoginViewHandler?.dismiss()
        baseViewHandler?.hideStatus(true)
        completionHandler?()
    }

    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        baseViewHandler?.hideStatus(true)
    }

    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        let token = Token(token: session.accessToken, refreshToken: session.refreshToken, expirationDate: session.expirationDate)

        authenticationService.storeTokenInfo(token)
        authenticationService.storeSpotifySession(session)

        completionHandler?()
    }
}

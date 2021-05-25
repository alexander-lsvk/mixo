//
//  AuthenticationService.swift
//  Mixo
//
//  Created by Alexander Lisovik on 5/22/19.
//  Copyright © 2019 Alexander Lisovik. All rights reserved.
//

import Foundation
import KeychainSwift

struct Token: Codable {
    let token: String
    let refreshToken: String
    let expirationDate: Date
}

protocol AuthenticationService {
    var tokenInfo: Token? { get }
    var spotifySession: SPTSession? { get }
    var isLoggedIn: Bool { get }
    var tokenNeedsRefresh: Bool { get }

    func storeTokenInfo(_ tokenInfo: Token)
    func storeSpotifySession(_ spotifySession: SPTSession)
    func removeAccountInfo()
}

final class MixoAuthenticationService: AuthenticationService {
    private let keychain = KeychainSwift()
    private let storageService: StorageService

    private(set) var tokenInfo: Token? {
        didSet {
            storageService.storeValue(tokenInfo, for: MixoAuthenticationService.tokenInfoKey)
        }
    }

    private(set) var spotifySession: SPTSession? {
        didSet {
            if let spotifySession = spotifySession,
               let spotifySessionData = try? NSKeyedArchiver.archivedData(withRootObject: spotifySession, requiringSecureCoding: false) {
                keychain.set(spotifySessionData, forKey: MixoAuthenticationService.spotifySessionKey)
            }
        }
    }

    var tokenNeedsRefresh: Bool {
        guard let tokenInfo = tokenInfo else {
            return false
        }
        return !(Date() < tokenInfo.expirationDate)
    }

    var isLoggedIn: Bool {
        return !(tokenInfo == nil)
    }

    static let shared = MixoAuthenticationService()

    private static let tokenInfoKey = "mixo.tokenInfo"
    private static let spotifySessionKey = "mixo.spotifySession"

    init(storageService: StorageService = SecuredStorageService()) {
        self.storageService = storageService

        self.tokenInfo = storageService.retrieveValue(for: MixoAuthenticationService.tokenInfoKey)

        if let spotifySessionData = keychain.getData(MixoAuthenticationService.spotifySessionKey) {
            do {
                self.spotifySession = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(spotifySessionData) as? SPTSession
            } catch {
                print(error)
            }
        }
    }

    func storeTokenInfo(_ tokenInfo: Token) {
        self.tokenInfo = tokenInfo
    }

    func storeSpotifySession(_ spotifySession: SPTSession) {
        self.spotifySession = spotifySession
    }

    func removeAccountInfo() {
        MixoAuthenticationService.shared.tokenInfo = nil

        storageService.removeValue(for: MixoAuthenticationService.tokenInfoKey)
        storageService.removeValue(for: MixoAuthenticationService.spotifySessionKey)
    }
}

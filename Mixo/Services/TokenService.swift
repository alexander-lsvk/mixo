//
//  TokenService.swift
//  Mixo
//
//  Created by Alexander on 14.04.2020.
//  Copyright © 2020 Alexander Lisovik. All rights reserved.
//

final class TokenService {
    static let shared = TokenService()

    init() {}

    var accessToken: String?
}

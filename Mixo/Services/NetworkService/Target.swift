//
//  Target.swift
//  Mixo
//
//  Created by Alexander Lisovik on 5/22/19.
//  Copyright © 2019 Alexander Lisovik. All rights reserved.
//

import Foundation
import Moya

enum Target {
    case search(query: String)
    case recommendations(seedArtists: String, seedTracks: String, targetKey: Int, targetMode: Int, targetTempo: Float)
    case audioFeatures(ids: [String])
    case tracks(id: String)
}

extension Target: TargetType {
    var baseURL: URL { return URL(string: "https://api.spotify.com/v1")! }
    
    var path: String {
        switch self {
        case .search:
            return "/search"
        case .recommendations:
            return "/recommendations"
        case .audioFeatures:
            return "/audio-features"
        case .tracks(let id):
            return "/tracks/\(id)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .search, .recommendations, .audioFeatures, .tracks:
            return .get
        }
    }
    
    var task: Task {
        let token = MixoAuthenticationService.shared.tokenInfo?.token

        switch self {
        case .search(let query):
            var parameters = [String: Any]()
            parameters["access_token"] = token
            parameters["query"] = query
            parameters["type"] = "track"
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)

        case .recommendations(let seedArtists, let seedTracks, let targetKey, let targetMode, let targetTempo):
            var parameters = [String: Any]()
            parameters["access_token"] = token
            parameters["seed_artists"] = seedArtists
            parameters["seed_tracks"] = seedTracks
            parameters["target_key"] = targetKey
            parameters["target_mode"] = targetMode
            parameters["min_tempo"] = targetTempo - 7.0
            parameters["max_tempo"] = targetTempo + 7.0
            parameters["limit"] = 100
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
            
        case .audioFeatures(let ids):
            var parameters = [String: Any]()
            parameters["ids"] = ids.joined(separator: ",")
            parameters["access_token"] = token
            
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        
        case .tracks:
            var parameters = [String: Any]()
            parameters["access_token"] = token
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }
    
    var sampleData: Data {
        switch self {
        case .search, .recommendations, .audioFeatures, .tracks:
            return Data("{}".utf8)
        }
    }
    
    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}


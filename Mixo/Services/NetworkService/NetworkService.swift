//
//  NetworkService.swift
//  Mixo
//
//  Created by Alexander Lisovik on 5/22/19.
//  Copyright © 2019 Alexander Lisovik. All rights reserved.
//

import Foundation
import FirebaseFirestore
import CodableFirebase
import Moya

public typealias DecodableCompletion<D: Decodable> = (_ result: Result<D, Error>) -> Void

protocol NetworkService {
    func requestDecodable<D: Decodable>(_ target: Target, completion: @escaping DecodableCompletion<D>)
}

enum NetworkError: Error {
    case underlying(Error, Response)
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .underlying(_, response):  return try? response.map(ErrorResponse.self).message
        }
    }
}

struct ProductionNetworkService: NetworkService {
    let provider = MoyaProvider<Target>()
    
    init() {}
    
    func requestDecodable<D>(_ target: Target, completion: @escaping (Result<D, Error>) -> Void) where D : Decodable {
        provider.request(target) { result in
            switch result {
            case .success(let response):
                print("\n--> Request: \(response.request!)")
                print("\n<-- Response: \(String(data: response.data, encoding: .utf8) ?? "")\n *")
                do {
                    let filteredResponse = try response.filterSuccessfulStatusCodes()
                    let model = try filteredResponse.map(D.self)
                    completion(.success(model))
                } catch {
                    completion(.failure(NetworkError.underlying(error, response)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension Timestamp: TimestampType {}


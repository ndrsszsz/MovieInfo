//
//  APIClient.swift
//  MovieInfo
//
//  Created by Andras Szasz on 2025. 09. 28..
//


import Foundation
import Combine

class APIClient {
    static let shared = APIClient(config: TMDBConfig())
    
    private let config: APIConfig
    
    init(config: APIConfig) {
        self.config = config
    }

    private var headers: [String: String] {
        [
            "Authorization": "Bearer \(config.accessToken)",
            "Content-Type": "application/json;charset=utf-8"
        ]
    }
    
    func requestPublisher<T: Decodable>(_ path: String, params: [String: String]) -> AnyPublisher<T, Error> {
        guard var components = URLComponents(string: config.baseURL + path) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }

        components.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }

        guard let url = components.url else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.addValue("Bearer \(config.accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")

        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

protocol APIConfig {
    var apiKey: String { get }
    var accessToken: String { get }
    var baseURL: String { get }
}

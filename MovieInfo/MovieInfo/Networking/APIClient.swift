//
//  APIClient.swift
//  MovieInfo
//
//  Created by Andras Szasz on 2025. 09. 28..
//


import Foundation
import Combine

class APIClient {
    static let shared = APIClient()

    private var headers: [String: String] {
        [
            "Authorization": "Bearer \(TMDBConfig.accessToken)",
            "Content-Type": "application/json;charset=utf-8"
        ]
    }
    
    func requestPublisher<T: Decodable>(_ path: String, params: [String: String]) -> AnyPublisher<T, Error> {
        var components = URLComponents(string: "https://api.themoviedb.org/3\(path)")!
        components.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }

        var request = URLRequest(url: components.url!)
        request.addValue("Bearer \(TMDBConfig.accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")

        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

//
//  APIClient.swift
//  MovieInfo
//
//  Created by Andras Szasz on 2025. 09. 28..
//


import Foundation
import Combine

// MARK: APIConfig

protocol APIConfig {
    var apiKey: String { get }
    var accessToken: String { get }
    var baseURL: String { get }
}

// MARK: APIClientProtocol

protocol APIClientProtocol {
    func requestPublisher<T: Decodable>(_ path: String, params: [String: String]) -> AnyPublisher<T, Error>
    func loadImageData(from url: URL) -> AnyPublisher<Data, Error>
}

// MARK: APIClient

final class APIClient: APIClientProtocol {
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

    // MARK: JSON Request

    func requestPublisher<T: Decodable>(_ path: String, params: [String: String]) -> AnyPublisher<T, Error> {
        guard var components = URLComponents(string: config.baseURL + path) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        components.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }

        guard let url = components.url else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { result in
                guard let httpResponse = result.response as? HTTPURLResponse,
                      200..<300 ~= httpResponse.statusCode else {
                    throw URLError(.badServerResponse)
                }
                return result.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    // MARK: Image Request

    func loadImageData(from url: URL) -> AnyPublisher<Data, Error> {
        let request = URLRequest(url: url)

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { result in
                guard let httpResponse = result.response as? HTTPURLResponse,
                      200..<300 ~= httpResponse.statusCode else {
                    throw URLError(.badServerResponse)
                }
                return result.data
            }
            .eraseToAnyPublisher()
    }
}

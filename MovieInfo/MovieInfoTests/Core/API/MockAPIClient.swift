//
//  MockAPIClient.swift
//  MovieInfo
//
//  Created by Andras Szasz on 2025. 09. 28..
//


import Foundation
import Combine
@testable import MovieInfo

final class MockAPIClient: APIClientProtocol {
    var mockResponse: Any?
    var mockError: Error?

    // MARK: JSON request

    func requestPublisher<T: Decodable>(_ path: String, params: [String: String]) -> AnyPublisher<T, Error> {
        if let error = mockError {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }

        if let response = mockResponse as? T {
            return Just(response)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: URLError(.badServerResponse))
                .eraseToAnyPublisher()
        }
    }

    // MARK: Image data request

    func loadImageData(from url: URL) -> AnyPublisher<Data, Error> {
        if let error = mockError {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }

        if let data = mockResponse as? Data {
            return Just(data)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: URLError(.badServerResponse))
                .eraseToAnyPublisher()
        }
    }
}

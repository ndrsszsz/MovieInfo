//
//  APIClientTests.swift
//  MovieInfoTests
//
//  Created by Andras Szasz on 2025. 09. 28..
//

import XCTest
import Combine
@testable import MovieInfo

final class APIClientTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    struct TestConfig: APIConfig {
        var apiKey: String = "FAKE_API_KEY"
        var accessToken: String = "FAKE_ACCESS_TOKEN"
        var baseURL: String = "https://jsonplaceholder.typicode.com"
    }

    struct FakeResponse: Codable, Equatable {
        let userId: Int
        let id: Int
        let title: String
        let body: String
    }

    func testSuccessfulResponse() {
        let expectation = XCTestExpectation(description: "Successfully fetch and decode response")

        let client = APIClient(config: TestConfig())

        client.requestPublisher("/posts/1", params: [:])
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Request failed with error: \(error)")
                }
            }, receiveValue: { (response: FakeResponse) in
                XCTAssertEqual(response.id, 1)
                expectation.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5)
    }

    func testBadURLHandling() {
        let badClient = APIClient(config: BadURLConfig())

        let expectation = XCTestExpectation(description: "Should fail with badURL")

        badClient.requestPublisher("/invalid path", params: [:])
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTAssertNotNil(error)
                    expectation.fulfill()
                }
            }, receiveValue: { (_: FakeResponse) in
                XCTFail("Expected failure, got value")
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 3)
    }

    struct BadURLConfig: APIConfig {
        var apiKey: String = ""
        var accessToken: String = ""
        var baseURL: String = "INVALID_URL"
    }
}


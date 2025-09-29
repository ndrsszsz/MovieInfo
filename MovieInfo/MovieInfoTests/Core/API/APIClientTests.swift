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

    // MARK: Test configs

    struct TestConfig: APIConfig {
        var apiKey: String = "FAKE_API_KEY"
        var accessToken: String = "FAKE_ACCESS_TOKEN"
        var baseURL: String = "https://jsonplaceholder.typicode.com"
    }

    struct BadURLConfig: APIConfig {
        var apiKey: String = ""
        var accessToken: String = ""
        var baseURL: String = "INVALID_URL"
    }

    // MARK: Mock models

    struct FakeResponse: Codable, Equatable {
        let userId: Int
        let id: Int
        let title: String
        let body: String
    }

    // MARK: Tests

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

    func testLoadImageDataSuccess() {
        let expectation = XCTestExpectation(description: "Successfully load image data")

        guard let url = URL(string: "https://httpbin.org/image/png") else {
            XCTFail("Invalid image URL")
            return
        }

        let client = APIClient(config: TestConfig())

        client.loadImageData(from: url)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Image loading failed: \(error)")
                }
            }, receiveValue: { data in
                XCTAssertFalse(data.isEmpty, "Expected non-empty image data")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5)
    }

    func testLoadImageDataFailure() {
        let expectation = XCTestExpectation(description: "Should fail to load image data")

        // Invalid URL that should 404 or not resolve
        guard let url = URL(string: "https://invalid.domain/image.png") else {
            XCTFail("Invalid test URL")
            return
        }

        let client = APIClient(config: TestConfig())

        client.loadImageData(from: url)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("Expected failure, got finished")
                case .failure(let error):
                    XCTAssertNotNil(error)
                    expectation.fulfill()
                }
            }, receiveValue: { _ in
                XCTFail("Expected failure, got value")
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5)
    }
}

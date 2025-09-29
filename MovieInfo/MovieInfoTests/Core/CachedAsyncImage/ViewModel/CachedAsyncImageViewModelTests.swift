//
//  CachedAsyncImageViewModelTests.swift
//  MovieInfo
//
//  Created by Andras Szasz on 2025. 09. 29..
//


import XCTest
import Combine
import UIKit
@testable import MovieInfo

final class CachedAsyncImageViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    // MARK: Helpers

    private func makeSampleImageData() -> Data {
        let image = UIImage(systemName: "star")!
        return image.pngData()!
    }

    private func makeMockClientWithImage(success: Bool) -> MockAPIClient {
        let mockClient = MockAPIClient()
        if success {
            mockClient.mockResponse = makeSampleImageData()
        } else {
            mockClient.mockError = URLError(.notConnectedToInternet)
        }
        return mockClient
    }

    // MARK: Tests

    func testSuccessfulImageLoad() {
        let url = URL(string: "https://example.com/image.png")!
        let mockClient = makeMockClientWithImage(success: true)

        let viewModel = CachedAsyncImageViewModel(url: url, apiClient: mockClient)

        let expectation = XCTestExpectation(description: "Loads image successfully")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertNotNil(viewModel.uiImage)
            XCTAssertFalse(viewModel.didFail)
            XCTAssertFalse(viewModel.isLoading)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testImageLoadFailure() {
        let url = URL(string: "https://example.com/image.png")!
        ImageCache.shared.clear()

        let mockClient = makeMockClientWithImage(success: false)
        let viewModel = CachedAsyncImageViewModel(url: url, apiClient: mockClient)

        let expectation = XCTestExpectation(description: "Handles image loading failure")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertNil(viewModel.uiImage)
            XCTAssertTrue(viewModel.didFail, "Expected didFail to be true")
            XCTAssertFalse(viewModel.isLoading, "Expected isLoading to be false")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testNilURLSkipsLoading() {
        let viewModel = CachedAsyncImageViewModel(url: nil, apiClient: MockAPIClient())

        XCTAssertNil(viewModel.uiImage)
        XCTAssertTrue(viewModel.didFail)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testCachedImageIsUsed() {
        let url = URL(string: "https://example.com/image.png")!
        let image = UIImage(systemName: "star")!
        ImageCache.shared.setImage(image, for: url)

        let mockClient = MockAPIClient()
        mockClient.mockError = URLError(.notConnectedToInternet) // Should not be called

        let viewModel = CachedAsyncImageViewModel(url: url, apiClient: mockClient)

        let expectation = XCTestExpectation(description: "Uses cached image")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertEqual(viewModel.uiImage?.pngData(), image.pngData())
            XCTAssertFalse(viewModel.didFail)
            XCTAssertFalse(viewModel.isLoading)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }
}

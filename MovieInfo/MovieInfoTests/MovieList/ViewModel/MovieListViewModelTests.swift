//
//  MovieListViewModelTests.swift
//  MovieInfo
//
//  Created by Andras Szasz on 2025. 09. 28..
//


import XCTest
import Combine
@testable import MovieInfo

@MainActor
final class MovieListViewModelTests: XCTestCase {

    var cancellables: Set<AnyCancellable> = []

    func testFetchNextPageSuccess() async throws {
        // Prepare mock data
        let movies = [
            Movie(id: 1, title: "Movie 1", posterPath: "/path1.jpg"),
            Movie(id: 2, title: "Movie 2", posterPath: "/path2.jpg")
        ]
        let mockResponse = MovieResponse(page: 1, results: movies, totalPages: 1, totalResults: 2)

        let mockAPIClient = MockAPIClient()
        mockAPIClient.mockResponse = mockResponse

        // Create ViewModel with mock client
        let viewModel = MovieListViewModel(genreId: 28, apiClient: mockAPIClient)

        // Initially loading should be true because init triggers fetchNextPage()
        XCTAssertTrue(viewModel.isLoading)

        // Wait until loading finishes (observe isLoading changes)
        try await waitForLoadingToFinish(viewModel: viewModel)

        // Assert movies loaded correctly
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.movies.count, movies.count)
        XCTAssertEqual(viewModel.totalPages, 1)
    }

    func testFetchNextPageFailure() async throws {
        let mockAPIClient = MockAPIClient()
        mockAPIClient.mockError = URLError(.notConnectedToInternet)

        let viewModel = MovieListViewModel(genreId: 28, apiClient: mockAPIClient)

        XCTAssertTrue(viewModel.isLoading)

        try await waitForLoadingToFinish(viewModel: viewModel)

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.movies.count, 0)
    }

    // Helper function to wait until loading finishes
    private func waitForLoadingToFinish(viewModel: MovieListViewModel) async throws {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = viewModel.$isLoading
                .dropFirst() // ignore initial value
                .sink { isLoading in
                    if !isLoading {
                        cancellable?.cancel()
                        continuation.resume()
                    }
                }
        }
    }
}

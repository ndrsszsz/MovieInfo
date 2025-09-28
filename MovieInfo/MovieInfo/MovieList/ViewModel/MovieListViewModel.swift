//
//  MoviesViewModel.swift
//  MovieInfo
//
//  Created by Andras Szasz on 2025. 09. 28..
//


import Foundation
import Combine

@MainActor
class MovieListViewModel: ObservableObject {
    
    // MARK: Outputs

    @Published private(set) var movies: [Movie] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    // MARK: Privates

    private(set) var totalPages = 1
    private var currentPage = 1
    private let genreId: Int
    private var subscriptions = Set<AnyCancellable>()

    // Subject to trigger fetching next page
    private let fetchNextPageSubject = PassthroughSubject<Void, Never>()
    
    private let apiClient: APIClientProtocol

    // MARK: Init

    init(genreId: Int, apiClient: APIClientProtocol = APIClient.shared) {
        self.genreId = genreId
        self.apiClient = apiClient
        setupBindings()
        fetchNextPage()
    }

    // MARK: Methods

    private func setupBindings() {
        fetchNextPageSubject
            .filter { [weak self] in
                guard let self = self else { return false }
                return !self.isLoading && self.currentPage <= self.totalPages
            }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isLoading = true
                self?.errorMessage = nil
            })
            .flatMap { [weak self] _ -> AnyPublisher<MovieResponse, Error> in
                guard let self = self else {
                    return Fail(error: URLError(.badServerResponse))
                        .eraseToAnyPublisher()
                }

                let params: [String: String] = [
                    "with_genres": "\(self.genreId)",
                    "page": "\(self.currentPage)"
                ]

                return apiClient
                    .requestPublisher("/discover/movie", params: params)
                    .retry(2)  // Retry up to 2 times on failure
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("Movies fetch failed:", error.localizedDescription)
                case .finished:
                    break
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                self.movies = self.movies.appendingUnique(response.results)
                self.totalPages = response.totalPages
                self.currentPage += 1
                print("Fetched \(response.results.count) movies. Total pages: \(self.totalPages)")
                self.isLoading = false
            }
            .store(in: &subscriptions)
    }

    // MARK: Public interface

    func fetchNextPage() {
        fetchNextPageSubject.send(())
    }

    func reset() {
        movies = []
        currentPage = 1
        totalPages = 1
        errorMessage = nil
    }
}

//
//  GenreViewModel.swift
//  MovieInfo
//
//  Created by Andras Szasz on 2025. 09. 28..
//


import Foundation
import CoreData
import Combine

@MainActor
class GenreViewModel: ObservableObject {
    @Published private(set) var genres: [Genre] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    private let cache = GenreCoreDataCache.shared
    private var cancellables = Set<AnyCancellable>()

    private let fetchTrigger = PassthroughSubject<NSManagedObjectContext, Never>()
    private var lastFetched: Date?

    init() {
        setupBindings()
    }

    private func setupBindings() {
        fetchTrigger
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isLoading = true
                self?.errorMessage = nil
            })
            .flatMap { [weak self] context -> AnyPublisher<[Genre], Error> in
                guard let self = self else {
                    return Fail(error: URLError(.unknown)).eraseToAnyPublisher()
                }

                if let cached = self.cache.loadGenres(from: context) {
                    if let lastFetched = self.lastFetched,
                       Date().timeIntervalSince(lastFetched) < 3600 {
                        return Just(cached)
                            .setFailureType(to: Error.self)
                            .eraseToAnyPublisher()
                    } else {
                        self.lastFetched = Date()
                        return Just(cached)
                            .setFailureType(to: Error.self)
                            .eraseToAnyPublisher()
                    }
                }

                return APIClient.shared
                    .requestPublisher("/genre/movie/list", params: ["language": "en"])
                    .map(\GenreResponse.genres)
                    .handleEvents(receiveOutput: { genres in
                        self.cache.saveGenres(genres, in: context)
                        self.lastFetched = Date()
                    })
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] genres in
                self?.genres = genres
            }
            .store(in: &cancellables)
    }

    func fetchGenres(context: NSManagedObjectContext) {
        guard !isLoading else { return }
        fetchTrigger.send(context)
    }
}

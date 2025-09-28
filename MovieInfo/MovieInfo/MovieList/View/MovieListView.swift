//
//  MoviesGridView.swift
//  MovieInfo
//
//  Created by Andras Szasz on 2025. 09. 28..
//


import SwiftUI

struct MovieListView: View {
    let genre: Genre
    @StateObject var viewModel: MovieListViewModel

    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    // MARK: Privates

    private var isTV: Bool {
        #if os(tvOS)
        true
        #else
        false
        #endif
    }

    private var columns: [GridItem] {
        let count: Int

        if isTV {
            count = 6
        } else if horizontalSizeClass == .compact {
            count = 2
        } else {
            count = 4
        }

        return Array(repeating: GridItem(.flexible()), count: count)
    }
    
    // MARK: Init
    
    init(genre: Genre) {
        self.genre = genre
        _viewModel = StateObject(wrappedValue: MovieListViewModel(genreId: genre.id))
    }

    // MARK: Body

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: .spacings.grid) {
                ForEach(viewModel.movies, id: \.id) { movie in
                    MovieCardView(movie: movie, isTV: isTV)
                        .id(movie.id)
                        .onAppear {
                            triggerPaginationIfNeeded(currentMovie: movie)
                        }
                }

                if viewModel.isLoading {
                    CustomSpinnerView()
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .padding()
            .animation(.default, value: viewModel.movies)
        }
        .navigationTitle(genre.name)
        .disabled(viewModel.isLoading && viewModel.movies.isEmpty)
        .overlay {
            LoadingOverlayView(
                isLoading: viewModel.isLoading,
                hasMovies: !viewModel.movies.isEmpty,
                errorMessage: viewModel.movies.isEmpty ? viewModel.errorMessage : nil,
                onRetry: {
                    viewModel.reset()
                    viewModel.fetchNextPage()
                }
            )
        }
        .task {
            if viewModel.movies.isEmpty && !viewModel.isLoading {
                viewModel.fetchNextPage()
            }
        }
    }

    // MARK: Methods

    private func triggerPaginationIfNeeded(currentMovie: Movie) {
        guard !viewModel.isLoading else { return }

        // Start prefetching early to improve scrolling experience
        if let index = viewModel.movies.firstIndex(of: currentMovie),
           index >= viewModel.movies.count - 20 {
            viewModel.fetchNextPage()
        }
    }
}

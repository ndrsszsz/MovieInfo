//
//  MoviesGridView.swift
//  MovieInfo
//
//  Created by Andras Szasz on 2025. 09. 28..
//


import SwiftUI

struct MoviesGridView: View {
    let genre: Genre
    @ObservedObject var viewModel: MoviesViewModel

    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var isTV: Bool {
        #if os(tvOS)
        true
        #else
        false
        #endif
    }

    var columns: [GridItem] {
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

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.movies) { movie in
                    MovieCardView(movie: movie, isTV: isTV)
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
        .refreshable {
            viewModel.reset()
            viewModel.fetchNextPage()
        }
        .task {
            if viewModel.movies.isEmpty && !viewModel.isLoading {
                viewModel.fetchNextPage()
            }
        }
    }

    // MARK: - Pagination Trigger Logic
    private func triggerPaginationIfNeeded(currentMovie: Movie) {
        guard !viewModel.isLoading else { return }

        if let index = viewModel.movies.firstIndex(of: currentMovie),
           index >= viewModel.movies.count - 6 {
            HapticFeedback.trigger(.light)
            viewModel.fetchNextPage()
        }
    }
}

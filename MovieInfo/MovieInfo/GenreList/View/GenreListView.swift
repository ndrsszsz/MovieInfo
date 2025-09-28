//
//  GenresView.swift
//  MovieInfo
//
//  Created by Andras Szasz on 2025. 09. 28..
//


import SwiftUI

struct GenreListView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var viewModel = GenreListViewModel()
    @State private var movieListViewModelCache: [Int: MovieListViewModel] = [:]
    
    // MARK: Body

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.genres, id: \.id) { genre in
                    NavigationLink(destination: destinationView(for: genre)) {
                        Text(genre.name)
                    }
                }
            }
            .navigationTitle("Genres")
            .overlay(overlayView)
            .task {
                // Only fetch if genres are empty to avoid repeated fetches
                if viewModel.genres.isEmpty {
                    viewModel.fetchGenres(context: context)
                }
                prepopulateMoviesViewModelCache()
            }
            .onChange(of: viewModel.genres) {
                prepopulateMoviesViewModelCache()
            }
        }
    }

    // MARK: Overlay View (loading / error)
    @ViewBuilder
    private var overlayView: some View {
        if viewModel.isLoading && viewModel.genres.isEmpty {
            CustomSpinnerView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground).opacity(0.8))
        } else if let error = viewModel.errorMessage, viewModel.genres.isEmpty {
            VStack(spacing: 8) {
                Text("Failed to load genres")
                    .foregroundColor(.red)
                    .font(.headline)
                Text(error)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Button("Retry") {
                    viewModel.fetchGenres(context: context)
                }
                .padding(.top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground).opacity(0.8))
        }
    }

    // MARK: Movies ViewModel Caching
    private func prepopulateMoviesViewModelCache() {
        for genre in viewModel.genres {
            if movieListViewModelCache[genre.id] == nil {
                movieListViewModelCache[genre.id] = MovieListViewModel(genreId: genre.id)
            }
        }
    }

    // MARK: Navigation Destination
    @ViewBuilder
    private func destinationView(for genre: Genre) -> some View {
        if let cachedVM = movieListViewModelCache[genre.id] {
            MovieListView(genre: genre, viewModel: cachedVM)
        } else {
            CustomSpinnerView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

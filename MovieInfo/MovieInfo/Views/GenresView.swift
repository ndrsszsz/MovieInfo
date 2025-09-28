//
//  GenresView.swift
//  MovieInfo
//
//  Created by Andras Szasz on 2025. 09. 28..
//


import SwiftUI

struct GenresView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var genreViewModel = GenreViewModel()
    @State private var moviesViewModelCache: [Int: MoviesViewModel] = [:]

    var body: some View {
        NavigationView {
            List {
                ForEach(genreViewModel.genres) { genre in
                    NavigationLink(destination: destinationView(for: genre)) {
                        Text(genre.name)
                    }
                }
            }
            .navigationTitle("Genres")
            .overlay(overlayView)
            .task {
                // Only fetch if genres are empty to avoid repeated fetches
                if genreViewModel.genres.isEmpty {
                    genreViewModel.fetchGenres(context: context)
                }
                prepopulateMoviesViewModelCache()
            }
            .onChange(of: genreViewModel.genres) {
                prepopulateMoviesViewModelCache()
            }
            .refreshable {
                // On pull-to-refresh, fetch regardless
                genreViewModel.fetchGenres(context: context)
            }
        }
    }

    // MARK: - Overlay View (loading / error)
    @ViewBuilder
    private var overlayView: some View {
        if genreViewModel.isLoading && genreViewModel.genres.isEmpty {
            CustomSpinnerView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground).opacity(0.8))
        } else if let error = genreViewModel.errorMessage, genreViewModel.genres.isEmpty {
            VStack(spacing: 8) {
                Text("Failed to load genres")
                    .foregroundColor(.red)
                    .font(.headline)
                Text(error)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Button("Retry") {
                    genreViewModel.fetchGenres(context: context)
                }
                .padding(.top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground).opacity(0.8))
        }
    }

    // MARK: - Movies ViewModel Caching
    private func prepopulateMoviesViewModelCache() {
        for genre in genreViewModel.genres {
            if moviesViewModelCache[genre.id] == nil {
                moviesViewModelCache[genre.id] = MoviesViewModel(genreId: genre.id)
            }
        }
    }

    // MARK: - Navigation Destination
    @ViewBuilder
    private func destinationView(for genre: Genre) -> some View {
        if let cachedVM = moviesViewModelCache[genre.id] {
            MoviesGridView(genre: genre, viewModel: cachedVM)
        } else {
            CustomSpinnerView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

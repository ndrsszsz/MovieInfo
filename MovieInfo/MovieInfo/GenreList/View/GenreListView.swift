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

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.genres, id: \.id) { genre in
                    NavigationLink(destination: MovieListView(genre: genre)) {
                        Text(genre.name)
                    }
                }
            }
            .navigationTitle("Genres")
            .overlay(overlayView)
            .task {
                if viewModel.genres.isEmpty {
                    viewModel.fetchGenres(context: context)
                }
            }
        }
    }

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
}

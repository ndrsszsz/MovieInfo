//
//  LoadingOverlayView.swift
//  MovieInfo
//
//  Created by Andras Szasz on 2025. 09. 28..
//


import SwiftUI

struct LoadingOverlayView: View {
    let isLoading: Bool
    let hasMovies: Bool
    let errorMessage: String?
    var onRetry: (() -> Void)? = nil

    var body: some View {
        Group {
            if isLoading && !hasMovies {
                ZStack {
                    Color.black.opacity(0.05)
                        .ignoresSafeArea()
                    CustomSpinnerView()
                        .scaleEffect(1.5)  // slightly larger spinner for visibility
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if isLoading {
                Color.black.opacity(0.001) // Invisible tap blocker
                    .ignoresSafeArea()
            } else if let errorMessage = errorMessage {
                VStack(spacing: 12) {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    if let onRetry = onRetry {
                        Button("Retry") {
                            onRetry()
                        }
                        .padding(.top, 4)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground).opacity(0.8))
                .ignoresSafeArea()
            }
        }
    }
}

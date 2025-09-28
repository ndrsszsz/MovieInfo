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

    private var shouldShowFullScreenSpinner: Bool {
        isLoading && !hasMovies
    }

    private var shouldBlockTouches: Bool {
        isLoading && hasMovies
    }

    // MARK: Body

    var body: some View {
        ZStack {
            if shouldShowFullScreenSpinner {
                spinnerOverlay
                    .transition(.opacity)
            }

            if shouldBlockTouches {
                tapBlocker
                    .transition(.opacity)
            }

            if let errorMessage = errorMessage {
                errorOverlay(message: errorMessage)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: isLoading || errorMessage != nil)
    }

    // MARK: Subviews

    private var spinnerOverlay: some View {
        ZStack {
            Color.black.opacity(0.05)
                .ignoresSafeArea()

            CustomSpinnerView()
                .scaleEffect(1.5)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var tapBlocker: some View {
        Color.black.opacity(0.001)
            .ignoresSafeArea()
            .accessibilityHidden(true)
    }

    private func errorOverlay(message: String) -> some View {
        VStack(spacing: .spacings.vStack) {
            Text("Error: \(message)")
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .accessibilityLabel("Error message")
                .accessibilityValue(message)

            if let onRetry = onRetry {
                Button("Retry") {
                    onRetry()
                }
                .padding(.top, .paddings.top)
                .accessibilityHint("Tap to retry loading")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).opacity(0.8))
        .ignoresSafeArea()
    }
}


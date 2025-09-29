//
//  CachedAsyncImage.swift
//  MovieInfo
//
//  Created by Andras Szasz on 2025. 09. 29..
//


import SwiftUI

struct CachedAsyncImage: View {
    @StateObject private var viewModel: CachedAsyncImageViewModel

    var contentMode: ContentMode
    var cornerRadius: CGFloat

    init(
        url: URL?,
        contentMode: ContentMode = .fill,
        cornerRadius: CGFloat = .defaultCornerRadius,
        apiClient: APIClientProtocol = APIClient.shared
    ) {
        _viewModel = StateObject(wrappedValue: CachedAsyncImageViewModel(url: url, apiClient: apiClient))
        self.contentMode = contentMode
        self.cornerRadius = cornerRadius
    }

    @State private var isImageVisible = false

    var body: some View {
        ZStack {
            if let uiImage = viewModel.uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .cornerRadius(cornerRadius)
                    .opacity(isImageVisible ? 1 : 0)
                    .onAppear {
                        withAnimation(.easeIn(duration: 0.3)) {
                            isImageVisible = true
                        }
                    }
            } else if viewModel.isLoading {
                placeholderView
            } else if viewModel.didFail {
                errorView
            } else {
                placeholderView // This state is very brief (initial load)
            }
        }
        .aspectRatio(2/3, contentMode: .fit)
    }

    private var placeholderView: some View {
        ZStack {
            Color.gray.opacity(0.1)
            CustomSpinnerView()
        }
        .cornerRadius(cornerRadius)
    }

    private var errorView: some View {
        ZStack {
            Color.gray.opacity(0.1)
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .foregroundColor(.gray)
                .padding(20)
        }
        .cornerRadius(cornerRadius)
    }
}

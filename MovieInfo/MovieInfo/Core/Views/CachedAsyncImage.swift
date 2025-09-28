//
//  ImageCache.swift
//  MovieInfo
//
//  Created by Andras Szasz on 2025. 09. 28..
//


import SwiftUI

struct CachedAsyncImage: View {
    let url: URL?
    var contentMode: ContentMode = .fill
    var cornerRadius: CGFloat = 8

    @State private var uiImage: UIImage?
    @State private var isLoading = false
    @State private var didFail = false
    @State private var isImageVisible = false

    var body: some View {
        ZStack {
            if let uiImage = uiImage {
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
            } else if isLoading {
                placeholderView
            } else if didFail {
                errorView
            } else {
                placeholderView
                    .onAppear(perform: loadImage)
            }
        }
        .aspectRatio(2/3, contentMode: .fit)
    }

    private var placeholderView: some View {
        ZStack {
            Color.gray.opacity(0.1)
            ProgressView()
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

    private func loadImage() {
        guard let url = url else {
            didFail = true
            return
        }

        if let cached = ImageCache.shared.image(for: url) {
            self.uiImage = cached
            return
        }

        isLoading = true
        didFail = false

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false

                if let data = data, let image = UIImage(data: data) {
                    ImageCache.shared.setImage(image, for: url)
                    self.uiImage = image
                } else {
                    didFail = true
                }
            }
        }.resume()
    }
}


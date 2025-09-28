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

    @State private var isImageLoaded = false

    var body: some View {
        if let url = url {
            if let cachedImage = ImageCache.shared.image(for: url) {
                Image(uiImage: cachedImage)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .cornerRadius(cornerRadius)
            } else {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        CustomSpinnerView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    case .success(let image):
                        let _ = cache(image: image, for: url)
                        image
                            .resizable()
                            .aspectRatio(contentMode: contentMode)
                            .cornerRadius(cornerRadius)
                            .opacity(isImageLoaded ? 1 : 0)
                            .onAppear {
                                withAnimation(.easeIn(duration: 0.3)) {
                                    isImageLoaded = true
                                }
                            }
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: contentMode)
                            .foregroundColor(.gray)
                            .cornerRadius(cornerRadius)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        } else {
            Image(systemName: "photo")
                .resizable()
                .aspectRatio(contentMode: contentMode)
                .foregroundColor(.gray)
                .cornerRadius(cornerRadius)
        }
    }

    private func cache(image: Image, for url: URL) {
        let renderer = ImageRenderer(content: image)
        if let uiImage = renderer.uiImage {
            ImageCache.shared.setImage(uiImage, for: url)
        }
    }
}

// MARK: Previews

struct CachedAsyncImage_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            Text("Valid Image URL")
            CachedAsyncImage(url: URL(string: "https://via.placeholder.com/150"))
                .frame(width: 150, height: 150)

            Text("No URL")
            CachedAsyncImage(url: nil)
                .frame(width: 150, height: 150)

            Text("Invalid Image URL")
            CachedAsyncImage(url: URL(string: "https://invalid-url"))
                .frame(width: 150, height: 150)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

//
//  CachedAsyncImageViewModel.swift
//  MovieInfo
//
//  Created by Andras Szasz on 2025. 09. 29..
//


import Combine
import SwiftUI

final class CachedAsyncImageViewModel: ObservableObject {
    @Published var uiImage: UIImage?
    @Published var isLoading: Bool = false
    @Published var didFail: Bool = false

    private var cancellable: AnyCancellable?
    private let url: URL?
    private let apiClient: APIClientProtocol

    init(url: URL?, apiClient: APIClientProtocol = APIClient.shared) {
        self.url = url
        self.apiClient = apiClient
        loadImage()
    }

    private func loadImage() {
        guard let url = url else {
            self.didFail = true
            return
        }

        if let cached = ImageCache.shared.image(for: url) {
            self.uiImage = cached
            return
        }

        isLoading = true
        didFail = false

        cancellable = apiClient.loadImageData(from: url)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false

                switch completion {
                case .finished:
                    break
                case .failure:
                    self.didFail = true
                }
            } receiveValue: { [weak self] data in
                guard let self = self else { return }

                if let image = UIImage(data: data) {
                    ImageCache.shared.setImage(image, for: url)
                    self.uiImage = image
                } else {
                    self.didFail = true
                }
            }
    }
}

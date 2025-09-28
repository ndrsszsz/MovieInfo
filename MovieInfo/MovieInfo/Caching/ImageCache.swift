//
//  ImageCache.swift
//  MovieInfo
//
//  Created by Andras Szasz on 2025. 09. 28..
//


import SwiftUI

final class ImageCache {
    static let shared = ImageCache()

    private init() {}

    private let cache = NSCache<NSURL, UIImage>()

    func image(for url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }

    func setImage(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL)
    }
}

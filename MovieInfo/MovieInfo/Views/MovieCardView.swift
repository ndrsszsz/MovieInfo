//
//  MovieCardView.swift
//  MovieInfo
//
//  Created by Andras Szasz on 2025. 09. 28..
//


import SwiftUI

struct MovieCardView: View {
    let movie: Movie
    let isTV: Bool

    var body: some View {
        VStack {
            CachedAsyncImage(url: movie.posterURL, contentMode: .fit, cornerRadius: 8)
                .frame(height: isTV ? 300 : 200)
                .drawingGroup()

            Text(movie.title)
                .font(isTV ? .title3 : .caption)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 4)
        }
    }
}

// MARK: Previews

struct MovieCardView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleMovie = Movie(id: 1, title: "Sample Movie", posterPath: "/sample.jpg")
        Group {
            MovieCardView(movie: sampleMovie, isTV: false)
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("iPhone")
            
            MovieCardView(movie: sampleMovie, isTV: true)
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("tvOS")
        }
    }
}

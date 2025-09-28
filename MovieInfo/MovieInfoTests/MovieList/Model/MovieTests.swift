//
//  MovieTests.swift
//  MovieInfo
//
//  Created by Andras Szasz on 2025. 09. 28..
//


import XCTest
@testable import MovieInfo

final class MovieTests: XCTestCase {
    func testMoviePosterURL() {
        let movie = Movie(id: 1, title: "Test Movie", posterPath: "/poster.jpg")
        let expectedURL = URL(string: "https://image.tmdb.org/t/p/w500/poster.jpg")

        XCTAssertEqual(movie.posterURL, expectedURL)
    }
}

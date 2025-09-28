//
//  MockGenreCoreDataCache.swift
//  MovieInfo
//
//  Created by Andras Szasz on 2025. 09. 28..
//


import CoreData
import Combine
@testable import MovieInfo

final class MockGenreCoreDataCache: GenreCoreDataCache {
    var cachedGenres: [Genre]? = nil
    var didSaveGenres = false

    override func loadGenres(from context: NSManagedObjectContext) -> [Genre]? {
        return cachedGenres
    }

    override func saveGenres(_ genres: [Genre], in context: NSManagedObjectContext) {
        didSaveGenres = true
        cachedGenres = genres
    }
}

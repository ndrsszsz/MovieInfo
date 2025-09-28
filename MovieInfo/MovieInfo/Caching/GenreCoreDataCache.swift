//
//  GenreCoreDataCache.swift
//  MovieInfo
//
//  Created by Andras Szasz on 2025. 09. 28..
//


import CoreData
import Foundation

class GenreCoreDataCache {
    static let shared = GenreCoreDataCache()

    private let expirationInterval: TimeInterval = 3600 // 1 hour

    func saveGenres(_ genres: [Genre], in context: NSManagedObjectContext) {
        clearGenres(in: context) // clear old cache

        for genre in genres {
            let entity = GenreEntity(context: context)
            entity.id = Int64(genre.id)
            entity.name = genre.name
            entity.timestamp = Date()
        }

        do {
            try context.save()
        } catch {
            print("Failed to save genres to Core Data:", error)
        }
    }

    func loadGenres(from context: NSManagedObjectContext) -> [Genre]? {
        let request: NSFetchRequest<GenreEntity> = GenreEntity.fetchRequest()
        do {
            let results = try context.fetch(request)

            guard let firstTimestamp = results.first?.timestamp else { return nil }

            let isExpired = Date().timeIntervalSince(firstTimestamp) > expirationInterval
            if isExpired {
                clearGenres(in: context)
                return nil
            }

            return results.map { Genre(id: Int($0.id), name: $0.name ?? "") }

        } catch {
            print("Failed to fetch genres:", error)
            return nil
        }
    }

    func clearGenres(in context: NSManagedObjectContext) {
        let request: NSFetchRequest<NSFetchRequestResult> = GenreEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)

        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Failed to delete old genres:", error)
        }
    }
}

//
//  PreviewHelper.swift
//  MovieInfo
//
//  Created by Andras Szasz on 2025. 09. 28..
//


import CoreData

enum PreviewHelper {
    static func inMemoryContext() -> NSManagedObjectContext {
        let container = NSPersistentContainer(name: "MovieInfo")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load in-memory store: \(error)")
            }
        }
        return container.viewContext
    }
}

//
//  PersistenceController.swift
//  MovieInfo
//
//  Created by Andras Szasz on 2025. 09. 28..
//


import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "MovieInfo")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved CoreData error: \(error), \(error.userInfo)")
            }
        }
    }
}

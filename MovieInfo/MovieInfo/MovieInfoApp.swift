//
//  MovieInfoApp.swift
//  MovieInfo
//
//  Created by Andras Szasz on 2025. 09. 28..
//

import SwiftUI

@main
struct MovieInfoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            GenresView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

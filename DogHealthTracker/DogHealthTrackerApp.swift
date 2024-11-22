//
//  DogHealthTrackerApp.swift
//  DogHealthTracker
//
//  Created by Henry Creamer on 11/22/24.
//

import SwiftUI

@main
struct DogHealthTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

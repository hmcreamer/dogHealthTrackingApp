//
//  ContentView.swift
//  DogHealthTracker
//
//  Created by Henry Creamer on 11/22/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        HomePageView()
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

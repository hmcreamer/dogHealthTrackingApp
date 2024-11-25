//
//  ContentView.swift
//  DogHealthTracker
//
//  Created by Henry Creamer on 11/22/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Dog.name, ascending: true)],
        animation: .default)
    private var dogs: FetchedResults<Dog>
    @State private var isAddingDogProfile = false

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(dogs) { dog in
                    NavigationLink {
                        Text("\(dog.name!)")
                    } label: {
                        Text(dog.name!)
                    }
                }
                .onDelete(perform: deleteDog)
            }
            .navigationTitle("Dog Profiles")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: {
                        isAddingDogProfile.toggle()
                    }) {
                        Label("Add Dog", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingDogProfile) {
                AddDogFormView(isPresented: $isAddingDogProfile)
            }
        } detail: {
            Text("Select a dog")
        }
    }

    private func deleteDog(offsets: IndexSet) {
        withAnimation {
            offsets.map { dogs[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

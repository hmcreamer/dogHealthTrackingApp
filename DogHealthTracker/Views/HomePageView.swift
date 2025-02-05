//
//  HomePageView.swift
//  DogHealthTracker
//
//  Created by Henry Creamer on 11/24/24.
//

import SwiftUI

struct HomePageView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Dog.name, ascending: true)],
        animation: .default)
    private var dogs: FetchedResults<Dog>
    @State private var isAddingDogProfile = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(dogs) { dog in
                    NavigationLink {
                        VStack {
                            DogProfileView(dog: dog)
                        }
                    } label: {
                        HStack {
                            if let dogPhoto = dog.photo,
                               let uiImage = UIImage(data: dogPhoto) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)

                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.5))
                                    .frame(width: 50, height: 50)
                                    .overlay(Text("No Image").font(.caption).foregroundColor(.white))
                            }
                            Text(dog.name!)
                                .font(.headline)
                        }
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
        }
    }

    private func deleteDog(offsets: IndexSet) {
        withAnimation {
            offsets.map { dogs[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                print("Failed to save dog: \(error.localizedDescription)")
            }
        }
    }
}


#Preview {
    HomePageView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

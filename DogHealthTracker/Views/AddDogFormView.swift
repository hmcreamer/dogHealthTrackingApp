//
//  AddDogFormView.swift
//  DogHealthTracker
//
//  Created by Henry Creamer on 11/24/24.
//

import SwiftUI

struct AddDogFormView: View {
    @Binding var isPresented: Bool // Binding to dismiss the form
    
    @State private var dogName: String = ""
    @State private var weight: Int? = nil
    @State private var birthday: Date = Date()
    @State private var lastVetVisit: Date = Date()
    
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Dog Information")) {
                    TextField("Name", text: $dogName)
                    TextField("Weight (lbs)", value: $weight, format: .number)
                        .keyboardType(.numberPad)
                    DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
                    DatePicker("Date of Last Vet Visit", selection: $lastVetVisit, displayedComponents: .date)
                }
            }
            .navigationTitle("Add New Dog")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false // Dismiss the form
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Handle saving the new dog profile here
                        addDogProfile()
                        print("Saved: \(dogName), \(weight ?? 0) \(birthday) \(lastVetVisit)")
                        isPresented = false // Dismiss the form after saving
                    }
                    .disabled(dogName.isEmpty || weight == nil) // Disable if fields are empty
                }
            }
        }
    }
    
    private func addDogProfile() {
        let newDog = Dog(context: viewContext) // Create a new Core Data object
        newDog.name = dogName
        newDog.weight = Int32(weight ?? 0)
        newDog.birthday = birthday // Convert Int? to Int16
        newDog.lastVetVisit = lastVetVisit
        
        do {
            try viewContext.save() // Save the object to Core Data
            print("\(dogName) saved successfully")
        } catch {
            print("Failed to save dog: \(error.localizedDescription)")
        }
    }

}

#Preview {
    AddDogFormView(isPresented: .constant(true))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

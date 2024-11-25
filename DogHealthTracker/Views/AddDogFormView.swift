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
    @State private var dogBreed: String = ""
    @State private var dogAge: Int? = nil

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Dog Information")) {
                    TextField("Name", text: $dogName)
                    TextField("Breed", text: $dogBreed)
                    TextField("Age", value: $dogAge, format: .number)
                        .keyboardType(.numberPad)
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
                        print("Saved: \(dogName), \(dogBreed), \(dogAge ?? 0)")
                        isPresented = false // Dismiss the form after saving
                    }
                    .disabled(dogName.isEmpty || dogBreed.isEmpty) // Disable if fields are empty
                }
            }
        }
    }
}

#Preview {
    AddDogFormView(isPresented: .constant(true))
}

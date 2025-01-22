//
//  AddDogFormView.swift
//  DogHealthTracker
//
//  Created by Henry Creamer on 11/24/24.
//

import SwiftUI
import PhotosUI

struct AddDogFormView: View {
    @Binding var isPresented: Bool // Binding to dismiss the form
    
    @State private var dogName: String = ""
    @State private var weight: Double? = nil
    @State private var birthday: Date = Date()
    @State private var selectedImage: UIImage? = nil // Store the selected image
    @State private var selectedItem: PhotosPickerItem? = nil // For binding the picker selection
    
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Dog Information")) {
                    TextField("Name", text: $dogName)
                    TextField("Weight (lbs)", value: $weight, format: .number)
                        .keyboardType(.numberPad)
                    DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
                }
                
                Section(header: Text("Dog Photo")) {
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200) // Display selected image
                            .cornerRadius(8)
                    } else {
                        Text("No photo selected")
                            .foregroundColor(.secondary)
                    }
                    
                    // Add the PhotosPicker
                    PhotosPicker("Select Photo", selection: $selectedItem, matching: .images)
                        .onChange(of: selectedItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let image = UIImage(data: data) {
                                    selectedImage = image // Set the selected image
                                }
                            }
                        }
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
                        print("Saved: \(dogName), \(weight ?? 0) \(birthday)")
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
        newDog.weight = Double(weight ?? 0)
        newDog.birthday = birthday // Convert Int? to Int16
        if let selectedImage = selectedImage {
            newDog.photo = selectedImage.jpegData(compressionQuality: 0.8) // Save the photo as Data
        }
        
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

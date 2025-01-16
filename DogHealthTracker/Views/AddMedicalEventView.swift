//
//  AddMedicalEventView.swift
//  DogHealthTracker
//
//  Created by Henry Creamer on 1/15/25.
//


import SwiftUI
import CoreData

struct AddMedicalEventView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    let dog: Dog

    @State private var selectedType: String = "Vaccine"
    @State private var occurrenceDate: Date = Date()
    @State private var eventDescription: String = ""
    @State private var expirationDate: Date = Date()
    @State private var reminderDate: Date = Date()

    private let eventTypes = ["Vaccine", "Heartworm Treatment", "Flea Treatment", "Vet Visit", "Other"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Event Type")) {
                    Picker("Type", selection: $selectedType) {
                        ForEach(eventTypes, id: \.self) { type in
                            Text(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }

                Section(header: Text("Event Details")) {
                    DatePicker("Occurrence Date", selection: $occurrenceDate, displayedComponents: .date)
                    TextField("Description", text: $eventDescription)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                if selectedType == "Vaccine" || selectedType == "Heartworm Treatment" || selectedType == "Flea Treatment" {
                    Section(header: Text("Additional Information")) {
                        DatePicker("Expiration Date", selection: $expirationDate, displayedComponents: .date)
                        DatePicker("Reminder Date", selection: $reminderDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("Add New Medical Event")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveMedicalEvent()
                    }
                }
            }
        }
    }

    private func saveMedicalEvent() {
        let newEvent = MedicalEvent(context: viewContext)
        newEvent.type = selectedType
        newEvent.eventDescription = eventDescription
        newEvent.occurrenceDate = occurrenceDate

        // Set expirationDate and reminderDate based on type
        if selectedType == "Vaccine" || selectedType == "Heartworm Treatment" || selectedType == "Flea Treatment" {
            newEvent.expirationDate = expirationDate
            newEvent.reminderDate = reminderDate
        } else {
            newEvent.expirationDate = occurrenceDate
            newEvent.reminderDate = occurrenceDate
        }

        newEvent.dog = dog

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Failed to save MedicalEvent: \(error.localizedDescription)")
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext

    // Use a helper function to create the Dog object
    let newDog = createPreviewDog(in: context)
    AddMedicalEventView(dog: newDog)
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

// Helper function to create a preview Dog object
private func createPreviewDog(in context: NSManagedObjectContext) -> Dog {
    let dog = Dog(context: context)
    dog.name = "Layla"
    dog.birthday = Calendar.current.date(byAdding: .year, value: -5, to: Date())
    dog.weight = Int32(25)
    dog.lastVetVisit = Calendar.current.date(byAdding: .month, value: -2, to: Date())
    if let image = UIImage(named: "laylaBed"),
       let imageData = image.jpegData(compressionQuality: 0.8) {
        dog.photo = imageData
    }
    
    let pdfDoc = PDFDoc(context: context)
    pdfDoc.title = "Sample Medical Record"
    pdfDoc.dog = dog

    // Get the URL of the Sample2.pdf file from the app's bundle
    if let samplePDFURL = Bundle.main.url(forResource: "Sample2", withExtension: "pdf") {
        pdfDoc.url = samplePDFURL.absoluteString
    }
    try? context.save()

    return dog
}

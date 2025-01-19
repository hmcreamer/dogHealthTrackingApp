//
//  MedicalEventDetailView.swift
//  DogHealthTracker
//
//  Created by Henry Creamer on 1/19/25.
//


import SwiftUI
import CoreData

struct MedicalEventDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isEditing = false
    @State private var editedOccurrenceDate: Date
    @State private var editedType: String
    @State private var editedEventDescription: String
    @State private var editedExpirationDate: Date
    @State private var editedReminderDate: Date

    let medicalEvent: MedicalEvent

    init(medicalEvent: MedicalEvent) {
        self.medicalEvent = medicalEvent

        // Initialize state variables with existing data
        _editedOccurrenceDate = State(initialValue: medicalEvent.occurrenceDate ?? Date())
        _editedType = State(initialValue: medicalEvent.type ?? "")
        _editedEventDescription = State(initialValue: medicalEvent.eventDescription ?? "")
        _editedExpirationDate = State(initialValue: medicalEvent.expirationDate ?? Date())
        _editedReminderDate = State(initialValue: medicalEvent.reminderDate ?? Date())
    }

    var body: some View {
        Form {
            Section(header: Text("Event Details")) {
                if isEditing {
                    Picker("Type", selection: $editedType) {
                        Text("Vaccine").tag("Vaccine")
                        Text("Heartworm Treatment").tag("Heartworm Treatment")
                        Text("Flea Treatment").tag("Flea Treatment")
                        Text("Vet Visit").tag("Vet Visit")
                        Text("Other").tag("Other")
                    }
                    
                    DatePicker("Occurrence Date", selection: $editedOccurrenceDate, displayedComponents: .date)

                    TextField("Description", text: $editedEventDescription)
                    DatePicker("Expiration Date", selection: $editedExpirationDate, displayedComponents: .date)
                    
                    DatePicker("Reminder Date", selection: $editedReminderDate, displayedComponents: .date)

                } else {
                    DetailRow(title: "Type", value: medicalEvent.type ?? "")
                    DetailRow(title: "Occurrence Date", value: formatDate(medicalEvent.occurrenceDate))
                    DetailRow(title: "Description", value: medicalEvent.eventDescription ?? "")
                    DetailRow(title: "Expiration Date", value: formatDate(medicalEvent.expirationDate))
                    DetailRow(title: "Reminder Date", value: formatDate(medicalEvent.reminderDate))
                }
            }
        }
        .navigationTitle("Medical Event Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isEditing {
                    Button("Save") {
                        saveChanges()
                    }
                } else {
                    Button("Edit") {
                        isEditing.toggle()
                    }
                }
            }
        }
    }

    private func saveChanges() {
        // Update the MedicalEvent with edited values
        medicalEvent.occurrenceDate = editedOccurrenceDate
        medicalEvent.type = editedType
        medicalEvent.eventDescription = editedEventDescription
        medicalEvent.expirationDate = editedExpirationDate
        medicalEvent.reminderDate = editedReminderDate

        do {
            try viewContext.save()
            isEditing = false
        } catch {
            print("Failed to save changes: \(error.localizedDescription)")
        }
    }

    // Helper function to format dates
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct DetailRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.semibold)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }
}


#Preview {
    let context = PersistenceController.preview.container.viewContext

    // Use a helper function to create the Dog object
    let newEvent = createPreviewEvent(in: context)
    
    NavigationStack {
                MedicalEventDetailView(medicalEvent: newEvent)
            }
            .environment(\.managedObjectContext, context)

}

// Helper function to create a preview Dog object
private func createPreviewEvent(in context: NSManagedObjectContext) -> MedicalEvent {
    let event1 = MedicalEvent(context: context)
     event1.eventDescription = "Rabies Vaccine"
     event1.occurrenceDate = Date()
     event1.expirationDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())
     event1.reminderDate = Calendar.current.date(byAdding: .month, value: 11, to: Date())
     event1.type = "Vaccine"
    return event1
}

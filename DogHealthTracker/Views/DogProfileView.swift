//
//  DogProfileView.swift
//  DogHealthTracker
//
//  Created by Henry Creamer on 12/14/24.
//

import SwiftUI
import PhotosUI
import CoreData

struct DogProfileView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var dog: Dog

    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var tempPhoto: UIImage? = nil
    @State private var birthday: Date? = nil
    @State private var weight: Double? = nil
    private var lastVetVisit: Date? {
        let fetchRequest: NSFetchRequest<MedicalEvent> = MedicalEvent.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "dog == %@ AND type == %@", dog, "Vet Visit")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "occurrenceDate", ascending: false)]
        fetchRequest.fetchLimit = 1

        do {
            if let mostRecentEvent = try viewContext.fetch(fetchRequest).first {
                return mostRecentEvent.occurrenceDate
            }
        } catch {
            print("Error fetching vet visits: \(error.localizedDescription)")
        }
        return nil
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Dog's Photo
                if let dogPhoto = tempPhoto ?? dog.photo.flatMap({ UIImage(data: $0) }) {
                    CircleImage(uiImage: dogPhoto)
                        .frame(width: 250, height: 250)
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 200, height: 200)
                        .overlay(
                            Text("No Image")
                                .foregroundColor(.white)
                                .font(.headline)
                        )
                }
                
                // Photos Picker to Update Photo
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Text("Edit Photo")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .onChange(of: selectedPhotoItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let newImage = UIImage(data: data) {
                            tempPhoto = newImage
                            savePhotoToCoreData(photo: newImage)
                        }
                    }
                }
                
                // Dog's Name
                Text(dog.name ?? "Unknown Name")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Dog Profile Information Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("About")
                        .font(.headline)
                    
                    Divider()
                    
                    // Birthday Field
                    HStack {
                        Text("Birthday:")
                            .fontWeight(.bold)
                        Spacer()
                        DatePicker(
                            "",
                            selection: Binding(
                                get: { dog.birthday ?? Date() },
                                set: { newValue in
                                    dog.birthday = newValue
                                    saveChanges()
                                }
                            ),
                            displayedComponents: .date
                        )
                        .labelsHidden()
                    }
                    
                    // Weight Field
                    HStack {
                        Text("Weight (lbs):")
                            .fontWeight(.bold)
                        Spacer()
                        TextField("Enter Weight", text: Binding(
                            get: { String(dog.weight) },
                            set: { newValue in
                                if let weightValue = Double(newValue) {
                                    dog.weight = weightValue
                                    saveChanges()
                                }
                            }
                        ))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                    }
                    
                    // Last Vet Visit Field
                    HStack {
                        Text("Last Vet Visit:")
                            .fontWeight(.bold)
                        Spacer()
                        if let lastVisit = lastVetVisit {
                            Text(DateFormatter.localizedString(from: lastVisit, dateStyle: .medium, timeStyle: .none))
                                .foregroundColor(.secondary)
                        } else {
                            Text("No visits recorded")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Dog's Age
                    HStack {
                        Text("Age:")
                            .fontWeight(.bold)
                        Spacer()
                        Text("\(calculateAge(birthday: dog.birthday))")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGroupedBackground))
                .cornerRadius(10)
                .padding(.horizontal)
                                
                // Treatment Information Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Treatment Information")
                        .font(.headline)
                    
                    Divider()
                    
                    // Table headers
                    HStack {
                        Text("Type")
                            .fontWeight(.bold)
                        Spacer()
                        Text("Renewal Date")
                            .fontWeight(.bold)
                    }
                    .padding(.bottom, 5)
                    
                    // Flea Treatment Row
                    HStack {
                        Text("Flea Treatment")
                        Spacer()
                        if let fleaTreatment = fetchMostRecentMedicalEvent(ofType: "Flea Treatment") {
                            Text(DateFormatter.localizedString(from: fleaTreatment.expirationDate ?? Date(), dateStyle: .medium, timeStyle: .none))
                                .foregroundColor(.secondary)
                        } else {
                            Text("No data")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Heartworm Treatment Row
                    HStack {
                        Text("Heartworm Treatment")
                        Spacer()
                        if let heartwormTreatment = fetchMostRecentMedicalEvent(ofType: "Heartworm Treatment") {
                            Text(DateFormatter.localizedString(from: heartwormTreatment.expirationDate ?? Date(), dateStyle: .medium, timeStyle: .none))
                                .foregroundColor(.secondary)
                        } else {
                            Text("No data")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Vaccine Rows
                    ForEach(fetchUniqueVaccinesSortedByExpirationDate(), id: \.self) { vaccine in
                        HStack {
                            Text("\(vaccine.name ?? "Unknown") Vaccine")
                            Spacer()
                            Text(DateFormatter.localizedString(from: vaccine.expirationDate ?? Date(), dateStyle: .medium, timeStyle: .none))
                                .foregroundColor(.secondary)
                        }
                    }

                }
                .padding()
                .background(Color(.systemGroupedBackground))
                .cornerRadius(10)
                .padding(.horizontal)

                Spacer()
                
                // Navigation Button to Medical Events
                NavigationLink(destination: MedicalEventsView(dog: dog)) {
                    Text("View Medical History")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
            }
            .padding()
            .navigationTitle(dog.name ?? "Dog Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func fetchMostRecentMedicalEvent(ofType type: String) -> MedicalEvent? {
        let fetchRequest: NSFetchRequest<MedicalEvent> = MedicalEvent.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "dog == %@ AND type == %@", dog, type)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "occurrenceDate", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            return try viewContext.fetch(fetchRequest).first
        } catch {
            print("Error fetching \(type) events: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func fetchUniqueVaccinesSortedByExpirationDate() -> [MedicalEvent] {
        let fetchRequest: NSFetchRequest<MedicalEvent> = MedicalEvent.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "dog == %@ AND type == %@", dog, "Vaccine")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true),
            NSSortDescriptor(key: "occurrenceDate", ascending: false)
        ]

        do {
            let allVaccines = try viewContext.fetch(fetchRequest)

            // Filter for the most recent vaccine for each vaccine type
            var uniqueVaccines: [String: MedicalEvent] = [:]
            for vaccine in allVaccines {
                if uniqueVaccines[vaccine.name ?? ""] == nil {
                    uniqueVaccines[vaccine.name ?? ""] = vaccine
                }
            }

            // Return vaccines sorted by expirationDate
            return uniqueVaccines.values.sorted {
                ($0.expirationDate ?? Date.distantFuture) < ($1.expirationDate ?? Date.distantFuture)
            }
        } catch {
            print("Error fetching vaccines: \(error.localizedDescription)")
            return []
        }
    }



    // Save profile info changes to Core Data
    private func saveChanges() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving changes: \(error.localizedDescription)")
        }
    }

    // Save dog photo to Core Data
    private func savePhotoToCoreData(photo: UIImage) {
        if let photoData = photo.jpegData(compressionQuality: 0.8) {
            dog.photo = photoData
            saveChanges()
        }
    }

    // Calculate dog's age based on the dog's birthday and current day
    private func calculateAge(birthday: Date?) -> String {
        guard let birthday = birthday else { return "Unknown age" }
        let calendar = Calendar.current

        // Calculate the years between birthday and current date
        let ageComponents = calendar.dateComponents([.year], from: birthday, to: Date())
        let years = ageComponents.year ?? 0
        
        // Calculate the previous birthday by subtracting the years from the birthday
        let previousBirthday = calendar.date(byAdding: .year, value: years, to: birthday)
        
        // Calculate the days from the previous birthday to today
        if let previousBirthday = previousBirthday {
            let daysSincePreviousBirthday = calendar.dateComponents([.day], from: previousBirthday, to: Date()).day ?? 0
            return "\(years) years and \(daysSincePreviousBirthday) days"
        }

        return "\(years) years and 0 days"
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext

    // Use a helper function to create the Dog object
    let newDog = createPreviewDog(in: context)

    // Pass the Dog object and context to DogProfileView
    DogProfileView(dog: newDog)
        .environment(\.managedObjectContext, context)
}

// Helper function to create a preview Dog object
private func createPreviewDog(in context: NSManagedObjectContext) -> Dog {
    let dog = Dog(context: context)
    dog.name = "Layla"
    dog.birthday = Calendar.current.date(byAdding: .year, value: -5, to: Date())
    dog.weight = Double(25)
    if let image = UIImage(named: "laylaBed"),
       let imageData = image.jpegData(compressionQuality: 0.8) {
        dog.photo = imageData
    }
    
    let pdfDoc = PDFDoc(context: context)
    pdfDoc.title = "Sample Medical Record"
    pdfDoc.dog = dog
    
    let event1 = MedicalEvent(context: context)
     event1.eventDescription = "Rabies Vaccine"
     event1.occurrenceDate = Date()
     event1.expirationDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())
     event1.reminderDate = Calendar.current.date(byAdding: .month, value: 11, to: Date())
     event1.type = "Vaccine"
     event1.name = "Rabies"
     event1.dog = dog
    
    let event1a = MedicalEvent(context: context)
     event1a.eventDescription = "Other Rabies Vaccine"
     event1a.occurrenceDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
     event1a.expirationDate = Calendar.current.date(byAdding: .year, value: 1, to: event1a.occurrenceDate ?? Date())
     event1a.reminderDate = Calendar.current.date(byAdding: .month, value: 11, to: Date())
     event1a.type = "Vaccine"
     event1a.name = "Rabies"
     event1a.dog = dog
    
    let event1b = MedicalEvent(context: context)
     event1b.eventDescription = "Other Rabies Vaccine"
     event1b.occurrenceDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())
     event1b.expirationDate = Calendar.current.date(byAdding: .year, value: 1, to: event1b.occurrenceDate ?? Date())
     event1b.reminderDate = Calendar.current.date(byAdding: .month, value: 11, to: Date())
     event1b.type = "Vaccine"
     event1b.name = "Parvovirus"
     event1b.dog = dog
    
    let event2 = MedicalEvent(context: context)
     event2.eventDescription = "Checkup"
     event2.occurrenceDate = Date()
     event2.expirationDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())
     event2.reminderDate = Calendar.current.date(byAdding: .month, value: 11, to: Date())
     event2.type = "Vet Visit"
     event2.dog = dog
    
    let event3 = MedicalEvent(context: context)
     event3.eventDescription = "Yummy heartworm"
     event3.occurrenceDate = Date()
     event3.expirationDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())
     event3.reminderDate = Calendar.current.date(byAdding: .month, value: 11, to: Date())
     event3.type = "Heartworm Treatment"
     event3.dog = dog
    
    let event4 = MedicalEvent(context: context)
     event4.eventDescription = "Flea meds"
     event4.occurrenceDate = Date()
     event4.expirationDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())
     event4.reminderDate = Calendar.current.date(byAdding: .month, value: 11, to: Date())
     event4.type = "Flea Treatment"
     event4.dog = dog

    // Get the URL of the Sample2.pdf file from the app's bundle
    if let samplePDFURL = Bundle.main.url(forResource: "Sample2", withExtension: "pdf") {
        pdfDoc.url = samplePDFURL.absoluteString
    }
    try? context.save()

    return dog
}


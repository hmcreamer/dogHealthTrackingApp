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
    @State private var weight: Int? = nil
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
                    Image(uiImage: dogPhoto)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                        .shadow(radius: 5)
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
                                if let weightValue = Int32(newValue) {
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
                
                // Navigation Button to Medical Records
                NavigationLink(destination: MedicalRecordsView(dog: dog)) {
                    Text("View Medical Records")
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
    dog.weight = Int32(25)
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
     event1.dog = dog
    
    let event2 = MedicalEvent(context: context)
     event2.eventDescription = "Checkup"
     event2.occurrenceDate = Date()
     event2.expirationDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())
     event2.reminderDate = Calendar.current.date(byAdding: .month, value: 11, to: Date())
     event2.type = "Vet Visit"
     event2.dog = dog

    // Get the URL of the Sample2.pdf file from the app's bundle
    if let samplePDFURL = Bundle.main.url(forResource: "Sample2", withExtension: "pdf") {
        pdfDoc.url = samplePDFURL.absoluteString
    }
    try? context.save()

    return dog
}


//
//  MedicalEventsView.swift
//  DogHealthTracker
//
//  Created by Henry Creamer on 1/19/25.
//


import SwiftUI
import CoreData

struct MedicalEventsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest private var medicalEvents: FetchedResults<MedicalEvent>
    @State private var isAddingMedicalEvent = false

    var dog: Dog

    init(dog: Dog) {
        self.dog = dog
        _medicalEvents = FetchRequest(
            entity: MedicalEvent.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \MedicalEvent.occurrenceDate, ascending: false)],
            predicate: NSPredicate(format: "dog == %@", dog)
        )
    }

    var body: some View {
        NavigationStack {
            VStack {
                if medicalEvents.isEmpty {
                    VStack {
                        Text("No Medical History")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Tap '+' to add a new medical event.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    List {
                        HStack {
                            Text("Date")
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Event Type")
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .center)
                            Text("Description")
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(.vertical, 4) // Slight padding for a cleaner look
                            
                        ForEach(medicalEvents) { event in
                            NavigationLink(destination: MedicalEventDetailView(medicalEvent: event)) {
                                HStack {
                                    Text(event.occurrenceDate ?? Date(), formatter: dateFormatter)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text(event.type ?? "")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    Text(event.eventDescription ?? "")
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                            }
                        }
                        .onDelete(perform: deleteMedicalEvent)
                    }
                }
            }
            .navigationTitle("Medical History")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isAddingMedicalEvent = true }) {
                        Label("Add Medical Event", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingMedicalEvent) {
                AddMedicalEventView(dog: dog)
            }
        }
    }

    private func deleteMedicalEvent(at offsets: IndexSet) {
        withAnimation {
            offsets.map { medicalEvents[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                print("Failed to delete medical event: \(error.localizedDescription)")
            }
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}


#Preview {
    let context = PersistenceController.preview.container.viewContext

    // Use a helper function to create the Dog object
    let newDog = createPreviewDog(in: context)
    MedicalEventsView(dog: newDog)
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
    
    let event1 = MedicalEvent(context: context)
     event1.eventDescription = "Rabies Vaccine"
     event1.occurrenceDate = Date()
     event1.expirationDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())
     event1.reminderDate = Calendar.current.date(byAdding: .month, value: 11, to: Date())
     event1.type = "Vaccine"
     event1.dog = dog

    // Get the URL of the Sample2.pdf file from the app's bundle
    if let samplePDFURL = Bundle.main.url(forResource: "Sample2", withExtension: "pdf") {
        pdfDoc.url = samplePDFURL.absoluteString
    }
    try? context.save()

    return dog
}


//
//  Persistence.swift
//  DogHealthTracker
//
//  Created by Henry Creamer on 11/22/24.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
//        let dogNames = ["Ollie", "Layla"]
//        for i in 0..<2 {
//            let newItem = Dog(context: viewContext)
//            newItem.name = dogNames[i]
//        }
        let newDog = Dog(context:viewContext)
        newDog.name = "Ollie"
        newDog.birthday = Calendar.current.date(byAdding: .year, value: -7, to: Date())
        newDog.weight = Int32(25)
        newDog.lastVetVisit = Calendar.current.date(byAdding: .month, value: -2, to: Date())
        
        let pdfDoc = PDFDoc(context: viewContext)
        pdfDoc.title = "Sample Medical Record"
        pdfDoc.dog = newDog
        
        let event1 = MedicalEvent(context: viewContext)
        event1.eventDescription = "Rabies Vaccine"
        event1.occurrenceDate = Date()
        event1.expirationDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())
        event1.reminderDate = Calendar.current.date(byAdding: .month, value: 11, to: Date())
        event1.typeData = "Vaccine"
        event1.dog = newDog

        // Get the URL of the Sample2.pdf file from the app's bundle
        if let samplePDFURL = Bundle.main.url(forResource: "Sample2", withExtension: "pdf") {
            pdfDoc.url = samplePDFURL.absoluteString
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "DogHealthTracker")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

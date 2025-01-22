//
//  MedicalRecordsView.swift
//  DogHealthTracker
//
//  Created by Henry Creamer on 1/8/25.
//


import SwiftUI
import UniformTypeIdentifiers

struct MedicalRecordsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest var pdfDocs: FetchedResults<PDFDoc>
    @State private var isAddingPDF = false
    @State private var selectedPDF: URL?
    @State private var newPDFTitle: String = ""

    var dog: Dog

    init(dog: Dog) {
        self.dog = dog
        // Fetch PDFDocs associated with this dog
        _pdfDocs = FetchRequest(
            entity: PDFDoc.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \PDFDoc.title, ascending: true)],
            predicate: NSPredicate(format: "dog == %@", dog)
        )
    }

    var body: some View {
        NavigationView {
            VStack {
            if pdfDocs.isEmpty {
                VStack {
                    Text("No Medical Records")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Tap '+' to add a new medical record.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else {
                List {
                    ForEach(pdfDocs) { pdfDoc in
                        NavigationLink {
                            if let urlString = pdfDoc.url, let pdfURL = URL(string: urlString), FileManager.default.fileExists(atPath: pdfURL.path) {
                                PDFViewer(pdfURL: pdfURL)
                            } else {
                                Text("Failed to load PDF")
                                    .foregroundColor(.red)
                            }
                        } label: {
                            Text(pdfDoc.title ?? "Untitled")
                        }
                    }
                    .onDelete(perform: deletePDF)
                }


            }
            }
            .navigationTitle("Medical Records")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        isAddingPDF = true
                    }) {
                        Label("Add PDF", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingPDF) {
                VStack(spacing: 20) {
                    Text("Add New Medical Record")
                        .font(.headline)
                    
                    TextField("Enter title for the PDF", text: $newPDFTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    PDFPicker { pickedURL in
                        if let pickedURL = pickedURL {
                            savePDF(url: pickedURL)
                            newPDFTitle = "" // Reset the title field
                            isAddingPDF = false // Dismiss the sheet
                        }
                    }
                    
                    Button("Cancel") {
                        isAddingPDF = false
                        newPDFTitle = "" // Reset the title field
                    }
                    .foregroundColor(.red)
                }
                .padding()
            }

        }
    }

    private func deletePDF(at offsets: IndexSet) {
        withAnimation {
            offsets.map { pdfDocs[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                print("Error deleting PDF: \(error.localizedDescription)")
            }
        }
    }

    private func savePDF(url: URL) {
        let destinationURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(url.lastPathComponent)
        do {
            if !FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.copyItem(at: url, to: destinationURL)
            }
            let newPDF = PDFDoc(context: viewContext)
            newPDF.title = newPDFTitle.isEmpty ? "Untitled" : newPDFTitle
            newPDF.url = destinationURL.absoluteString // Save the sandboxed file URL
            newPDF.dog = dog

            try viewContext.save()
            print("PDF copied and saved successfully at \(destinationURL)")
        } catch {
            print("Error saving PDF: \(error.localizedDescription)")
        }
    }






}

#Preview {
    // Set up a Core Data preview context
    let previewContainer = PersistenceController.preview
    let context = previewContainer.container.viewContext

    // Create a sample Dog
    let dog = Dog(context: context)
    dog.name = "Buddy"

    // Add a sample PDFDoc
    let pdfDoc = PDFDoc(context: context)
    pdfDoc.title = "Sample Medical Record"
    pdfDoc.dog = dog

    // Get the URL of the Sample2.pdf file from the app's bundle
    if let samplePDFURL = Bundle.main.url(forResource: "Sample2", withExtension: "pdf") {
        pdfDoc.url = samplePDFURL.absoluteString
    }

    // Save the context
    try? context.save()

    // Preview the MedicalRecordsView with the sample Dog
    return MedicalRecordsView(dog: dog)
        .environment(\.managedObjectContext, context)
}


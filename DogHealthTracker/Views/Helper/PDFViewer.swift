//
//  PDFViewer.swift
//  DogHealthTracker
//
//  Created by Henry Creamer on 1/8/25.
//


import SwiftUI
import PDFKit

struct PDFViewer: View {
    let pdfURL: URL

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            if let document = PDFDocument(url: pdfURL) {
                PDFKitView(document: document)
                    .navigationTitle(pdfURL.lastPathComponent)
                    .navigationBarTitleDisplayMode(.inline)
            } else {
                Text("Failed to load the PDF")
                    .foregroundColor(.red)
                    .font(.headline)
                    .navigationTitle("Error")
            }
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let document: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = document
    }
}

#Preview {
    let pdfURL = Bundle.main.url(forResource: "Sample2", withExtension: "pdf")

    PDFViewer(pdfURL: pdfURL!)
}





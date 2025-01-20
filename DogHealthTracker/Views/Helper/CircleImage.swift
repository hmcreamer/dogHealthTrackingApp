//
//  CircleImage.swift
//  DogHealthTracker
//
//  Created by Henry Creamer on 1/20/25.
//


import SwiftUI

import SwiftUI

struct CircleImage: View {
    var uiImage: UIImage

    var body: some View {
        Image(uiImage: uiImage)
            .resizable()
            .scaledToFit()
            .clipShape(Circle())
            .overlay {
                Circle().stroke(.white, lineWidth: 5)
            }
            .shadow(radius: 7)
    }
}

#Preview {
    if let image = UIImage(named: "laylaBed") {
        CircleImage(uiImage: image)
    } else {
        Text("Image not found")
    }
}


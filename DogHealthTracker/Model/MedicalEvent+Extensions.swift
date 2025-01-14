//
//  MedicalEvent+Extensions.swift
//  DogHealthTracker
//
//  Created by Henry Creamer on 1/13/25.
//
import Foundation

extension MedicalEvent {
    enum MedicalEventType: String, Codable {
        case vaccine = "Vaccine"
        case heartwormTreatment = "Heartworm Treatment"
        case vetVisit = "Vet Visit"
        case fleaPreventative = "Flea Preventative"
        case other = "Other"
    }

    // Computed property to handle the enum
    var type: MedicalEventType {
        get {
            if let data = typeData {
                return (try? JSONDecoder().decode(MedicalEventType.self, from: data)) ?? .other
            }
            return .other
        }
        set {
            typeData = try? JSONEncoder().encode(newValue)
        }
    }
}


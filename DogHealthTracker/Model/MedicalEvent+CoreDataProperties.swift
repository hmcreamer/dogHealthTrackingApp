//
//  MedicalEvent+CoreDataProperties.swift
//  DogHealthTracker
//
//  Created by Henry Creamer on 1/13/25.
//
//

import Foundation
import CoreData

extension MedicalEvent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MedicalEvent> {
        return NSFetchRequest<MedicalEvent>(entityName: "MedicalEvent")
    }

    @NSManaged public var eventDescription: String?
    @NSManaged public var occurrenceDate: Date
    @NSManaged public var expirationDate: Date?
    @NSManaged public var reminderDate: Date?
    @NSManaged public var typeData: Data?
    @NSManaged public var dog: Dog?
}


extension MedicalEvent : Identifiable {

}

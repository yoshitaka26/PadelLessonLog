//
//  Lesson+CoreDataProperties.swift
//  PadelLessonLog
//
//  Created by Yoshitaka Tanaka on 2022/03/05.
//
//

import Foundation
import CoreData


extension Lesson {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Lesson> {
        return NSFetchRequest<Lesson>(entityName: "Lesson")
    }

    @NSManaged public var favorite: Bool
    @NSManaged public var id: UUID?
    @NSManaged public var image: Data?
    @NSManaged public var imageOrientation: Int16
    @NSManaged public var imageSaved: Bool
    @NSManaged public var inGroup: UUID?
    @NSManaged public var steps: NSSet?

}

// MARK: Generated accessors for steps
extension Lesson {

    @objc(addStepsObject:)
    @NSManaged public func addToSteps(_ value: LessonStep)

    @objc(removeStepsObject:)
    @NSManaged public func removeFromSteps(_ value: LessonStep)

    @objc(addSteps:)
    @NSManaged public func addToSteps(_ values: NSSet)

    @objc(removeSteps:)
    @NSManaged public func removeFromSteps(_ values: NSSet)

}

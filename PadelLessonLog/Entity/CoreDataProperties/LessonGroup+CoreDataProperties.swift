//
//  LessonGroup+CoreDataProperties.swift
//  PadelLessonLog
//
//  Created by Yoshitaka Tanaka on 2022/03/05.
//
//

import Foundation
import CoreData

extension LessonGroup {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LessonGroup> {
        return NSFetchRequest<LessonGroup>(entityName: "LessonGroup")
    }

    @NSManaged public var groupId: UUID?
    @NSManaged public var subTitle: String?

}

//
//  BaseLesson+CoreDataProperties.swift
//  PadelLessonLog
//
//  Created by Yoshitaka Tanaka on 2022/03/05.
//
//

import Foundation
import CoreData


extension BaseLesson {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BaseLesson> {
        return NSFetchRequest<BaseLesson>(entityName: "BaseLesson")
    }

    @NSManaged public var archived: Bool
    @NSManaged public var timeStamp: Date?
    @NSManaged public var orderNum: Int16
    @NSManaged public var title: String?
    @NSManaged public var status: Int16

}

extension BaseLesson : Identifiable {

}

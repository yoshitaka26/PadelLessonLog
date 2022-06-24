//
//  BaseLesson+Additions.swift
//  PadelLessonLog
//
//  Created by Yoshitaka Tanaka on 2022/03/06.
//

import Foundation

extension BaseLesson {
    func isGroupedLesson() -> Bool {
        if let lesson = self as? Lesson {
            return lesson.inGroup != nil ? true : false
        } else {
            return false
        }
    }
    func checkUUID() -> UUID? {
        if let lesson = self as? Lesson {
            return lesson.id
        } else if let group = self as? LessonGroup {
            return group.groupId
        } else {
            return nil
        }
    }
    func isLesson() -> Lesson? {
        if let lesson = self as? Lesson {
            return lesson
        } else {
            return nil
        }
    }
    func isGroup() -> LessonGroup? {
        if let group = self as? LessonGroup {
            return group
        } else {
            return nil
        }
    }
}

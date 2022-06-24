//
//  CoreDataManager.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/26.
//

import UIKit
import CoreData

enum CoreDataObjectType: String {
    case lesson = "Lesson"
    case lessonStep = "LessonStep"
    case baseLesson = "BaseLesson"
    case lessonGroup = "LessonGroup"
 }

protocol CoreDataProtocol {
    func createNewLesson(image: UIImage, steps: [String]) -> Lesson
    func createNewLessonGroup(title: String, baseLesson: BaseLesson) -> LessonGroup
    func loadAllBaseLessonData() -> [BaseLesson]
    func loadAllFavoriteLessonData() -> [Lesson]
    func loadAllLessonDataWithImage() -> [Lesson]
    func loadAllFavoriteLessonDataWithImage() -> [Lesson]
    func updateLessonFavorite(lessonID: String) -> Bool
    func updateLessonGroupTitle(groupID: String, title: String) -> Bool
    func updateLessonOrder(lessonArray: [BaseLesson])
    func updateBaseLessonOrder(from: IndexPath?, to: IndexPath, baseLesson: BaseLesson)
    func updateBaseLessonGrouping(orderNum: Int16, lesson: Lesson, groupId: UUID?)
    func deleteLessonGroup(groupID: String) -> Bool
}

final class CoreDataManager: CoreDataProtocol {
    static let shared = CoreDataManager()
    
    private init() { }
    
    // アプリケーション内のオブジェクトとデータベースの間のやり取りを行う
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "PadelLessonLog")
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                // リリースビルドでは通っても何も起きない
                assertionFailure("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // persistentContainerデータベース情報を表す
    // 管理オブジェクトコンテキスト。NSManagedObject 群を管理するクラス
    var managerObjectContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    // LightWeightMigrationできるかの確認時に使用する
    var checkLightWeightMigration: NSMappingModel {
        let subdirectory = "PadelLessonLog.momd"
        // swiftlint:disable force_unwrapping
        let sourceModel = NSManagedObjectModel(contentsOf: Bundle.main.url(forResource: "PadelLessonLog", withExtension: "mom", subdirectory: subdirectory)!)!
        let destinationModel = NSManagedObjectModel(contentsOf: Bundle.main.url(forResource: "PadelLessonLog 2", withExtension: "mom", subdirectory: subdirectory)!)!
        // swiftlint:enable force_unwrapping
        do {
            return try NSMappingModel.inferredMappingModel(forSourceModel: sourceModel, destinationModel: destinationModel)
        } catch {
            fatalError("migrationCheck error \(error)")
        }
    }
}

extension CoreDataManager {
    // MARK: - Lesson - create
    func createNewLesson(image: UIImage, steps: [String]) -> Lesson {
        let lesson = createNewObject(objectType: .lesson) as! Lesson
        lesson.id = UUID()
        lesson.timeStamp = Date()
        // UIImageをNSDataに変換
        let imageData = image.pngData()
        
        // UIImageの方向を確認
        var imageOrientation: Int = 0
        if image.imageOrientation == UIImage.Orientation.down {
            imageOrientation = 2
        } else {
            imageOrientation = 1
        }
        
        lesson.setValue(imageData, forKey: "image")
        lesson.setValue(imageOrientation, forKey: "imageOrientation")
    
        if !steps.isEmpty {
            for (index, step) in steps.enumerated() {
                let lessonStep = createNewObject(objectType: .lessonStep) as! LessonStep
                lessonStep.lessonID = lesson.id
                lessonStep.orderNum = Int16(index)
                lessonStep.explication = step
                lesson.addToSteps(lessonStep)
            }
        }
        saveContext()
        return lesson
    }
    
    func createNewLessonGroup(title: String, baseLesson: BaseLesson) -> LessonGroup {
        let lessonGroup = createNewObject(objectType: .lessonGroup) as! LessonGroup
        lessonGroup.title = title
        lessonGroup.timeStamp = Date()
        lessonGroup.groupId = UUID()
        
        if let lesson = baseLesson as? Lesson {
            lessonGroup.orderNum = lesson.orderNum
            lesson.orderNum = 0
            lesson.inGroup = lessonGroup.groupId
        } else if let group = baseLesson as? LessonGroup {
            lessonGroup.orderNum = group.orderNum
        }
        saveContext()
        return lessonGroup
    }
    
    // MARK: - Lesson - read
    func loadLessonData(lessonID: String) -> Lesson? {
        let fetchRequest = createRequest(objectType: .lesson)
        guard let uuid = NSUUID(uuidString: lessonID) else { return nil }
        let predicate = NSPredicate(format: "%K == %@", "id", uuid)
        fetchRequest.predicate = predicate
        do {
            let lessons = try managerObjectContext.fetch(fetchRequest) as! [Lesson]
            return lessons.first
        } catch {
            fatalError("loadData error")
        }
    }
    
    func loadAllFavoriteLessonData() -> [Lesson] {
        let fetchRequest = createRequest(objectType: .lesson)
        let predicate = NSPredicate(format: "%K == %@", "favorite", NSNumber(value: true))
        fetchRequest.predicate = predicate
        let orderSort = NSSortDescriptor(key: "orderNum", ascending: true)
        let timeSort = NSSortDescriptor(key: "timeStamp", ascending: false)
        fetchRequest.sortDescriptors = [orderSort, timeSort]
        do {
            let lessons = try managerObjectContext.fetch(fetchRequest) as! [Lesson]
            return lessons
        } catch {
            fatalError("loadData error")
        }
    }
    func loadAllFavoriteLessonDataWithImage() -> [Lesson] {
        let fetchRequest = createRequest(objectType: .lesson)
        let predicate = NSPredicate(format: "%K == %@", "favorite", NSNumber(value: true))
        fetchRequest.predicate = predicate
        let orderSort = NSSortDescriptor(key: "orderNum", ascending: true)
        let timeSort = NSSortDescriptor(key: "timeStamp", ascending: false)
        fetchRequest.sortDescriptors = [orderSort, timeSort]
        do {
            var lessons = try managerObjectContext.fetch(fetchRequest) as! [Lesson]
            lessons = lessons.filter { $0.imageSaved }
            return lessons
        } catch {
            fatalError("loadData error")
        }
    }
    
    func loadAllBaseLessonData() -> [BaseLesson] {
        let fetchRequest = createRequest(objectType: .baseLesson)
        let orderSort = NSSortDescriptor(key: "orderNum", ascending: true)
        let timeSort = NSSortDescriptor(key: "timeStamp", ascending: false)
        fetchRequest.sortDescriptors = [orderSort, timeSort]
        do {
            let lessons = try managerObjectContext.fetch(fetchRequest) as! [BaseLesson]
            return lessons
        } catch {
            fatalError("loadData error")
        }
    }
    
    func loadAllLessonDataWithImage() -> [Lesson] {
        let fetchRequest = createRequest(objectType: .lesson)
        let orderSort = NSSortDescriptor(key: "orderNum", ascending: true)
        let timeSort = NSSortDescriptor(key: "timeStamp", ascending: false)
        fetchRequest.sortDescriptors = [orderSort, timeSort]
        do {
            var lessons = try managerObjectContext.fetch(fetchRequest) as! [Lesson]
            lessons = lessons.filter { $0.imageSaved }
            return lessons
        } catch {
            fatalError("loadData error")
        }
    }
    
    // MARK: - Lesson - update
    func resetLessonImage(lessonID: String, image: UIImage) -> Bool {
        let fetchRequest = createRequest(objectType: .lesson)
        guard let uuid = NSUUID(uuidString: lessonID) else { return false }
        let predicate = NSPredicate(format: "%K == %@", "id", uuid)
        fetchRequest.predicate = predicate
        do {
            let lessons = try managerObjectContext.fetch(fetchRequest) as! [Lesson]
            guard let lesson = lessons.first else { return false }
            // UIImageをNSDataに変換
            let imageData = image.pngData()
            
            // UIImageの方向を確認
            var imageOrientation: Int = 0
            if image.imageOrientation == UIImage.Orientation.down {
                imageOrientation = 2
            } else {
                imageOrientation = 1
            }
            
            lesson.setValue(imageData, forKey: "image")
            lesson.setValue(imageOrientation, forKey: "imageOrientation")
            lesson.imageSaved = false
            
            saveContext()
            return true
        } catch {
            fatalError("loadData error")
        }
    }
    
    func updateLessonImage(lessonID: String, image: UIImage) -> Bool {
        let fetchRequest = createRequest(objectType: .lesson)
        guard let uuid = NSUUID(uuidString: lessonID) else { return false }
        let predicate = NSPredicate(format: "%K == %@", "id", uuid)
        fetchRequest.predicate = predicate
        do {
            let lessons = try managerObjectContext.fetch(fetchRequest) as! [Lesson]
            guard let lesson = lessons.first else { return false }
            // UIImageをNSDataに変換
            let imageData = image.pngData()
            // UIImageの方向を確認
            var imageOrientation: Int = 0
            if image.imageOrientation == UIImage.Orientation.down {
                imageOrientation = 2
            } else {
                imageOrientation = 1
            }
            
            lesson.setValue(imageData, forKey: "image")
            lesson.setValue(imageOrientation, forKey: "imageOrientation")
            lesson.imageSaved = true
            
            saveContext()
            return true
        } catch {
            fatalError("loadData error")
        }
    }
    
    func updateLessonTitle(lessonID: String, title: String) -> Bool {
        let fetchRequest = createRequest(objectType: .lesson)
        guard let uuid = NSUUID(uuidString: lessonID) else { return false }
        let predicate = NSPredicate(format: "%K == %@", "id", uuid)
        fetchRequest.predicate = predicate
        do {
            let lessons = try managerObjectContext.fetch(fetchRequest) as! [Lesson]
            guard let lesson = lessons.first else { return false }
            lesson.title = title
            saveContext()
            return true
        } catch {
            fatalError("updateData error")
        }
    }
    
    func updateLessonFavorite(lessonID: String) -> Bool {
        let fetchRequest = createRequest(objectType: .lesson)
        guard let uuid = NSUUID(uuidString: lessonID) else { return false }
        let predicate = NSPredicate(format: "%K == %@", "id", uuid)
        fetchRequest.predicate = predicate
        do {
            let lessons = try managerObjectContext.fetch(fetchRequest) as! [Lesson]
            guard let lesson = lessons.first else { return false }
            lesson.favorite.toggle()
            saveContext()
            return true
        } catch {
            fatalError("updateData error")
        }
    }
    
    func updateLessonGroupTitle(groupID: String, title: String) -> Bool {
        let fetchRequest = createRequest(objectType: .lessonGroup)
        guard let uuid = NSUUID(uuidString: groupID) else { return false }
        let predicate = NSPredicate(format: "%K == %@", "groupId", uuid)
        fetchRequest.predicate = predicate
        do {
            let groups = try managerObjectContext.fetch(fetchRequest) as! [LessonGroup]
            guard let group = groups.first else { return false }
            group.title = title
            saveContext()
            return true
        } catch {
            fatalError("updateData error")
        }
    }
    
    func updateLessonFavorite(lessonID: String, favorite: Bool) {
        let fetchRequest = createRequest(objectType: .lesson)
        guard let uuid = NSUUID(uuidString: lessonID) else { return }
        let predicate = NSPredicate(format: "%K == %@", "id", uuid)
        fetchRequest.predicate = predicate
        do {
            let lessons = try managerObjectContext.fetch(fetchRequest) as! [Lesson]
            guard let lesson = lessons.first else { return }
            lesson.favorite = favorite
            saveContext()
        } catch {
            fatalError("loadData error")
        }
    }
    
    func updateLessonOrder(lessonArray: [BaseLesson]) {
        for (index, lesson) in lessonArray.enumerated() {
            lesson.orderNum = Int16(index)
        }
        saveContext()
    }
    func updateBaseLessonOrder() {
        let baseLessons = loadAllBaseLessonData().filter { !$0.isGroupedLesson() }
        for (index, baseLesson) in baseLessons.enumerated() {
            baseLesson.orderNum = Int16(index)
            if let lesson = baseLesson.isLesson() {
                lesson.inGroup = nil
            }
        }
        
        let inGroupLessons: [Lesson] = loadAllBaseLessonData()
            .filter { $0.isGroupedLesson() }
            .map { return $0.isLesson() }
            .compactMap { $0 }
        
        var data = [UUID: [Lesson]]()
        data = Dictionary(grouping: inGroupLessons, by: { lesson in
            return lesson.inGroup ?? UUID()
        })
        
        data.forEach { (key: UUID, value: [Lesson]) in
            let sortedArray = value.sorted(by: {
                if $0.orderNum == $1.orderNum {
                    return $0.timeStamp! < $1.timeStamp! // swiftlint:disable:this force_unwrapping
                } else {
                    return $0.orderNum < $1.orderNum
                }
            })
            for (index, groupedLesson) in sortedArray.enumerated() {
                groupedLesson.orderNum = Int16(index + 1)
            }
        }
        saveContext()
    }
    
    func updateBaseLessonOrder(from: IndexPath?, to: IndexPath, baseLesson: BaseLesson) {
        var baseLessons = loadAllBaseLessonData().filter { !$0.isGroupedLesson() }
        if let removeIndex = from {
            baseLessons.remove(at: removeIndex.item)
        }
        baseLessons.insert(baseLesson, at: to.item)
        for (index, baseLesson) in baseLessons.enumerated() {
            baseLesson.orderNum = Int16(index)
            if let lesson = baseLesson.isLesson() {
                lesson.inGroup = nil
            }
        }
        saveContext()
    }
    
    func updateBaseLessonGrouping(orderNum: Int16, lesson: Lesson, groupId: UUID?) {
        lesson.inGroup = groupId
        lesson.orderNum = orderNum - 1
        saveContext()
        
        updateBaseLessonOrder()
    }
    
    // MARK: - Lesson - delete
    func deleteLessonData(lessonID: String) -> Bool {
        let fetchRequest = createRequest(objectType: .lesson)
        guard let uuid = NSUUID(uuidString: lessonID) else { return false }
        let predicate = NSPredicate(format: "%K == %@", "id", uuid)
        fetchRequest.predicate = predicate
        do {
            let lessons = try managerObjectContext.fetch(fetchRequest) as! [Lesson]
            guard let lesson = lessons.first else { return false }
            deleteAllSteps(lessonID: lessonID)
            managerObjectContext.delete(lesson)
            saveContext()
            return true
        } catch {
            fatalError("deleteData error")
        }
    }
    
    func deleteLessonGroup(groupID: String) -> Bool {
        let fetchRequest = createRequest(objectType: .lessonGroup)
        guard let uuid = NSUUID(uuidString: groupID) else { return false }
        let predicate = NSPredicate(format: "%K == %@", "groupId", uuid)
        fetchRequest.predicate = predicate
        do {
            let groups = try managerObjectContext.fetch(fetchRequest) as! [LessonGroup]
            guard let group = groups.first else { return false }
            managerObjectContext.delete(group)
            saveContext()
            return true
        } catch {
            fatalError("deleteData error")
        }
    }
    
    // MARK: - Steps - fetch
    func featchSteps(lessonID: String) -> [LessonStep] {
        let fetchRequest = createRequest(objectType: .lessonStep)
        guard let uuid = NSUUID(uuidString: lessonID) else { return Array() }
        let predicate = NSPredicate(format: "%K == %@", "lessonID", uuid)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "number", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let lessonSteps = try managerObjectContext.fetch(fetchRequest) as! [LessonStep]
            return lessonSteps
        } catch {
            fatalError("loadData error")
        }
    }
    
    // MARK: - Steps - create
    
    func createStep(lesson: Lesson) {
        let steps = lesson.steps?.allObjects as! [LessonStep]
        var numbers: [Int16] = []
        steps.forEach { numbers.append($0.orderNum) }
        let lessonStep = createNewObject(objectType: .lessonStep) as! LessonStep
        lessonStep.lessonID = lesson.id
        lessonStep.orderNum = (numbers.max() ?? 0) + 1
        lessonStep.explication = ""
        lesson.addToSteps(lessonStep)
        saveContext()
    }
    
    // MARK: - Steps - delete
    func deleteAllSteps(lessonID: String) {
        let fetchRequest = createRequest(objectType: .lessonStep)
        guard let uuid = NSUUID(uuidString: lessonID) else { return }
        let predicate = NSPredicate(format: "%K == %@", "lessonID", uuid)
        fetchRequest.predicate = predicate
        do {
            let lessonSteps = try managerObjectContext.fetch(fetchRequest) as! [LessonStep]
            let lesson = loadLessonData(lessonID: lessonID)
            if !lessonSteps.isEmpty {
                lessonSteps.forEach {
                    lesson?.removeFromSteps($0)
                    managerObjectContext.delete($0)
                }
            }
        } catch {
            fatalError("loadData error")
        }
    }
    
    func deleteStep(lesson: Lesson, step: LessonStep, steps: [LessonStep]) {
        steps.forEach {
            if $0.orderNum > step.orderNum {
                $0.orderNum -= 1
            }
        }
        lesson.removeFromSteps(step)
        managerObjectContext.delete(step)
        saveContext()
    }
    
    func createRequest(objectType: CoreDataObjectType) -> NSFetchRequest<NSFetchRequestResult> {
        NSFetchRequest<NSFetchRequestResult>(entityName: objectType.rawValue)
    }
    func createNewObject(objectType: CoreDataObjectType) -> NSManagedObject {
        return NSEntityDescription.insertNewObject(forEntityName: objectType.rawValue, into: managerObjectContext)
    }
    
    func saveContext() {
        managerObjectContext.mergePolicy = NSOverwriteMergePolicy

        if managerObjectContext.hasChanges {
            do {
                try managerObjectContext.save()
            } catch let error {
                print(error)
//                abort()
            }
        }
    }
    
    func saveContextFromAppDelegate () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let NSError = error as NSError
                fatalError("Unresolved error \(NSError), \(NSError.userInfo)")
            }
        }
    }
}

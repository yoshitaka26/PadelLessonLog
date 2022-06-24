//
//  StubManager.swift
//  PadelLessonLogTests
//
//  Created by Yoshitaka Tanaka on 2022/01/08.
//

import Quick
@testable import PadelLessonLog
import Foundation
import CoreData

class StubManager {
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var managedObjectContext: NSManagedObjectContext?
    
    init() {
        setUpStubCoreData()
    }
    
    func setUpStubCoreData() {
        let storeCoordinator = CoreDataManager.shared.persistentContainer.persistentStoreCoordinator
        do {
            try storeCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        } catch let error as NSError {
            print("\(error) \(error.userInfo)")
            abort()
        }
        managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        guard let managedObjectContext = managedObjectContext else { return }
        managedObjectContext.persistentStoreCoordinator = storeCoordinator
    }
    
    func createStubLessonData() -> Lesson {
        let lessonData = NSEntityDescription.insertNewObject(forEntityName: CoreDataObjectType.lesson.rawValue, into: managedObjectContext!) as! Lesson
        lessonData.id = UUID()
        lessonData.timeStamp = Date()
        lessonData.title = "TEST DATA"
        lessonData.setValue(R.image.img_court(compatibleWith: .current)!.pngData(), forKey: "image")
        lessonData.setValue(1, forKey: "imageOrientation")
        
        let lessonStep = NSEntityDescription.insertNewObject(forEntityName: CoreDataObjectType.lessonStep.rawValue, into: managedObjectContext!) as! LessonStep
        lessonStep.lessonID = UUID()
        lessonStep.orderNum = Int16(0)
        lessonStep.explication = "TEST DATA"
        
        lessonData.addToSteps(lessonStep)
//        saveContext()
        return lessonData
    }
    func createStubDummmyLessonData() -> Lesson {
        let lessonData = NSEntityDescription.insertNewObject(forEntityName: CoreDataObjectType.lesson.rawValue, into: managedObjectContext!) as! Lesson
        lessonData.id = UUID()
        lessonData.timeStamp = Date()
        lessonData.title = "DUMMY DATA"
        lessonData.setValue(R.image.img_court(compatibleWith: .current)!.pngData(), forKey: "image")
        lessonData.setValue(2, forKey: "imageOrientation")
        
        let lessonStep = NSEntityDescription.insertNewObject(forEntityName: CoreDataObjectType.lessonStep.rawValue, into: managedObjectContext!) as! LessonStep
        lessonStep.lessonID = UUID()
        lessonStep.orderNum = Int16(0)
        lessonStep.explication = "DUMMY DATA"
        
        lessonData.addToSteps(lessonStep)
        return lessonData
    }
    
    func saveContext() {
        guard let managedObjectContext = managedObjectContext else { return }
        managedObjectContext.mergePolicy = NSOverwriteMergePolicy
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch let error {
                print(error)
            }
        }
    }
}

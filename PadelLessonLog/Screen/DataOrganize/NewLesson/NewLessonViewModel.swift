//
//  NewLessonViewModel.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/11.
//

import UIKit
import Combine

enum NewLessonTransition {
    case addEditImage(Lesson)
    case saved
    case deleted
}
enum NewLessonAlert {
    case deleteImage
    case titleEmpty
    case titleStringCountOver
    case dataProcessingError
}

final class NewLessonViewModel: BaseViewModel {
    
    let imageButtonPressed = PassthroughSubject<Bool, Never>()
    let editImageButtonPressed = PassthroughSubject<Void, Never>()
    let deleteImageConfirmed = PassthroughSubject<Void, Never>()
    let addStepButtonPressed = PassthroughSubject<Void, Never>()
    let editStepButtonPressed = PassthroughSubject<Bool, Never>()
    var textFieldDidEndEditing = PassthroughSubject<String?, Never>()
    
    let deleteData = PassthroughSubject<Void, Never>()
    let saveData = PassthroughSubject<Void, Never>()
    
    let dataReload = PassthroughSubject<Void, Never>()
    
    var lessonData = CurrentValueSubject<Lesson?, Never>(nil)
    var lessonStepData = CurrentValueSubject<[LessonStep], Never>([])
    var lessonTitleText = CurrentValueSubject<String?, Never>("")
    var lessonStepDidEndEditing = PassthroughSubject<(LessonStep, String), Never>()
    var lessonStepDidDelete = PassthroughSubject<IndexPath, Never>()
    
    private(set) var showAlert = PassthroughSubject<NewLessonAlert, Never>()
    private(set) var imageDeleted = PassthroughSubject<Void, Never>()
    private(set) var dataDeleted = PassthroughSubject<Void, Never>()
    private(set) var dataSaved = PassthroughSubject<Void, Never>()
    private(set) var imageButtonIsOn = CurrentValueSubject<Bool, Never>(false)
    private(set) var editImageButtonIsHidden = CurrentValueSubject<Bool, Never>(false)
    private(set) var editStepButtonIsOn = CurrentValueSubject<Bool, Never>(false)
    private(set) var loadView = PassthroughSubject<Lesson, Never>()
    private(set) var scrollStepTable = PassthroughSubject<Void, Never>()
    private(set) var transition = PassthroughSubject<NewLessonTransition, Never>()
    
    let coreDataManager = CoreDataManager.shared
    let validation = CharacterCountValidation()
    
    override init() {
        super.init()
        mutate()
    }
    
    func mutate() {
        lessonData.sink { [weak self] lessonData in
            guard let self = self else { return }
            guard let lesson = lessonData else { return }
            let steps = lesson.steps?.allObjects as? [LessonStep]
            guard let safeSteps = steps, !safeSteps.isEmpty else { return }
            self.lessonTitleText.send(lesson.title)
            self.lessonStepData.send(safeSteps)
            self.loadView.send(lesson)
            
            self.imageButtonIsOn.send(lesson.imageSaved)
            self.editImageButtonIsHidden.send(!lesson.imageSaved)
        }.store(in: &subscriptions)
        
        textFieldDidEndEditing.sink { [weak self] inputText in
            guard let self = self else { return }
            self.lessonTitleText.send(inputText)
            guard let text = inputText else { return }
            let maxCount = 40
            let result: ValidateResult = self.validation.validate(word: text, maxCount: maxCount)
            if result == .countOverError {
                let dif = text.count - maxCount
                let dropedText = text.dropLast(dif)
                self.showAlert.send(.titleStringCountOver)
                self.lessonTitleText.send(dropedText.description)
            }
        }.store(in: &subscriptions)
        
        imageButtonPressed.sink { [weak self] isSelected in
            guard let self = self else { return }
            if !isSelected {
                guard let lesson = self.lessonData.value else { return }
                self.transition.send(.addEditImage(lesson))
            } else {
                self.showAlert.send(.deleteImage)
            }
        }.store(in: &subscriptions)
        
        deleteImageConfirmed.sink { [weak self] _ in
            guard let self = self else { return }
            guard let lesson = self.lessonData.value, let id = lesson.id else { return }
            guard let courtImage = R.image.img_court(compatibleWith: .current) else { return }
            if self.coreDataManager.resetLessonImage(lessonID: id.uuidString, image: courtImage) {
                self.lessonData.send(self.coreDataManager.loadLessonData(lessonID: id.uuidString))
                self.imageDeleted.send()
            } else {
                assertionFailure("画像が更新できない")
                self.showAlert.send(.dataProcessingError)
            }
        }.store(in: &subscriptions)
        
        editImageButtonPressed.sink { [weak self] _ in
            guard let self = self else { return }
            guard let lesson = self.lessonData.value else { return }
            self.transition.send(.addEditImage(lesson))
        }.store(in: &subscriptions)
        
        addStepButtonPressed.sink { [weak self] _ in
            guard let self = self else { return }
            guard let lesson = self.lessonData.value else { return }
            self.coreDataManager.createStep(lesson: lesson)
            self.lessonData.send(lesson)
            self.scrollStepTable.send()
        }.store(in: &subscriptions)
        
        editStepButtonPressed.sink { [weak self] isSelected in
            guard let self = self else { return }
            self.editStepButtonIsOn.send(!isSelected)
        }.store(in: &subscriptions)
        
        lessonStepDidEndEditing.sink { [weak self] lessonStep, text in
            guard self != nil else { return }
            lessonStep.explication = text
            lessonStep.save()
        }.store(in: &subscriptions)
        
        lessonStepDidDelete.sink { [weak self] indexPath in
            guard let self = self else { return }
            guard let lesson = self.lessonData.value else { return }
            guard self.lessonStepData.value.count > 1 else { return }
            var deleteStep: LessonStep?
            for step in self.lessonStepData.value where step.orderNum == indexPath.row {
                deleteStep = step
            }
            guard let step = deleteStep else { return }
            self.coreDataManager.deleteStep(lesson: lesson, step: step, steps: self.lessonStepData.value)
            self.lessonData.send(lesson)
        }.store(in: &subscriptions)
        
        deleteData.sink { [weak self] _ in
            guard let self = self else { return }
            guard let lesson = self.lessonData.value else { return }
            guard let id = lesson.id else { return }
            if self.coreDataManager.deleteLessonData(lessonID: id.uuidString) {
                self.dataDeleted.send()
            } else {
                assertionFailure("データ削除失敗")
                self.showAlert.send(.dataProcessingError)
            }
        }.store(in: &subscriptions)
        
        saveData.sink { [weak self] _ in
            guard let self = self else { return }
            guard let lesson = self.lessonData.value else { return }
            guard let id = lesson.id else { return }
            guard let title = self.lessonTitleText.value else {
                self.showAlert.send(.titleEmpty)
                return
            }
            let trinmingTitle = title.trimmingCharacters(in: .whitespaces)
            let result: ValidateResult = self.validation.validate(word: trinmingTitle, maxCount: 0)
            guard result == .valid else {
                self.showAlert.send(.titleEmpty)
                return
            }
            
            if self.coreDataManager.updateLessonTitle(lessonID: id.uuidString, title: title) {
                self.dataSaved.send()
            } else {
                assertionFailure("データ保存失敗")
                self.showAlert.send(.dataProcessingError)
            }
        }.store(in: &subscriptions)
    }
}

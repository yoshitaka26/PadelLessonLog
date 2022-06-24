//
//  DetailViewMode.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/09/12.
//

import UIKit
import Combine

enum DetailTransition {
    case imageView(Lesson)
    case editView(Lesson)
    case back
}

final class DetailViewModel: BaseViewModel {
    
    let imageViewButtonPressed = PassthroughSubject<Void, Never>()
    let editViewButtonPressed = PassthroughSubject<Void, Never>()
    let backButtonPressed = PassthroughSubject<Void, Never>()
    
    var lessonData = CurrentValueSubject<Lesson?, Never>(nil)
    var tableViewCellData = CurrentValueSubject<[LessonStep], Never>([])
    
    private(set) var loadView = PassthroughSubject<Lesson, Never>()
    private(set) var transition = PassthroughSubject<DetailTransition, Never>()
    
    override init() {
        super.init()
        mutate()
    }
    
    func mutate() {
        imageViewButtonPressed.sink { [weak self] _ in
            guard let self = self else { return }
            guard let lesson = self.lessonData.value else { return }
            self.transition.send(.imageView(lesson))
        }.store(in: &subscriptions)
        
        editViewButtonPressed.sink { [weak self] _ in
            guard let self = self else { return }
            guard let lesson = self.lessonData.value else { return }
            self.transition.send(.editView(lesson))
        }.store(in: &subscriptions)
        
        backButtonPressed.sink { [weak self] _ in
            guard let self = self else { return }
            self.transition.send(.back)
        }.store(in: &subscriptions)
        
        lessonData.sink { [weak self] lessonData in
            guard let self = self else { return }
            guard let lesson = lessonData else { return }
            let stpes = lesson.steps?.allObjects as? [LessonStep]
            guard let safeSteps = stpes, !safeSteps.isEmpty else { return }
            self.tableViewCellData.send(safeSteps)
            self.loadView.send(lesson)
        }.store(in: &subscriptions)
    }
}

//
//  LessonViewModel.swift
//  PadelLessonLog
//
//  Created by Yoshitaka Tanaka on 2022/01/04.
//

import UIKit
import Combine

enum LessonTransition {
    case setting
    case lesson(Lesson, Bool)
    case arView
    case detail(Lesson)
}

enum TableMode {
    case allTableView
    case favoriteTableView
}

class LessonViewModel: BaseViewModel {
    let settingButtonPressed = PassthroughSubject<Void, Never>()
    let detailButtonPressed = PassthroughSubject<Lesson, Never>()
    let allButtonPressed = PassthroughSubject<Void, Never>()
    let favoriteButtonPressed = PassthroughSubject<Void, Never>()
    let dataReload = PassthroughSubject<Void, Never>()
    let pushToEditLessonView = PassthroughSubject<Lesson, Never>()
    
    private(set) var allBarButtonIsOn = CurrentValueSubject<Bool, Never>(true)
    private(set) var favoriteBarButtonIsOn = CurrentValueSubject<Bool, Never>(false)
    
    var tableMode = CurrentValueSubject<TableMode, Never>(.allTableView)
    
    private(set) var transition = PassthroughSubject<LessonTransition, Never>()
    
    override init() {
        super.init()
        mutate()
    }
    
    func mutate() {
        settingButtonPressed.sink { [weak self] _ in
            guard let self = self else { return }
            self.transition.send(.setting)
        }.store(in: &subscriptions)
                
        detailButtonPressed.sink { [weak self] lessonData in
            guard let self = self else { return }
            self.transition.send(.detail(lessonData))
        }.store(in: &subscriptions)
        
        pushToEditLessonView.sink { [weak self] editLessonData in
            guard let self = self else { return }
            self.transition.send(.lesson(editLessonData, false))
        }.store(in: &subscriptions)
        
        allButtonPressed.sink { [weak self] _ in
            guard let self = self else { return }
            self.allBarButtonIsOn.send(true)
            self.favoriteBarButtonIsOn.send(false)
            self.tableMode.send(.allTableView)
            self.dataReload.send()
        }.store(in: &subscriptions)
        
        favoriteButtonPressed.sink { [weak self] _ in
            guard let self = self else { return }
            self.allBarButtonIsOn.send(false)
            self.favoriteBarButtonIsOn.send(true)
            self.tableMode.send(.favoriteTableView)
            self.dataReload.send()
        }.store(in: &subscriptions)
    }
}

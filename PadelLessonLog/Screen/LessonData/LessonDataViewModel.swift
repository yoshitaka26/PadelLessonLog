//
//  LessonDataViewModel.swift
//  PadelLessonLog
//
//  Created by Yoshitaka Tanaka on 2022/01/04.
//

import Foundation
import Combine

final class LessonDataViewModel: LessonViewModel {
    struct Dependency {
        let coreDataProtocol: CoreDataProtocol
    }
    init (dependency: Dependency) {
        coreDataManager = dependency.coreDataProtocol
        super.init()
    }
    let coreDataManager: CoreDataProtocol
        
    let addLessonButtonPressed = PassthroughSubject<Void, Never>()
    let pushBackFromNewLessonView = PassthroughSubject<Void, Never>()
    let didSelectItemAt = PassthroughSubject<Lesson, Never>()
    let createNewGroup = PassthroughSubject<(IndexPath, String?), Never>()
    let favoriteToggled = PassthroughSubject<Lesson, Never>()
    let renameGroup = PassthroughSubject<(BaseLesson, String?), Never>()
    let deleteGroup = PassthroughSubject<BaseLesson, Never>()
    let reorderData = PassthroughSubject<(lesson: BaseLesson, from: IndexPath?, to: IndexPath), Never>()
    let moveIntoGroup = PassthroughSubject<(lesson: Lesson, group: LessonGroup), Never>()
    let reorderInsideOfGroup = PassthroughSubject<(lesson: Lesson, nextTo: Lesson), Never>()
    let searchAndFilterData = PassthroughSubject<String, Never>()
    private(set) var lessonsArray = CurrentValueSubject<[BaseLesson], Never>([])
    private(set) var scrollToTableIndex = PassthroughSubject<Int, Never>()
    
    override func mutate() {
        super.mutate()
        addLessonButtonPressed.sink { [weak self] _ in
            guard let self = self else { return }
            guard let courtImg = R.image.img_court(compatibleWith: .current) else { return }
            let newLessonData = self.coreDataManager.createNewLesson(image: courtImg, steps: [""])
            self.transition.send(.lesson(newLessonData, true))
        }.store(in: &subscriptions)
        
        dataReload.sink { [weak self] _ in
            guard let self = self else { return }
            if self.tableMode.value == .allTableView {
                self.lessonsArray.send(self.coreDataManager.loadAllBaseLessonData())
            } else {
                self.lessonsArray.send(self.coreDataManager.loadAllFavoriteLessonData())
            }
        }.store(in: &subscriptions)
        
        didSelectItemAt.sink { [weak self] lesson in
            guard let self = self else { return }
            self.transition.send(.detail(lesson))
        }.store(in: &subscriptions)
        
        createNewGroup.sink { [weak self] indexPath, title in
            guard let self = self else { return }
            guard let groupTitle = title else { return }
            let baseLesson = self.lessonsArray.value[indexPath.row]
            let newGroup = self.coreDataManager.createNewLessonGroup(title: groupTitle, baseLesson: baseLesson)
            self.lessonsArray.value.insert(newGroup, at: indexPath.row)
            self.lessonsArray.send(self.coreDataManager.loadAllBaseLessonData())
        }.store(in: &subscriptions)
        
        favoriteToggled.sink { [weak self] lesson in
            guard let self = self else { return }
            guard let id = lesson.id else { return }
            if self.coreDataManager.updateLessonFavorite(lessonID: id.uuidString) {
                self.dataReload.send()
            }
        }.store(in: &subscriptions)
        
        renameGroup.sink { [weak self] baseLesson, title in
            guard let self = self else { return }
            guard let groupTitle = title else { return }
            guard let group = baseLesson as? LessonGroup, let id = group.groupId else { return }
            if self.coreDataManager.updateLessonGroupTitle(groupID: id.uuidString, title: groupTitle) {
                self.dataReload.send()
            }
        }.store(in: &subscriptions)
        
        deleteGroup.sink { [weak self] baseLesson in
            guard let self = self else { return }
            guard let group = baseLesson as? LessonGroup, let id = group.groupId else { return }
            if self.coreDataManager.deleteLessonGroup(groupID: id.uuidString) {
                self.dataReload.send()
            }
        }.store(in: &subscriptions)
        
        reorderData.sink { [weak self] baseLesson, from, to in
            guard let self = self else { return }
            if let fromIndex = from {
                guard fromIndex.row != to.row else { return }
            }
            self.coreDataManager.updateBaseLessonOrder(from: from, to: to, baseLesson: baseLesson)
            self.dataReload.send()
        }.store(in: &subscriptions)
        
        moveIntoGroup.sink { [weak self] lesson, group in
            guard let self = self else { return }
            self.coreDataManager.updateBaseLessonGrouping(orderNum: 1, lesson: lesson, groupId: group.groupId)
            self.dataReload.send()
        }.store(in: &subscriptions)
        
        reorderInsideOfGroup.sink { [weak self] dragLesson, nextToLesson in
            guard let self = self else { return }
            self.coreDataManager.updateBaseLessonGrouping(orderNum: nextToLesson.orderNum, lesson: dragLesson, groupId: nextToLesson.inGroup)
            self.dataReload.send()
        }.store(in: &subscriptions)
        
        searchAndFilterData.sink { [weak self] text in
            guard let self = self else { return }
            let filteredData = self.lessonsArray.value.filter {
                guard let title = $0.title else { return false }
                return title.contains(text)
            }
            self.lessonsArray.send(filteredData)
        }.store(in: &subscriptions)
        
        pushBackFromNewLessonView.sink { [weak self] _ in
            guard let self = self else { return }
            guard !self.lessonsArray.value.isEmpty else { return }
            self.scrollToTableIndex.send(0)
        }.store(in: &subscriptions)
    }
}

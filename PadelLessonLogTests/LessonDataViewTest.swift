//
//  LessonDataViewTest.swift
//  PadelLessonLogTests
//
//  Created by Yoshitaka Tanaka on 2022/01/12.
//

import Quick
@testable import PadelLessonLog
import Combine

class LessonDataViewTest: QuickSpec {
    override func spec() {
        let lessonDataView = LessonDataViewController.makeInstance(dependency: .init(viewModel: LessonDataViewModel(dependency: .init(coreDataProtocol: CoreDataManager.shared))))
        
        describe("LessonDataView") {
            describe("動作検証") {
                context("ライフサイクルをトリガする") {
                    beforeEach {
                        lessonDataView.view.layoutIfNeeded()
                    }
                    it("UIの状態が期待通りであること") {
                        XCTAssertEqual(lessonDataView.allBarButton.tintColor, .colorButtonOn)
                        XCTAssertEqual(lessonDataView.favoriteBarButton.tintColor, .colorButtonOff)
                        XCTAssertEqual(lessonDataView.searchButton.tintColor, .colorButtonOff)
                        XCTAssertEqual(lessonDataView.searchBar.isHidden, true)
                    }
                }
                context("Favoriteボタンをタップ") {
                    beforeEach {
                        lessonDataView.favoriteButtonPressed(lessonDataView.favoriteBarButton)
                    }
                    it("UIの状態が期待通りであること") {
                        XCTAssertEqual(lessonDataView.allBarButton.tintColor, .colorButtonOff)
                        XCTAssertEqual(lessonDataView.favoriteBarButton.tintColor, .colorButtonOn)
                    }
                }
                context("Allボタンをタップ") {
                    beforeEach {
                        lessonDataView.allButtonPressed(lessonDataView.allBarButton)
                    }
                    it("UIの状態が期待通りであること") {
                        XCTAssertEqual(lessonDataView.allBarButton.tintColor, .colorButtonOn)
                        XCTAssertEqual(lessonDataView.favoriteBarButton.tintColor, .colorButtonOff)
                    }
                }
                context("検索ボタンをタップ") {
                    beforeEach {
                        lessonDataView.searchButtonPressed(lessonDataView.searchButton)
                    }
                    it("UIの状態が期待通りであること") {
                        XCTAssertEqual(lessonDataView.searchButton.tintColor, .colorButtonOn)
                        XCTAssertEqual(lessonDataView.searchBar.isHidden, false)
                    }
                }
            }
        }
    }
}


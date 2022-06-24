//
//  LessonImageViewTest.swift
//  PadelLessonLogTests
//
//  Created by Yoshitaka Tanaka on 2022/01/10.
//

import Quick
@testable import PadelLessonLog
import Combine

class LessonImageViewTest: QuickSpec {
    override func spec() {
        let lessonImageView = LessonImageViewController.makeInstance(dependency: .init(viewModel: LessonImageViewModel(dependency: .init(coreDataProtocol: CoreDataManager.shared))))
        
        describe("LessonImageView") {
            describe("動作検証") {
                context("ライフサイクルをトリガする") {
                    beforeEach {
                        lessonImageView.view.layoutIfNeeded()
                    }
                    it("UIの状態が期待通りであること") {
                        XCTAssertEqual(lessonImageView.allBarButton.tintColor, .colorButtonOn)
                        XCTAssertEqual(lessonImageView.favoriteBarButton.tintColor, .colorButtonOff)
                    }
                }
                context("Favoriteボタンをタップ") {
                    beforeEach {
                        lessonImageView.favoriteButtonPressed(lessonImageView.favoriteBarButton)
                    }
                    it("UIの状態が期待通りであること") {
                        XCTAssertEqual(lessonImageView.allBarButton.tintColor, .colorButtonOff)
                        XCTAssertEqual(lessonImageView.favoriteBarButton.tintColor, .colorButtonOn)
                    }
                }
                context("Allボタンをタップ") {
                    beforeEach {
                        lessonImageView.allButtonPressed(lessonImageView.allBarButton)
                    }
                    it("UIの状態が期待通りであること") {
                        XCTAssertEqual(lessonImageView.allBarButton.tintColor, .colorButtonOn)
                        XCTAssertEqual(lessonImageView.favoriteBarButton.tintColor, .colorButtonOff)
                    }
                }
            }
        }
    }
}


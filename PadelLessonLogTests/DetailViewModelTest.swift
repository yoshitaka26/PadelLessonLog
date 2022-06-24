//
//  DetailViewModelTest.swift
//  PadelLessonLogTests
//
//  Created by Yoshitaka Tanaka on 2022/01/05.
//

import Quick
@testable import PadelLessonLog
import Combine

class DetailViewModelTest: QuickSpec {
    override func spec() {
        describe("DetailViewModel") {
            let detailViewModel = DetailViewModel()
            let stubManager = StubManager()
            var subscriptions = Set<AnyCancellable>()
            
            var flag: Bool?
            
            describe("動作検証") {
                context("画像追加ボタンをタップ") {
                    beforeEach {
                        subscriptions.removeAll()
                        detailViewModel.transition.sink { value in
                            switch value {
                            case .imageView(_):
                                flag = true
                            default:
                                flag = false
                            }
                        }.store(in: &subscriptions)
                        
                        flag = nil
                        detailViewModel.lessonData.send(stubManager.createStubLessonData())
                        detailViewModel.imageViewButtonPressed.send()
                    }
                    it("画像表示画面に遷移") {
                        XCTAssertEqual(flag, true)
                    }
                }
                context("編集ボタンをタップ") {
                    beforeEach {
                        subscriptions.removeAll()
                        detailViewModel.transition.sink { value in
                            switch value {
                            case .editView(_):
                                flag = true
                            default:
                                flag = false
                            }
                        }.store(in: &subscriptions)
                        
                        flag = nil
                        detailViewModel.lessonData.send(stubManager.createStubLessonData())
                        detailViewModel.editViewButtonPressed.send()
                    }
                    it("修正画面に遷移") {
                        XCTAssertEqual(flag, true)
                    }
                }
                context("前の画面に戻る") {
                    beforeEach {
                        subscriptions.removeAll()
                        detailViewModel.transition.sink { value in
                            switch value {
                            case .back:
                                flag = true
                            default:
                                flag = false
                            }
                        }.store(in: &subscriptions)
                        
                        flag = nil
                        detailViewModel.lessonData.send(stubManager.createStubLessonData())
                        detailViewModel.backButtonPressed.send()
                    }
                    it(".backが流れてくること") {
                        XCTAssertEqual(flag, true)
                    }
                }
            }
        }
    }
}

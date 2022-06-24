//
//  NewLessonViewModelTest.swift
//  PadelLessonLogTests
//
//  Created by Yoshitaka Tanaka on 2022/01/07.
//

import Quick
@testable import PadelLessonLog
import Combine
import CoreData

class NewLessonViewModelTest: QuickSpec {
    override func spec() {
        describe("NewLessonViewModel") {
            let newLessonViewModel = NewLessonViewModel()
            let stubManager = StubManager()
            var subscriptions = Set<AnyCancellable>()
            
            var flag: Bool?
            
            //TODO: addStepButtonPressed・lessonStepDidEndEditing・lessonStepDidDelete・deleteData・saveData を叩いての遷移はCoreDataManagerで新規レコードが追加されてしまうのでテストできない
            describe("動作検証") {
                context("ViewからViewModelにデータを渡す(初期表示)") {
                    beforeEach {
                        subscriptions.removeAll()
                        newLessonViewModel.loadView.sink { _ in
                            flag = true
                        }.store(in: &subscriptions)
                        flag = nil
                        newLessonViewModel.lessonData.send(stubManager.createStubLessonData())
                    }
                    it("画像追加ボタンがfalse(削除)、画像修正ボタンが表示状態であること") {
                        XCTAssertEqual(flag, true)
                        XCTAssertEqual(newLessonViewModel.lessonTitleText.value, "TEST DATA")
                        XCTAssertEqual(newLessonViewModel.imageButtonIsOn.value, false)
                        XCTAssertEqual(newLessonViewModel.editImageButtonIsHidden.value, true)
                    }
                }
                context("タイトル入力_40文字以上") {
                    beforeEach {
                        subscriptions.removeAll()
                        newLessonViewModel.showAlert.sink { alert in
                            if alert == .titleStringCountOver {
                                flag = true
                            }
                        }.store(in: &subscriptions)
                        flag = nil
                        newLessonViewModel.textFieldDidEndEditing.send("TEST TITLE OVER 40 CHARACTORS IT WILL BE OUT OF MAX COOUNT")
                    }
                    it("入力文字数オーバーアラートが表示されること") {
                        XCTAssertEqual(flag, true)
                    }
                }
                context("タイトル入力_20文字前後") {
                    beforeEach {
                        subscriptions.removeAll()
                        newLessonViewModel.showAlert.sink { alert in
                            if alert == .titleStringCountOver {
                                flag = true
                            }
                        }.store(in: &subscriptions)
                        flag = false
                        newLessonViewModel.textFieldDidEndEditing.send("TEST TITLE OVER 20 CHARACTORS")
                    }
                    it("入力文字数オーバーアラートが表示されないこと") {
                        XCTAssertEqual(flag, false)
                    }
                }
                context("タイトル入力_空文字") {
                    beforeEach {
                        subscriptions.removeAll()
                        newLessonViewModel.showAlert.sink { alert in
                            if alert == .titleEmpty {
                                flag = true
                            }
                        }.store(in: &subscriptions)
                        flag = false
                        newLessonViewModel.textFieldDidEndEditing.send("")
                    }
                    it("入力文字数オーバーアラートが表示されないこと") {
                        XCTAssertEqual(flag, false)
                    }
                }
                
                context("画像追加ボタンタップ") {
                    beforeEach {
                        subscriptions.removeAll()
                        newLessonViewModel.transition.sink { value in
                            switch value {
                            case .addEditImage(_):
                                flag = true
                            default:
                                flag = false
                            }
                        }.store(in: &subscriptions)
                        
                        flag = nil
                        newLessonViewModel.imageButtonPressed.send(false)
                    }
                    it("画像追加画面に遷移") {
                        XCTAssertEqual(flag, true)
                    }
                }
                context("画像削除ボタンタップ") {
                    beforeEach {
                        subscriptions.removeAll()
                        newLessonViewModel.showAlert.sink { alert in
                            if alert == .deleteImage {
                                flag = true
                            }
                        }.store(in: &subscriptions)
                        
                        flag = nil
                        newLessonViewModel.imageButtonPressed.send(true)
                    }
                    it("画像削除アラート表示") {
                        XCTAssertEqual(flag, true)
                    }
                }
                context("編集ボタンタップ") {
                    beforeEach {
                        subscriptions.removeAll()
                        newLessonViewModel.transition.sink { value in
                            switch value {
                            case .addEditImage(_):
                                flag = true
                            default:
                                flag = false
                            }
                        }.store(in: &subscriptions)
                        
                        flag = nil
                        newLessonViewModel.editImageButtonPressed.send()
                    }
                    it("画像編集画面に遷移") {
                        XCTAssertEqual(flag, true)
                    }
                }
                context("StepTable編集ボタンタップ") {
                    beforeEach {
                        subscriptions.removeAll()
                        newLessonViewModel.editStepButtonIsOn.sink { value in
                            if value {
                                flag = true
                            }
                        }.store(in: &subscriptions)
                        
                        flag = nil
                        newLessonViewModel.editStepButtonPressed.send(false)
                    }
                    it("TableViewが編集モードになっている") {
                        XCTAssertEqual(flag, true)
                    }
                }
            }
        }
    }
}

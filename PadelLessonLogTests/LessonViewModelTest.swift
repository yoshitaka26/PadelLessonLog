//
//  LessonViewModelTest.swift
//  PadelLessonLogTests
//
//  Created by Yoshitaka Tanaka on 2022/01/04.
//

import Quick
@testable import PadelLessonLog
import Combine

class LessonViewModelTest: QuickSpec {
    override func spec() {
        describe("LessonViewModel") {
            let lessonViewModel = LessonViewModel()
            let stubManager = StubManager()
            var subscriptions = Set<AnyCancellable>()
            
            var recievedReloadStreamFlag: Bool?
            var recievedAllButtonStateStreamFlag: Bool?
            var recievedFavoriteButtonStateStreamFlag: Bool?
            var flag: Bool?
            
            //TODO: addLessonButtonPressed・pushToEditLessonViewを叩いての遷移はCoreDataManagerで新規レコードが追加されてしまうのでテストできない
            describe("動作検証") {
                context("Allボタンタップ") {
                    beforeEach {
                        subscriptions.removeAll()
                        lessonViewModel.dataReload.sink { _ in
                            recievedReloadStreamFlag = true
                        }.store(in: &subscriptions)
                        
                        lessonViewModel.allBarButtonIsOn.sink { value in
                            recievedAllButtonStateStreamFlag = value
                        }.store(in: &subscriptions)
                        
                        lessonViewModel.favoriteBarButtonIsOn.sink { value in
                            recievedFavoriteButtonStateStreamFlag = value
                        }.store(in: &subscriptions)
                        
                        recievedReloadStreamFlag = nil
                        recievedAllButtonStateStreamFlag = nil
                        recievedFavoriteButtonStateStreamFlag = nil
                        lessonViewModel.allButtonPressed.send()
                    }
                    it("テーブルデータがリロードされること") {
                        XCTAssertEqual(recievedReloadStreamFlag, true)
                    }
                    it("テーブルモードがAllになっていること") {
                        XCTAssertEqual(lessonViewModel.tableMode.value, .allTableView)
                    }
                    it("ボタンのOnOff値が正しいこと") {
                        XCTAssertEqual(recievedAllButtonStateStreamFlag, true)
                        XCTAssertEqual(recievedFavoriteButtonStateStreamFlag, false)
                    }
                }
                context("Favoriteボタンタップ") {
                    beforeEach {
                        subscriptions.removeAll()
                        lessonViewModel.dataReload.sink { _ in
                            recievedReloadStreamFlag = true
                        }.store(in: &subscriptions)
                        
                        lessonViewModel.allBarButtonIsOn.sink { value in
                            recievedAllButtonStateStreamFlag = value
                        }.store(in: &subscriptions)
                        
                        lessonViewModel.favoriteBarButtonIsOn.sink { value in
                            recievedFavoriteButtonStateStreamFlag = value
                        }.store(in: &subscriptions)
                        
                        recievedReloadStreamFlag = nil
                        recievedAllButtonStateStreamFlag = nil
                        recievedFavoriteButtonStateStreamFlag = nil
                        lessonViewModel.favoriteButtonPressed.send()
                    }
                    it("テーブルデータがリロードされること") {
                        XCTAssertEqual(recievedReloadStreamFlag, true)
                    }
                    it("テーブルモードがAllになっていること") {
                        XCTAssertEqual(lessonViewModel.tableMode.value, .favoriteTableView)
                    }
                    it("ボタンのOnOff値が正しいこと") {
                        XCTAssertEqual(recievedAllButtonStateStreamFlag, false)
                        XCTAssertEqual(recievedFavoriteButtonStateStreamFlag, true)
                    }
                }
                
                context("設定画面に遷移") {
                    beforeEach {
                        subscriptions.removeAll()
                        lessonViewModel.transition.sink { value in
                            switch value {
                            case .setting:
                                flag = true
                            default:
                                break
                            }
                        }.store(in: &subscriptions)
                        
                        flag = nil
                        lessonViewModel.settingButtonPressed.send()
                    }
                    it(".settingが流れてくること") {
                        XCTAssertEqual(flag, true)
                    }
                }
                context("詳細画面に遷移") {
                    beforeEach {
                        subscriptions.removeAll()
                        lessonViewModel.transition.sink { value in
                            switch value {
                            case .detail(_):
                                flag = true
                            default:
                                break
                            }
                        }.store(in: &subscriptions)
                        
                        flag = nil
                        lessonViewModel.detailButtonPressed.send(stubManager.createStubLessonData())
                    }
                    it(".detail(Lesson)が流れてくること") {
                        XCTAssertEqual(flag, true)
                    }
                }
            }
        }
    }
}

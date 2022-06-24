//
//  LessonDataViewModelTest.swift
//  PadelLessonLogTests
//
//  Created by Yoshitaka Tanaka on 2022/01/05.
//


import Quick
@testable import PadelLessonLog
import Combine

class LessonDataViewModelTest: QuickSpec {
    override func spec() {
        describe("LessonDataViewModel") {
            let lessonDataViewModel = LessonDataViewModel(dependency: LessonDataViewModel.Dependency.init(coreDataProtocol: CoreDataManager.shared))
            let stubManager = StubManager()
            var subscriptions = Set<AnyCancellable>()
            
            var recievedReloadStreamFlag: Bool?
            var recievedAllButtonStateStreamFlag: Bool?
            var recievedFavoriteButtonStateStreamFlag: Bool?
            var flag: Bool?
            
            //TODO: reorderDataを叩いてデータの並び替えをテストしたいが、CoreDataManagerでUpdateが走るのでできない
            describe("動作検証") {
                context("Allボタンタップ") {
                    beforeEach {
                        subscriptions.removeAll()
                        lessonDataViewModel.dataReload.sink { _ in
                            recievedReloadStreamFlag = true
                        }.store(in: &subscriptions)
                        lessonDataViewModel.allBarButtonIsOn.sink { value in
                            recievedAllButtonStateStreamFlag = value
                        }.store(in: &subscriptions)
                        lessonDataViewModel.favoriteBarButtonIsOn.sink { value in
                            recievedFavoriteButtonStateStreamFlag = value
                        }.store(in: &subscriptions)
                        
                        recievedReloadStreamFlag = nil
                        recievedAllButtonStateStreamFlag = nil
                        recievedFavoriteButtonStateStreamFlag = nil
                        lessonDataViewModel.allButtonPressed.send()
                    }
                    it("テーブルデータがリロードされること") {
                        XCTAssertEqual(recievedReloadStreamFlag, true)
                    }
                    it("テーブルモードがAllになっていること") {
                        XCTAssertEqual(lessonDataViewModel.tableMode.value, .allTableView)
                    }
                    it("ボタンのOnOff値が正しいこと") {
                        XCTAssertEqual(recievedAllButtonStateStreamFlag, true)
                        XCTAssertEqual(recievedFavoriteButtonStateStreamFlag, false)
                    }
                }
                context("Favoriteボタンタップ") {
                    beforeEach {
                        subscriptions.removeAll()
                        lessonDataViewModel.dataReload.sink { _ in
                            recievedReloadStreamFlag = true
                        }.store(in: &subscriptions)
                        lessonDataViewModel.allBarButtonIsOn.sink { value in
                            recievedAllButtonStateStreamFlag = value
                        }.store(in: &subscriptions)
                        lessonDataViewModel.favoriteBarButtonIsOn.sink { value in
                            recievedFavoriteButtonStateStreamFlag = value
                        }.store(in: &subscriptions)
                        
                        recievedReloadStreamFlag = nil
                        recievedAllButtonStateStreamFlag = nil
                        recievedFavoriteButtonStateStreamFlag = nil
                        lessonDataViewModel.favoriteButtonPressed.send()
                    }
                    it("テーブルデータがリロードされること") {
                        XCTAssertEqual(recievedReloadStreamFlag, true)
                    }
                    it("テーブルモードがAllになっていること") {
                        XCTAssertEqual(lessonDataViewModel.tableMode.value, .favoriteTableView)
                    }
                    it("ボタンのOnOff値が正しいこと") {
                        XCTAssertEqual(recievedAllButtonStateStreamFlag, false)
                        XCTAssertEqual(recievedFavoriteButtonStateStreamFlag, true)
                    }
                }
                context("設定画面に遷移") {
                    beforeEach {
                        subscriptions.removeAll()
                        lessonDataViewModel.transition.sink { value in
                            switch value {
                            case .setting:
                                flag = true
                            default:
                                break
                            }
                        }.store(in: &subscriptions)
                        
                        flag = nil
                        lessonDataViewModel.settingButtonPressed.send()
                    }
                    it(".settingが流れてくること") {
                        XCTAssertEqual(flag, true)
                    }
                }
                context("詳細画面に遷移") {
                    beforeEach {
                        subscriptions.removeAll()
                        lessonDataViewModel.lessonsArray.send([stubManager.createStubLessonData(),stubManager.createStubDummmyLessonData()])
                        lessonDataViewModel.transition.sink { value in
                            switch value {
                            case .detail(_):
                                flag = true
                            default:
                                break
                            }
                        }.store(in: &subscriptions)
                        
                        flag = nil
                        lessonDataViewModel.didSelectRowAt.send(IndexPath(row: 0, section: 0))
                    }
                    it(".detail(dummyLesson)が流れてくること") {
                        XCTAssertEqual(flag, true)
                    }
                }
                context("追加画面から戻ってきたら自動スクロール") {
                    beforeEach {
                        subscriptions.removeAll()
                        lessonDataViewModel.lessonsArray.send([stubManager.createStubLessonData(),stubManager.createStubDummmyLessonData()])
                        lessonDataViewModel.scrollToTableIndex.sink { _ in
                            flag = true
                        }.store(in: &subscriptions)
                        
                        flag = nil
                        lessonDataViewModel.pushBackFromNewLessonView.send()
                    }
                    it("スクロールされること") {
                        XCTAssertEqual(flag, true)
                    }
                }
                context("TESTで検索してフィルタリングされるか") {
                    beforeEach {
                        subscriptions.removeAll()
                        lessonDataViewModel.lessonsArray.send([stubManager.createStubLessonData(),stubManager.createStubDummmyLessonData()])
                        lessonDataViewModel.lessonsArray.sink { value in
                            guard !value.isEmpty else { return }
                            guard value[0].title == "TEST DATA" else { return }
                            flag = true
                        }.store(in: &subscriptions)
                        
                        flag = nil
                        lessonDataViewModel.searchAndFilterData.send("TEST")
                    }
                    it("検索結果でフィルタリングされること") {
                        XCTAssertEqual(flag, true)
                    }
                }
            }
        }
    }
}

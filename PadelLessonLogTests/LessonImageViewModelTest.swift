//
//  LessonImageViewModelTest.swift
//  PadelLessonLogTests
//
//  Created by Yoshitaka Tanaka on 2022/01/05.
//


import Quick
@testable import PadelLessonLog
import Combine

class LessonImageViewModelTest: QuickSpec {
    override func spec() {
        describe("LessonImageViewModel") {
            let lessonImageViewModel = LessonImageViewModel(dependency: .init(coreDataProtocol: CoreDataManager.shared))
            let stubManager = StubManager()
            var subscriptions = Set<AnyCancellable>()
            
            var recievedReloadStreamFlag: Bool?
            var recievedAllButtonStateStreamFlag: Bool?
            var recievedFavoriteButtonStateStreamFlag: Bool?
            var flag: Bool?
            
            describe("動作検証") {
                context("Allボタンタップ") {
                    beforeEach {
                        subscriptions.removeAll()
                        lessonImageViewModel.dataReload.sink { _ in
                            recievedReloadStreamFlag = true
                        }.store(in: &subscriptions)
                        lessonImageViewModel.allBarButtonIsOn.sink { value in
                            recievedAllButtonStateStreamFlag = value
                        }.store(in: &subscriptions)
                        lessonImageViewModel.favoriteBarButtonIsOn.sink { value in
                            recievedFavoriteButtonStateStreamFlag = value
                        }.store(in: &subscriptions)
                        
                        recievedReloadStreamFlag = nil
                        recievedAllButtonStateStreamFlag = nil
                        recievedFavoriteButtonStateStreamFlag = nil
                        
                        lessonImageViewModel.allButtonPressed.send()
                    }
                    it("テーブルデータがリロードされること") {
                        XCTAssertEqual(recievedReloadStreamFlag, true)
                    }
                    it("テーブルモードがAllになっていること") {
                        XCTAssertEqual(lessonImageViewModel.tableMode.value, .allTableView)
                    }
                    it("ボタンのOnOff値が正しいこと") {
                        XCTAssertEqual(recievedAllButtonStateStreamFlag, true)
                        XCTAssertEqual(recievedFavoriteButtonStateStreamFlag, false)
                    }
                }
                context("Favoriteボタンタップ") {
                    beforeEach {
                        subscriptions.removeAll()
                        lessonImageViewModel.dataReload.sink { _ in
                            recievedReloadStreamFlag = true
                        }.store(in: &subscriptions)
                        lessonImageViewModel.allBarButtonIsOn.sink { value in
                            recievedAllButtonStateStreamFlag = value
                        }.store(in: &subscriptions)
                        lessonImageViewModel.favoriteBarButtonIsOn.sink { value in
                            recievedFavoriteButtonStateStreamFlag = value
                        }.store(in: &subscriptions)
                        
                        recievedReloadStreamFlag = nil
                        recievedAllButtonStateStreamFlag = nil
                        recievedFavoriteButtonStateStreamFlag = nil
                        
                        lessonImageViewModel.favoriteButtonPressed.send()
                    }
                    it("テーブルデータがリロードされること") {
                        XCTAssertEqual(recievedReloadStreamFlag, true)
                    }
                    it("テーブルモードがAllになっていること") {
                        XCTAssertEqual(lessonImageViewModel.tableMode.value, .favoriteTableView)
                    }
                    it("ボタンのOnOff値が正しいこと") {
                        XCTAssertEqual(recievedAllButtonStateStreamFlag, false)
                        XCTAssertEqual(recievedFavoriteButtonStateStreamFlag, true)
                    }
                }
                
                context("設定画面に遷移") {
                    beforeEach {
                        subscriptions.removeAll()
                        lessonImageViewModel.transition.sink { value in
                            switch value {
                            case .setting:
                                flag = true
                            default:
                                break
                            }
                        }.store(in: &subscriptions)
                        
                        flag = nil
                        lessonImageViewModel.settingButtonPressed.send()
                    }
                    
                    it(".settingが流れてくること") {
                        XCTAssertEqual(flag, true)
                    }
                }
                context("詳細画面に遷移") {
                    beforeEach {
                        subscriptions.removeAll()
                        lessonImageViewModel.transition.sink { value in
                            switch value {
                            case .detail(_):
                                flag = true
                            default:
                                break
                            }
                        }.store(in: &subscriptions)
                        
                        flag = nil
                        lessonImageViewModel.detailButtonPressed.send(stubManager.createStubLessonData())
                    }
                    it(".detail(dummyLesson)が流れてくること") {
                        XCTAssertEqual(flag, true)
                    }
                }
                
                context("3D画面に遷移") {
                    beforeEach {
                        subscriptions.removeAll()
                        lessonImageViewModel.transition.sink { value in
                            switch value {
                            case .arView:
                                flag = true
                            default:
                                break
                            }
                        }.store(in: &subscriptions)
                        
                        flag = nil
                        lessonImageViewModel.arButtonPressed.send()
                    }
                    it(".arが流れてくること") {
                        XCTAssertEqual(flag, true)
                    }
                }
                
                context("追加画面から戻ってきたら自動スクロール") {
                    beforeEach {
                        subscriptions.removeAll()
                        lessonImageViewModel.lessonsArray.send([stubManager.createStubLessonData(),stubManager.createStubDummmyLessonData()])
                        lessonImageViewModel.scrollToCellIndex.sink { _ in
                            flag = true
                        }.store(in: &subscriptions)
                        
                        flag = nil
                        lessonImageViewModel.pushBackFromNewLessonView.send()
                    }
                    it("スクロールされること") {
                        XCTAssertEqual(flag, true)
                    }
                }
                
                context("画面スクロール 開始 右") {
                    var direction: Bool?
                    beforeEach {
                        subscriptions.removeAll()
                        lessonImageViewModel.detailButtonIsHidden.sink { value in
                            flag = value
                        }.store(in: &subscriptions)
                        lessonImageViewModel.scrollDirection.sink { value in
                            direction = value
                        }.store(in: &subscriptions)
                        flag = nil
                        lessonImageViewModel.scrollViewDidTouch.send(CGPoint(x: 0, y: 0))
                        lessonImageViewModel.scrollViewDidScroll.send(CGPoint(x: 1, y: 0))
                    }
                    it("スクロールされること") {
                        XCTAssertEqual(flag, true)
                        XCTAssertEqual(direction, true)
                    }
                }
                context("画面スクロール　右　停止") {
                    var scrollCell: Int?
                    beforeEach {
                        subscriptions.removeAll()
                        lessonImageViewModel.detailButtonIsHidden.sink { value in
                            flag = value
                        }.store(in: &subscriptions)
                        lessonImageViewModel.scrollToCellIndex.sink { value in
                            scrollCell = value
                        }.store(in: &subscriptions)
                        flag = nil
                        lessonImageViewModel.scrollViewDidStop.send([0,1,2])
                    }
                    it("スクロールされること") {
                        XCTAssertEqual(flag, false)
                        XCTAssertEqual(scrollCell, 2)
                    }
                }
                context("画面スクロール 開始 左") {
                    var direction: Bool?
                    beforeEach {
                        subscriptions.removeAll()
                        lessonImageViewModel.detailButtonIsHidden.sink { value in
                            flag = value
                        }.store(in: &subscriptions)
                        lessonImageViewModel.scrollDirection.sink { value in
                            direction = value
                        }.store(in: &subscriptions)
                        flag = nil
                        lessonImageViewModel.scrollViewDidTouch.send(CGPoint(x: 1, y: 0))
                        lessonImageViewModel.scrollViewDidScroll.send(CGPoint(x: 0, y: 0))
                    }
                    it("スクロールされること") {
                        XCTAssertEqual(flag, true)
                        XCTAssertEqual(direction, false)
                    }
                }
                context("画面スクロール　左　停止") {
                    var scrollCell: Int?
                    beforeEach {
                        subscriptions.removeAll()
                        lessonImageViewModel.detailButtonIsHidden.sink { value in
                            flag = value
                        }.store(in: &subscriptions)
                        lessonImageViewModel.scrollToCellIndex.sink { value in
                            scrollCell = value
                        }.store(in: &subscriptions)
                        flag = nil
                        lessonImageViewModel.scrollViewDidStop.send([0,1,2])
                    }
                    it("スクロールされること") {
                        XCTAssertEqual(flag, false)
                        XCTAssertEqual(scrollCell, 0)
                    }
                }
            }
        }
    }
}

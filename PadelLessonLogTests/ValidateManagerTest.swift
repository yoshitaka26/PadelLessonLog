//
//  ValidateManagerTest.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/12.
//  
//

import Quick
@testable import PadelLessonLog
import Combine

class ValidateManagerTest: QuickSpec {
    override func spec() {
        describe("ValidateManager") {
            // テスト用の変数
            let validation = CharacterCountValidation()
            var inputString: String!
            var subject: ValidateResult {
                return validation.validate(word: inputString, maxCount: 8)
            }
            
            // 概要
            describe("入力文字検証") {
                // 条件1:空文字列
                context("空文字列") {
                    // この階層以下に定義されたitの直前に呼ばれる
                    beforeEach { inputString = "" }
                    
                    // 期待する結果
                    it("invalidが返ってくること") {
                        XCTAssertEqual(subject, .emptyError)
                    }
                }
                
                // 条件2:ブランク文字列
                context("ブランク文字") {
                    // この階層以下に定義されたitの直前に呼ばれる
                    beforeEach { inputString = " " }
                    // 期待する結果
                    it("validが返ってくること") {
                        XCTAssertEqual(subject, .valid)
                    }
                }
                // 条件3:4文字
                context("8文字") {
                    // この階層以下に定義されたitの直前に呼ばれる
                    beforeEach { inputString = "ABCDEFGH" }
                    // 期待する結果
                    it("validが返ってくること") {
                        XCTAssertEqual(subject, .valid)
                    }
                }
                // 条件4:9文字
                context("9文字") {
                    // この階層以下に定義されたitの直前に呼ばれる
                    beforeEach { inputString = "ABCDEFGHI" }
                    // 期待する結果
                    it("最大文字数オーバーが返ってくること") {
                        XCTAssertEqual(subject, .countOverError)
                    }
                }
            }
        }
    }
}

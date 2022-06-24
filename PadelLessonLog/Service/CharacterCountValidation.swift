//
//  CharacterCountValidation.swift
//  PadelLessonLog
//
//  Created by Yoshitaka Tanaka on 2021/12/27.
//

import Foundation

enum ValidateResult {
    case valid
    case emptyError
    case countOverError
}

final class CharacterCountValidation {
    func validate(word: String, maxCount: Int) -> ValidateResult {
        guard !word.isEmpty else { return .emptyError }
        guard word.count != 0 else { return .emptyError }
        guard maxCount != 0 else { return .valid }
        guard word.count <= maxCount else { return .countOverError }

        return .valid
    }
}

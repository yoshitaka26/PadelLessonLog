//
//  ValidationManager.swift
//  PadelLessonLog
//
//  Created by Yoshitaka on 2021/08/12.
//


import Foundation

enum ValidationResult {
    case valid
    case invalid
}

protocol ValidationErrorProtocol: LocalizedError { }

protocol Validator {
    func validate(_ value: String) -> ValidationResult
}

protocol CompositeValidator: Validator {
    var validators: [Validator] { get }
    func validate(_ value: String) -> ValidationResult
}

extension CompositeValidator {
    func validate(_ value: String) -> [ValidationResult] {
        return validators.map { $0.validate(value) }
    }
    func validate(_ value: String) -> ValidationResult {
        let results: [ValidationResult] = validate(value)
        
        let errors = results.filter { result -> Bool in
            switch result {
            case .valid:
                return false
            case .invalid:
                return true
            }
        }
        return errors.first ?? .valid
    }
}

struct EmptyValidator: Validator {
    func validate(_ value: String) -> ValidationResult {
        if value.isEmpty == true {
            return .invalid
        } else {
            return .valid
        }
    }
}

struct LengthValidator: Validator {
    let min: Int
    let max: Int
    
    func validate(_ value: String) -> ValidationResult {
        if value.count >= min && value.count <= max {
            return .valid
        } else {
            return .invalid
        }
    }
}

struct CharacterValidatior: Validator {
    
    func validate(_ value: String) -> ValidationResult {
        guard let name: NSString = (value as NSString?) else { return .invalid }
        // CP932でNSDataとの相互変換を行い
        guard let convertedNameData = name.data(using: String.Encoding.shiftJIS.rawValue), let convertedName = NSString(data: convertedNameData, encoding: String.Encoding.shiftJIS.rawValue) else {
            return .invalid
        }
        // 同じ文字になっている（CP932でサポートされている文字のみで構成）ならOK
        guard name.isEqual(to: convertedName as String) else { return .invalid }
        return .valid
    }
}

class ValidationManager: CompositeValidator {
//    static let shared = ValidationManager()
    private var defMaxNum = 1
    private var emptyCheck = false
    var maxTextNum: Int {
        get {
            return defMaxNum
        }
        set {
            defMaxNum = newValue
        }
    }
    var emptyFlag: Bool {
        get {
            return emptyCheck
        }
        set {
            emptyCheck = newValue
        }
    }
    lazy var validators = { () -> [Validator] in
        if emptyCheck {
            return [EmptyValidator()]
        } else {
            return  [LengthValidator(min: 0, max: maxTextNum), CharacterValidatior()]
        }
    }()
}
//
//  Validators.swift
//  BuddyCoffee
//
//  Created by Ryan on 7/13/19.
//  Copyright © 2019 Equity. All rights reserved.
//

// Consult the article: https://medium.com/swift2go/a-better-approach-to-text-field-validations-on-ios-81bd87598070
// Source: https://github.com/Arrlindii/AAValidators

import Foundation

class ValidationError: Error {
    var message: String
    
    init(_ message: String) {
        self.message = message
    }
}

protocol ValidatorConvertible {
    func validated(_ value: String) throws -> String
}

enum ValidationType {
    case email
    case password
    case phone
    case requiredField(field: String)
}

struct ValidatorFactory {
    static func validatorFor(type: ValidationType) -> ValidatorConvertible {
        switch type {
        case .email:
            return EmailValidator()
        case .password:
            return PasswordValidator()
        case .phone:
            return PhoneValidator()
        case .requiredField(let field):
            return RequiredFieldValidator(field)
        }
    }
}

struct EmailValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        do {
            if try NSRegularExpression(pattern: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$", options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
                throw ValidationError("Invalid e-mail Address")
            }
        } catch {
            throw ValidationError("Invalid e-mail Address")
        }
        return value
    }
}

struct PasswordValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard value != "" else {throw ValidationError("Password is Required")}
        guard value.count >= 6 else { throw ValidationError("Password must have at least 6 characters") }
        
        do {
            if try NSRegularExpression(pattern: "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{6,}$",  options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
                throw ValidationError("Password must have at least 6 characters, with at least one character and one numeric character")
            }
        } catch {
            throw ValidationError("Password must have at least 6 characters, with at least one character and one numeric character")
        }
        return value
    }
}

struct PhoneValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard value.count >= 6 else {
            throw ValidationError("Phone number must contain more than 6 digits" )
        }
        guard value.count < 18 else {
            throw ValidationError("Phone number shoudn't conain more than 40 digits" )
        }
        
        do {
            if try NSRegularExpression(pattern: "^[0-9]{6,18}$",  options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
                throw ValidationError("Invalid phone number, phone number should not contain whitespaces or characters")
            }
        } catch {
            throw ValidationError("Invalid phone number, phone number should not contain whitespaces or characters")
        }
        return value
    }
}

struct RequiredFieldValidator: ValidatorConvertible {
    private let fieldName: String
    
    init(_ field: String) {
        fieldName = field
    }
    
    func validated(_ value: String) throws -> String {
        guard !value.isEmpty else {
            throw ValidationError("Required field " + fieldName)
        }
        return value
    }
}

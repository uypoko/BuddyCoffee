//
//  UITextView+Extensions.swift
//  BuddyCoffee
//
//  Created by Ryan on 7/15/19.
//  Copyright © 2019 Equity. All rights reserved.
//

import UIKit.UITextView

extension UITextView {
    func validatedText(validationType: ValidationType) throws -> String {
        let validator = ValidatorFactory.validatorFor(type: validationType)
        return try validator.validated(self.text!)
    }
}

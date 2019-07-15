//
//  AddressTextView.swift
//  BuddyCoffee
//
//  Created by Ryan on 7/13/19.
//  Copyright © 2019 Equity. All rights reserved.
//

import UIKit

class AddressTextView: UITextView, UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if (textView.text == "Address" && textView.textColor == .lightGray)
        {
            textView.text = ""
            textView.textColor = .black
        }
        textView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if (textView.text == "")
        {
            textView.text = "Address"
            textView.textColor = .lightGray
        }
        textView.resignFirstResponder()
    }
    
    func configure() {
        delegate = self
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 0.25
        layer.cornerRadius = 5
        text = "Address"
        textColor = .lightGray
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

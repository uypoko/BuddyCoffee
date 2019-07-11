//
//  SignInSignUpViewController.swift
//  BuddyCoffee
//
//  Created by Ryan on 7/11/19.
//  Copyright © 2019 Equity. All rights reserved.
//

import UIKit

class SignInSignUpViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var emailPasswordStackView: UIStackView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var userInfoStackView: UIStackView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    
    @IBOutlet weak var emailPasswordCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailPasswordBottomToUserInfoConstraint: NSLayoutConstraint!
    @IBOutlet weak var submitTopToUserInfoConstraint: NSLayoutConstraint!
    @IBOutlet weak var submitTopToEmailPasswordConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userInfoStackView.isHidden = true

        // Do any additional setup after loading the view.
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            userInfoStackView.isHidden = true
            emailPasswordBottomToUserInfoConstraint.isActive = false
            submitTopToUserInfoConstraint.isActive = false
            emailPasswordCenterYConstraint.isActive = true
            submitTopToEmailPasswordConstraint.isActive = true
        case 1:
            userInfoStackView.isHidden = false
            emailPasswordCenterYConstraint.isActive = false
            submitTopToEmailPasswordConstraint.isActive = false
            emailPasswordBottomToUserInfoConstraint.isActive = true
            submitTopToUserInfoConstraint.isActive = true
        default:
            break
        }
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

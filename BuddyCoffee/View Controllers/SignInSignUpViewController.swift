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
    @IBOutlet weak var addressTextView: AddressTextView!
    
    @IBOutlet weak var emailPasswordCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailPasswordBottomToUserInfoConstraint: NSLayoutConstraint!
    @IBOutlet weak var submitTopToUserInfoConstraint: NSLayoutConstraint!
    @IBOutlet weak var submitTopToEmailPasswordConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userInfoStackView.isHidden = true
        addressTextView.configure()
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
        let activityView = UIActivityIndicatorView(style: .whiteLarge)
        activityView.center = view.center
        view.addSubview(activityView)
        activityView.startAnimating()
        do {
            let email = try emailTextField.validatedText(validationType: .email)
            let password = try passwordTextField.validatedText(validationType: .password)
            switch segmentedControl.selectedSegmentIndex {
            case 0:
                UserController.shared.signIn(email: email, password: password) { error in
                    activityView.stopAnimating()
                    if let error = error {
                        self.showAlert(message: error.localizedDescription, completion: nil)
                    } else {
                        // Dismiss to UserManagementViewController
                        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                    }
                }
            case 1:
                let name = try nameTextField.validatedText(validationType: .requiredField(field: "Name"))
                let phone = try phoneTextField.validatedText(validationType: .phone)
                let address = try addressTextView.validatedText(validationType: .requiredField(field: "Address"))
                UserController.shared.signUp(email: email, password: password, name: name, phone: Int(phone)!, address: address) { error in
                    if let error = error {
                        self.showAlert(message: error.localizedDescription, completion: nil)
                    } else {
                        self.showAlert(message: "\(email) created!") { action in
                            self.segmentedControl.selectedSegmentIndex = 0
                            self.segmentedControl.sendActions(for: .valueChanged)
                        }
                    }
                }
            default:
                break
            }
        } catch(let error) {
            showAlert(message: (error as! ValidationError).message, completion: nil)
        }
    }
    
    func showAlert(message: String, completion: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }

}

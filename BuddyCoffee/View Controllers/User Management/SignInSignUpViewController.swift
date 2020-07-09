//
//  SignInSignUpViewController.swift
//  BuddyCoffee
//
//  Created by Ryan on 7/11/19.
//  Copyright © 2019 Equity. All rights reserved.
//

import UIKit

class SignInSignUpViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var addressTextView: AddressTextView!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true
        addressTextView.configure()
        
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        removeObservers()
    }
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func onKeyboardAppear(_ notification: NSNotification) {
        let info = notification.userInfo!
        let rect: CGRect = info[UIResponder.keyboardFrameBeginUserInfoKey] as! CGRect
        let kbSize = rect.size
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
    }
    
    @objc func onKeyboardDisappear(_ notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    func updateUI() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            nameTextField.isHidden = true
            phoneTextField.isHidden = true
            addressTextView.isHidden = true
        case 1:
            nameTextField.isHidden = false
            phoneTextField.isHidden = false
            addressTextView.isHidden = false
        default:
            break
        }
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: Any) {
        updateUI()
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        do {
            let email = try emailTextField.validatedText(validationType: .email)
            let password = try passwordTextField.validatedText(validationType: .password)
            switch segmentedControl.selectedSegmentIndex {
            case 0:
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
                view.isUserInteractionEnabled = false
                UserController.shared.signIn(email: email, password: password) { [weak self] error in
                    guard let self = self else { return }
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.view.isUserInteractionEnabled = true
                    if let error = error {
                        self.showAlert(message: error.localizedDescription, completion: nil)
                    } else {
                        // Dismiss to UserManagementViewController
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            case 1:
                let name = try nameTextField.validatedText(validationType: .requiredField(field: "Name"))
                let phone = try phoneTextField.validatedText(validationType: .phone)
                let address = try addressTextView.validatedText(validationType: .requiredField(field: "Address"))
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
                view.isUserInteractionEnabled = false
                UserController.shared.signUp(email: email, password: password, name: name, phone: phone, address: address) { [weak self] error in
                    guard let self = self else { return }
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.view.isUserInteractionEnabled = true
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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }

}

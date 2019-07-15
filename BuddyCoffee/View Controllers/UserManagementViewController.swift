//
//  UserManagementViewController.swift
//  BuddyCoffee
//
//  Created by Uy Cung Dinh on 7/3/19.
//  Copyright © 2019 Equity. All rights reserved.
//

import UIKit

class UserManagementViewController: UIViewController {

    @IBOutlet weak var memberInfoView: UIView!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var changeProfilePictureButton: UIButton!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var addressTextView: AddressTextView!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var signInSignOutButton: UIButton!
    
    @IBOutlet var signInButtonTopToMemberInfoConstraint: NSLayoutConstraint!
    @IBOutlet var signInButtonTopToSuperviewConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addressTextView.configure()
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: UserController.authChangedNotification, object: nil)
    }
    
    @objc func updateUI() {
        DispatchQueue.main.async {
            if let buddyUser = UserController.shared.buddyUser {
                self.memberInfoView.isHidden = false
                self.signInButtonTopToSuperviewConstraint.isActive = false
                self.signInButtonTopToMemberInfoConstraint.isActive = true
                self.signInSignOutButton.setTitle("Sign Out", for: .normal)
                self.emailTextField.text = buddyUser.email
                self.nameTextField.text = buddyUser.name
                self.phoneTextField.text = "\(buddyUser.phone)"
                self.addressTextView.text = buddyUser.address
                self.addressTextView.textColor = .black
            } else {
                self.memberInfoView.isHidden = true
                self.signInButtonTopToMemberInfoConstraint.isActive = false
                self.signInButtonTopToSuperviewConstraint.isActive = true
                self.signInSignOutButton.setTitle("Sign In", for: .normal)
            }
        }
    }
    
    @IBAction func signInSignOutButtonTapped(_ sender: Any) {
        if signInSignOutButton.currentTitle == "Sign In" {
            // Create a FirebaseUI sign-in view controller
            performSegue(withIdentifier: "signInSegue", sender: nil)
        } else {
            UserController.shared.signOut()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UserController.shared.addAuthStateListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserController.shared.removeAuthStateListener()
    }
    
    @IBAction func changeProfilePictureTapped(_ sender: Any) {
    }
    
    @IBAction func viewOrderHistoryButtonTapped(_ sender: Any) {
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
    }
    
    @IBAction func unwindToUserManagementViewController(segue: UIStoryboardSegue) {
        
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

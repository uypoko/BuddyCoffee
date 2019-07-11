//
//  UserManagementViewController.swift
//  BuddyCoffee
//
//  Created by Uy Cung Dinh on 7/3/19.
//  Copyright © 2019 Equity. All rights reserved.
//

import UIKit
import FirebaseUI

class UserManagementViewController: UIViewController, FUIAuthDelegate {

    @IBOutlet weak var memberInfoView: UIView!
    @IBOutlet weak var signInSignOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: UserController.authChangedNotification, object: nil)
    }
    
    @objc func updateUI() {
        if UserController.shared.buddyUser != nil {
            memberInfoView.isHidden = false
            signInSignOutButton.setTitle("Sign Out", for: .normal)
        } else {
            memberInfoView.isHidden = true
            signInSignOutButton.setTitle("Sign In", for: .normal)
        }
    }
    
    @IBAction func signInSignOutButtonTapped(_ sender: Any) {
        if signInSignOutButton.currentTitle == "Sign In" {
            // Create a FirebaseUI sign-in view controller
            guard let authUI = FUIAuth.defaultAuthUI() else { return }
            authUI.delegate = self
            authUI.providers = [FUIEmailAuth()]
            let authUIViewController = authUI.authViewController()
            present(authUIViewController, animated: true, completion: nil)
        } else {
            UserController.shared.signOut()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    /*
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
    }
    */
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

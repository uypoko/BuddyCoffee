//
//  UpdatePasswordViewController.swift
//  BuddyCoffee
//
//  Created by Ryan on 7/16/19.
//  Copyright © 2019 Equity. All rights reserved.
//

import UIKit

class UpdatePasswordViewController: UIViewController {

    @IBOutlet weak var currentPasswordField: UITextField!
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var reTypeNewPasswordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        do {
            let currentPassword = try currentPasswordField.validatedText(validationType: .password)
            let newPassword = try newPasswordField.validatedText(validationType: .password)
            let reTypeNewPassword = try reTypeNewPasswordField.validatedText(validationType: .password)
            if newPassword != reTypeNewPassword {
                showAlert(message: "Retype New Password has to match New Password!", completion: nil)
                return
            }
            UserController.shared.updatePassword(currentPassword: currentPassword, newPassword: newPassword) { error in
                if let error = error {
                    self.showAlert(message: error.localizedDescription, completion: nil)
                } else {
                    self.showAlert(message: "Password updated!") { _ in
                        self.navigationController?.popViewController(animated: true)
                    }
                }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

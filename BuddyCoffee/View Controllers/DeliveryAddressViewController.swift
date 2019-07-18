//
//  DeliveryAddressViewController.swift
//  BuddyCoffee
//
//  Created by Uy Cung Dinh on 7/17/19.
//  Copyright © 2019 Equity. All rights reserved.
//

import UIKit

class DeliveryAddressViewController: UIViewController {

    var orderTotal: Int?
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var addressTextView: AddressTextView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true
        addressTextView.configure()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: DrinkController.orderUpdatedNotification, object: nil)
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UserController.shared.addAuthStateListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserController.shared.removeAuthStateListener()
    }
    
    @objc func updateUI() {
        if let user = UserController.shared.buddyUser {
            emailField.text = user.email
            emailField.isUserInteractionEnabled = false
            nameField.text = user.name
            phoneNumberField.text = "\(user.phone)"
            addressTextView.text = user.address
            addressTextView.textColor = .black
        }
    }
    
    @IBAction func placeOrderButtonTapped(_ sender: Any) {
        guard let total = orderTotal else { return }
        do {
            let email = try emailField.validatedText(validationType: .email)
            let name = try nameField.validatedText(validationType: .requiredField(field: "Name"))
            let phone = try phoneNumberField.validatedText(validationType: .phone)
            let address = try addressTextView.validatedText(validationType: .requiredField(field: "Address"))

            let alert = UIAlertController(title: "Confirm Order", message: "You're about to submit the order with the total of \(total)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Submit", style: .default) { action in
                self.uploadOrder(email: email, name: name, phone: Int(phone)!, address: address, total: total)
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        } catch (let error) {
            showAlert(message: (error as! ValidationError).message, completion: nil)
        }
    }
    
    func uploadOrder(email: String, name: String, phone: Int, address: String, total: Int) {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        DrinkController.shared.submitOrder(email: email, name: name, phone: phone, address: address, total: total) { error in
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            if let error = error {
                self.showAlert(message: error.localizedDescription, completion: nil)
            } else {
                self.performSegue(withIdentifier: "PlaceOrderSegue", sender: nil)
            }
        }
    }
    
    func showAlert(message: String, completion: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "PlaceOrderSegue" {
            let orderConfirmationViewController = segue.destination as! OrderConfirmationViewController
            orderConfirmationViewController.message = "We've got your order.\nPlease keep an eye on your phone 😄"
        }
    }

}

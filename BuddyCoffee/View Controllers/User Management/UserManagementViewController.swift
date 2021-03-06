//
//  UserManagementViewController.swift
//  BuddyCoffee
//
//  Created by Uy Cung Dinh on 7/3/19.
//  Copyright © 2019 Equity. All rights reserved.
//

import UIKit

class UserManagementViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var memberInfoView: UIView!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var changeProfilePictureButton: UIButton!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var addressTextView: AddressTextView!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var signInSignOutButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: View life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePictureImageView.isHidden = true
        memberInfoView.isHidden = true
        activityIndicator.isHidden = true
        // Do any additional setup after loading the view.
        addressTextView.configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: UserController.authChangedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfilePicture), name: UserController.profilePictureChangedNotification, object: nil)
            registerForKeyboardNotifications()
        UserController.shared.addAuthStateListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserController.shared.removeAuthStateListener()
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func updateUI() {
        DispatchQueue.main.async {
            if let buddyUser = UserController.shared.buddyUser {
                self.memberInfoView.isHidden = false
                self.signInSignOutButton.setTitle("Sign Out", for: .normal)
                self.emailTextField.text = buddyUser.email
                self.nameTextField.text = buddyUser.name
                self.phoneTextField.text = buddyUser.phone
                self.addressTextView.text = buddyUser.address
            } else {
                self.emailTextField.text = nil
                self.nameTextField.text = nil
                self.phoneTextField.text = nil
                self.addressTextView.text = "Address"
                self.memberInfoView.isHidden = true
                self.signInSignOutButton.setTitle("Sign In", for: .normal)
            }
        }
    }
    
    @objc func updateProfilePicture() {
        DispatchQueue.main.async {
            if UserController.shared.buddyUser == nil {
                self.profilePictureImageView.image = nil
                self.profilePictureImageView.isHidden = true
            } else {
                UserController.shared.fetchUserImage { image in
                    self.profilePictureImageView.image = image
                    if image != nil {
                        self.profilePictureImageView.isHidden = false
                    } else {
                        self.profilePictureImageView.isHidden = true
                    }
                }
            }
        }
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
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
    
    @IBAction func signInSignOutButtonTapped(_ sender: Any) {
        if signInSignOutButton.currentTitle == "Sign In" {
            // Create a FirebaseUI sign-in view controller
            performSegue(withIdentifier: "signInSegue", sender: nil)
        } else {
            UserController.shared.signOut()
        }
    }
    
    @IBAction func changeProfilePictureTapped(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let alertController = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { action in
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            }
            alertController.addAction(photoLibraryAction)
        }
        present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            var compressionQuality: CGFloat = 1.0
            let greaterSize = CGFloat.maximum(image.size.width, image.size.height)
            if greaterSize > 1024 {
                compressionQuality = 1 / (greaterSize / 1024)
            }
            guard let data = image.jpegData(compressionQuality: compressionQuality) else { return }
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            view.isUserInteractionEnabled = false
            UserController.shared.uploadProfilePicture(data: data) { error in
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.view.isUserInteractionEnabled = true
                if let error = error {
                    self.showAlert(message: error.localizedDescription, completion: nil)
                } else {
                    self.showAlert(message: "Profile Picture updated!", completion: nil)
                    NotificationCenter.default.post(name: UserController.profilePictureChangedNotification, object: nil)
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        do {
            let name = try nameTextField.validatedText(validationType: .requiredField(field: "Name"))
            let phone = try phoneTextField.validatedText(validationType: .phone)
            let address = try addressTextView.validatedText(validationType: .requiredField(field: "Address"))
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            view.isUserInteractionEnabled = false
            UserController.shared.updateInformation(name: name, phone: phone, address: address) { error in
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.view.isUserInteractionEnabled = true
                if error == nil {
                    self.showAlert(message: "Information updated!") { _ in
                        guard let user = UserController.shared.buddyUser else { return }
                        UserController.shared.loadUserInformation(userId: user.id)
                    }
                } else {
                    self.showAlert(message: "Couldn't update information", completion: nil)
                }
            }
        } catch(let error) {
            showAlert(message: (error as! ValidationError).message, completion: nil)
        }
        
    }
    
    @IBAction func updatePasswordTapped(_ sender: Any) {
        performSegue(withIdentifier: "UpdatePasswordSegue", sender: nil)
    }
    
    @IBAction func viewOrderHistoryButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "OrderHistorySegue", sender: nil)
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

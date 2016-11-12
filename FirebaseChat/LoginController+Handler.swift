//
//  LoginController+Handler.swift
//  FirebaseChat
//
//  Created by Ky Nguyen on 10/29/16.
//  Copyright © 2016 Ky Nguyen. All rights reserved.
//

import UIKit
import Firebase

extension LoginController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func handleLoginRegisterChange() {
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        
        inputContainerViewHeightAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
        
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        nameTextField.isHidden = loginRegisterSegmentedControl.selectedSegmentIndex == 0
        
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        passwordTextFieldHeightConstraint?.isActive = false
        passwordTextFieldHeightConstraint = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightConstraint?.isActive = true
        
    }
    
    func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func handleLoginRegister() {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    func handleLogin() {
        
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            
            guard isSuccess(error: error) else { return }
            
            self.loginDelegate?.fetchUser()
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func handleRegister() {
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else { return }
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            
            guard isSuccess(error: error) else { return }
            
            guard let uid = user?.uid else { return }
            
            let fileName = uid + ".jpg"
            self.uploadProfileImage(name: fileName, completionHandler: { (metadata) in
                
                var values: [String: Any] = [
                    "name": name,
                    "email": email
                ]
                
                if let url = metadata.downloadURL()?.absoluteString {
                    values["image"] = url
                }
                
                self.registerUserIntoDatabase(uid, values: values)
            })
        })
    }
    
    func uploadProfileImage(name: String, completionHandler: @escaping (_ metadata: FIRStorageMetadata) -> Void) {
        
        guard let image = profileImageView.image, let uploadData = UIImageJPEGRepresentation(image, 0.1) else { return }

        let storageRef = FIRStorage.storage().reference().child("profile_images").child(name)
        
        storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
            
            guard isSuccess(error: error) else { return }
            
            completionHandler(metadata!)
            
        })
    }
    
    func registerUserIntoDatabase(_ uid: String, values: [String: Any]) {
        let ref = FIRDatabase.database().reference()
        let userReference = ref.child("users").child(uid)
        
        userReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
            
            guard isSuccess(error: error) else { return }
            
            self.loginDelegate?.showTheMessageController(with: values["name"] as? String, image: values["image"] as? String)
            self.dismiss(animated: true, completion: nil)
            print("Saved user successfully into firebase db")
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImage : UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImage = editedImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage  {
            selectedImage = originalImage
        }
        
        if let selectedImage = selectedImage {
            profileImageView.image = selectedImage
            profileImageView.createCircleView()
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

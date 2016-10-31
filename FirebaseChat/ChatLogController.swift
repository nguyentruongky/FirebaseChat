//
//  ChatLogController.swift
//  FirebaseChat
//
//  Created by Ky Nguyen on 11/1/16.
//  Copyright © 2016 Ky Nguyen. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Chat Log Controller"
     
        collectionView?.backgroundColor = UIColor.white
        
        setupInputComponents()
    }
    
    lazy var inputTextField : UITextField = {
        
        let tf = UITextField()
        tf.delegate = self
        tf.placeholder = "Your message goes here"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    func setupInputComponents() {
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("Send", for: .normal)
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 8).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        
        containerView.addSubview(inputTextField)
        
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true

        let separator = UIView()
        separator.backgroundColor = UIColor.lightGray
        separator.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separator)
        
        separator.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separator.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separator.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }

    func handleSend() {
        
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let values = ["text": inputTextField.text!, "name": "Keen"]
        childRef.updateChildValues(values)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}

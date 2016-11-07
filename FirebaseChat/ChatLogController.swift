//
//  ChatLogController.swift
//  FirebaseChat
//
//  Created by Ky Nguyen on 11/1/16.
//  Copyright © 2016 Ky Nguyen. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {

    let cellId = "cellId"
    var user: User? {
        
        didSet {
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    
    var messages = [Message]()
    
    func observeMessages() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        let userMessageRef = FIRDatabase.database().reference().child("user-messages").child(uid)
        
        userMessageRef.observe(.childAdded, with: { snapshot in
            
            let messageid = snapshot.key
            let messageRef = FIRDatabase.database().reference().child("messages").child(messageid)
            
            messageRef.observeSingleEvent(of: .value, with: { snapshot in

                guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
                
                let message = Message()
                message.setValuesForKeys(dictionary)
                if message.chatParnterId() == self.user?.id {
                    self.messages.append(message)
                    self.collectionView?.reloadData()
                }
                
            })
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        collectionView?.backgroundColor = UIColor.white
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        setupInputComponents()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        cell.textView.text = messages[indexPath.row].text
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 80)
    }
    
    lazy var inputTextField : UITextField = {
        
        let tf = UITextField()
        tf.delegate = self
        tf.placeholder = "Your message goes here"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.autocorrectionType = .no
        return tf
    }()
    
    func setupInputComponents() {
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        containerView.backgroundColor = UIColor.white
        
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
        let toId = user!.id!
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let timestamp = NSDate().timeIntervalSince1970 as NSNumber
        let values: [String: Any] = [
            "text": inputTextField.text!,
            "toId": toId,
            "fromId": fromId,
            "timestamp": timestamp
        ]
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error)
                return
            }
            
            let messageId = childRef.key
            let values = [messageId: 1]
            
            let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(fromId)
            userMessagesRef.updateChildValues(values)
            
            let recipientUserMessageRef = FIRDatabase.database().reference().child("user-messages").child(toId)
            recipientUserMessageRef.updateChildValues(values)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}








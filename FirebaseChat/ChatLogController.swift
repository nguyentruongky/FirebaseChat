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
     
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView?.backgroundColor = UIColor.white
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        setupInputComponents()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        let message = messages[indexPath.row]
        cell.textView.text = message.text
        
        setupCell(cell: cell, message: message)
        
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: message.text!).width + 32
        return cell
    }
    
    func setupCell(cell: ChatMessageCell, message: Message) {
        
        if let profileImageUrl = user?.image {
            cell.profileImageView.loadImageUsingCache(profileImageUrl)
        }
        
        if message.fromId == FIRAuth.auth()?.currentUser?.uid {
            cell.bubbleView.backgroundColor = ChatMessageCell.blue
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = true
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.bubbleViewRightAnchor?.isActive = true
        }
        else {
            cell.bubbleView.backgroundColor = ChatMessageCell.lightGray
            cell.textView.textColor = UIColor.black
         
            cell.profileImageView.isHidden = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.bubbleViewRightAnchor?.isActive = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        // estimate the height 
        if let text = messages[indexPath.row].text {
            height = estimateFrameForText(text: text).height + 20
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        
        let size = CGSize(width: 200, height: 100)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15)], context: nil)
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
                return
            }
            
            self.inputTextField.text = ""
            
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








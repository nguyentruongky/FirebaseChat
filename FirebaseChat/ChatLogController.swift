//
//  ChatLogController.swift
//  FirebaseChat
//
//  Created by Ky Nguyen on 11/1/16.
//  Copyright © 2016 Ky Nguyen. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let cellId = "cellId"
    var user: User? {
        
        didSet {
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    
    var messages = [Message]()
    
    func observeMessages() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid, let toId = user?.id else { return }
        
        let userMessageRef = FIRDatabase.database().reference().child("user-messages").child(uid).child(toId)
        
        userMessageRef.observe(.childAdded, with: { snapshot in

            let messageId = snapshot.key
        
            let messageRef = FIRDatabase.database().reference().child("messages").child(messageId)
            
            messageRef.observeSingleEvent(of: .value, with: { snapshot in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
                
                let message = Message()
                message.setValuesForKeys(dictionary)
                self.messages.append(message)
                self.collectionView?.reloadData()
                
            })
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
//        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView?.backgroundColor = UIColor.white
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive
        
//        setupInputComponents()
//        
//        setupKeyboardObservers()
    }
    
    lazy var inputContainerView : UIView = {
        
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.white
        
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "camera")
        uploadImageView.contentMode = .scaleAspectFit
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(uploadImageView)
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalTo: uploadImageView.widthAnchor).isActive = true
        uploadImageView.isUserInteractionEnabled = true
        
        let sendButton = UIButton(type: .system)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("Send", for: .normal)
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 8).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        
        containerView.addSubview(self.inputTextField)
        
        self.inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 18).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        
        let separator = UIView()
        separator.backgroundColor = UIColor.lightGray
        separator.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separator)
        
        separator.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separator.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separator.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        return containerView
    }()
    
    func handleUploadTap() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
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
            uploadToFirebaseStorageUsingImage(selectedImage: selectedImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func uploadToFirebaseStorageUsingImage(selectedImage: UIImage) {
        
        let imageName = NSUUID().uuidString
        let ref = FIRStorage.storage().reference().child("message_images").child(imageName)
        if let uploadData = UIImageJPEGRepresentation(selectedImage, 0.2) {
            
            ref.put(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print("fail to upload")
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    
                    self.sendImageMessageWithImageUrl(imageUrl: imageUrl)
                }
            })
        }
    }
    
    func sendImageMessageWithImageUrl(imageUrl: String) {
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let timestamp = NSDate().timeIntervalSince1970 as NSNumber
        let values: [String: Any] = [
            "imageUrl": imageUrl,
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
            
            let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(fromId).child(toId)
            userMessagesRef.updateChildValues(values)
            
            let recipientUserMessageRef = FIRDatabase.database().reference().child("user-messages").child(toId).child(fromId)
            recipientUserMessageRef.updateChildValues(values)
        }
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    func setupKeyboardObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleKeyboardWillHide(notification: Notification) {
        containerViewBottomAnchor?.constant = 0
        
        let keyboardDuration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        UIView.animate(withDuration: keyboardDuration, animations: {
            
            self.view.layoutIfNeeded()
        })
    }
    
    func handleKeyboardWillShow(notification: Notification) {
        
        let keyboardFrame = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        containerViewBottomAnchor?.constant = -keyboardFrame.height
        
        let keyboardDuration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        UIView.animate(withDuration: keyboardDuration, animations: {
            
            self.view.layoutIfNeeded()
        })
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
        
        if let text = message.text {
            if text != "" {
                cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
            }
            else {
                cell.bubbleWidthAnchor?.constant = 200
            }
        }
        
        return cell
    }
    
    func setupCell(cell: ChatMessageCell, message: Message) {
        
        if let profileImageUrl = user?.image {
            cell.profileImageView.loadImageUsingCache(profileImageUrl)
        }
        
        if let messageImageUrl = message.imageUrl {
            
            cell.messageImageView.loadImageUsingCache(messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
        }
        else {
            cell.messageImageView.isHidden = true
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
            if text != "" {
                height = estimateFrameForText(text: text).height + 20
                return CGSize(width: UIScreen.main.bounds.width, height: height)
            }
        }
        
        return CGSize(width: UIScreen.main.bounds.width, height: height)
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
    
    var containerViewBottomAnchor: NSLayoutConstraint?

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
            
            let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(fromId).child(toId)
            userMessagesRef.updateChildValues(values)
            
            let recipientUserMessageRef = FIRDatabase.database().reference().child("user-messages").child(toId).child(fromId)
            recipientUserMessageRef.updateChildValues(values)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}








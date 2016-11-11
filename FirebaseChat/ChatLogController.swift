//
//  ChatLogController.swift
//  FirebaseChat
//
//  Created by Ky Nguyen on 11/1/16.
//  Copyright © 2016 Ky Nguyen. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

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
                
                let message = Message(dictionary: dictionary)
                self.messages.append(message)
                NSObject.cancelPreviousPerformRequests(withTarget: self)
                self.perform(#selector(self.reloadCollectionView), with: nil, afterDelay: 0.2)
            })
        })
    }
    
    func reloadCollectionView() {
        print("Reload collection view")
        collectionView?.reloadData()
        
        guard messages.count > 0 else { return }
        let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
        collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView?.backgroundColor = UIColor.white
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupKeyboardObservers()
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
        imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
            handleVideoSelectedForUrl(url: videoUrl)
        }
        else {
            handleImageSelectedInfo(info: info)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func handleVideoSelectedForUrl(url: URL) {
        
        let filename = NSUUID().uuidString + ".mov"
        let uploadTask = FIRStorage.storage().reference().child("message_movies").child(filename).putFile(url, metadata: nil, completion: { (metadata, error) in
            
            if error != nil {
                print("fail upload video: \(error)")
                return
            }
            
            if let videoUrl = metadata?.downloadURL()?.absoluteString {
                
                if let thumbnailImage = self.thumbnailImageForFileUrl(fileUrl: url) {
                    
                    self.uploadToFirebaseStorageUsingImage(selectedImage: thumbnailImage, completion: { (imageUrl) in
                        
                        let values: [String: Any] = [
                            "imageUrl": imageUrl,
                            "imageWidth": thumbnailImage.size.width,
                            "imageHeight" : thumbnailImage.size.height,
                            "videoUrl": videoUrl
                        ]
                        self.sendMessageWithProperties(properties: values)
                        
                    })
                    
                    
                }
            }
        })
        
        uploadTask.observe(.progress, handler: { snapshot in
        
            if let completedUnitCount = snapshot.progress?.completedUnitCount {
                self.navigationItem.title = String(completedUnitCount)
            }
        })
        
        uploadTask.observe(.success, handler: { snapshot in
         
            self.navigationItem.title = self.user?.name
        })
    }
    
    private func thumbnailImageForFileUrl(fileUrl: URL) -> UIImage? {

        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let time = CMTime(value: 1, timescale: 60)
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        }
        catch let err {
            print(err)
        }
        
        return nil
    }
    
    func handleImageSelectedInfo(info: [String: Any]) {
        
        var selectedImage : UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImage = editedImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage  {
            selectedImage = originalImage
        }
        
        if let selectedImage = selectedImage {
            uploadToFirebaseStorageUsingImage(selectedImage: selectedImage, completion: { (imageUrl) in
                
                self.sendImageMessageWithImageUrl(imageUrl: imageUrl, image: selectedImage)
            })
        }
    }
    
    func uploadToFirebaseStorageUsingImage(selectedImage: UIImage, completion: @escaping (_ imageUrl: String) -> Void) {
        
        let imageName = NSUUID().uuidString
        let ref = FIRStorage.storage().reference().child("message_images").child(imageName)
        if let uploadData = UIImageJPEGRepresentation(selectedImage, 0.2) {
            
            ref.put(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print("fail to upload")
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    
                    completion(imageUrl)
                }
            })
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func handleKeyboardDidShow(notification: Notification) {
        
//        guard messages.count > 0 else { return }
//        let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
//        collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
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
        
        cell.message = message
        cell.textView.text = message.text
        
        cell.chatLogController = self
        
        setupCell(cell: cell, message: message)
        
        if let text = message.text {
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
        }
        else if message.imageUrl != nil {
            cell.bubbleWidthAnchor?.constant = 200
        }
        
        cell.playButton.isHidden = message.videoUrl == nil
        
        return cell
    }
    
    func setupCell(cell: ChatMessageCell, message: Message) {
        
        if let profileImageUrl = user?.image {
            cell.profileImageView.loadImageUsingCache(profileImageUrl)
        }
        
        if let messageImageUrl = message.imageUrl {
            
            cell.messageImageView.loadImageUsingCache(messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.white
            cell.textView.isHidden = true
        }
        else {
            cell.bubbleView.backgroundColor = ChatMessageCell.blue
            cell.messageImageView.isHidden = true
            cell.textView.isHidden = false 
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
        let message = messages[indexPath.row]
        // estimate the height 
        if let text = message.text {
            height = estimateFrameForText(text: text).height + 20
            return CGSize(width: UIScreen.main.bounds.width, height: height)
        }
        
        if let height = message.imageHeight, let width = message.imageWidth {
            let newHeight = 200 / CGFloat(width) * CGFloat(height)
            return CGSize(width: UIScreen.main.bounds.width, height: CGFloat(newHeight))
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
        let values: [String: Any] = [
            "text": inputTextField.text!
        ]
        sendMessageWithProperties(properties: values)
    }

    func sendImageMessageWithImageUrl(imageUrl: String, image: UIImage) {
        
        let values: [String: Any] = [
            "imageUrl": imageUrl,
            "imageWidth": image.size.width,
            "imageHeight" : image.size.height
        ]
        sendMessageWithProperties(properties: values)
    }
    
    private func sendMessageWithProperties(properties: [String: Any]) {
        
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let timestamp = NSDate().timeIntervalSince1970 as NSNumber
        var values: [String: Any] = [
            "toId": toId,
            "fromId": fromId,
            "timestamp": timestamp
        ]
        
        properties.forEach({ values[$0] = $1 })
        
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
    
    var startFrame : CGRect?
    var blackBackgroundView : UIView?
    var zoomingImageView : UIImageView?
    func performZoomInForImageView(startingImageView: UIImageView) {
        
        guard let startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil) else { return }
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        
        self.startFrame = startingFrame
        
        zoomingImageView = UIImageView(frame: startingFrame)
        guard let zoomingImageView = zoomingImageView else { return }
        zoomingImageView.backgroundColor = UIColor.red
        
        zoomingImageView.image = startingImageView.image
        zoomingImageView.contentMode = .scaleAspectFit
        blackBackgroundView = UIView(frame: keyWindow.frame)
        blackBackgroundView!.alpha = 0
        blackBackgroundView!.backgroundColor = UIColor.black
        zoomingImageView.backgroundColor = UIColor.black
//        keyWindow.addSubview(blackBackgroundView!)
        keyWindow.addSubview(zoomingImageView)
        
        let button = UIButton(frame: keyWindow.frame)
        button.addTarget(self, action: #selector(handleZoomOut), for: .touchUpInside)
        keyWindow.addSubview(button)
        
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            
            let height = startingFrame.height / startingFrame.width / keyWindow.frame.width
            
            zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: keyWindow.frame.height)
            
            zoomingImageView.center = keyWindow.center
            
            self.blackBackgroundView!.alpha = 1
            self.inputContainerView.alpha = 0
            
        }, completion: nil)
        
    }
    
    func handleZoomOut(sender: UIButton) {
        
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
        
            self.zoomingImageView?.frame = self.startFrame!
            self.blackBackgroundView!.alpha = 0
            self.inputContainerView.alpha = 1
            
        }, completion: { _ in
            
            self.blackBackgroundView?.removeFromSuperview()
            self.zoomingImageView?.removeFromSuperview()
            sender.removeFromSuperview()
        })
    }
}

//
//  ChatInputswift
//  FirebaseChat
//
//  Created by Ky Nguyen on 11/12/16.
//  Copyright © 2016 Ky Nguyen. All rights reserved.
//

import UIKit

class ChatInputContainerView : UIView, UITextFieldDelegate {
    
    weak var chatLogController : ChatLogController? {
        
        didSet {
            sendButton.addTarget(chatLogController!, action: #selector(ChatLogController.handleSend), for: .touchUpInside)
            
            uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: chatLogController, action: #selector(ChatLogController.handleUploadTap)))
        }
    }
    
    let sendButton: UIButton = {
        
        let sendButton = UIButton(type: .system)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("Send", for: .normal)
        return sendButton
    }()
    
    let uploadImageView : UIImageView = {
        
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "camera")
        uploadImageView.contentMode = .scaleAspectFit
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        return uploadImageView
    }()
    
    lazy var inputTextField : UITextField = {
        
        let tf = UITextField()
        tf.delegate = self
        tf.placeholder = "Your message goes here"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.autocorrectionType = .no
        return tf
    }()
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        
        addSubview(uploadImageView)
        uploadImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalTo: uploadImageView.widthAnchor).isActive = true
        uploadImageView.isUserInteractionEnabled = true

        addSubview(sendButton)
        sendButton.rightAnchor.constraint(equalTo: rightAnchor, constant: 8).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(self.inputTextField)

        inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 18).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true

        let separator = UIView()
        separator.backgroundColor = UIColor.lightGray
        separator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separator)

        separator.topAnchor.constraint(equalTo: topAnchor).isActive = true
        separator.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separator.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        chatLogController?.handleSend()
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  ViewController.swift
//  FirebaseChat
//
//  Created by Ky Nguyen on 10/28/16.
//  Copyright © 2016 Ky Nguyen. All rights reserved.
//

import UIKit
import Firebase

protocol LoginDelegate {
    
    func showTheMessageController(with name: String?, image: String?)
    
    func fetchUser()
}

class MessageController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Loading..."
        setupBackButton()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleNewMessage))
        
        checkIfUserLogin()
    }
    
    func handleNewMessage() {
        
        showChatController()
//        let newMessageController = NewMessageController()
//        let navigationController = UINavigationController(rootViewController: newMessageController)
//        present(navigationController, animated: true, completion: nil)
    }
    
    func setupBackButton() {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }
    
    func checkIfUserLogin() {
        if FIRAuth.auth()?.currentUser == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        else {
            fetchUser()
        }
    }
    
    func updateTitleBar(with name: String?, image: String?) {
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        titleView.backgroundColor = UIColor.clear
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        if let image = image {
            profileImageView.loadImageUsingCache(image)
        }
        
        containerView.addSubview(profileImageView)
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor).isActive = true
        profileImageView.layer.cornerRadius = 20
        profileImageView.layer.masksToBounds = true
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(nameLabel)
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 16).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        navigationItem.titleView = titleView
        
        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
        
    }
    
    func showChatController() {
        
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    func handleLogout() {
        
        do {
            
            try FIRAuth.auth()?.signOut()
        } catch let error {
            print(error)
        }
        
        navigationItem.title = "Loading..."
        let loginController = LoginController()
        loginController.loginDelegate = self
        present(loginController, animated: true, completion: nil)
    }
}

extension MessageController : LoginDelegate {
    
    func showTheMessageController(with name: String?, image: String?) {
        updateTitleBar(with: name, image: image)
    }
    
    func fetchUser() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let name = dictionary["name"] as? String
                let image = dictionary["image"] as? String
                self.updateTitleBar(with: name, image: image)
            }
            
            }, withCancel: nil)
    }
}

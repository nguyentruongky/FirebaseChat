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

    let cellId = "cellId"
    
    var messagesDictionary = [String: Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Loading..."
        setupBackButton()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleNewMessage))
        
        checkIfUserLogin()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
    }
    
    func handleNewMessage() {
        
        let newMessageController = NewMessageController()
        newMessageController.messageController = self
        let navigationController = UINavigationController(rootViewController: newMessageController)
        present(navigationController, animated: true, completion: nil)
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
    
    var messages = [Message]()
    
    func observeUserMessages() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
        
        ref.observe(.childAdded, with: { snapshot in
        
            let messageId = snapshot.key
            let messageref = FIRDatabase.database().reference().child("messages").child(messageId)
            messageref.observeSingleEvent(of: .value, with: { snapshot in
                
                if let dictionary = snapshot.value as? [String: Any] {
                    let message = Message()
                    message.setValuesForKeys(dictionary)
                    
                    if let chatPartnerId = message.chatParnterId() {
                        self.messagesDictionary[chatPartnerId] = message
                        self.messages = Array(self.messagesDictionary.values)
                        self.messages.sort(by: { (message1, message2) -> Bool in
                            return message1.timestamp!.intValue > message2.timestamp!.intValue
                        })
                    }
                    
                }
                
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
            })
        })
    }
    
    var timer: Timer?
    
    func handleReloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let message = messages[indexPath.row]
        cell.message = message
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]
        guard let chatPartnerId = message.chatParnterId() else { return }
        
        let ref = FIRDatabase.database().reference().child("users").child(chatPartnerId)
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
        
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            
            let user = User()
            user.id = chatPartnerId
            user.setValuesForKeys(dictionary)
            self.showChatControllerForUser(user: user)
        })

    }
    
    func updateTitleBar(with name: String?, image: String?) {
        
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        observeUserMessages()
        
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
    }
    
    func showChatControllerForUser(user: User) {
        
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
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

//
//  ViewController.swift
//  FirebaseChat
//
//  Created by Ky Nguyen on 10/28/16.
//  Copyright © 2016 Ky Nguyen. All rights reserved.
//

import UIKit
import Firebase

class MessageController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Loading..."
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleNewMessage))
        
        checkIfUserLogin()
    }
    
    func handleNewMessage() {
        let newMessageController = NewMessageController()
        let navigationController = UINavigationController(rootViewController: newMessageController)
        present(navigationController, animated: true, completion: nil)
    }
    
    func checkIfUserLogin() {
        if FIRAuth.auth()?.currentUser == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        else {
            let uid = FIRAuth.auth()?.currentUser?.uid
            FIRDatabase.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.navigationItem.title = dictionary["name"] as? String
                }
                
                
                }, withCancel: nil)
        }
    }
    
    func handleLogout() {
        
        do {
            
            try FIRAuth.auth()?.signOut()
        } catch let error {
            print(error)
        }
        
        
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }
}


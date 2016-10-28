//
//  ViewController.swift
//  FirebaseChat
//
//  Created by Ky Nguyen on 10/28/16.
//  Copyright © 2016 Ky Nguyen. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        if FIRAuth.auth()?.currentUser == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        else {
            
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


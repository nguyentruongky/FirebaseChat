//
//  Message.swift
//  FirebaseChat
//
//  Created by Ky Nguyen on 11/1/16.
//  Copyright © 2016 Ky Nguyen. All rights reserved.
//

import UIKit
import  Firebase

class Message: NSObject {

    var fromId: String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?
    
    func chatParnterId() -> String? {

        return fromId == FIRAuth.auth()?.currentUser?.uid ? toId : fromId
    }
}

//
//  GlobalHelper.swift
//  FirebaseChat
//
//  Created by Ky Nguyen on 10/29/16.
//  Copyright © 2016 Ky Nguyen. All rights reserved.
//

import Foundation

func isSuccess(error: Error?) -> Bool {
    guard error != nil else { return true }
    print(error)
    return false
}

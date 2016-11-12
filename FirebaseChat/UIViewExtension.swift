//
//  UIViewExtension.swift
//  FirebaseChat
//
//  Created by Ky Nguyen on 10/29/16.
//  Copyright © 2016 Ky Nguyen. All rights reserved.
//

import UIKit

extension UIView {
    
    func createCircleView() {
        layer.cornerRadius = frame.size.width / 2
        layer.masksToBounds = true
    }
}


//
//  UIImageViewExtension.swift
//  FirebaseChat
//
//  Created by Ky Nguyen on 10/29/16.
//  Copyright © 2016 Ky Nguyen. All rights reserved.
//

import UIKit

let avatarCaching = ImageCaching()

extension UIImageView {
    
    func loadImageUsingCache(_ urlString: String) {

        avatarCaching.getImage(with: urlString) { (downloadedImage) in
            self.image = downloadedImage
        }
    }
}


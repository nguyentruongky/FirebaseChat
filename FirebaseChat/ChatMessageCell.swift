//
//  ChatMessageCell.swift
//  FirebaseChat
//
//  Created by Ky Nguyen on 11/8/16.
//  Copyright © 2016 Ky Nguyen. All rights reserved.
//

import UIKit

class ChatMessageCell : UICollectionViewCell {
    
    let textView : UITextView = {
       
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 15)
        tv.text = "Nguyen Truong Ky Nguyen Truong Ky Nguyen Truong Ky Nguyen Truong Ky Nguyen Truong Ky"
        tv.backgroundColor = UIColor.yellow
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(textView)
        textView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        textView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        textView.widthAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

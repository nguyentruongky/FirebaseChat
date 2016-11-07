//
//  UserCell.swift
//  FirebaseChat
//
//  Created by Ky Nguyen on 11/2/16.
//  Copyright © 2016 Ky Nguyen. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    var message: Message? {
        
        didSet {
        
            setupNameAndAvatar()
            detailTextLabel?.text = message?.text
            
            if let seconds = message?.timestamp?.doubleValue {
                let timestamp = Date(timeIntervalSince1970: seconds)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                timeLabel.text = dateFormatter.string(from: timestamp)
            }
            
        }
    }
    
    private func setupNameAndAvatar() {
        
        if let id = message?.chatParnterId() {
            let ref = FIRDatabase.database().reference().child("users").child(id)
            ref.observe(.value, with: { snapshot in
                
                guard let dictionary = snapshot.value as? [String: Any] else { return
                }
                
                self.textLabel?.text = dictionary["name"] as? String
                if let profileImageUrl = dictionary["image"] as? String {
                    
                    self.profileImageView.loadImageUsingCache(profileImageUrl)
                }
            })
        }

    }
    
    let timeLabel : UILabel = {
       
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "2 mins ago"
        label.textColor = UIColor.lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let xOffset : CGFloat = 56
        textLabel?.frame = CGRect(x: xOffset, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.size.width, height: textLabel!.frame.size.height)
        
        detailTextLabel?.frame = CGRect(x: xOffset, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.size.width, height: detailTextLabel!.frame.size.height)
    }
    
    let profileImageView : UIImageView = {
        
        let iv = UIImageView()
        iv.image = UIImage(named: "chat")
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 20
        iv.layer.masksToBounds = true
        return iv
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        profileImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor).isActive = true
        
        addSubview(timeLabel)
        timeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        timeLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}




//
//  ChatMessageCell.swift
//  FirebaseChat
//
//  Created by Ky Nguyen on 11/8/16.
//  Copyright © 2016 Ky Nguyen. All rights reserved.
//

import UIKit
import AVFoundation

class ChatMessageCell : UICollectionViewCell {
    
    var message: Message?
    
    let textView : UITextView = {
       
        let tv = UITextView()
        tv.isEditable = false 
        tv.font = UIFont.systemFont(ofSize: 15)
        tv.textColor = UIColor.white
        tv.backgroundColor = UIColor.clear
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    let activityView : UIActivityIndicatorView = {
       
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .white)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    lazy var playButton: UIButton = {
       
        let button = UIButton(type: .system)
        let playImage = UIImage(named: "play_ico")
        button.setImage(playImage, for: .normal)
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        button.tintColor = UIColor.white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var playerLayer : AVPlayerLayer?
    var player : AVPlayer?
    
    func handlePlay() {
        
        guard let videoUrl = message?.videoUrl, let url = URL(string: videoUrl)  else { return }
        
        activityView.startAnimating()
        playButton.isHidden = true
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = bubbleView.bounds
        bubbleView.layer.addSublayer(playerLayer!)
        player?.play()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        activityView.stopAnimating()
    }
    
    static let blue = UIColor(r: 0, g: 137, b: 249)
    static let lightGray = UIColor(r: 240, g: 240, b: 240)
    
    let bubbleView: UIView = {
        
        let view = UIView()
        view.backgroundColor = blue
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    let profileImageView : UIImageView = {
        
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(named: "chat")
        iv.layer.cornerRadius = 16
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    weak var chatLogController : ChatLogController?
    
    var bubbleWidthAnchor : NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    
    lazy var messageImageView : UIImageView = {
        
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 5
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        return iv
    }()
    
    func handleZoomTap() {
        chatLogController?.performZoomInForImageView(startingImageView: messageImageView)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(textView)
        textView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: 8).isActive = true
        textView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        addSubview(profileImageView)
        profileImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor).isActive = true
        
        bubbleView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8)
        bubbleViewRightAnchor!.isActive = true
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo:profileImageView.rightAnchor, constant: 8)
        
        bubbleView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        
        bubbleView.addSubview(messageImageView)
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        
        bubbleView.addSubview(playButton)

        playButton.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        playButton.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        playButton.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        playButton.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor).isActive = true
        
        bubbleView.addSubview(activityView)
        activityView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        activityView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
//        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
//        playButton.heightAnchor.constraint(equalTo: playButton.widthAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

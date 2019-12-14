//
//  DirectCell.swift
//  Mast
//
//  Created by Shihab Mehboob on 18/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import ActiveLabel

class DirectCell: UITableViewCell {
    
    var containerView = UIView()
    var profile = UIImageView()
    var username = UILabel()
    var usertag = UILabel()
    var timestamp = UILabel()
    var content = ActiveLabel()
    var unread = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = GlobalStruct.baseTint
        containerView.layer.cornerRadius = 0
        containerView.alpha = 0
        contentView.addSubview(containerView)
        
        unread.translatesAutoresizingMaskIntoConstraints = false
        unread.backgroundColor = GlobalStruct.baseTint
        unread.layer.cornerRadius = 5
        contentView.addSubview(unread)
        
        profile.translatesAutoresizingMaskIntoConstraints = false
        profile.layer.cornerRadius = 20
        profile.backgroundColor = GlobalStruct.baseDarkTint
        profile.isUserInteractionEnabled = true
        contentView.addSubview(profile)
        
        username.translatesAutoresizingMaskIntoConstraints = false
        username.textColor = UIColor(named: "baseBlack")
        username.textAlignment = .natural
        username.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        username.isUserInteractionEnabled = false
        username.adjustsFontForContentSizeCategory = true
        username.numberOfLines = 1
        username.lineBreakMode = .byTruncatingTail
        contentView.addSubview(username)
        
        usertag.translatesAutoresizingMaskIntoConstraints = false
        usertag.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.45)
        usertag.textAlignment = .natural
        usertag.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        usertag.isUserInteractionEnabled = false
        usertag.adjustsFontForContentSizeCategory = true
        usertag.numberOfLines = 1
        usertag.lineBreakMode = .byTruncatingTail
        contentView.addSubview(usertag)
        
        timestamp.translatesAutoresizingMaskIntoConstraints = false
        timestamp.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.45)
        timestamp.textAlignment = .natural
        timestamp.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize)
        timestamp.isUserInteractionEnabled = false
        timestamp.adjustsFontForContentSizeCategory = true
        timestamp.numberOfLines = 1
        timestamp.lineBreakMode = .byTruncatingTail
        contentView.addSubview(timestamp)
        
        content.translatesAutoresizingMaskIntoConstraints = false
        content.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.85)
        content.textAlignment = .natural
        content.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        content.isUserInteractionEnabled = true
        content.adjustsFontForContentSizeCategory = true
        content.numberOfLines = 0
        content.enabledTypes = [.mention, .hashtag, .url]
        content.mentionColor = GlobalStruct.baseTint
        content.hashtagColor = GlobalStruct.baseTint
        content.URLColor = GlobalStruct.baseTint
        contentView.addSubview(content)
        
        username.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        usertag.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        timestamp.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        let viewsDict = [
            "containerView" : containerView,
            "unread" : unread,
            "profile" : profile,
            "username" : username,
            "usertag" : usertag,
            "timestamp" : timestamp,
            "content" : content,
        ]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[containerView]-0-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[containerView]-0-|", options: [], metrics: nil, views: viewsDict))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[unread(10)]-9-[profile(40)]-(>=18)-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-81-[username]-5-[usertag]-(>=5)-[timestamp]-18-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-81-[content]-18-|", options: [], metrics: nil, views: viewsDict))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[profile(40)]-(>=15)-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-30-[unread(10)]-(>=15)-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[username]-2-[content]-15-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[usertag]-2-[content]-15-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[timestamp]-2-[content]-15-|", options: [], metrics: nil, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ convo: Conversation) {
        content.mentionColor = GlobalStruct.baseTint
        content.hashtagColor = GlobalStruct.baseTint
        content.URLColor = GlobalStruct.baseTint
        containerView.backgroundColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.09)
        if GlobalStruct.markedReadIDs.contains(convo.id) {
            self.unread.alpha = 0
        } else {
            if convo.unread {
                self.unread.alpha = 1
            } else {
                self.unread.alpha = 0
            }
        }
        self.username.text = convo.lastStatus?.account.displayName ?? ""
        self.usertag.text = "@\(convo.lastStatus?.account.username ?? "")"
        self.content.text = convo.lastStatus?.content.stripHTML() ?? ""
        self.timestamp.text = timeAgoSince(convo.lastStatus?.createdAt ?? Date())
        self.profile.image = UIImage()
        guard let imageURL = URL(string: convo.lastStatus?.account.avatar ?? "") else { return }
        self.profile.sd_setImage(with: imageURL, completed: nil)
        self.profile.layer.masksToBounds = true
        
        if convo.lastStatus?.emojis.isEmpty ?? true {
            
        } else {
            let attributedString = NSMutableAttributedString(string: "\(convo.lastStatus?.content.stripHTML() ?? "")", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "baseBlack")!.withAlphaComponent(0.85)])
            if let z = convo.lastStatus?.emojis {
                let _ = z.map({
                    let textAttachment = NSTextAttachment()
                    textAttachment.kf.setImage(with: $0.url) { r in
                        self.content.setNeedsDisplay()
                    }
                    textAttachment.bounds = CGRect(x:0, y: Int(-4), width: Int(self.content.font.lineHeight), height: Int(self.content.font.lineHeight))
                    let attrStringWithImage = NSAttributedString(attachment: textAttachment)
                    while attributedString.mutableString.contains(":\($0.shortcode):") {
                        let range: NSRange = (attributedString.mutableString as NSString).range(of: ":\($0.shortcode):")
                        attributedString.replaceCharacters(in: range, with: attrStringWithImage)
                    }
                })
                #if !targetEnvironment(macCatalyst)
                self.content.attributedText = attributedString
                self.reloadInputViews()
                #endif
            }
        }
        
        if convo.lastStatus?.account.emojis.isEmpty ?? true {
            
        } else {
            let attributedString = NSMutableAttributedString(string: "\(convo.lastStatus?.account.displayName ?? "")", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "baseBlack")!.withAlphaComponent(0.85)])
            if let z = convo.lastStatus?.account.emojis {
                let _ = z.map({
                    let textAttachment = NSTextAttachment()
                    textAttachment.kf.setImage(with: $0.url) { r in
                        self.username.setNeedsDisplay()
                    }
                    textAttachment.bounds = CGRect(x:0, y: Int(-4), width: Int(self.content.font.lineHeight), height: Int(self.content.font.lineHeight))
                    let attrStringWithImage = NSAttributedString(attachment: textAttachment)
                    while attributedString.mutableString.contains(":\($0.shortcode):") {
                        let range: NSRange = (attributedString.mutableString as NSString).range(of: ":\($0.shortcode):")
                        attributedString.replaceCharacters(in: range, with: attrStringWithImage)
                    }
                })
                #if !targetEnvironment(macCatalyst)
                self.username.attributedText = attributedString
                self.reloadInputViews()
                #endif
            }
        }
    }
    
    func configure2(_ unread: Bool, id: String) {
        if GlobalStruct.markedReadIDs.contains(id) {
            self.unread.alpha = 0
        } else {
            if unread {
                self.unread.alpha = 1
            } else {
                self.unread.alpha = 0
            }
        }
    }
    
    func highlightCell() {
        springWithDelay(duration: 0.3, delay: 0, animations: {
            self.containerView.alpha = 1
        })
    }
    
    func unhighlightCell() {
        springWithDelay(duration: 0.3, delay: 0, animations: {
            self.containerView.alpha = 0
        })
    }
}



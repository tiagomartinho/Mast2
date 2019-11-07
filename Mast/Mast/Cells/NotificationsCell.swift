//
//  NotificationsCell.swift
//  Mast
//
//  Created by Shihab Mehboob on 18/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import ActiveLabel

class NotificationsCell: UITableViewCell {
    
    var containerView = UIView()
    var typeOf = UIImageView()
    var profile = UIImageView()
    var profile2 = UIImageView()
    var title = UILabel()
    var username = UILabel()
    var usertag = UILabel()
    var timestamp = UILabel()
    var content = ActiveLabel()
    var heart = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = GlobalStruct.baseTint
        containerView.layer.cornerRadius = 0
        containerView.alpha = 0
        contentView.addSubview(containerView)
        
        typeOf.translatesAutoresizingMaskIntoConstraints = false
        typeOf.backgroundColor = UIColor.clear
        typeOf.contentMode = .scaleAspectFit
        contentView.addSubview(typeOf)
        
        profile.translatesAutoresizingMaskIntoConstraints = false
        profile.layer.cornerRadius = 20
        profile.backgroundColor = UIColor(named: "baseWhite")
        profile.isUserInteractionEnabled = true
        contentView.addSubview(profile)
        
        profile2.translatesAutoresizingMaskIntoConstraints = false
        profile2.layer.cornerRadius = 14
        profile2.backgroundColor = UIColor(named: "baseWhite")
        profile2.isUserInteractionEnabled = true
        profile2.layer.borderWidth = 1.6
        contentView.addSubview(profile2)
        
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.45)
        title.textAlignment = .natural
        title.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize)
        title.isUserInteractionEnabled = false
        title.adjustsFontForContentSizeCategory = true
        title.numberOfLines = 0
        title.lineBreakMode = .byTruncatingTail
        contentView.addSubview(title)
        
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

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .regular)
        heart.image = UIImage(systemName: "heart.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.systemPink, renderingMode: .alwaysOriginal)
        heart.translatesAutoresizingMaskIntoConstraints = false
        heart.backgroundColor = UIColor(named: "baseWhite")
        heart.contentMode = .scaleAspectFit
        heart.alpha = 0
        contentView.addSubview(heart)
        
        username.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        usertag.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        timestamp.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        let viewsDict = [
            "containerView" : containerView,
            "typeOf" : typeOf,
            "profile" : profile,
            "profile2" : profile2,
            "title" : title,
            "username" : username,
            "usertag" : usertag,
            "timestamp" : timestamp,
            "content" : content,
            "heart" : heart,
        ]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[containerView]-0-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[containerView]-0-|", options: [], metrics: nil, views: viewsDict))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[typeOf(20)]-10-[profile(40)]-10-[username]-5-[usertag]-(>=5)-[heart(20)]-[timestamp]-18-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-66-[profile2(28)]-(>=18)-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-98-[content]-18-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-98-[title]-18-|", options: [], metrics: nil, views: viewsDict))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[typeOf(20)]-(>=15)-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[profile(40)]-(>=15)-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-33-[profile2(28)]-(>=5)-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[title]-4-[heart(20)]", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[title]-4-[username]-2-[content]-15-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[title]-4-[usertag]-2-[content]-15-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[title]-4-[timestamp]-2-[content]-15-|", options: [], metrics: nil, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ noti: Notificationt) {
        containerView.backgroundColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.09)
        self.timestamp.text = timeAgoSince(noti.createdAt)
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        if noti.type == .mention {
            if noti.status?.visibility == .direct {
                self.typeOf.image = UIImage(systemName: "paperplane.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.systemTeal, renderingMode: .alwaysOriginal)
            } else {
                self.typeOf.image = UIImage(systemName: "arrowshape.turn.up.left.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.systemBlue, renderingMode: .alwaysOriginal)
            }
        } else if noti.type == .favourite {
            self.typeOf.image = UIImage(systemName: "heart.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.systemPink, renderingMode: .alwaysOriginal)
        } else if noti.type == .reblog {
            self.typeOf.image = UIImage(systemName: "arrow.2.circlepath", withConfiguration: symbolConfig)?.withTintColor(UIColor.systemGreen, renderingMode: .alwaysOriginal)
        } else if noti.type == .direct {
            self.typeOf.image = UIImage(systemName: "paperplane.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.systemTeal, renderingMode: .alwaysOriginal)
        } else if noti.type == .poll {
            self.typeOf.image = UIImage(systemName: "chart.bar.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.systemTeal, renderingMode: .alwaysOriginal)
        } else if noti.type == .follow {
            self.typeOf.image = UIImage(systemName: "person.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.systemOrange, renderingMode: .alwaysOriginal)
        }
        if noti.type == .follow {
            self.title.text = "New follower".localized
            self.username.text = noti.account.displayName
            self.usertag.text = "@\(noti.account.username)"
            self.content.text = "\(noti.account.followersCount) \("followers".localized), \(noti.account.followingCount) \("following".localized)"
            self.profile.image = UIImage()
            guard let imageURL = URL(string: noti.account.avatar) else { return }
            self.profile.sd_setImage(with: imageURL, completed: nil)
            self.profile.layer.masksToBounds = true
            self.profile2.alpha = 0
        } else {
            if noti.type == .mention {
                if noti.status?.visibility == .direct {
                    self.title.text = "\(noti.account.displayName) \("direct messaged you".localized)"
                } else {
                    self.title.text = "\(noti.account.displayName) \("mentioned you".localized)"
                }
            } else if noti.type == .favourite {
                self.title.text = "\(noti.account.displayName) \("liked your toot".localized)"
            } else if noti.type == .reblog {
                self.title.text = "\(noti.account.displayName) \("boosted your toot".localized)"
            } else if noti.type == .direct {
                self.title.text = "\(noti.account.displayName) \("direct messaged you".localized)"
            } else if noti.type == .poll {
                self.title.text = "\(noti.account.displayName) \("voted on your poll".localized)"
            }
            self.username.text = noti.status?.account.displayName ?? ""
            self.usertag.text = "@\(noti.status?.account.username ?? "")"
            self.content.text = noti.status?.content.stripHTML() ?? ""
            self.profile.image = UIImage()
            guard let imageURL = URL(string: noti.status?.account.avatar ?? "") else { return }
            self.profile.sd_setImage(with: imageURL, completed: nil)
            self.profile.layer.masksToBounds = true
            if noti.type == .mention {
                self.profile2.alpha = 0
            } else {
                self.profile2.image = UIImage()
                guard let imageURL2 = URL(string: noti.account.avatar) else { return }
                self.profile2.sd_setImage(with: imageURL2, completed: nil)
                self.profile2.layer.masksToBounds = true
                self.profile2.alpha = 1
                self.profile2.layer.borderColor = UIColor(named: "baseWhite")!.cgColor
            }
        }
        if noti.status?.favourited ?? false {
            self.heart.alpha = 1
        } else {
            self.heart.alpha = 0
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


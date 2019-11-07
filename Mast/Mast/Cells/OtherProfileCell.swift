//
//  OtherProfileCell.swift
//  Mast
//
//  Created by Shihab Mehboob on 22/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import GSImageViewerController
import SDWebImage
import ActiveLabel

class OtherProfileCell: UITableViewCell {
    
    var header = UIButton()
    var profile = UIButton()
    var username = UILabel()
    var usertag = UILabel()
    var content = ActiveLabel()
    var followers = UIButton()
    var joined = UILabel()
    var followsYou = UIButton()
    var following = UIButton()
    var more = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        header.translatesAutoresizingMaskIntoConstraints = false
        header.backgroundColor = GlobalStruct.baseTint
        header.isUserInteractionEnabled = true
        header.contentMode = .scaleAspectFill
        header.imageView?.contentMode = .scaleAspectFill
        header.addTarget(self, action: #selector(self.headerTap), for: .touchUpInside)
        contentView.addSubview(header)
        
        profile.translatesAutoresizingMaskIntoConstraints = false
        profile.layer.cornerRadius = 40
        profile.backgroundColor = UIColor(named: "baseWhite")
        profile.isUserInteractionEnabled = true
        profile.layer.borderWidth = 2
        profile.layer.borderColor = UIColor(named: "baseWhite")!.cgColor
        profile.addTarget(self, action: #selector(self.profileTap), for: .touchUpInside)
        profile.imageView?.contentMode = .scaleAspectFill
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
        
        followers.translatesAutoresizingMaskIntoConstraints = false
        followers.setTitleColor(GlobalStruct.baseTint, for: .normal)
        followers.contentHorizontalAlignment = .leading
        followers.titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        followers.titleLabel?.adjustsFontForContentSizeCategory = true
        followers.titleLabel?.numberOfLines = 1
        followers.titleLabel?.lineBreakMode = .byTruncatingTail
        contentView.addSubview(followers)
        
        joined.translatesAutoresizingMaskIntoConstraints = false
        joined.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.85)
        joined.textAlignment = .natural
        joined.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize)
        joined.isUserInteractionEnabled = false
        joined.adjustsFontForContentSizeCategory = true
        joined.numberOfLines = 0
        contentView.addSubview(joined)
        
        followsYou.translatesAutoresizingMaskIntoConstraints = false
        followsYou.setTitle("   Follows You   ".localized, for: .normal)
        followsYou.setTitleColor(UIColor(named: "baseWhite"), for: .normal)
        followsYou.backgroundColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.7)
        followsYou.layer.cornerRadius = 10
        followsYou.contentHorizontalAlignment = .leading
        followsYou.titleLabel?.font = UIFont.systemFont(ofSize: 11)
        followsYou.titleLabel?.adjustsFontForContentSizeCategory = true
        followsYou.titleLabel?.numberOfLines = 1
        followsYou.titleLabel?.lineBreakMode = .byTruncatingTail
        followsYou.sizeToFit()
        followsYou.alpha = 0
        contentView.addSubview(followsYou)
        
        following.translatesAutoresizingMaskIntoConstraints = false
        following.setTitle("   Follow   ".localized, for: .normal)
        following.setTitleColor(UIColor(named: "baseBlack"), for: .normal)
        following.layer.borderColor = UIColor(named: "baseBlack")!.cgColor
        following.backgroundColor = UIColor.clear
        following.layer.cornerRadius = 14
        following.layer.borderWidth = 1.2
        following.contentHorizontalAlignment = .leading
        following.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        following.titleLabel?.adjustsFontForContentSizeCategory = true
        following.titleLabel?.numberOfLines = 1
        following.titleLabel?.lineBreakMode = .byTruncatingTail
        following.sizeToFit()
        contentView.addSubview(following)
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)
        more.translatesAutoresizingMaskIntoConstraints = false
        more.backgroundColor = UIColor.clear
        more.setImage(UIImage(systemName: "ellipsis", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        contentView.addSubview(more)
        
        username.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        usertag.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        let viewsDict = [
            "header" : header,
            "profile" : profile,
            "username" : username,
            "usertag" : usertag,
            "content" : content,
            "followers" : followers,
            "joined" : joined,
            "followsYou" : followsYou,
            "following" : following,
            "more" : more,
        ]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[header]-0-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[profile(80)]", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[username]-20-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[usertag]-20-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[content]-20-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[followers]-20-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[joined]-20-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-110-[followsYou]", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-110-[following]", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=20)-[more(28)]-20-|", options: [], metrics: nil, views: viewsDict))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-150-[more(28)]", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-110-[followsYou(20)]-20-[following(28)]", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[header(140)]-(>=40)-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-100-[profile(80)]-12-[username]-2-[usertag]-8-[content]-8-[followers]-2-[joined]-(>=15)-|", options: [], metrics: nil, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func headerTap() {
        let imageInfo = GSImageInfo(image: self.header.image(for: .normal) ?? UIImage(), imageMode: .aspectFit, imageHD: nil)
        let transitionInfo = GSTransitionInfo(fromView: self.header)
        let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
        let win = UIApplication.shared.keyWindow?.rootViewController
        win?.present(imageViewer, animated: true, completion: nil)
    }
    
    @objc func profileTap() {
        let imageInfo = GSImageInfo(image: self.profile.image(for: .normal) ?? UIImage(), imageMode: .aspectFit, imageHD: nil)
        let transitionInfo = GSTransitionInfo(fromView: self.profile)
        let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
        let win = UIApplication.shared.keyWindow?.rootViewController
        win?.present(imageViewer, animated: true, completion: nil)
    }
    
    var image1: UIImageView? = nil
    var image2: UIImageView? = nil
    func configure(_ acc: Account) {
        self.username.text = acc.displayName
        self.usertag.text = "@\(acc.acct)"
        self.content.text = acc.note.stripHTML()
        self.joined.text = "\("Joined on".localized) \(acc.createdAt.toString(dateStyle: .medium, timeStyle: .medium))"
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value: acc.followersCount))
        let numberFormatter2 = NumberFormatter()
        numberFormatter2.numberStyle = NumberFormatter.Style.decimal
        let formattedNumber2 = numberFormatter2.string(from: NSNumber(value: acc.followingCount))
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: UIFont.preferredFont(forTextStyle: .body).pointSize - 4, weight: .bold)
        let normalFont = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize - 2)
        let attachment = NSTextAttachment()
        attachment.image = UIImage(systemName: "person.and.person", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.35), renderingMode: .alwaysOriginal)
        let attachment2 = NSTextAttachment()
        attachment2.image = UIImage(systemName: "arrow.upright.circle", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.35), renderingMode: .alwaysOriginal)
        let attStringNewLine = NSMutableAttributedString(string: "\(formattedNumber ?? "0")", attributes: [NSAttributedString.Key.font : normalFont, NSAttributedString.Key.foregroundColor : UIColor(named: "baseBlack")!.withAlphaComponent(1)])
        let attStringNewLine2 = NSMutableAttributedString(string: "\(formattedNumber2 ?? "0")", attributes: [NSAttributedString.Key.font : normalFont, NSAttributedString.Key.foregroundColor : UIColor(named: "baseBlack")!.withAlphaComponent(1)])
        let attString = NSAttributedString(attachment: attachment)
        let attString2 = NSAttributedString(attachment: attachment2)
        let fullString = NSMutableAttributedString(string: "")
        let spaceString0 = NSMutableAttributedString(string: " ")
        let spaceString = NSMutableAttributedString(string: "  ")
        fullString.append(attString)
        fullString.append(spaceString0)
        fullString.append(attStringNewLine)
        fullString.append(spaceString)
        fullString.append(attString2)
        fullString.append(spaceString0)
        fullString.append(attStringNewLine2)
        self.followers.setAttributedTitle(fullString, for: .normal)
        
        self.profile.setImage(UIImage(), for: .normal)
        guard let imageURL = URL(string: acc.avatar) else { return }
        self.profile.sd_setImage(with: imageURL, for: .normal, completed: nil)
        self.profile.layer.masksToBounds = true
        self.profile.imageView?.contentMode = .scaleAspectFill
        self.image1?.sd_setImage(with: imageURL, completed: nil)
        guard let imageURL2 = URL(string: acc.header) else { return }
        self.header.sd_setImage(with: imageURL2, for: .normal, completed: nil)
        self.header.layer.masksToBounds = true
        self.header.imageView?.contentMode = .scaleAspectFill
        self.image2?.sd_setImage(with: imageURL2, completed: nil)
        
        let request = Accounts.relationships(ids: [GlobalStruct.currentUser.id, acc.id])
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                DispatchQueue.main.async {
                    if stat[1].following {
                        self.following.setTitle("   Following   ".localized, for: .normal)
                        self.following.setTitleColor(UIColor(named: "baseWhite"), for: .normal)
                        self.following.layer.borderColor = GlobalStruct.baseTint.cgColor
                        self.following.backgroundColor = GlobalStruct.baseTint
                    } else {
                        self.following.setTitle("   Follow   ".localized, for: .normal)
                        self.following.setTitleColor(UIColor(named: "baseBlack"), for: .normal)
                        self.following.layer.borderColor = UIColor(named: "baseBlack")!.cgColor
                        self.following.backgroundColor = UIColor.clear
                    }
                    if stat[1].followedBy {
                        self.followsYou.setTitle("   Follows You   ".localized, for: .normal)
                        self.followsYou.setTitleColor(UIColor(named: "baseWhite"), for: .normal)
                        self.followsYou.backgroundColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.7)
                        self.followsYou.alpha = 1
                    } else {
                        self.followsYou.setTitle("".localized, for: .normal)
                        self.followsYou.setTitleColor(UIColor(named: "baseWhite"), for: .normal)
                        self.followsYou.backgroundColor = UIColor.clear
                        self.followsYou.alpha = 0
                    }
                }
            }
        }
    }
}

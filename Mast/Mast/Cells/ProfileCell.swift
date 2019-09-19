//
//  ProfileCell.swift
//  Mast
//
//  Created by Shihab Mehboob on 19/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class ProfileCell: UITableViewCell {
    
    var header = UIImageView()
    var profile = UIImageView()
    var username = UILabel()
    var usertag = UILabel()
    var content = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        header.translatesAutoresizingMaskIntoConstraints = false
        header.backgroundColor = UIColor(named: "baseWhite")
        header.isUserInteractionEnabled = true
        header.contentMode = .scaleAspectFill
        contentView.addSubview(header)
        
        profile.translatesAutoresizingMaskIntoConstraints = false
        profile.layer.cornerRadius = 40
        profile.backgroundColor = UIColor(named: "baseWhite")
        profile.isUserInteractionEnabled = true
        profile.layer.borderWidth = 2
        profile.layer.borderColor = UIColor(named: "baseWhite")!.cgColor
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
        content.isUserInteractionEnabled = false
        content.adjustsFontForContentSizeCategory = true
        content.numberOfLines = 0
        contentView.addSubview(content)
        
        username.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        usertag.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        let viewsDict = [
            "header" : header,
            "profile" : profile,
            "username" : username,
            "usertag" : usertag,
            "content" : content,
        ]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[header]-0-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[profile(80)]", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[username]-20-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[usertag]-20-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[content]-20-|", options: [], metrics: nil, views: viewsDict))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[header(140)]-(>=40)-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-100-[profile(80)]-10-[username]-2-[usertag]-5-[content]-(>=15)-|", options: [], metrics: nil, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ acc: Account) {
        self.username.text = acc.displayName
        self.usertag.text = "@\(acc.username)"
        self.content.text = acc.note.stripHTML()
        guard let imageURL = URL(string: acc.avatar) else { return }
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: imageURL) else { return }
            let image = UIImage(data: imageData)
            DispatchQueue.main.async {
                self.profile.image = image
                self.profile.layer.masksToBounds = true
            }
        }
        guard let imageURL2 = URL(string: acc.header) else { return }
        DispatchQueue.global().async {
            guard let imageData2 = try? Data(contentsOf: imageURL2) else { return }
            let image = UIImage(data: imageData2)
            DispatchQueue.main.async {
                self.header.image = image
                self.header.layer.masksToBounds = true
            }
        }
    }
}




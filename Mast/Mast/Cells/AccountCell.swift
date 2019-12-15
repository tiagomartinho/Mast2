//
//  AccountCell.swift
//  Mast
//
//  Created by Shihab Mehboob on 08/11/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class AccountCell: UITableViewCell {
    
    var containerView = UIView()
    var profile = UIImageView()
    var username = UILabel()
    var usertag = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = GlobalStruct.baseTint
        containerView.layer.cornerRadius = 0
        containerView.alpha = 0
        contentView.addSubview(containerView)
        
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
        usertag.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize + 3)
        usertag.isUserInteractionEnabled = false
        usertag.adjustsFontForContentSizeCategory = true
        usertag.numberOfLines = 1
        usertag.lineBreakMode = .byTruncatingTail
        contentView.addSubview(usertag)
        
        username.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        usertag.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        let viewsDict = [
            "containerView" : containerView,
            "profile" : profile,
            "username" : username,
            "usertag" : usertag,
        ]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[containerView]-0-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[containerView]-0-|", options: [], metrics: nil, views: viewsDict))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[profile(40)]-(>=18)-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-68-[username]-18-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-68-[usertag]-18-|", options: [], metrics: nil, views: viewsDict))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[profile(40)]-(>=15)-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[username]-2-[usertag]-15-|", options: [], metrics: nil, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ op1: String, op2: String, op3: String) {
        containerView.backgroundColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.09)
        self.username.text = op1
        self.usertag.text = op2
        self.profile.image = UIImage()
        guard let imageURL = URL(string: op3) else { return }
        self.profile.sd_setImage(with: imageURL, completed: nil)
        self.profile.layer.masksToBounds = true
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




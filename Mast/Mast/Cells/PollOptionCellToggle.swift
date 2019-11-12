//
//  PollOptionCellToggle.swift
//  Mast
//
//  Created by Shihab Mehboob on 12/11/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class PollOptionCellToggle: UITableViewCell {
    
    var userName = UILabel()
    var userTag = UILabel()
    var toot = UILabel()
    var switchView = UISwitch(frame: .zero)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        userName.translatesAutoresizingMaskIntoConstraints = false
        userTag.translatesAutoresizingMaskIntoConstraints = false
        toot.translatesAutoresizingMaskIntoConstraints = false
        switchView.translatesAutoresizingMaskIntoConstraints = false
        
        userName.numberOfLines = 0
        userTag.numberOfLines = 0
        toot.numberOfLines = 0
        
        userName.textColor = UIColor(named: "baseBlack")!
        userTag.textColor = UIColor(named: "baseBlack")!
        toot.textColor = UIColor(named: "baseBlack")!
        
        userName.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        userTag.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        toot.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        
        switchView.setOn(false, animated: true)
        switchView.onTintColor = GlobalStruct.baseTint
        contentView.addSubview(switchView)
        
        contentView.addSubview(userName)
        contentView.addSubview(userTag)
        contentView.addSubview(toot)
        
        let viewsDict = [
            "name" : userName,
            "artist" : userTag,
            "episodes" : toot,
            "switch" : switchView,
            ]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[name]-(>=10)-[switch(40)]-20-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[artist]-(>=10)-[switch(40)]-20-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[episodes]-(>=10)-[switch(40)]-20-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-18-[switch(40)]-(>=12)-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-18-[name]-1-[artist]-1-[episodes]-18-|", options: [], metrics: nil, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(status: String, status2: String) {
        userTag.text = status
        toot.text = status2
        switchView.onTintColor = GlobalStruct.baseTint
        
    }
    
}



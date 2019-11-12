//
//  PollOptionCell.swift
//  Mast
//
//  Created by Shihab Mehboob on 12/11/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class PollOptionCell: UITableViewCell {
    
    var optionCount = UILabel()
    var theOption = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        optionCount.translatesAutoresizingMaskIntoConstraints = false
        theOption.translatesAutoresizingMaskIntoConstraints = false
        
        optionCount.numberOfLines = 0
        theOption.numberOfLines = 0
        
        optionCount.textColor = UIColor(named: "baseBlack")!
        theOption.textColor = UIColor(named: "baseBlack")!
        
        optionCount.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        theOption.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        
        contentView.addSubview(optionCount)
        contentView.addSubview(theOption)
        
        let viewsDict = [
            "optionCount" : optionCount,
            "theOption" : theOption,
            ]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[optionCount]-(>=12)-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[theOption]-12-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-18-[optionCount]-5-[theOption]-18-|", options: [], metrics: nil, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ poll: String, count: String) {
        optionCount.text = count
        theOption.text = poll
    }
    
}

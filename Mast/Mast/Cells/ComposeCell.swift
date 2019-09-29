//
//  ComposeCell.swift
//  Mast
//
//  Created by Shihab Mehboob on 29/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class ComposeCell: UITableViewCell {
    
    var textView = UITextView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.textView.translatesAutoresizingMaskIntoConstraints = false
        let normalFont = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        self.textView.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        self.textView.textStorage.setAttributes([NSAttributedString.Key.font : normalFont, NSAttributedString.Key.foregroundColor : UIColor(named: "baseBlack")!], range: NSRange(location: 0, length: self.textView.text.count))
        self.textView.backgroundColor = UIColor.clear
        self.textView.showsVerticalScrollIndicator = false
        self.textView.showsHorizontalScrollIndicator = false
        self.textView.adjustsFontForContentSizeCategory = true
        self.textView.isSelectable = true
        self.textView.alwaysBounceVertical = true
        self.textView.isUserInteractionEnabled = true
        self.textView.isScrollEnabled = true
        self.textView.textContainerInset = UIEdgeInsets(top: 10, left: 18, bottom: 10, right: 18)
        contentView.addSubview(self.textView)
        
        let viewsDict = [
            "textView" : textView,
        ]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[textView]-0-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[textView]-0-|", options: [], metrics: nil, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

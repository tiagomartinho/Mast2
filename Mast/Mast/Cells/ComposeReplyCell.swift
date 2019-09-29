//
//  ComposeReplyCell.swift
//  Mast
//
//  Created by Shihab Mehboob on 29/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class ComposeReplyCell: UITableViewCell {
    
    var replyText = UITextView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.replyText.translatesAutoresizingMaskIntoConstraints = false
        self.replyText.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize, weight: .regular)
        self.replyText.backgroundColor = UIColor(named: "lighterBaseWhite")
        self.replyText.showsVerticalScrollIndicator = false
        self.replyText.showsHorizontalScrollIndicator = false
        self.replyText.alwaysBounceVertical = true
        self.replyText.isScrollEnabled = true
        self.replyText.textContainerInset = UIEdgeInsets(top: 5, left: 18, bottom: 5, right: 18)
        self.replyText.isEditable = false
        self.replyText.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.6)
        contentView.addSubview(self.replyText)
        
        let viewsDict = [
            "replyText" : replyText,
        ]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[replyText]-0-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[replyText]-0-|", options: [], metrics: nil, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ replyStatus: [Status]) {
        if replyStatus.isEmpty {
            self.replyText.alpha = 0
        } else {
            self.replyText.alpha = 1
            
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 13)
            
            let upImage = UIImage(systemName: "arrow.turn.down.right", withConfiguration: symbolConfig)
            let tintedUpImage = upImage?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.36), renderingMode: .alwaysOriginal)
            let attachment = NSTextAttachment()
            attachment.image = tintedUpImage
            let attString = NSAttributedString(attachment: attachment)
            
            let normalFont = UIFont.systemFont(ofSize: 14)
            let attStringNewLine = NSMutableAttributedString(string: "", attributes: [NSAttributedString.Key.font : normalFont, NSAttributedString.Key.foregroundColor : UIColor(named: "baseBlack")!.withAlphaComponent(0.36)])
            let attStringNewLine2 = NSMutableAttributedString(string: " \("Replying to".localized) @\(replyStatus.first?.account.username ?? "")", attributes: [NSAttributedString.Key.font : normalFont, NSAttributedString.Key.foregroundColor : UIColor(named: "baseBlack")!.withAlphaComponent(0.36)])
            
            attStringNewLine.append(attString)
            attStringNewLine.append(attStringNewLine2)
            self.replyText.attributedText = attStringNewLine
        }
    }
}


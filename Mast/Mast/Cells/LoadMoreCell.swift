//
//  LoadMoreCell.swift
//  Mast
//
//  Created by Shihab Mehboob on 27/11/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class LoadMoreCell: UITableViewCell {
    
    var containerView = UIView()
    var content = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor(named: "lighterBaseWhite")!
        containerView.layer.cornerRadius = 0
        containerView.alpha = 0
        contentView.addSubview(containerView)
        
        content.translatesAutoresizingMaskIntoConstraints = false
        content.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.4)
        let attributedString = NSMutableAttributedString(string: "Load More".localized, attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "baseBlack")!.withAlphaComponent(0.4)])
        let textAttachment = NSTextAttachment()
        let symbolConfig2 = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
        textAttachment.image = UIImage(systemName: "chevron.down", withConfiguration: symbolConfig2)?.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal)
        textAttachment.bounds = CGRect(x:10, y: Int(0), width: Int(self.content.font.lineHeight), height: Int(self.content.font.lineHeight/2))
        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
        attributedString.append(attrStringWithImage)
        content.attributedText = attributedString
        content.textAlignment = .center
        content.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        content.isUserInteractionEnabled = false
        content.adjustsFontForContentSizeCategory = true
        content.numberOfLines = 1
        contentView.addSubview(content)
        
        let viewsDict = [
            "containerView" : containerView,
            "content" : content,
        ]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[containerView]-0-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[containerView]-0-|", options: [], metrics: nil, views: viewsDict))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[content]-18-|", options: [], metrics: nil, views: viewsDict))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[content]-15-|", options: [], metrics: nil, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        content.text = "Loading...".localized
    }
    
    func configureBack() {
        let attributedString = NSMutableAttributedString(string: "Load More".localized, attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "baseBlack")!.withAlphaComponent(0.4)])
        let textAttachment = NSTextAttachment()
        let symbolConfig2 = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
        textAttachment.image = UIImage(systemName: "chevron.down", withConfiguration: symbolConfig2)?.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal)
        textAttachment.bounds = CGRect(x:10, y: Int(0), width: Int(self.content.font.lineHeight), height: Int(self.content.font.lineHeight/2))
        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
        attributedString.append(attrStringWithImage)
        content.attributedText = attributedString
    }
}

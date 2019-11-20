//
//  IAPOptionsCell.swift
//  Mast
//
//  Created by Shihab Mehboob on 20/11/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class IAPOptionsCell: UITableViewCell {
    
    var im = UIImageView()
    var titl = UILabel()
    var subtitl = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.im.translatesAutoresizingMaskIntoConstraints = false
        self.im.backgroundColor = UIColor.clear
        self.im.contentMode = .scaleAspectFit
        self.contentView.addSubview(self.im)
        
        self.titl.translatesAutoresizingMaskIntoConstraints = false
        self.titl.textAlignment = .natural
        self.titl.textColor = UIColor(named: "baseBlack")!
        self.titl.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        self.titl.numberOfLines = 0
        self.contentView.addSubview(self.titl)
        
        self.subtitl.translatesAutoresizingMaskIntoConstraints = false
        self.subtitl.textAlignment = .natural
        self.subtitl.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.75)
        self.subtitl.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        self.subtitl.numberOfLines = 0
        self.contentView.addSubview(self.subtitl)
        
        let viewsDict = [
            "im" : self.im,
            "titl" : self.titl,
            "subtitl" : self.subtitl,
        ]
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[im(28)]-12-[titl]-15-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[im(28)]-12-[subtitl]-15-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[im(28)]", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[titl]-4-[subtitl]-10-|", options: [], metrics: nil, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(_ str: String, str2: String, im: String) {
        self.titl.text = str
        self.subtitl.text = str2
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 26)
        self.im.image = UIImage(systemName: im, withConfiguration: symbolConfig)
    }
}


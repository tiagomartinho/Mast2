//
//  ImageCell2.swift
//  Mast
//
//  Created by Shihab Mehboob on 09/11/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class ImageCell2: UICollectionViewCell {
    
    var bgImage = UIImageView()
    var image = UIImageView()
    var imageCountTag = UIButton()
    var videoOverlay = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    public func configure() {
        self.bgImage.backgroundColor = UIColor.clear
        self.bgImage.frame = CGRect(x: 0, y: 0, width: contentView.frame.size.width, height: contentView.frame.size.height)
        self.bgImage.layer.cornerRadius = 4
        self.bgImage.layer.cornerCurve = .continuous
        contentView.addSubview(bgImage)
        
        self.image.backgroundColor = UIColor.clear
        self.image.frame = CGRect(x: 0, y: 0, width: contentView.frame.size.width, height: contentView.frame.size.height)
        self.image.layer.cornerRadius = 4
        self.image.layer.cornerCurve = .continuous
        contentView.addSubview(image)
        
        imageCountTag.isUserInteractionEnabled = false
        imageCountTag.setTitle("", for: .normal)
        imageCountTag.backgroundColor = UIColor.clear
        imageCountTag.translatesAutoresizingMaskIntoConstraints = false
        imageCountTag.layer.cornerRadius = 7
        imageCountTag.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        imageCountTag.layer.shadowColor = UIColor.black.cgColor
        imageCountTag.layer.shadowOffset = CGSize(width: 0, height: 7)
        imageCountTag.layer.shadowRadius = 10
        imageCountTag.layer.shadowOpacity = 0.22
        imageCountTag.layer.masksToBounds = false
        imageCountTag.alpha = 1
        contentView.addSubview(imageCountTag)
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 26, weight: .regular)
        self.videoOverlay.frame = CGRect(x: self.bounds.width/2 - 30, y: self.bounds.height/2 - 30, width: 60, height: 60)
        self.videoOverlay.contentMode = .scaleAspectFit
        self.videoOverlay.image = UIImage(systemName: "play.circle.fill", withConfiguration: symbolConfig)?.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal)
        self.videoOverlay.alpha = 0
        self.videoOverlay.layer.shadowColor = UIColor(named: "alwaysBlack")!.cgColor
        self.videoOverlay.layer.shadowOffset = CGSize(width: 0, height: 8)
        self.videoOverlay.layer.shadowRadius = 14
        self.videoOverlay.layer.shadowOpacity = 0.18
        contentView.addSubview(videoOverlay)
        
        let viewsDict = [
            "countTag" : imageCountTag,
        ]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[countTag(30)]-(>=12)-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[countTag(22)]-(>=12)-|", options: [], metrics: nil, views: viewsDict))
    }
}

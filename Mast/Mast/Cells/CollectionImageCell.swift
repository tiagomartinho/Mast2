//
//  CollectionImageCell.swift
//  Mast
//
//  Created by Shihab Mehboob on 19/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class CollectionImageCell: UICollectionViewCell {
    
    var bgImage = UIImageView()
    var image = UIImageView()
    let gradient: CAGradientLayer = CAGradientLayer()
    var videoOverlay = UIImageView()
    var duration = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    public func configure() {
        self.bgImage.backgroundColor = GlobalStruct.baseDarkTint
        self.bgImage.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 260)
        self.bgImage.layer.cornerRadius = 0
        contentView.addSubview(bgImage)
        
        self.image.layer.borderWidth = 0.4
        self.layer.borderColor = UIColor.black.cgColor
        
        self.image.frame.origin.x = 0
        self.image.frame.origin.y = 0
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.image.frame.size.width = 360
        } else {
            self.image.frame.size.width = UIScreen.main.bounds.width
        }
        self.image.frame.size.height = 260
        self.image.backgroundColor = UIColor.clear
        self.image.layer.cornerRadius = 0
        contentView.addSubview(image)

        self.gradient.frame.size = contentView.frame.size
        self.gradient.colors = [UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.withAlphaComponent(0).cgColor]
        contentView.layer.addSublayer(gradient)
        
        self.duration.frame = CGRect(x: 10, y: contentView.bounds.height - 30, width: contentView.bounds.width - 20, height: 30)
        self.duration.text = ""
        self.duration.font = UIFont.boldSystemFont(ofSize: 18)
        self.duration.textColor = UIColor.white
        self.duration.textAlignment = .left
        contentView.addSubview(duration)
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.videoOverlay.frame = CGRect(x: 140, y: 90, width: 80, height: 80)
        } else {
            self.videoOverlay.frame = CGRect(x: ((UIScreen.main.bounds.width)/2) - 40, y: 90, width: 80, height: 80)
        }
        self.videoOverlay.contentMode = .scaleAspectFit
        self.videoOverlay.image = UIImage(systemName: "play.circle.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "alwaysWhite")!, renderingMode: .alwaysOriginal)
        self.videoOverlay.alpha = 0
        self.videoOverlay.layer.cornerRadius = 80
        self.videoOverlay.backgroundColor = UIColor.black
        self.videoOverlay.layer.shadowColor = UIColor(named: "alwaysBlack")!.cgColor
        self.videoOverlay.layer.shadowOffset = CGSize(width: 0, height: 8)
        self.videoOverlay.layer.shadowRadius = 14
        self.videoOverlay.layer.shadowOpacity = 0.2
        contentView.addSubview(videoOverlay)
    }
}

class CollectionImageCell2: UICollectionViewCell {
    
    var bgImage = UIImageView()
    var image = UIImageView()
    let gradient: CAGradientLayer = CAGradientLayer()
    var videoOverlay = UIImageView()
    var duration = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    public func configure() {
        self.bgImage.backgroundColor = GlobalStruct.baseDarkTint
        self.bgImage.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 260)
        self.bgImage.layer.cornerRadius = 0
        contentView.addSubview(bgImage)
        
        self.image.layer.borderWidth = 0.4
        self.layer.borderColor = UIColor.black.cgColor
        
        self.image.frame.origin.x = 0
        self.image.frame.origin.y = 0
        self.image.frame.size.width = 160
        self.image.frame.size.height = 120
        self.image.backgroundColor = UIColor.clear
        self.image.layer.cornerRadius = 5
        contentView.addSubview(image)

        self.gradient.frame.size = contentView.frame.size
        self.gradient.colors = [UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.withAlphaComponent(0).cgColor]
        contentView.layer.addSublayer(gradient)
        
        self.duration.frame = CGRect(x: 10, y: contentView.bounds.height - 30, width: contentView.bounds.width - 20, height: 30)
        self.duration.text = ""
        self.duration.font = UIFont.boldSystemFont(ofSize: 16)
        self.duration.textColor = UIColor.white
        self.duration.textAlignment = .left
        contentView.addSubview(duration)
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
        self.videoOverlay.frame = CGRect(x: 50, y: 30, width: 60, height: 60)
        self.videoOverlay.contentMode = .scaleAspectFit
        self.videoOverlay.image = UIImage(systemName: "play.circle.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "alwaysWhite")!, renderingMode: .alwaysOriginal)
        self.videoOverlay.alpha = 0
        self.videoOverlay.layer.cornerRadius = 60
        self.videoOverlay.backgroundColor = UIColor.black
        self.videoOverlay.layer.shadowColor = UIColor(named: "alwaysBlack")!.cgColor
        self.videoOverlay.layer.shadowOffset = CGSize(width: 0, height: 8)
        self.videoOverlay.layer.shadowRadius = 14
        self.videoOverlay.layer.shadowOpacity = 0.2
        contentView.addSubview(videoOverlay)
    }
}


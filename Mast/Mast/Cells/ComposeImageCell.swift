//
//  ComposeImageCell.swift
//  Mast
//
//  Created by Shihab Mehboob on 24/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class ComposeImageCell: UICollectionViewCell {
    
    var image = UIImageView()
    var videoOverlay = UIImageView()
    var percentage = UIButton()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    public func configure() {
        self.image.layer.borderWidth = 0.4
        self.layer.borderColor = UIColor.black.cgColor
        
        self.image.frame.origin.x = 0
        self.image.frame.origin.y = 0
        self.image.frame.size.width = 110
        self.image.frame.size.height = 80
        self.image.backgroundColor = UIColor.clear
        self.image.layer.cornerRadius = 5
        contentView.addSubview(image)
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 26, weight: .regular)
        self.videoOverlay.frame = CGRect(x: 35, y: 20, width: 40, height: 40)
        self.videoOverlay.contentMode = .scaleAspectFit
        self.videoOverlay.image = UIImage(systemName: "play.circle.fill", withConfiguration: symbolConfig)?.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal)
        self.videoOverlay.alpha = 0
        self.videoOverlay.layer.shadowColor = UIColor(named: "alwaysBlack")!.cgColor
        self.videoOverlay.layer.shadowOffset = CGSize(width: 0, height: 8)
        self.videoOverlay.layer.shadowRadius = 14
        self.videoOverlay.layer.shadowOpacity = 0.18
        contentView.addSubview(videoOverlay)
        
        self.percentage.frame = CGRect(x: -10, y: -10, width: 26, height: 26)
        self.percentage.setTitle("0", for: .normal)
        self.percentage.setTitleColor(GlobalStruct.baseTint, for: .normal)
        self.percentage.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .heavy)
        self.percentage.backgroundColor = GlobalStruct.baseDarkTint
        self.percentage.layer.cornerRadius = 13
        self.percentage.alpha = 0
        contentView.addSubview(percentage)
    }
    
    public func configurePercent(_ percent: Double) {
        let perc = percent * 100
        if perc == 100 {
            self.percentage.setTitle("100", for: .normal)
            UIView.animate(withDuration: 0.16, delay: 0.3, options: .curveEaseOut, animations: {
                self.percentage.alpha = 0
            }) { (completed: Bool) in
            }
        } else {
            self.percentage.setTitle("\(Int(perc))", for: .normal)
            self.percentage.alpha = 1
        }
    }
}

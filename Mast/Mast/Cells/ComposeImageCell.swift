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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    public func configure() {
        self.image.frame.origin.x = 0
        self.image.frame.origin.y = 0
        self.image.frame.size.width = 40
        self.image.frame.size.height = 40
        self.image.backgroundColor = UIColor.clear
        self.image.layer.cornerRadius = 5
        contentView.addSubview(image)
    }
}

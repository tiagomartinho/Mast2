//
//  ImageCell3.swift
//  Mast
//
//  Created by Shihab Mehboob on 11/11/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class ImageCell3: UICollectionViewCell {
    
    var image = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    public func configure() {
        self.image.backgroundColor = UIColor.clear
        self.image.frame = CGRect(x: 5, y: 5, width: contentView.frame.size.width - 10, height: contentView.frame.size.height - 10)
        contentView.addSubview(image)
    }
}


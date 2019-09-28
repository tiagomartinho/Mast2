//
//  ImageViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 28/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class ImageViewController: UIViewController {
    
    var image = UIImage()
    var imageView = UIImageView()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.imageView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        self.imageView.sizeToFit()
        self.preferredContentSize = CGSize(width: self.imageView.bounds.width, height: self.imageView.bounds.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        
        self.imageView.image = self.image
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.sizeToFit()
        self.preferredContentSize = CGSize(width: self.imageView.bounds.width, height: self.imageView.bounds.height)
        self.view.addSubview(self.imageView)
    }
    
}

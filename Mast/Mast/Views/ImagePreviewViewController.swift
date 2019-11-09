//
//  ImagePreviewViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 28/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class ImagePreviewViewController: UIViewController {
    var image = UIImage()
    let imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = self.image
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        let width = view.bounds.width
        let height = self.image.size.height * (width / self.image.size.width)
        preferredContentSize = CGSize(width: width, height: height)
    }
}

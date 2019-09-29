//
//  ColumnViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 27/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class ColumnViewController: UIViewController {
    
    var viewControllers: [UIViewController] = [] {
        didSet {
            for viewController in viewControllers {
                self.addChild(viewController)
                self.view.addSubview(viewController.view)
                viewController.didMove(toParent: self)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let firstViewWidth: CGFloat = 80
        var count = 0
        for viewController in viewControllers {
            if count == 0 {
                viewController.view.frame = CGRect(x: 0, y: 0, width: firstViewWidth, height: self.view.bounds.height)
                count += 1
            } else {
                viewController.view.frame = CGRect(x: firstViewWidth + 0.6, y: 0, width: self.view.bounds.width - firstViewWidth, height: self.view.bounds.height)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "lighterBaseWhite")
    }
    
}

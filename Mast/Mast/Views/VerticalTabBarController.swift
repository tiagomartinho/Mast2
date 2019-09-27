//
//  VerticalTabBarController.swift
//  Mast
//
//  Created by Shihab Mehboob on 27/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class VerticalTabBarController: UIViewController {
    
    var button1 = UIButton()
    var button2 = UIButton()
    var button3 = UIButton()
    
    @objc func load() {
        DispatchQueue.main.async {
            self.loadLoadLoad()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.button1.frame = CGRect(x: 10, y: self.view.bounds.height - 90, width: 60, height: 60)
        self.button1.backgroundColor = .clear
        self.button1.setImage(UIImage(named: "newac2")?.maskWithColor(color: Colours.tabSelected), for: .normal)
        self.button1.adjustsImageWhenHighlighted = false
        self.button1.addTarget(self, action: #selector(self.compose), for: .touchUpInside)
        self.view.addSubview(self.button1)
        
        self.button2.frame = CGRect(x: 10, y: self.view.bounds.height - 160, width: 60, height: 60)
        self.button2.backgroundColor = .clear
        self.button2.setImage(UIImage(named: "se3")?.maskWithColor(color: Colours.tabSelected), for: .normal)
        self.button2.adjustsImageWhenHighlighted = false
        self.button2.addTarget(self, action: #selector(self.search), for: .touchUpInside)
        self.view.addSubview(self.button2)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "lighterBaseWhite")
        self.navigationController?.navigationBar.backgroundColor = UIColor(named: "lighterBaseWhite")
    }
    
    @objc func search() {
        
    }
    
    @objc func compose() {
        
    }
}

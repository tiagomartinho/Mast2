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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
        
        #if targetEnvironment(macCatalyst)
        self.button1.frame = CGRect(x: 10, y: 30, width: 60, height: 60)
        self.button2.frame = CGRect(x: 10, y: 100, width: 60, height: 60)
        self.button3.frame = CGRect(x: 10, y: 170, width: 60, height: 60)
        #elseif !targetEnvironment(macCatalyst)
        self.button1.frame = CGRect(x: 10, y: self.view.bounds.height - 90, width: 60, height: 60)
        self.button2.frame = CGRect(x: 10, y: self.view.bounds.height - 160, width: 60, height: 60)
        self.button3.frame = CGRect(x: 10, y: self.view.bounds.height - 230, width: 60, height: 60)
        #endif
        
        self.button1.backgroundColor = .clear
        self.button1.setImage(UIImage(systemName: "plus", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        self.button1.adjustsImageWhenHighlighted = false
        self.button1.addTarget(self, action: #selector(self.compose), for: .touchUpInside)
        self.button1.accessibilityLabel = "Create".localized
        self.view.addSubview(self.button1)
        
        self.button2.backgroundColor = .clear
        self.button2.setImage(UIImage(systemName: "magnifyingglass", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        self.button2.adjustsImageWhenHighlighted = false
        self.button2.addTarget(self, action: #selector(self.search), for: .touchUpInside)
        self.button2.accessibilityLabel = "Search".localized
        self.view.addSubview(self.button2)
        
        self.button3.backgroundColor = .clear
        self.button3.setImage(UIImage(systemName: "gear", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        self.button3.adjustsImageWhenHighlighted = false
        self.button3.addTarget(self, action: #selector(self.settings), for: .touchUpInside)
        self.button3.accessibilityLabel = "Settings".localized
        self.view.addSubview(self.button3)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "lighterBaseWhite")
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.compose), name: NSNotification.Name(rawValue: "composea"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.search), name: NSNotification.Name(rawValue: "searcha"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.settings), name: NSNotification.Name(rawValue: "settingsa"), object: nil)
    }
    
    @objc func settings() {
        #if targetEnvironment(macCatalyst)
        GlobalStruct.macWindow = 3
        let userActivity = NSUserActivity(activityType: "com.shi.Mast.openSettings")
        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: userActivity, options: nil) { (e) in
          print("error", e)
        }
        #elseif !targetEnvironment(macCatalyst)
        let vc = SettingsViewController()
        self.show(UINavigationController(rootViewController: vc), sender: self)
        #endif
    }
    
    @objc func search() {
        let alert = UIAlertController(style: .actionSheet, message: nil)
        alert.addLocalePicker(type: .country) { info in
            // action with selected object
        }
        alert.addAction(title: "Dismiss", style: .cancel)
        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = self.button2
            presenter.sourceRect = self.button2.bounds
        }
        alert.show()
    }
    
    @objc func compose() {
        #if targetEnvironment(macCatalyst)
        GlobalStruct.macWindow = 1
        let userActivity = NSUserActivity(activityType: "com.shi.Mast.openComposer")
        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: userActivity, options: nil) { (e) in
          print("error", e)
        }
        #elseif !targetEnvironment(macCatalyst)
        let vc = TootViewController()
        self.show(UINavigationController(rootViewController: vc), sender: self)
        #endif
    }
}

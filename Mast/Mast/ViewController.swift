//
//  ViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 11/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import UIKit

class ViewController: UITabBarController, UITabBarControllerDelegate {
    
    var tabOne = UINavigationController()
    var tabTwo = UINavigationController()
    var tabThree = UINavigationController()
    var tabFour = UINavigationController()
    
    var firstView = FirstViewController()
    var secondView = SecondViewController()
    var thirdView = ThirdViewController()
    var fourthView = FourthViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createTabBar()
    }
    
    func createTabBar() {
        DispatchQueue.main.async {
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
            let im1 = UIImage(systemName: "bubble.middle.bottom", withConfiguration: symbolConfig)?.withTintColor(UIColor.black.withAlphaComponent(1), renderingMode: .alwaysOriginal)
            let im1b = UIImage(systemName: "bubble.middle.bottom.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.black.withAlphaComponent(1), renderingMode: .alwaysOriginal)
            
            let im2 = UIImage(systemName: "paperplane", withConfiguration: symbolConfig)?.withTintColor(UIColor.black.withAlphaComponent(1), renderingMode: .alwaysOriginal)
            let im2b = UIImage(systemName: "paperplane.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.black.withAlphaComponent(1), renderingMode: .alwaysOriginal)
            
            let im3 = UIImage(systemName: "person.crop.circle", withConfiguration: symbolConfig)?.withTintColor(UIColor.black.withAlphaComponent(1), renderingMode: .alwaysOriginal)
            let im3b = UIImage(systemName: "person.crop.circle.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.black.withAlphaComponent(1), renderingMode: .alwaysOriginal)
            
            let im4 = UIImage(systemName: "plus.circle", withConfiguration: symbolConfig)?.withTintColor(UIColor.black.withAlphaComponent(1), renderingMode: .alwaysOriginal)
            let im4b = UIImage(systemName: "plus.circle.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.black.withAlphaComponent(1), renderingMode: .alwaysOriginal)
            
            // Create Tab one
            self.tabOne = UINavigationController(rootViewController: self.firstView)
            let tabOneBarItem = UITabBarItem(title: "", image: im1, selectedImage: im1b)
            self.tabOne.tabBarItem = tabOneBarItem
            self.tabOne.navigationBar.backgroundColor = UIColor.white
            self.tabOne.navigationBar.barTintColor = UIColor.white
            self.tabOne.tabBarItem.tag = 1
            
            // Create Tab two
            self.tabTwo = UINavigationController(rootViewController: self.secondView)
            let tabTwoBarItem = UITabBarItem(title: "", image: im2, selectedImage: im2b)
            self.tabTwo.tabBarItem = tabTwoBarItem
            self.tabTwo.navigationBar.backgroundColor = UIColor.white
            self.tabTwo.navigationBar.barTintColor = UIColor.white
            self.tabTwo.tabBarItem.tag = 2
            
            // Create Tab three
            self.tabThree = UINavigationController(rootViewController: self.thirdView)
            let tabThreeBarItem = UITabBarItem(title: "", image: im3, selectedImage: im3b)
            self.tabThree.tabBarItem = tabThreeBarItem
            self.tabThree.navigationBar.backgroundColor = UIColor.white
            self.tabThree.navigationBar.barTintColor = UIColor.white
            self.tabThree.tabBarItem.tag = 3
            
            // Create Tab four
            self.tabFour = UINavigationController(rootViewController: self.fourthView)
            let tabFourBarItem = UITabBarItem(title: "", image: im4, selectedImage: im4b)
            self.tabFour.tabBarItem = tabFourBarItem
            self.tabFour.navigationBar.backgroundColor = UIColor.white
            self.tabFour.navigationBar.barTintColor = UIColor.white
            self.tabFour.tabBarItem.tag = 4
            
            let viewControllerList = [self.tabOne, self.tabTwo, self.tabThree, self.tabFour]
            self.viewControllers = viewControllerList
        }
    }
    
    
}


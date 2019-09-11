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
    var tabFive = UINavigationController()
    
    var firstView = FirstViewController()
    var secondView = SecondViewController()
    var thirdView = ThirdViewController()
    var fourthView = FourthViewController()
    var fifthView = FifthViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.createTabBar()
    }
    
    func createTabBar() {
        DispatchQueue.main.async {
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 20)
            let im1 = UIImage(systemName: "list.bullet.below.rectangle", withConfiguration: symbolConfig)?.withTintColor(UIColor.blue.withAlphaComponent(1), renderingMode: .alwaysOriginal)
            let im2 = UIImage(systemName: "bolt", withConfiguration: symbolConfig)?.withTintColor(UIColor.blue.withAlphaComponent(1), renderingMode: .alwaysOriginal)
            let im3 = UIImage(systemName: "tray", withConfiguration: symbolConfig)?.withTintColor(UIColor.blue.withAlphaComponent(1), renderingMode: .alwaysOriginal)
            let im4 = UIImage(systemName: "person.crop.circle", withConfiguration: symbolConfig)?.withTintColor(UIColor.blue.withAlphaComponent(1), renderingMode: .alwaysOriginal)
            let im5 = UIImage(systemName: "plus.circle", withConfiguration: symbolConfig)?.withTintColor(UIColor.blue.withAlphaComponent(1), renderingMode: .alwaysOriginal)
            
            // Create Tab one
            self.tabOne = UINavigationController(rootViewController: self.firstView)
            let tabOneBarItem = UITabBarItem(title: "", image: im1, selectedImage: im1)
            self.tabOne.tabBarItem = tabOneBarItem
            self.tabOne.navigationBar.backgroundColor = UIColor.white
            self.tabOne.navigationBar.barTintColor = UIColor.white
            self.tabOne.tabBarItem.tag = 1
            
            // Create Tab two
            self.tabTwo = UINavigationController(rootViewController: self.secondView)
            let tabTwoBarItem2 = UITabBarItem(title: "", image: im2, selectedImage: im2)
            self.tabTwo.tabBarItem = tabTwoBarItem2
            self.tabTwo.navigationBar.backgroundColor = UIColor.white
            self.tabTwo.navigationBar.barTintColor = UIColor.white
            self.tabTwo.tabBarItem.tag = 2
            
            // Create Tab three
            self.tabThree = UINavigationController(rootViewController: self.thirdView)
            let tabThreeBarItem = UITabBarItem(title: "", image: im3, selectedImage: im3)
            self.tabThree.tabBarItem = tabThreeBarItem
            self.tabThree.navigationBar.backgroundColor = UIColor.white
            self.tabThree.navigationBar.barTintColor = UIColor.white
            self.tabThree.tabBarItem.tag = 3
            
            // Create Tab four
            self.tabFour = UINavigationController(rootViewController: self.fourthView)
            let tabFourBarItem = UITabBarItem(title: "", image: im4, selectedImage: im4)
            self.tabFour.tabBarItem = tabFourBarItem
            self.tabFour.navigationBar.backgroundColor = UIColor.white
            self.tabFour.navigationBar.barTintColor = UIColor.white
            self.tabFour.tabBarItem.tag = 4
            
            // Create Tab five
            self.tabFive = UINavigationController(rootViewController: self.fourthView)
            let tabFiveBarItem = UITabBarItem(title: "", image: im5, selectedImage: im5)
            self.tabFive.tabBarItem = tabFiveBarItem
            self.tabFive.navigationBar.backgroundColor = UIColor.white
            self.tabFive.navigationBar.barTintColor = UIColor.white
            self.tabFive.tabBarItem.tag = 5
            
            let viewControllerList = [self.tabOne, self.tabTwo, self.tabThree, self.tabFour, self.tabFive]
            self.viewControllers = viewControllerList
        }
    }
    
    
}


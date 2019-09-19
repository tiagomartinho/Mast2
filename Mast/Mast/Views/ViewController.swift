//
//  ViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 11/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import UIKit
import CoreHaptics

class ViewController: UITabBarController, UITabBarControllerDelegate {
    
    var engine: CHHapticEngine?
    
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
        
        self.view.backgroundColor = UIColor(named: "baseWhite")
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.startHaptics), name: NSNotification.Name(rawValue: "startHaptics"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.addTapped), name: NSNotification.Name(rawValue: "addTapped"), object: nil)
        
        self.createTabBar()
        self.tabBar.barTintColor = UIColor(named: "baseWhite")
        self.tabBar.backgroundColor = UIColor(named: "baseWhite")
        self.tabBar.isTranslucent = false
    }
    
    @objc func startHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
    
    @objc func addTapped() {
        self.hapticPatternType1()
        self.show(UINavigationController(rootViewController: TootViewController()), sender: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            engine?.playsHapticsOnly = true
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
    
    func createTabBar() {
        DispatchQueue.main.async {
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
            
            let im1 = UIImage(systemName: "bubble.middle.bottom", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.45), renderingMode: .alwaysOriginal)
            let im1b = UIImage(systemName: "bubble.middle.bottom.fill", withConfiguration: symbolConfig)?.withTintColor(GlobalStruct.baseTint.withAlphaComponent(1), renderingMode: .alwaysOriginal)
            
            let im2 = UIImage(systemName: "bell", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.45), renderingMode: .alwaysOriginal)
            let im2b = UIImage(systemName: "bell.fill", withConfiguration: symbolConfig)?.withTintColor(GlobalStruct.baseTint.withAlphaComponent(1), renderingMode: .alwaysOriginal)
            
            let im3 = UIImage(systemName: "paperplane", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.45), renderingMode: .alwaysOriginal)
            let im3b = UIImage(systemName: "paperplane.fill", withConfiguration: symbolConfig)?.withTintColor(GlobalStruct.baseTint.withAlphaComponent(1), renderingMode: .alwaysOriginal)
            
            let im4 = UIImage(systemName: "grid.circle", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.45), renderingMode: .alwaysOriginal)
            let im4b = UIImage(systemName: "grid.circle.fill", withConfiguration: symbolConfig)?.withTintColor(GlobalStruct.baseTint.withAlphaComponent(1), renderingMode: .alwaysOriginal)
            
            let im5 = UIImage(systemName: "person.crop.circle", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.45), renderingMode: .alwaysOriginal)
            let im5b = UIImage(systemName: "person.crop.circle.fill", withConfiguration: symbolConfig)?.withTintColor(GlobalStruct.baseTint.withAlphaComponent(1), renderingMode: .alwaysOriginal)
            
            // Create Tab one
            self.tabOne = UINavigationController(rootViewController: self.firstView)
            self.tabOne.tabBarItem = UITabBarItem(title: "".localized, image: im1, selectedImage: im1b)
            self.tabOne.navigationBar.backgroundColor = UIColor(named: "baseWhite")
            self.tabOne.navigationBar.barTintColor = UIColor(named: "baseWhite")
            self.tabOne.tabBarItem.tag = 1
            
            // Create Tab two
            self.tabTwo = UINavigationController(rootViewController: self.secondView)
            self.tabTwo.tabBarItem = UITabBarItem(title: "".localized, image: im2, selectedImage: im2b)
            self.tabTwo.navigationBar.backgroundColor = UIColor(named: "baseWhite")
            self.tabTwo.navigationBar.barTintColor = UIColor(named: "baseWhite")
            self.tabTwo.tabBarItem.tag = 2
            
            // Create Tab three
            self.tabThree = UINavigationController(rootViewController: self.thirdView)
            self.tabThree.tabBarItem = UITabBarItem(title: "".localized, image: im3, selectedImage: im3b)
            self.tabThree.navigationBar.backgroundColor = UIColor(named: "baseWhite")
            self.tabThree.navigationBar.barTintColor = UIColor(named: "baseWhite")
            self.tabThree.tabBarItem.tag = 3
            
            // Create Tab four
            self.tabFour = UINavigationController(rootViewController: self.fourthView)
            self.tabFour.tabBarItem = UITabBarItem(title: "".localized, image: im4, selectedImage: im4b)
            self.tabFour.navigationBar.backgroundColor = UIColor(named: "baseWhite")
            self.tabFour.navigationBar.barTintColor = UIColor(named: "baseWhite")
            self.tabFour.tabBarItem.tag = 4
            
            // Create Tab five
            self.tabFive = UINavigationController(rootViewController: self.fifthView)
            self.tabFive.tabBarItem = UITabBarItem(title: "".localized, image: im5, selectedImage: im5b)
            self.tabFive.navigationBar.backgroundColor = UIColor(named: "baseWhite")
            self.tabFive.navigationBar.barTintColor = UIColor(named: "baseWhite")
            self.tabFive.tabBarItem.tag = 5
            
            self.viewControllers = [self.tabOne, self.tabTwo, self.tabThree, self.tabFour, self.tabFive]
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        self.hapticPatternType1()
    }
    
    //MARK: Haptic patterns
    
    func hapticPatternType1() {
        if UserDefaults.standard.value(forKey: "sync-haptics") as? Int != nil {
            if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
                if CHHapticEngine.capabilitiesForHardware().supportsHaptics {
                    self.hapticPattern1()
                } else {
                    let selection = UISelectionFeedbackGenerator()
                    selection.selectionChanged()
                }
            } else {
                
            }
        } else {
            if CHHapticEngine.capabilitiesForHardware().supportsHaptics {
                self.hapticPattern1()
            } else {
                let selection = UISelectionFeedbackGenerator()
                selection.selectionChanged()
            }
        }
    }
    
    func hapticPattern1() {
        var events = [CHHapticEvent]()
        for i in stride(from: 0, to: 1.0, by: 1) {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(0.65))
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(0.5))
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: i)
            events.append(event)
        }
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
    
}

// EXTENSIONS

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}

extension Array where Element: Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        return result
    }
}

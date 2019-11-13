//
//  ViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 11/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import UIKit
import CoreHaptics
import SafariServices

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
    
    var statusBarView = UIView()
    var safariVC: SFSafariViewController?
    
    @objc func notifChangeTint() {
        self.createTabBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
    }
    
    func openLink() {
        if UserDefaults.standard.value(forKey: "sync-chosenBrowser") as? Int == 0 {
            UIApplication.shared.openURL(GlobalStruct.tappedURL!)
        }
        if UserDefaults.standard.value(forKey: "sync-chosenBrowser") as? Int == 1 {
            let newLink = String(String(GlobalStruct.tappedURL?.absoluteString.replacingOccurrences(of: "https://", with: "googlechrome://") ?? "").replacingOccurrences(of: "http://", with: "googlechrome://"))
            if UIApplication.shared.canOpenURL(URL(string: newLink)!) {
                UIApplication.shared.openURL(URL(string: newLink)!)
            } else {
                UIApplication.shared.openURL(GlobalStruct.tappedURL!)
            }
        }
        if UserDefaults.standard.value(forKey: "sync-chosenBrowser") as? Int == 2 {
            let newLink = String(String(GlobalStruct.tappedURL?.absoluteString.replacingOccurrences(of: "https://", with: "firefox://open-url?url=https://") ?? "").replacingOccurrences(of: "http://", with: "firefox://open-url?url=http://"))
            if UIApplication.shared.canOpenURL(URL(string: newLink)!) {
                UIApplication.shared.openURL(URL(string: newLink)!)
            } else {
                UIApplication.shared.openURL(GlobalStruct.tappedURL!)
            }
        }
        if UserDefaults.standard.value(forKey: "sync-chosenBrowser") as? Int == 3 {
            let newLink = String(String(GlobalStruct.tappedURL?.absoluteString.replacingOccurrences(of: "https://", with: "opera://open-url?url=https://") ?? "").replacingOccurrences(of: "http://", with: "opera://open-url?url=http://"))
            if UIApplication.shared.canOpenURL(URL(string: newLink)!) {
                UIApplication.shared.openURL(URL(string: newLink)!)
            } else {
                UIApplication.shared.openURL(GlobalStruct.tappedURL!)
            }
        }
        if UserDefaults.standard.value(forKey: "sync-chosenBrowser") as? Int == 4 {
            let newLink = String(String(GlobalStruct.tappedURL?.absoluteString.replacingOccurrences(of: "https://", with: "dolphin://") ?? "").replacingOccurrences(of: "http://", with: "dolphin://"))
            if UIApplication.shared.canOpenURL(URL(string: newLink)!) {
                UIApplication.shared.openURL(URL(string: newLink)!)
            } else {
                UIApplication.shared.openURL(GlobalStruct.tappedURL!)
            }
        }
        if UserDefaults.standard.value(forKey: "sync-chosenBrowser") as? Int == 5 {
            let newLink = String(String(GlobalStruct.tappedURL?.absoluteString.replacingOccurrences(of: "https://", with: "brave://open-url?url=https://") ?? "").replacingOccurrences(of: "http://", with: "brave://open-url?url=http://"))
            if UIApplication.shared.canOpenURL(URL(string: newLink)!) {
                UIApplication.shared.openURL(URL(string: newLink)!)
            } else {
                UIApplication.shared.openURL(GlobalStruct.tappedURL!)
            }
        }
        if UserDefaults.standard.value(forKey: "sync-chosenBrowser") as? Int == 6 {
            if let x = GlobalStruct.tappedURL {
                self.safariVC = SFSafariViewController(url: x)
                getTopMostViewController()?.present(self.safariVC!, animated: true, completion: nil)
            }
        }
    }
    
    func getTopMostViewController() -> UIViewController? {
        var topMostViewController = UIApplication.shared.keyWindow?.rootViewController
        while let presentedViewController = topMostViewController?.presentedViewController {
            topMostViewController = presentedViewController
        }
        return topMostViewController
    }
    
    @objc func viewNotifications() {
        self.viewControllers?.last?.tabBarController?.selectedIndex = 1
    }
    
    @objc func viewMessages() {
        self.viewControllers?.last?.tabBarController?.selectedIndex = 2
    }
    
    @objc func viewProfile() {
        self.viewControllers?.last?.tabBarController?.selectedIndex = 4
    }
    
    @objc func notifChangeBG() {
        GlobalStruct.baseDarkTint = (UserDefaults.standard.value(forKey: "sync-startDarkTint") == nil || UserDefaults.standard.value(forKey: "sync-startDarkTint") as? Int == 0) ? UIColor(named: "baseWhite")! : UIColor(named: "baseWhite2")!
        self.view.backgroundColor = GlobalStruct.baseDarkTint
        self.tabBar.barTintColor = GlobalStruct.baseDarkTint
        self.navigationController?.navigationBar.backgroundColor = GlobalStruct.baseDarkTint
        self.navigationController?.navigationBar.barTintColor = GlobalStruct.baseDarkTint
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = GlobalStruct.baseDarkTint
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.startHaptics), name: NSNotification.Name(rawValue: "startHaptics"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.addTapped), name: NSNotification.Name(rawValue: "addTapped"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notifChangeTint), name: NSNotification.Name(rawValue: "notifChangeTint"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.viewNotifications), name: NSNotification.Name(rawValue: "viewNotifications"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.viewMessages), name: NSNotification.Name(rawValue: "viewMessages"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.viewProfile), name: NSNotification.Name(rawValue: "viewProfile"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notifChangeBG), name: NSNotification.Name(rawValue: "notifChangeBG"), object: nil)
        
        statusBarView.backgroundColor = GlobalStruct.baseDarkTint
        view.addSubview(statusBarView)
        
        self.createTabBar()
        self.tabBar.barTintColor = GlobalStruct.baseDarkTint
        self.tabBar.isTranslucent = true
        
        if UserDefaults.standard.value(forKey: "sync-startTint") == nil {
            UserDefaults.standard.set(0, forKey: "sync-startTint")
            GlobalStruct.baseTint = GlobalStruct.arrayCols[0]
        } else {
            if let x = UserDefaults.standard.value(forKey: "sync-startTint") as? Int {
                GlobalStruct.baseTint = GlobalStruct.arrayCols[x]
            }
        }
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(tabButtonItemLongPressed(_:)))
        longPressRecognizer.minimumPressDuration = 0.3
        self.tabBar.addGestureRecognizer(longPressRecognizer)
    }

    @objc func tabButtonItemLongPressed(_ recognizer: UILongPressGestureRecognizer) {
        guard recognizer.state == .began else { return }
        guard let tabBar = recognizer.view as? UITabBar else { return }
        guard let tabBarItems = tabBar.items else { return }
        guard let viewControllers = viewControllers else { return }
        guard tabBarItems.count == viewControllers.count else { return }

        let loc = recognizer.location(in: tabBar)

        for (index, item) in tabBarItems.enumerated() {
            guard let view = item.value(forKey: "view") as? UIView else { continue }
            guard view.frame.contains(loc) else { continue }

            if let _ = viewControllers[index] as? UINavigationController {
                if index == 3 {
                    self.viewControllers?.last?.tabBarController?.selectedIndex = 3
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "searchTapped"), object: self)
                }
                if index == 4 {
                    self.displayAccounts()
                }
            }

            break
        }
    }
    
    func displayAccounts() {
        let instances = InstanceData.getAllInstances()
        let curr = InstanceData.getCurrentInstance()
        let alert = UIAlertController(title: "All Accounts".localized, message: nil, preferredStyle: .actionSheet)
        var count = 0
        for (z, x) in Account.getAccounts().enumerated() {
            var instance: InstanceData? = nil
            if InstanceData.getAllInstances().count == 0 {} else {
                instance = InstanceData.getAllInstances()[z]
            }
            let instanceAndAccount = "@\(instance?.returnedText ?? "")"
            
            let op1 = UIAlertAction(title: "\(x.displayName) (@\(x.username)\(instanceAndAccount))", style: .default , handler:{ (UIAlertAction) in
                if curr?.clientID == instances[z].clientID {
                    
                } else {
                    InstanceData.setCurrentInstance(instance: instances[z])
                    GlobalStruct.client = Client(
                        baseURL: "https://\(instances[z].returnedText)",
                        accessToken: instances[z].accessToken
                    )
                    FirstViewController().initialFetches()
                    UIApplication.shared.keyWindow?.rootViewController = ViewController()
                }
            })
            if curr?.clientID == instances[z].clientID {
                op1.setValue(UIImage(systemName: "checkmark.circle.fill")!, forKey: "image")
            } else {
                op1.setValue(UIImage(systemName: "circle")!, forKey: "image")
            }
            op1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op1)
            count += 1
        }
        
        alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
            
        }))
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.left
        let messageText = NSMutableAttributedString(
            string: "All Accounts".localized,
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
            ]
        )
        alert.setValue(messageText, forKey: "attributedTitle")
        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = self.view
            presenter.sourceRect = self.view.bounds
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        self.hapticPatternType1()
        if item.tag == 1 && GlobalStruct.currentTab == 1 {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "scrollTop1"), object: nil)
        }
        if item.tag == 2 && GlobalStruct.currentTab == 2 {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "scrollTop2"), object: nil)
        }
        if item.tag == 3 && GlobalStruct.currentTab == 3 {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "scrollTop3"), object: nil)
        }
        if item.tag == 4 && GlobalStruct.currentTab == 4 {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "scrollTop4"), object: nil)
        }
        if item.tag == 5 && GlobalStruct.currentTab == 5 {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "scrollTop5"), object: nil)
        }
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
            
            let im1 = UIImage(systemName: "text.bubble", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.45), renderingMode: .alwaysOriginal)
            let im1b = UIImage(systemName: "text.bubble.fill", withConfiguration: symbolConfig)?.withTintColor(GlobalStruct.baseTint.withAlphaComponent(1), renderingMode: .alwaysOriginal)
            
            let im2 = UIImage(systemName: "bell", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.45), renderingMode: .alwaysOriginal)
            let im2b = UIImage(systemName: "bell.fill", withConfiguration: symbolConfig)?.withTintColor(GlobalStruct.baseTint.withAlphaComponent(1), renderingMode: .alwaysOriginal)
            
            let im3 = UIImage(systemName: "paperplane", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.45), renderingMode: .alwaysOriginal)
            let im3b = UIImage(systemName: "paperplane.fill", withConfiguration: symbolConfig)?.withTintColor(GlobalStruct.baseTint.withAlphaComponent(1), renderingMode: .alwaysOriginal)
            
            let im4 = UIImage(systemName: "magnifyingglass.circle", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.45), renderingMode: .alwaysOriginal)
            let im4b = UIImage(systemName: "magnifyingglass.circle.fill", withConfiguration: symbolConfig)?.withTintColor(GlobalStruct.baseTint.withAlphaComponent(1), renderingMode: .alwaysOriginal)
            
            let im5 = UIImage(systemName: "person.crop.circle", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.45), renderingMode: .alwaysOriginal)
            let im5b = UIImage(systemName: "person.crop.circle.fill", withConfiguration: symbolConfig)?.withTintColor(GlobalStruct.baseTint.withAlphaComponent(1), renderingMode: .alwaysOriginal)
            
            // Create Tab one
            self.tabOne = UINavigationController(rootViewController: self.firstView)
            self.tabOne.tabBarItem = UITabBarItem(title: "Feed".localized, image: im1, selectedImage: im1b)
            self.tabOne.navigationBar.backgroundColor = GlobalStruct.baseDarkTint
            self.tabOne.navigationBar.barTintColor = GlobalStruct.baseDarkTint
            self.tabOne.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: GlobalStruct.baseTint], for: .selected)
            self.tabOne.accessibilityLabel = "Feed".localized
            self.tabOne.tabBarItem.tag = 1
            
            // Create Tab two
            self.tabTwo = UINavigationController(rootViewController: self.secondView)
            self.tabTwo.tabBarItem = UITabBarItem(title: "Notifications".localized, image: im2, selectedImage: im2b)
            self.tabTwo.navigationBar.backgroundColor = GlobalStruct.baseDarkTint
            self.tabTwo.navigationBar.barTintColor = GlobalStruct.baseDarkTint
            self.tabTwo.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: GlobalStruct.baseTint], for: .selected)
            self.tabTwo.accessibilityLabel = "Notifications".localized
            self.tabTwo.tabBarItem.tag = 2
            
            // Create Tab three
            self.tabThree = UINavigationController(rootViewController: self.thirdView)
            self.tabThree.tabBarItem = UITabBarItem(title: "Messages".localized, image: im3, selectedImage: im3b)
            self.tabThree.navigationBar.backgroundColor = GlobalStruct.baseDarkTint
            self.tabThree.navigationBar.barTintColor = GlobalStruct.baseDarkTint
            self.tabThree.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: GlobalStruct.baseTint], for: .selected)
            self.tabThree.accessibilityLabel = "Messages".localized
            self.tabThree.tabBarItem.tag = 3
            
            // Create Tab four
            self.tabFour = UINavigationController(rootViewController: self.fourthView)
            self.tabFour.tabBarItem = UITabBarItem(title: "Explore".localized, image: im4, selectedImage: im4b)
            self.tabFour.navigationBar.backgroundColor = GlobalStruct.baseDarkTint
            self.tabFour.navigationBar.barTintColor = GlobalStruct.baseDarkTint
            self.tabFour.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: GlobalStruct.baseTint], for: .selected)
            self.tabFour.accessibilityLabel = "Explore".localized
            self.tabFour.tabBarItem.tag = 4
            
            // Create Tab five
            self.tabFive = UINavigationController(rootViewController: self.fifthView)
            self.tabFive.tabBarItem = UITabBarItem(title: "Profile".localized, image: im5, selectedImage: im5b)
            self.tabFive.navigationBar.backgroundColor = GlobalStruct.baseDarkTint
            self.tabFive.navigationBar.barTintColor = GlobalStruct.baseDarkTint
            self.tabFive.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: GlobalStruct.baseTint], for: .selected)
            self.tabFive.accessibilityLabel = "Profile".localized
            self.tabFive.tabBarItem.tag = 5
            
            self.viewControllers = [self.tabOne, self.tabTwo, self.tabThree, self.tabFour, self.tabFive]
        }
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

public func timeAgoSince(_ date: Date) -> String {
    let calendar = Calendar.current
    let now = Date()
    let unitFlags: NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfYear, .month, .year]
    let components = (calendar as NSCalendar).components(unitFlags, from: date, to: now, options: [])
    
    if let year = components.year, year >= 2 {
        return "\(year)y"
    }
    
    if let year = components.year, year >= 1 {
        return "1y"
    }
    
    if let month = components.month, month >= 2 {
        return "\(month)M"
    }
    
    if let month = components.month, month >= 1 {
        return "1M"
    }
    
    if let week = components.weekOfYear, week >= 2 {
        return "\(week)w"
    }
    
    if let week = components.weekOfYear, week >= 1 {
        return "1w"
    }
    
    if let day = components.day, day >= 2 {
        return "\(day)d"
    }
    
    if let day = components.day, day >= 1 {
        return "1d"
    }
    
    if let hour = components.hour, hour >= 2 {
        return "\(hour)h"
    }
    
    if let hour = components.hour, hour >= 1 {
        return "1h"
    }
    
    if let minute = components.minute, minute >= 2 {
        return "\(minute)m"
    }
    
    if let minute = components.minute, minute >= 1 {
        return "1m"
    }
    
    if let second = components.second, second >= 3 {
        return "\(second)s"
    }
    
    return "Just now"
}

let imageCache = NSCache<NSString, AnyObject>()

extension NSTextAttachment {
    func loadImageUsingCache(withUrl urlString : String) {
        let url = URL(string: urlString)
        self.image = nil
        
        // check cached image
        if let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.image = cachedImage
            return
        }
        
        // if not, download image from url
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                if let image = UIImage(data: data!) {
                    self.image = image
                    imageCache.setObject(image, forKey: urlString as NSString)
                }
            }
            
        }).resume()
    }
}

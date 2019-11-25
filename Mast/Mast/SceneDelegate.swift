//
//  SceneDelegate.swift
//  Mast
//
//  Created by Shihab Mehboob on 11/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let blurEffect = UIBlurEffect(style: .systemChromeMaterial)
    var blurredEffectView = UIVisualEffectView()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }

        #if targetEnvironment(macCatalyst)
        if let windowScene = scene as? UIWindowScene {
            windowScene.titlebar?.titleVisibility = .hidden
        }
        #endif

        var isSplitOrSlideOver: Bool {
            let windows = UIApplication.shared.windows
            for x in windows {
                if let z = self.window {
                    if x == z {
                        if x.frame.width == x.screen.bounds.width || x.frame.width == x.screen.bounds.height {
                            return false
                        } else {
                            return true
                        }
                    }
                }
            }
            return false
        }
        
        #if targetEnvironment(macCatalyst)
        if GlobalStruct.macWindow == 1 {
            let vc = TootViewController()
            self.window?.rootViewController = vc
            self.window!.makeKeyAndVisible()
            if let windowScene = scene as? UIWindowScene {
                windowScene.sizeRestrictions?.minimumSize = CGSize(width: 650, height: 400)
                windowScene.sizeRestrictions?.maximumSize = CGSize(width: 650, height: 400)
                if let titlebar = windowScene.titlebar {
                    let toolbar = NSToolbar(identifier: "testToolbar")
                    toolbar.delegate = vc.self
                    toolbar.allowsUserCustomization = false
                    toolbar.insertItem(withItemIdentifier: NSToolbarItem.Identifier(rawValue: "addMedia"), at: 0)
                    toolbar.insertItem(withItemIdentifier: NSToolbarItem.Identifier(rawValue: "visibility"), at: 0)
                    toolbar.insertItem(withItemIdentifier: NSToolbarItem.Identifier(rawValue: "spoiler"), at: 0)
                    toolbar.insertItem(withItemIdentifier: NSToolbarItem.Identifier(rawValue: "emo"), at: 0)
                    toolbar.insertItem(withItemIdentifier: NSToolbarItem.Identifier(rawValue: "poll"), at: 0)
                    toolbar.insertItem(withItemIdentifier: NSToolbarItem.Identifier(rawValue: "schedule"), at: 0)
                    toolbar.insertItem(withItemIdentifier: NSToolbarItem.Identifier(rawValue: "drafts"), at: 0)
                    toolbar.insertItem(withItemIdentifier: NSToolbarItem.Identifier(rawValue: "tick"), at: 0)
                    titlebar.toolbar = toolbar
                }
            }
        } else if GlobalStruct.macWindow == 2 {
            let vc = TootViewController()
            vc.replyStatus = GlobalStruct.macReply
            self.window?.rootViewController = vc
            self.window!.makeKeyAndVisible()
            if let windowScene = scene as? UIWindowScene {
                windowScene.sizeRestrictions?.minimumSize = CGSize(width: 650, height: 400)
                windowScene.sizeRestrictions?.maximumSize = CGSize(width: 650, height: 400)
                if let titlebar = windowScene.titlebar {
                    let toolbar = NSToolbar(identifier: "testToolbar")
                    toolbar.delegate = vc.self
                    toolbar.allowsUserCustomization = false
                    toolbar.insertItem(withItemIdentifier: NSToolbarItem.Identifier(rawValue: "addMedia"), at: 0)
                    toolbar.insertItem(withItemIdentifier: NSToolbarItem.Identifier(rawValue: "visibility"), at: 0)
                    toolbar.insertItem(withItemIdentifier: NSToolbarItem.Identifier(rawValue: "spoiler"), at: 0)
                    toolbar.insertItem(withItemIdentifier: NSToolbarItem.Identifier(rawValue: "emo"), at: 0)
                    toolbar.insertItem(withItemIdentifier: NSToolbarItem.Identifier(rawValue: "poll"), at: 0)
                    toolbar.insertItem(withItemIdentifier: NSToolbarItem.Identifier(rawValue: "schedule"), at: 0)
                    toolbar.insertItem(withItemIdentifier: NSToolbarItem.Identifier(rawValue: "drafts"), at: 0)
                    toolbar.insertItem(withItemIdentifier: NSToolbarItem.Identifier(rawValue: "tick"), at: 0)
                    titlebar.toolbar = toolbar
                }
            }
        } else {
            let rootController = ColumnViewController()
            let nav0 = VerticalTabBarController()
            let nav1 = ScrollMainViewController()
            
            let nav01 = UINavigationController(rootViewController: FirstViewController())
            let nav02 = UINavigationController(rootViewController: SecondViewController())
            let nav03 = UINavigationController(rootViewController: ThirdViewController())
            let nav04 = UINavigationController(rootViewController: FourthViewController())
            let nav05 = UINavigationController(rootViewController: FifthViewController())
            nav1.viewControllers = [nav01, nav02, nav03, nav04, nav05]
            
            rootController.viewControllers = [nav0, nav1]
            self.window?.rootViewController = rootController
            self.window!.makeKeyAndVisible()
        }
        #elseif !targetEnvironment(macCatalyst)
        if UIDevice.current.userInterfaceIdiom == .pad && isSplitOrSlideOver == false {
            let rootController = ColumnViewController()
            let nav0 = VerticalTabBarController()
            let nav1 = ScrollMainViewController()

            let nav01 = UINavigationController(rootViewController: FirstViewController())
            let nav02 = UINavigationController(rootViewController: SecondViewController())
            let nav03 = UINavigationController(rootViewController: ThirdViewController())
            let nav04 = UINavigationController(rootViewController: FourthViewController())
            let nav05 = UINavigationController(rootViewController: FifthViewController())
            nav1.viewControllers = [nav01, nav02, nav03, nav04, nav05]

            rootController.viewControllers = [nav0, nav1]
            self.window?.rootViewController = rootController
            self.window!.makeKeyAndVisible()
        }
        #endif
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        if shortcutItem.type == "com.shi.Mast.NewToot" {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "addTapped"), object: self)
            completionHandler(true)
        } else if shortcutItem.type == "com.shi.Mast.Notifications" {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "viewNotifications"), object: self)
            completionHandler(true)
        } else if shortcutItem.type == "com.shi.Mast.Messages" {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "viewMessages"), object: self)
            completionHandler(true)
        } else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "viewProfile"), object: self)
            completionHandler(false)
        }
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        if userActivity.activityType == "com.shi.Mast.newToot" {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "addTapped"), object: self)
        }
        if userActivity.activityType == "com.shi.Mast.viewNotifs" {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "viewNotifications"), object: self)
        }
        if userActivity.activityType == "com.shi.Mast.viewMessages" {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "viewMessages"), object: self)
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = (URLContexts.first?.url ?? URL(string: "www.google.com")) {
            if url.host == "success" {
                print("Response ==> \(url.absoluteString)")
                let x = url.absoluteString
                let y = x.split(separator: "=")
                GlobalStruct.currentInstance.authCode = y.last?.description ?? ""
                NotificationCenter.default.post(name: Notification.Name(rawValue: "logged"), object: nil)
            } else if url.host == "addNewInstance" {
                print("Response ==> \(url.absoluteString)")
                let x = url.absoluteString
                let y = x.split(separator: "=")
                GlobalStruct.newInstance!.authCode = y.last?.description ?? ""
                NotificationCenter.default.post(name: Notification.Name(rawValue: "newInstanceLogged"), object: nil)
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        self.window?.tintColor = UIColor(named: "baseBlack")!
        NotificationCenter.default.post(name: Notification.Name(rawValue: "startHaptics"), object: self)
        
        self.showBioLock()
    }
    
    func showBioLock() {
        if UserDefaults.standard.value(forKey: "sync-lock") as? Int == 1 {
            self.blurredEffectView = UIVisualEffectView(effect: blurEffect)
            self.blurredEffectView.frame = UIApplication.shared.windows.last?.bounds ?? UIWindow().bounds
            window?.addSubview(self.blurredEffectView)
            
            if UserDefaults.standard.value(forKey: "sync-lockTime") as? Int == 0 {
                BioMetricAuthenticator.shared.allowableReuseDuration = 1
            } else if UserDefaults.standard.value(forKey: "sync-lockTime") as? Int == 1 {
                BioMetricAuthenticator.shared.allowableReuseDuration = 60
            } else if UserDefaults.standard.value(forKey: "sync-lockTime") as? Int == 2 {
                BioMetricAuthenticator.shared.allowableReuseDuration = 300
            } else if UserDefaults.standard.value(forKey: "sync-lockTime") as? Int == 3 {
                BioMetricAuthenticator.shared.allowableReuseDuration = 900
            } else if UserDefaults.standard.value(forKey: "sync-lockTime") as? Int == 4 {
                BioMetricAuthenticator.shared.allowableReuseDuration = 3600
            }
            
            if BioMetricAuthenticator.canAuthenticate() {
                BioMetricAuthenticator.authenticateWithBioMetrics(reason: "") { [weak self] (result) in
                    switch result {
                    case .success( _):
                        self?.blurredEffectView.removeFromSuperview()
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "becomeFirst"), object: self)
                    case .failure(let error):
                        switch error {
                        case .biometryNotAvailable:
                            self?.blurredEffectView.removeFromSuperview()
                            self?.showBioLock()
                        case .biometryNotEnrolled:
                            self?.blurredEffectView.removeFromSuperview()
                            self?.showBioLock()
                        case .fallback:
                            self?.blurredEffectView.removeFromSuperview()
                            self?.showBioLock()
                        case .biometryLockedout:
                            self?.blurredEffectView.removeFromSuperview()
                            self?.showBioLock()
                        case .canceledBySystem:
                            self?.blurredEffectView.removeFromSuperview()
                            self?.showBioLock()
                        case .canceledByUser:
                            self?.blurredEffectView.removeFromSuperview()
                            self?.showBioLock()
                        default:
                            self?.blurredEffectView.removeFromSuperview()
                            self?.showBioLock()
                        }
                    }
                }
            } else {
                self.showBioLock()
            }
        }
    }
    
    func showPasscodeAuthentication(message: String) {
        BioMetricAuthenticator.authenticateWithPasscode(reason: message) { [weak self] (result) in
            switch result {
            case .success( _):
                self?.blurredEffectView.removeFromSuperview()
            case .failure(let error):
                self?.showBioLock()
                print(error.message())
            }
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}


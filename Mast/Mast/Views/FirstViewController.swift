//
//  FirstViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 11/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import SafariServices
import WatchConnectivity

class FirstViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, WCSessionDelegate {
    
    public var isSplitOrSlideOver: Bool {
        let windows = UIApplication.shared.windows
        for x in windows {
            if let z = self.view.window {
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
    var tableView = UITableView()
    var tableViewL = UITableView()
    var tableViewF = UITableView()
    var tableViewIntro = UITableView()
    var loginBG = UIView()
    var loginLogo = UIImageView()
    var loginLabel = UILabel()
    var textField = PaddedTextField()
    var safariVC: SFSafariViewController?
    let segment: UISegmentedControl = UISegmentedControl(items: ["Home".localized, "Local".localized, "All".localized])
    var refreshControl = UIRefreshControl()
    var refreshControlL = UIRefreshControl()
    var refreshControlF = UIRefreshControl()
    let top1 = UIButton()
    let top2 = UIButton()
    let top3 = UIButton()
    let btn2 = UIButton(type: .custom)
    var newInstance = false
    var notTypes: [NotificationType] = [.direct, .favourite, .follow, .mention, .poll, .reblog]
    var statusesHome: [Status] = []
    var statusesLocal: [Status] = []
    var statusesFed: [Status] = []
    var statusesHomeTemp: [Status] = []
    var statusesLocalTemp: [Status] = []
    var statusesFedTemp: [Status] = []
    var keyHeight: CGFloat = 0
    var altInstances: [String] = []
    var fullWid = UIScreen.main.bounds.width
    var fullHe = UIScreen.main.bounds.height
    var gapLastID = ""
    var gapLastStat: Status? = nil
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("active: \(activationState)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("deactivate")
    }
    
    var watchSession: WCSession? {
        didSet {
            if let session = watchSession {
                session.delegate = self
                session.activate()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let statusBarOrientation = UIApplication.shared.statusBarOrientation
        if (statusBarOrientation != UIInterfaceOrientation.portrait
            && statusBarOrientation != UIInterfaceOrientation.portraitUpsideDown) {
            self.fullHe = UIScreen.main.bounds.width
            self.fullWid = UIScreen.main.bounds.height
        } else {
            self.fullHe = UIScreen.main.bounds.height
            self.fullWid = UIScreen.main.bounds.width
        }
        
        #if targetEnvironment(macCatalyst)
        let part1 = (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + 210 + self.keyHeight
        let theWid = self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right
        self.loginBG.frame = CGRect(x: 0, y: 0, width: 50000, height: 50000)
        self.loginLogo.frame = CGRect(x: self.fullWid/2 - 40, y: (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + 40, width: 80, height: 80)
        self.textField.frame = CGRect(x: self.fullWid/2 - (theWid/2) + 20, y: (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + 140, width: theWid - 40, height: 50)
        self.tableViewIntro.frame = CGRect(x: self.fullWid/2 - (theWid/2), y: (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + 210, width: theWid, height: self.view.bounds.height - part1)
        #elseif !targetEnvironment(macCatalyst)
        let part1 = (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + 210 + self.keyHeight
        if UIDevice.current.userInterfaceIdiom == .pad && self.isSplitOrSlideOver == false {
            let theWid = self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right
            self.loginBG.frame = CGRect(x: 0, y: 0, width: self.fullWid, height: self.fullHe)
            self.loginLogo.frame = CGRect(x: self.fullWid/2 - 40, y: (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + 40, width: 80, height: 80)
            self.textField.frame = CGRect(x: self.fullWid/2 - (theWid/2) + 20, y: (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + 140, width: theWid - 40, height: 50)
            self.tableViewIntro.frame = CGRect(x: self.fullWid/2 - (theWid/2), y: (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + 210, width: theWid, height: self.view.bounds.height - part1)
        } else {
            self.loginBG.frame = UIApplication.applicationWindow.screen.bounds
            self.loginLogo.frame = CGRect(x: self.view.bounds.width/2 - 40, y: (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + 40, width: 80, height: 80)
            self.textField.frame = CGRect(x: self.view.safeAreaInsets.left + 20, y: (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + 140, width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right - 40, height: 50)
            self.tableViewIntro.frame = CGRect(x: self.view.safeAreaInsets.left, y: (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + 210, width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: self.view.bounds.height - part1)
        }
        #endif
        
        #if targetEnvironment(macCatalyst)
        self.segment.frame = CGRect(x: 15, y: (self.navigationController?.navigationBar.bounds.height ?? 0) + 5, width: self.view.bounds.width - 30, height: segment.bounds.height)
        
        // Table
        let tableHeight = (self.navigationController?.navigationBar.bounds.height ?? 0) + (self.segment.bounds.height) + 10
        self.tableView.frame = CGRect(x: 0, y: tableHeight, width: self.view.bounds.width, height: (self.view.bounds.height) - tableHeight)
        self.tableViewL.frame = CGRect(x: 0, y: tableHeight, width: self.view.bounds.width, height: (self.view.bounds.height) - tableHeight)
        self.tableViewF.frame = CGRect(x: 0, y: tableHeight, width: self.view.bounds.width, height: (self.view.bounds.height) - tableHeight)
        #elseif !targetEnvironment(macCatalyst)
        if UIDevice.current.userInterfaceIdiom == .pad && self.isSplitOrSlideOver == false {
            self.segment.frame = CGRect(x: 15, y: (self.navigationController?.navigationBar.bounds.height ?? 0) + 5, width: self.view.bounds.width - 30, height: segment.bounds.height)
            
            // Table
            let tableHeight = (self.navigationController?.navigationBar.bounds.height ?? 0) + (self.segment.bounds.height) + 10
            self.tableView.frame = CGRect(x: 0, y: tableHeight, width: self.view.bounds.width, height: (self.view.bounds.height) - tableHeight)
            self.tableViewL.frame = CGRect(x: 0, y: tableHeight, width: self.view.bounds.width, height: (self.view.bounds.height) - tableHeight)
            self.tableViewF.frame = CGRect(x: 0, y: tableHeight, width: self.view.bounds.width, height: (self.view.bounds.height) - tableHeight)
        } else {
            self.segment.frame = CGRect(x: 15, y: (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + (self.navigationController?.navigationBar.bounds.height ?? 0) + 5, width: self.view.bounds.width - 30, height: segment.bounds.height)
            
            // Table
            let tab0 = (self.navigationController?.navigationBar.bounds.height ?? 0) + (self.segment.bounds.height) + 10
            let tableHeight = (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + tab0
            self.tableView.frame = CGRect(x: 0, y: tableHeight, width: self.view.bounds.width, height: (self.view.bounds.height) - tableHeight)
            self.tableViewL.frame = CGRect(x: 0, y: tableHeight, width: self.view.bounds.width, height: (self.view.bounds.height) - tableHeight)
            self.tableViewF.frame = CGRect(x: 0, y: tableHeight, width: self.view.bounds.width, height: (self.view.bounds.height) - tableHeight)
        }
        #endif
    }
    
    @objc func updatePosted() {
        print("toot toot")
    }
    
    @objc func scrollTop1() {
        if self.tableView.alpha == 1 {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut, animations: {
                self.top1.alpha = 0
                self.top1.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            }) { (completed: Bool) in
            }
        }
        if self.tableViewL.alpha == 1 {
            self.tableViewL.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut, animations: {
                self.top2.alpha = 0
                self.top2.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            }) { (completed: Bool) in
            }
        }
        if self.tableViewF.alpha == 1 {
            self.tableViewF.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut, animations: {
                self.top3.alpha = 0
                self.top3.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            }) { (completed: Bool) in
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.view.backgroundColor = GlobalStruct.baseDarkTint
        GlobalStruct.currentTab = 1
        
        let applicationContext = [GlobalStruct.currentInstance.accessToken: GlobalStruct.currentInstance.returnedText]
        WatchSessionManager.sharedManager.transferUserInfo(userInfo: applicationContext as [String: AnyObject])
        
        // Add button
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
        #if targetEnvironment(macCatalyst)
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(systemName: "square.on.square", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn1.addTarget(self, action: #selector(self.newWindow), for: .touchUpInside)
        btn1.accessibilityLabel = "New Window".localized
        let addButton = UIBarButtonItem(customView: btn1)
//        self.navigationItem.setRightBarButton(addButton, animated: true)
        #elseif !targetEnvironment(macCatalyst)
        if UIDevice.current.userInterfaceIdiom == .pad && self.isSplitOrSlideOver == false {
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
            let btn1 = UIButton(type: .custom)
            btn1.setImage(UIImage(systemName: "square.on.square", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
            btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            btn1.addTarget(self, action: #selector(self.newWindow), for: .touchUpInside)
            btn1.accessibilityLabel = "New Window".localized
            let addButton = UIBarButtonItem(customView: btn1)
//            self.navigationItem.setRightBarButton(addButton, animated: true)
        } else {
            let btn1 = UIButton(type: .custom)
            btn1.setImage(UIImage(systemName: "plus", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
            btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            btn1.addTarget(self, action: #selector(self.addTapped), for: .touchUpInside)
            btn1.accessibilityLabel = "Create".localized
            let addButton = UIBarButtonItem(customView: btn1)
            self.navigationItem.setRightBarButton(addButton, animated: true)
        }
        #endif
    }
    
    @objc func refreshTable1() {
        self.tableView.reloadData()
    }
    
    @objc func notifChangeTint() {
        self.tableView.reloadData()
        self.tableViewL.reloadData()
        self.tableViewF.reloadData()
        
        self.tableView.reloadInputViews()
        self.tableViewL.reloadInputViews()
        self.tableViewF.reloadInputViews()
    }
    
    @objc func newWindow() {
        
    }
    
    @objc func openTootDetail() {
        let vc = DetailViewController()
        vc.isPassedID = true
        vc.passedID = GlobalStruct.thePassedID
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func notifChangeBG() {
        GlobalStruct.baseDarkTint = (UserDefaults.standard.value(forKey: "sync-startDarkTint") == nil || UserDefaults.standard.value(forKey: "sync-startDarkTint") as? Int == 0) ? UIColor(named: "baseWhite")! : UIColor(named: "baseWhite2")!
        self.view.backgroundColor = GlobalStruct.baseDarkTint
        self.navigationController?.navigationBar.backgroundColor = GlobalStruct.baseDarkTint
        self.navigationController?.navigationBar.barTintColor = GlobalStruct.baseDarkTint
        self.tableView.reloadData()
        self.tableViewL.reloadData()
        self.tableViewF.reloadData()
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.keyHeight = CGFloat(keyboardHeight)

            let part1 = (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + 210 + self.keyHeight
            self.tableView.frame = CGRect(x: self.view.safeAreaInsets.left, y: (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + 210, width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: self.view.bounds.height - part1)
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            self.keyHeight = CGFloat(0)

            let part1 = (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + 210
            self.tableView.frame = CGRect(x: self.view.safeAreaInsets.left, y: (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + 210, width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: self.view.bounds.height - part1)
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var keyCommands: [UIKeyCommand]? {
        let newToot = UIKeyCommand(input: "n", modifierFlags: .command, action: #selector(self.compose), discoverabilityTitle: "New Toot".localized)
        let search = UIKeyCommand(input: "f", modifierFlags: .command, action: #selector(self.search), discoverabilityTitle: "Search".localized)
        let settings = UIKeyCommand(input: ";", modifierFlags: .command, action: #selector(self.settings), discoverabilityTitle: "Settings".localized)
        let leftA = UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: .command, action: #selector(self.leftA), discoverabilityTitle: "Scroll to Left".localized)
        let rightA = UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags: .command, action: #selector(self.rightA), discoverabilityTitle: "Scroll to Right".localized)
        return [
            newToot, search, settings
        ]
    }
    
    @objc func compose() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "composea"), object: nil)
    }
    
    @objc func search() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "searcha"), object: nil)
    }
    
    @objc func settings() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "settingsa"), object: nil)
    }
    
    @objc func leftA() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "leftAr"), object: nil)
    }
    
    @objc func rightA() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "rightAr"), object: nil)
    }
    
    @objc func goToIDNoti() {
        sleep(2)
        let request = Notifications.notification(id: GlobalStruct.curIDNoti)
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                DispatchQueue.main.async {
                    if let x = stat.status {
                        let vc = DetailViewController()
                        vc.pickedStatusesHome = [x]
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        let vc = FifthViewController()
                        vc.isYou = false
                        vc.isTapped = true
                        vc.userID = stat.account.id
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = GlobalStruct.baseDarkTint
        self.title = "Feed".localized
        //        self.removeTabbarItemsText()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.logged), name: NSNotification.Name(rawValue: "logged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePosted), name: NSNotification.Name(rawValue: "updatePosted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.scrollTop1), name: NSNotification.Name(rawValue: "scrollTop1"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTable1), name: NSNotification.Name(rawValue: "refreshTable1"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notifChangeTint), name: NSNotification.Name(rawValue: "notifChangeTint"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openTootDetail), name: NSNotification.Name(rawValue: "openTootDetail1"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notifChangeBG), name: NSNotification.Name(rawValue: "notifChangeBG"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.goToIDNoti), name: NSNotification.Name(rawValue: "gotoidnoti1"), object: nil)
        
        if UserDefaults.standard.object(forKey: "clientID") == nil {} else {
            GlobalStruct.clientID = UserDefaults.standard.object(forKey: "clientID") as! String
        }
        if UserDefaults.standard.object(forKey: "clientSecret") == nil {} else {
            GlobalStruct.clientSecret = UserDefaults.standard.object(forKey: "clientSecret") as! String
        }
        if UserDefaults.standard.object(forKey: "authCode") == nil {} else {
            GlobalStruct.authCode = UserDefaults.standard.object(forKey: "authCode") as! String
        }
        if UserDefaults.standard.object(forKey: "returnedText") == nil {} else {
            GlobalStruct.returnedText = UserDefaults.standard.object(forKey: "returnedText") as! String
        }
        
        if UserDefaults.standard.value(forKey: "sync-startTint") == nil {
            UserDefaults.standard.set(0, forKey: "sync-startTint")
            GlobalStruct.baseTint = GlobalStruct.arrayCols[0]
        } else {
            if let x = UserDefaults.standard.value(forKey: "sync-startTint") as? Int {
                GlobalStruct.baseTint = GlobalStruct.arrayCols[x]
            }
        }
        if UserDefaults.standard.value(forKey: "sync-haptics") == nil {
            UserDefaults.standard.set(0, forKey: "sync-haptics")
        }
        if UserDefaults.standard.value(forKey: "sync-sensitive") == nil {
            UserDefaults.standard.set(0, forKey: "sync-sensitive")
        }
        if UserDefaults.standard.value(forKey: "sync-chosenBrowser") == nil {
            UserDefaults.standard.set(0, forKey: "sync-chosenBrowser")
        }
        if UserDefaults.standard.value(forKey: "sync-chosenKeyboard") == nil {
            UserDefaults.standard.set(0, forKey: "sync-chosenKeyboard")
        }
        if UserDefaults.standard.value(forKey: "filterTimelines") == nil {
            UserDefaults.standard.set(0, forKey: "filterTimelines")
        }
        if UserDefaults.standard.value(forKey: "filterNotifications") == nil {
            UserDefaults.standard.set(0, forKey: "filterNotifications")
        }
        if UserDefaults.standard.value(forKey: "sync-chosenVisibility") == nil {
            UserDefaults.standard.set(0, forKey: "sync-chosenVisibility")
        }
        if UserDefaults.standard.value(forKey: "sync-scanMode") == nil {
            UserDefaults.standard.set(0, forKey: "sync-scanMode")
        }
        if UserDefaults.standard.value(forKey: "sync-startDarkTint") == nil {
            UserDefaults.standard.set(0, forKey: "sync-startDarkTint")
        }
        if UserDefaults.standard.value(forKey: "switchbanners") == nil {
            UserDefaults.standard.set(0, forKey: "switchbanners")
        }
        if UserDefaults.standard.value(forKey: "sync-lock") == nil {
            UserDefaults.standard.set(0, forKey: "sync-lock")
        }
        if UserDefaults.standard.value(forKey: "sync-lockTime") == nil {
            UserDefaults.standard.set(0, forKey: "sync-lockTime")
        }
        
        let icon00 = UIApplicationShortcutIcon(systemImageName: "plus")
        let item00 = UIApplicationShortcutItem(type: "com.shi.Mast.NewToot", localizedTitle: "New Toot".localized, localizedSubtitle: nil, icon: icon00, userInfo: nil)
        item00.accessibilityLabel = "New Toot".localized
        let icon0 = UIApplicationShortcutIcon(systemImageName: "bell")
        let item0 = UIApplicationShortcutItem(type: "com.shi.Mast.Notifications", localizedTitle: "View Notifications".localized, localizedSubtitle: nil, icon: icon0, userInfo: nil)
        item0.accessibilityLabel = "View Notifications".localized
        let icon1 = UIApplicationShortcutIcon(systemImageName: "paperplane")
        let item1 = UIApplicationShortcutItem(type: "com.shi.Mast.Messages", localizedTitle: "View Messages".localized, localizedSubtitle: nil, icon: icon1, userInfo: nil)
        item1.accessibilityLabel = "View Messages".localized
        let icon2 = UIApplicationShortcutIcon(systemImageName: "person.crop.circle")
        let item2 = UIApplicationShortcutItem(type: "com.shi.Mast.Profile", localizedTitle: "View Profile".localized, localizedSubtitle: nil, icon: icon2, userInfo: nil)
        item2.accessibilityLabel = "View Profile".localized
        UIApplication.shared.shortcutItems = [item00, item0, item1, item2]
        
        // Segmented control
        self.segment.selectedSegmentIndex = 0
        self.segment.addTarget(self, action: #selector(changeSegment(_:)), for: .valueChanged)
        self.view.addSubview(self.segment)
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
        btn2.setImage(UIImage(systemName: "line.horizontal.3.decrease", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        btn2.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn2.addTarget(self, action: #selector(self.sortTapped), for: .touchUpInside)
        btn2.accessibilityLabel = "Sort".localized
        let settingsButton = UIBarButtonItem(customView: btn2)
        self.navigationItem.setLeftBarButton(settingsButton, animated: true)
        
        // Log in
        if UserDefaults.standard.object(forKey: "accessToken") == nil {
            self.createLoginView()
        } else {
            GlobalStruct.currentInstance.accessToken = UserDefaults.standard.object(forKey: "accessToken") as! String
            GlobalStruct.client = Client(
                baseURL: "https://\(GlobalStruct.currentInstance.returnedText)",
                accessToken: GlobalStruct.currentInstance.accessToken
            )
            self.initialFetches()
        }
        
        // Table
        self.tableView.register(TootCell.self, forCellReuseIdentifier: "TootCell")
        self.tableView.register(TootImageCell.self, forCellReuseIdentifier: "TootImageCell")
        self.tableView.register(LoadMoreCell.self, forCellReuseIdentifier: "LoadMoreCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .singleLine
        self.tableView.separatorColor = UIColor(named: "baseBlack")?.withAlphaComponent(0.24)
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.layer.masksToBounds = true
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.showsVerticalScrollIndicator = true
        self.tableView.tableFooterView = UIView()
        self.view.addSubview(self.tableView)
        
        self.refreshControl.addTarget(self, action: #selector(refresh(_:)), for: UIControl.Event.valueChanged)
        self.tableView.addSubview(self.refreshControl)
        
        self.tableViewL.register(TootCell.self, forCellReuseIdentifier: "TootCellL")
        self.tableViewL.register(TootImageCell.self, forCellReuseIdentifier: "TootImageCellL")
        self.tableViewL.delegate = self
        self.tableViewL.dataSource = self
        self.tableViewL.separatorStyle = .singleLine
        self.tableViewL.separatorColor = UIColor(named: "baseBlack")?.withAlphaComponent(0.24)
        self.tableViewL.backgroundColor = UIColor.clear
        self.tableViewL.layer.masksToBounds = true
        self.tableViewL.estimatedRowHeight = UITableView.automaticDimension
        self.tableViewL.rowHeight = UITableView.automaticDimension
        self.tableViewL.showsVerticalScrollIndicator = true
        self.tableViewL.tableFooterView = UIView()
        self.tableViewL.alpha = 0
        self.view.addSubview(self.tableViewL)
        
        self.refreshControlL.addTarget(self, action: #selector(refreshL(_:)), for: UIControl.Event.valueChanged)
        self.tableViewL.addSubview(self.refreshControlL)
        
        self.tableViewF.register(TootCell.self, forCellReuseIdentifier: "TootCellF")
        self.tableViewF.register(TootImageCell.self, forCellReuseIdentifier: "TootImageCellF")
        self.tableViewF.delegate = self
        self.tableViewF.dataSource = self
        self.tableViewF.separatorStyle = .singleLine
        self.tableViewF.separatorColor = UIColor(named: "baseBlack")?.withAlphaComponent(0.24)
        self.tableViewF.backgroundColor = UIColor.clear
        self.tableViewF.layer.masksToBounds = true
        self.tableViewF.estimatedRowHeight = UITableView.automaticDimension
        self.tableViewF.rowHeight = UITableView.automaticDimension
        self.tableViewF.showsVerticalScrollIndicator = true
        self.tableViewF.tableFooterView = UIView()
        self.tableViewF.alpha = 0
        self.view.addSubview(self.tableViewF)
        
        self.refreshControlF.addTarget(self, action: #selector(refreshF(_:)), for: UIControl.Event.valueChanged)
        self.tableViewF.addSubview(self.refreshControlF)
        
        // Top buttons
        let tab0 = (self.navigationController?.navigationBar.bounds.height ?? 0) + (self.segment.bounds.height) + 10
        let startHeight = (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + tab0
        let symbolConfig2 = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
        
        self.top1.frame = CGRect(x: Int(self.view.bounds.width) - 48, y: Int(startHeight + 6), width: 38, height: 38)
        self.top1.setImage(UIImage(systemName: "chevron.up.circle.fill", withConfiguration: symbolConfig2)?.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal), for: .normal)
        self.top1.backgroundColor = GlobalStruct.baseDarkTint
        self.top1.layer.cornerRadius = 19
        self.top1.alpha = 0
        self.top1.addTarget(self, action: #selector(self.didTouchTop1), for: .touchUpInside)
        self.top1.accessibilityLabel = "Top".localized
        self.view.addSubview(self.top1)
        
        self.top2.frame = CGRect(x: Int(self.view.bounds.width) - 48, y: Int(startHeight + 6), width: 38, height: 38)
        self.top2.setImage(UIImage(systemName: "chevron.up.circle.fill", withConfiguration: symbolConfig2)?.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal), for: .normal)
        self.top2.backgroundColor = GlobalStruct.baseDarkTint
        self.top2.layer.cornerRadius = 19
        self.top2.alpha = 0
        self.top2.addTarget(self, action: #selector(self.didTouchTop2), for: .touchUpInside)
        self.top2.accessibilityLabel = "Top".localized
        self.view.addSubview(self.top2)
        
        self.top3.frame = CGRect(x: Int(self.view.bounds.width) - 48, y: Int(startHeight + 6), width: 38, height: 38)
        self.top3.setImage(UIImage(systemName: "chevron.up.circle.fill", withConfiguration: symbolConfig2)?.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal), for: .normal)
        self.top3.backgroundColor = GlobalStruct.baseDarkTint
        self.top3.layer.cornerRadius = 19
        self.top3.alpha = 0
        self.top3.addTarget(self, action: #selector(self.didTouchTop3), for: .touchUpInside)
        self.top3.accessibilityLabel = "Top".localized
        self.view.addSubview(self.top3)
        
        if GlobalStruct.iapPurchased {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
                DispatchQueue.main.async {
                    UserDefaults.standard.set(true, forKey: "pnmentions")
                    UserDefaults.standard.set(true, forKey: "pnlikes")
                    UserDefaults.standard.set(true, forKey: "pnboosts")
                    UserDefaults.standard.set(true, forKey: "pnfollows")
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    @objc func didTouchTop1() {
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut, animations: {
            self.top1.alpha = 0
            self.top1.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        }) { (completed: Bool) in
        }
    }
    
    @objc func didTouchTop2() {
        self.tableViewL.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut, animations: {
            self.top2.alpha = 0
            self.top2.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        }) { (completed: Bool) in
        }
    }
    
    @objc func didTouchTop3() {
        self.tableViewF.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut, animations: {
            self.top3.alpha = 0
            self.top3.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        }) { (completed: Bool) in
        }
    }
    
    func initialFetches() {
        if let userDefaults = UserDefaults(suiteName: "group.com.shi.Mast.wormhole") {
            userDefaults.set(GlobalStruct.currentInstance.accessToken, forKey: "key1")
            userDefaults.set(GlobalStruct.currentInstance.returnedText, forKey: "key2")
            userDefaults.synchronize()
        }
        let applicationContext = [GlobalStruct.currentInstance.accessToken: GlobalStruct.currentInstance.returnedText]
        WatchSessionManager.sharedManager.transferUserInfo(userInfo: applicationContext as [String: AnyObject])
        
        let request0 = Accounts.currentUser()
        GlobalStruct.client.run(request0) { (statuses) in
            if let stat = (statuses.value) {
                DispatchQueue.main.async {
                    GlobalStruct.currentUser = stat
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "initialTimelineLoads1"), object: nil)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "refProf"), object: nil)
                    
                    #if targetEnvironment(macCatalyst)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshTable"), object: nil)
                    #elseif !targetEnvironment(macCatalyst)
                    if UIDevice.current.userInterfaceIdiom == .pad && self.isSplitOrSlideOver == false {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshTable"), object: nil)
                    }
                    #endif

                    let request7 = Accounts.statuses(id: GlobalStruct.currentUser.id, mediaOnly: false, pinnedOnly: true, excludeReplies: false, excludeReblogs: false, range: .default)
                    GlobalStruct.client.run(request7) { (statuses) in
                        if let stat = statuses.value {
                            GlobalStruct.allPinned = stat
                        }
                    }
                }
            }
        }
        
//        let request = Timelines.home()
//        GlobalStruct.client.run(request) { (statuses) in
//            if let stat = (statuses.value) {
//                DispatchQueue.main.async {
//                    self.statusesHome = stat
//                    self.tableView.reloadData()
//                    self.statusesHomeTemp = stat
//                }
//            }
//        }
        
        self.markersGet()
        
        let request2 = Timelines.public(local: true, range: .default)
        GlobalStruct.client.run(request2) { (statuses) in
            if let stat = (statuses.value) {
                DispatchQueue.main.async {
                    self.statusesLocal = stat
                    self.tableViewL.reloadData()
                    self.statusesLocalTemp = stat
                }
            }
        }
        let request3 = Timelines.public(local: false, range: .default)
        GlobalStruct.client.run(request3) { (statuses) in
            if let stat = (statuses.value) {
                DispatchQueue.main.async {
                    self.statusesFed = stat
                    self.tableViewF.reloadData()
                    self.statusesFedTemp = stat
                }
            }
        }
        
//        if UserDefaults.standard.value(forKey: "filterNotifications") as? Int == 0 {
//            self.notTypes = []
//        } else if UserDefaults.standard.value(forKey: "filterNotifications") as? Int == 1 {
//            self.notTypes = GlobalStruct.notTypes.filter {$0 != NotificationType.mention}
//        } else if UserDefaults.standard.value(forKey: "filterNotifications") as? Int == 2 {
//            self.notTypes = GlobalStruct.notTypes.filter {$0 != NotificationType.favourite}
//        } else if UserDefaults.standard.value(forKey: "filterNotifications") as? Int == 3 {
//            self.notTypes = GlobalStruct.notTypes.filter {$0 != NotificationType.reblog}
//        } else if UserDefaults.standard.value(forKey: "filterNotifications") as? Int == 4 {
//            self.notTypes = GlobalStruct.notTypes.filter {$0 != NotificationType.direct}
//        } else if UserDefaults.standard.value(forKey: "filterNotifications") as? Int == 5 {
//            self.notTypes = GlobalStruct.notTypes.filter {$0 != NotificationType.follow}
//        } else if UserDefaults.standard.value(forKey: "filterNotifications") as? Int == 6 {
//            self.notTypes = GlobalStruct.notTypes.filter {$0 != NotificationType.poll}
//        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "initialTimelineLoads"), object: nil)
        
//        let request4 = Notifications.all(range: .default, typesToExclude: self.notTypes)
//        GlobalStruct.client.run(request4) { (statuses) in
//            if let stat = (statuses.value) {
//                DispatchQueue.main.async {
//                    GlobalStruct.notifications = stat
//                    #if targetEnvironment(macCatalyst)
//                    NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshTable"), object: nil)
//                    #elseif !targetEnvironment(macCatalyst)
//                    if UIDevice.current.userInterfaceIdiom == .pad && self.isSplitOrSlideOver == false {
//                        NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshTable"), object: nil)
//                    }
//                    #endif
//                }
//            }
//        }
//        let request5 = Timelines.conversations(range: .max(id: GlobalStruct.notificationsDirect.last?.id ?? "", limit: 5000))
//        GlobalStruct.client.run(request5) { (statuses) in
//            if let stat = (statuses.value) {
//                DispatchQueue.main.async {
//                    GlobalStruct.notificationsDirect = GlobalStruct.notificationsDirect + stat
//                    #if targetEnvironment(macCatalyst)
//                    NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshTable"), object: nil)
//                    #elseif !targetEnvironment(macCatalyst)
//                    if UIDevice.current.userInterfaceIdiom == .pad && self.isSplitOrSlideOver == false {
//                        NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshTable"), object: nil)
//                    }
//                    #endif
//                }
//            }
//        }
        
        let request6 = Instances.current()
        GlobalStruct.client.run(request6) { (statuses) in
            if let stat = (statuses.value) {
                GlobalStruct.maxChars = stat.max_toot_chars ?? 500
                GlobalStruct.currentInstanceDetails = [stat]
            }
        }
        
        let request7 = Instances.customEmojis()
        GlobalStruct.client.run(request7) { (statuses) in
            if let stat = (statuses.value) {
                GlobalStruct.allEmoticons = stat.sorted { $0.shortcode < $1.shortcode }
            }
        }
        
        if let x = UserDefaults.standard.value(forKey: "sync-customInstances") as? [String] {
            GlobalStruct.allCustomInstances = x
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let cell = self.tableView.indexPathsForVisibleRows?.first {
            self.markersPost(self.statusesHome[cell.row].id)
        }
    }
    
    func markersPost(_ homeID: String) {
        let urlStr = "\(GlobalStruct.client.baseURL)/api/v1/markers"
        let url: URL = URL(string: urlStr)!
        var request01 = URLRequest(url: url)
        request01.httpMethod = "POST"
        request01.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request01.addValue("application/json", forHTTPHeaderField: "Accept")
        request01.addValue("Bearer \(GlobalStruct.client.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let paraHome: [String: Any?] = [
            "last_read_id": homeID
        ]
        let params: [String: Any?] = [
            "home": paraHome,
        ]
        do {
            request01.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        let task = session.dataTask(with: request01) { data, response, err in
            do {
                let model = try JSONDecoder().decode(Marker.self, from: data ?? Data())
                print("marker1 - \(model.home?.lastReadID ?? "")")
            } catch {
                print("error")
            }
        }
        task.resume()
    }
    
    func markersGet() {
        let urlStr = "\(GlobalStruct.client.baseURL)/api/v1/markers/?timeline=home"
        let url: URL = URL(string: urlStr)!
        var request01 = URLRequest(url: url)
        request01.httpMethod = "GET"
        request01.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request01.addValue("application/json", forHTTPHeaderField: "Accept")
        request01.addValue("Bearer \(GlobalStruct.client.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let task = session.dataTask(with: request01) { data, response, err in
            do {
                let model = try JSONDecoder().decode(Marker.self, from: data ?? Data())
                let request = Timelines.home(range: .max(id: model.home?.lastReadID ?? "", limit: 5000))
                GlobalStruct.client.run(request) { (statuses) in
                    if let stat = (statuses.value) {
                        DispatchQueue.main.async {
                            if stat.isEmpty {
                                let request = Timelines.home()
                                GlobalStruct.client.run(request) { (statuses) in
                                    if let stat = (statuses.value) {
                                        DispatchQueue.main.async {
                                            self.statusesHome = stat
                                            self.tableView.reloadData()
                                            self.statusesHomeTemp = stat
                                        }
                                    }
                                }
                            } else {
                                self.statusesHome = stat
                                self.tableView.reloadData()
                                self.statusesHomeTemp = stat
                            }
                        }
                    }
                }
            } catch {
                print("error")
            }
        }
        task.resume()
    }
    
    func fetchGap() {
        let request = Timelines.home(range: .max(id: self.gapLastID, limit: nil))
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                if stat.isEmpty {
                    DispatchQueue.main.async {
                        self.refreshControl.endRefreshing()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.refreshControl.endRefreshing()
                        self.top1.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                        UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut, animations: {
                            self.top1.alpha = 1
                            self.top1.transform = CGAffineTransform(scaleX: 1, y: 1)
                        }) { (completed: Bool) in
                        }
                        
                        let y = self.statusesHome.split(separator: self.gapLastStat ?? self.statusesHome.last!)
                        
                        if self.statusesHome.contains(stat.last!) || stat.count < 19 {
                            
                        } else {
                            self.gapLastID = stat.last?.id ?? ""
                            let z = stat.last!
                            z.id = "loadmorehere"
                            self.gapLastStat = z
                        }
                        
                        let indexPaths = ((y.first?.count ?? 0)..<(stat.count + (y.first?.count ?? 0) - 1)).map {
                            IndexPath(row: $0, section: 0)
                        }
                        self.statusesHome = y.first! + stat + y.last!
                        self.tableView.beginUpdates()
                        UIView.setAnimationsEnabled(false)
                        var heights: CGFloat = 0
                        let _ = indexPaths.map {
                            if let cell = self.tableView.cellForRow(at: $0) as? TootCell {
                                heights += cell.bounds.height
                            }
                            if let cell = self.tableView.cellForRow(at: $0) as? TootImageCell {
                                heights += cell.bounds.height
                            }
                            if let cell = self.tableView.cellForRow(at: $0) as? LoadMoreCell {
                                heights += cell.bounds.height
                            }
                        }
                        self.tableView.insertRows(at: indexPaths, with: UITableView.RowAnimation.none)
                        self.tableView.setContentOffset(CGPoint(x: 0, y: heights), animated: false)
                        self.tableView.endUpdates()
                        UIView.setAnimationsEnabled(true)

                        if UserDefaults.standard.value(forKey: "filterTimelines") as? Int == 1 {
                            self.statusesHome = self.statusesHome.filter({ (stat) -> Bool in
                                if stat.reblog == nil {
                                    return false
                                } else {
                                    return true
                                }
                            })
                            self.tableView.reloadData()
                        }
                        if UserDefaults.standard.value(forKey: "filterTimelines") as? Int == 2 {
                            self.statusesHome = self.statusesHome.filter({ (stat) -> Bool in
                                if stat.mediaAttachments.isEmpty {
                                    return false
                                } else {
                                    return true
                                }
                            })
                            self.tableView.reloadData()
                        }
                        
                    }
                }
            }
        }
    }
    
    @objc func refresh(_ sender: AnyObject) {
        let request = Timelines.home(range: .since(id: self.statusesHome.first?.id ?? "", limit: nil))
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                if stat.isEmpty {
                    DispatchQueue.main.async {
                        self.refreshControl.endRefreshing()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.refreshControl.endRefreshing()
                        self.top1.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                        UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut, animations: {
                            self.top1.alpha = 1
                            self.top1.transform = CGAffineTransform(scaleX: 1, y: 1)
                        }) { (completed: Bool) in
                        }
                        
                        if self.statusesHome.contains(stat.last!) || stat.count < 19 {
                            
                        } else {
                            self.gapLastID = stat.last?.id ?? ""
                            let z = stat.last!
                            z.id = "loadmorehere"
                            self.gapLastStat = z
                        }
                        
                        let indexPaths = (0..<stat.count).map {
                            IndexPath(row: $0, section: 0)
                        }
                        self.statusesHome = stat + self.statusesHome
                        self.tableView.beginUpdates()
                        UIView.setAnimationsEnabled(false)
                        var heights: CGFloat = 0
                        let _ = indexPaths.map {
                            if let cell = self.tableView.cellForRow(at: $0) as? TootCell {
                                heights += cell.bounds.height
                            }
                            if let cell = self.tableView.cellForRow(at: $0) as? TootImageCell {
                                heights += cell.bounds.height
                            }
                            if let cell = self.tableView.cellForRow(at: $0) as? LoadMoreCell {
                                heights += cell.bounds.height
                            }
                        }
                        self.tableView.insertRows(at: indexPaths, with: UITableView.RowAnimation.none)
                        self.tableView.setContentOffset(CGPoint(x: 0, y: heights), animated: false)
                        self.tableView.endUpdates()
                        UIView.setAnimationsEnabled(true)

                        if UserDefaults.standard.value(forKey: "filterTimelines") as? Int == 1 {
                            self.statusesHome = self.statusesHome.filter({ (stat) -> Bool in
                                if stat.reblog == nil {
                                    return false
                                } else {
                                    return true
                                }
                            })
                            self.tableView.reloadData()
                        }
                        if UserDefaults.standard.value(forKey: "filterTimelines") as? Int == 2 {
                            self.statusesHome = self.statusesHome.filter({ (stat) -> Bool in
                                if stat.mediaAttachments.isEmpty {
                                    return false
                                } else {
                                    return true
                                }
                            })
                            self.tableView.reloadData()
                        }
                        
                    }
                }
            }
        }
    }
    
    @objc func refreshL(_ sender: AnyObject) {
        let request = Timelines.public(local: true, range: .since(id: self.statusesLocal.first?.id ?? "", limit: nil))
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                if stat.isEmpty {
                    DispatchQueue.main.async {
                        self.refreshControlL.endRefreshing()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.refreshControlL.endRefreshing()
                        self.top2.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                        UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut, animations: {
                            self.top2.alpha = 1
                            self.top2.transform = CGAffineTransform(scaleX: 1, y: 1)
                        }) { (completed: Bool) in
                        }
                        let indexPaths = (0..<stat.count).map {
                            IndexPath(row: $0, section: 0)
                        }
                        self.statusesLocal = stat + self.statusesLocal
                        self.tableViewL.beginUpdates()
                        UIView.setAnimationsEnabled(false)
                        var heights: CGFloat = 0
                        let _ = indexPaths.map {
                            if let cell = self.tableViewL.cellForRow(at: $0) as? TootCell {
                                heights += cell.bounds.height
                            }
                            if let cell = self.tableView.cellForRow(at: $0) as? TootImageCell {
                                heights += cell.bounds.height
                            }
                        }
                        self.tableViewL.insertRows(at: indexPaths, with: UITableView.RowAnimation.none)
                        self.tableViewL.setContentOffset(CGPoint(x: 0, y: heights), animated: false)
                        self.tableViewL.endUpdates()
                        UIView.setAnimationsEnabled(true)

                        if UserDefaults.standard.value(forKey: "filterTimelines") as? Int == 1 {
                            self.statusesLocal = self.statusesLocal.filter({ (stat) -> Bool in
                                if stat.reblog == nil {
                                    return false
                                } else {
                                    return true
                                }
                            })
                            self.tableView.reloadData()
                        }
                        if UserDefaults.standard.value(forKey: "filterTimelines") as? Int == 2 {
                            self.statusesLocal = self.statusesLocal.filter({ (stat) -> Bool in
                                if stat.mediaAttachments.isEmpty {
                                    return false
                                } else {
                                    return true
                                }
                            })
                            self.tableView.reloadData()
                        }
                        
                    }
                }
            }
        }
    }
    
    @objc func refreshF(_ sender: AnyObject) {
        let request = Timelines.public(local: false, range: .since(id: self.statusesFed.first?.id ?? "", limit: nil))
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                if stat.isEmpty {
                    DispatchQueue.main.async {
                        self.refreshControlF.endRefreshing()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.refreshControlF.endRefreshing()
                        self.top3.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                        UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut, animations: {
                            self.top3.alpha = 1
                            self.top3.transform = CGAffineTransform(scaleX: 1, y: 1)
                        }) { (completed: Bool) in
                        }
                        let indexPaths = (0..<stat.count).map {
                            IndexPath(row: $0, section: 0)
                        }
                        self.statusesFed = stat + self.statusesFed
                        self.tableViewF.beginUpdates()
                        UIView.setAnimationsEnabled(false)
                        var heights: CGFloat = 0
                        let _ = indexPaths.map {
                            if let cell = self.tableViewF.cellForRow(at: $0) as? TootCell {
                                heights += cell.bounds.height
                            }
                            if let cell = self.tableView.cellForRow(at: $0) as? TootImageCell {
                                heights += cell.bounds.height
                            }
                        }
                        self.tableViewF.insertRows(at: indexPaths, with: UITableView.RowAnimation.none)
                        self.tableViewF.setContentOffset(CGPoint(x: 0, y: heights), animated: false)
                        self.tableViewF.endUpdates()
                        UIView.setAnimationsEnabled(true)

                        if UserDefaults.standard.value(forKey: "filterTimelines") as? Int == 1 {
                            self.statusesFed = self.statusesFed.filter({ (stat) -> Bool in
                                if stat.reblog == nil {
                                    return false
                                } else {
                                    return true
                                }
                            })
                            self.tableView.reloadData()
                        }
                        if UserDefaults.standard.value(forKey: "filterTimelines") as? Int == 2 {
                            self.statusesFed = self.statusesFed.filter({ (stat) -> Bool in
                                if stat.mediaAttachments.isEmpty {
                                    return false
                                } else {
                                    return true
                                }
                            })
                            self.tableView.reloadData()
                        }
                        
                    }
                }
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut, animations: {
            self.top1.alpha = 0
            self.top1.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            self.top2.alpha = 0
            self.top2.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            self.top3.alpha = 0
            self.top3.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        }) { (completed: Bool) in
        }
    }
    
    @objc func changeSegment(_ segment: UISegmentedControl) {
        if segment.selectedSegmentIndex == 0 {
            self.tableView.alpha = 1
            self.tableViewL.alpha = 0
            self.tableViewF.alpha = 0
        }
        if segment.selectedSegmentIndex == 1 {
            self.tableView.alpha = 0
            self.tableViewL.alpha = 1
            self.tableViewF.alpha = 0
        }
        if segment.selectedSegmentIndex == 2 {
            self.tableView.alpha = 0
            self.tableViewL.alpha = 0
            self.tableViewF.alpha = 1
        }
        UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut, animations: {
            self.top1.alpha = 0
            self.top1.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            self.top2.alpha = 0
            self.top2.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            self.top3.alpha = 0
            self.top3.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        }) { (completed: Bool) in
        }
    }
    
    @objc func sortTapped() {
        if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
            let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
            impactFeedbackgenerator.prepare()
            impactFeedbackgenerator.impactOccurred()
        }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let op1 = UIAlertAction(title: "All".localized, style: .default , handler:{ (UIAlertAction) in
            UserDefaults.standard.set(0, forKey: "filterTimelines")
            DispatchQueue.main.async {
                self.statusesHome = self.statusesHomeTemp
                self.tableView.reloadData()
                self.statusesLocal = self.statusesLocalTemp
                self.tableViewL.reloadData()
                self.statusesFed = self.statusesFedTemp
                self.tableViewF.reloadData()
            }
        })
        if UserDefaults.standard.value(forKey: "filterTimelines") as? Int == 0 {
            op1.setValue(UIImage(systemName: "checkmark.circle.fill")!, forKey: "image")
        } else {
            op1.setValue(UIImage(systemName: "circle")!, forKey: "image")
        }
        op1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op1)
        let op2 = UIAlertAction(title: "Boosted".localized, style: .default , handler:{ (UIAlertAction) in
            UserDefaults.standard.set(1, forKey: "filterTimelines")
            DispatchQueue.main.async {
                self.statusesHome = self.statusesHomeTemp
                self.statusesHome = self.statusesHome.filter({ (stat) -> Bool in
                    if stat.reblog == nil {
                        return false
                    } else {
                        return true
                    }
                })
                self.tableView.reloadData()
                self.statusesLocal = self.statusesLocalTemp
                self.statusesLocal = self.statusesLocal.filter({ (stat) -> Bool in
                    if stat.reblog == nil {
                        return false
                    } else {
                        return true
                    }
                })
                self.tableViewL.reloadData()
                self.statusesFed = self.statusesFedTemp
                self.statusesFed = self.statusesFed.filter({ (stat) -> Bool in
                    if stat.reblog == nil {
                        return false
                    } else {
                        return true
                    }
                })
                self.tableViewF.reloadData()
            }
        })
        if UserDefaults.standard.value(forKey: "filterTimelines") as? Int == 1 {
            op2.setValue(UIImage(systemName: "checkmark.circle.fill")!, forKey: "image")
        } else {
            op2.setValue(UIImage(systemName: "circle")!, forKey: "image")
        }
        op2.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op2)
        let op3 = UIAlertAction(title: "Contains Media".localized, style: .default , handler:{ (UIAlertAction) in
            UserDefaults.standard.set(2, forKey: "filterTimelines")
            DispatchQueue.main.async {
                self.statusesHome = self.statusesHomeTemp
                self.statusesHome = self.statusesHome.filter({ (stat) -> Bool in
                    if stat.mediaAttachments.isEmpty {
                        return false
                    } else {
                        return true
                    }
                })
                self.tableView.reloadData()
                self.statusesLocal = self.statusesLocalTemp
                self.statusesLocal = self.statusesLocal.filter({ (stat) -> Bool in
                    if stat.mediaAttachments.isEmpty {
                        return false
                    } else {
                        return true
                    }
                })
                self.tableViewL.reloadData()
                self.statusesFed = self.statusesFedTemp
                self.statusesFed = self.statusesFed.filter({ (stat) -> Bool in
                    if stat.mediaAttachments.isEmpty {
                        return false
                    } else {
                        return true
                    }
                })
                self.tableViewF.reloadData()
            }
        })
        if UserDefaults.standard.value(forKey: "filterTimelines") as? Int == 2 {
            op3.setValue(UIImage(systemName: "checkmark.circle.fill")!, forKey: "image")
        } else {
            op3.setValue(UIImage(systemName: "circle")!, forKey: "image")
        }
        op3.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op3)
        alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
            
        }))
        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = self.btn2
            presenter.sourceRect = self.btn2.bounds
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableViewIntro {
            return self.altInstances.count
        } else if tableView == self.tableView {
            return self.statusesHome.count
        } else if tableView == self.tableViewL {
            return self.statusesLocal.count
        } else {
            return self.statusesFed.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableViewIntro {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell1", for: indexPath)
            cell.textLabel?.text = self.altInstances[indexPath.row]
            cell.textLabel?.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.85)
            cell.backgroundColor = UIColor(named: "baseWhite")!
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor(named: "baseWhite")!
            cell.selectedBackgroundView = bgColorView
            return cell
        } else if tableView == self.tableView {
            if self.statusesHome[indexPath.row].id == "loadmorehere" {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "LoadMoreCell", for: indexPath) as! LoadMoreCell
                cell.backgroundColor = UIColor(named: "lighterBaseWhite")!
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                return cell
                
            } else if self.statusesHome[indexPath.row].reblog?.mediaAttachments.isEmpty ?? self.statusesHome[indexPath.row].mediaAttachments.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TootCell", for: indexPath) as! TootCell
                if self.statusesHome.isEmpty {} else {
                    cell.configure(self.statusesHome[indexPath.row])
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile(_:)))
                    cell.profile.tag = indexPath.row
                    cell.profile.addGestureRecognizer(tap)
                    let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile2(_:)))
                    cell.profile2.tag = indexPath.row
                    cell.profile2.addGestureRecognizer(tap2)
                    if indexPath.row == self.statusesHome.count - 10 {
                        self.fetchMoreHome()
                    }
                }
                
                cell.content.handleMentionTap { (string) in
                if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
                    let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
                    impactFeedbackgenerator.prepare()
                    impactFeedbackgenerator.impactOccurred()
                }
                    let vc = FifthViewController()
                    vc.isYou = false
                    vc.isTapped = true
                    vc.userID = string
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                cell.content.handleHashtagTap { (string) in
                if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
                    let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
                    impactFeedbackgenerator.prepare()
                    impactFeedbackgenerator.impactOccurred()
                }
                    let vc = HashtagViewController()
                    vc.theHashtag = string
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                cell.content.handleURLTap { (string) in
                if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
                    let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
                    impactFeedbackgenerator.prepare()
                    impactFeedbackgenerator.impactOccurred()
                }
                    GlobalStruct.tappedURL = string
                    ViewController().openLink()
                }
                
                cell.backgroundColor = GlobalStruct.baseDarkTint
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TootImageCell", for: indexPath) as! TootImageCell
                if self.statusesHome.isEmpty {} else {
                    cell.configure(self.statusesHome[indexPath.row])
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile(_:)))
                    cell.profile.tag = indexPath.row
                    cell.profile.addGestureRecognizer(tap)
                    let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile2(_:)))
                    cell.profile2.tag = indexPath.row
                    cell.profile2.addGestureRecognizer(tap2)
                    if indexPath.row == self.statusesHome.count - 10 {
                        self.fetchMoreHome()
                    }
                }
                
                cell.content.handleMentionTap { (string) in
                if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
                    let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
                    impactFeedbackgenerator.prepare()
                    impactFeedbackgenerator.impactOccurred()
                }
                    let vc = FifthViewController()
                    vc.isYou = false
                    vc.isTapped = true
                    vc.userID = string
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                cell.content.handleHashtagTap { (string) in
                if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
                    let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
                    impactFeedbackgenerator.prepare()
                    impactFeedbackgenerator.impactOccurred()
                }
                    let vc = HashtagViewController()
                    vc.theHashtag = string
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                cell.content.handleURLTap { (string) in
                if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
                    let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
                    impactFeedbackgenerator.prepare()
                    impactFeedbackgenerator.impactOccurred()
                }
                    GlobalStruct.tappedURL = string
                    ViewController().openLink()
                }
                
                cell.backgroundColor = GlobalStruct.baseDarkTint
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                return cell
            }
        } else if tableView == self.tableViewL {
//            if (self.statusesLocal[indexPath.row].reblog?.mediaAttachments.isEmpty ?? self.statusesLocal[indexPath.row].mediaAttachments.isEmpty) || (self.statusesLocal[indexPath.row].reblog?.mediaAttachments.first?.type ?? self.statusesLocal[indexPath.row].mediaAttachments.first?.type == .audio)  {

            if (self.statusesLocal[indexPath.row].reblog?.mediaAttachments.isEmpty ?? self.statusesLocal[indexPath.row].mediaAttachments.isEmpty)  {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TootCellL", for: indexPath) as! TootCell
                if self.statusesLocal.isEmpty {} else {
                    cell.configure(self.statusesLocal[indexPath.row])
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile(_:)))
                    cell.profile.tag = indexPath.row
                    cell.profile.addGestureRecognizer(tap)
                    let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile2(_:)))
                    cell.profile2.tag = indexPath.row
                    cell.profile2.addGestureRecognizer(tap2)
                    if indexPath.row == self.statusesLocal.count - 10 {
                        self.fetchMoreLocal()
                    }
                }
                
                cell.content.handleMentionTap { (string) in
                if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
                    let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
                    impactFeedbackgenerator.prepare()
                    impactFeedbackgenerator.impactOccurred()
                }
                    let vc = FifthViewController()
                    vc.isYou = false
                    vc.isTapped = true
                    vc.userID = string
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                cell.content.handleHashtagTap { (string) in
                if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
                    let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
                    impactFeedbackgenerator.prepare()
                    impactFeedbackgenerator.impactOccurred()
                }
                    let vc = HashtagViewController()
                    vc.theHashtag = string
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                cell.content.handleURLTap { (string) in
                if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
                    let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
                    impactFeedbackgenerator.prepare()
                    impactFeedbackgenerator.impactOccurred()
                }
                    GlobalStruct.tappedURL = string
                    ViewController().openLink()
                }
                
                cell.backgroundColor = GlobalStruct.baseDarkTint
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TootImageCellL", for: indexPath) as! TootImageCell
                if self.statusesLocal.isEmpty {} else {
                    cell.configure(self.statusesLocal[indexPath.row])
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile(_:)))
                    cell.profile.tag = indexPath.row
                    cell.profile.addGestureRecognizer(tap)
                    let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile2(_:)))
                    cell.profile2.tag = indexPath.row
                    cell.profile2.addGestureRecognizer(tap2)
                    if indexPath.row == self.statusesLocal.count - 10 {
                        self.fetchMoreLocal()
                    }
                }
                
                cell.content.handleMentionTap { (string) in
                if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
                    let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
                    impactFeedbackgenerator.prepare()
                    impactFeedbackgenerator.impactOccurred()
                }
                    let vc = FifthViewController()
                    vc.isYou = false
                    vc.isTapped = true
                    vc.userID = string
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                cell.content.handleHashtagTap { (string) in
                if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
                    let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
                    impactFeedbackgenerator.prepare()
                    impactFeedbackgenerator.impactOccurred()
                }
                    let vc = HashtagViewController()
                    vc.theHashtag = string
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                cell.content.handleURLTap { (string) in
                if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
                    let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
                    impactFeedbackgenerator.prepare()
                    impactFeedbackgenerator.impactOccurred()
                }
                    GlobalStruct.tappedURL = string
                    ViewController().openLink()
                }
                
                cell.backgroundColor = GlobalStruct.baseDarkTint
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                return cell
            }
        } else {
            if self.statusesFed[indexPath.row].reblog?.mediaAttachments.isEmpty ?? self.statusesFed[indexPath.row].mediaAttachments.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TootCellF", for: indexPath) as! TootCell
                if self.statusesFed.isEmpty {} else {
                    cell.configure(self.statusesFed[indexPath.row])
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile(_:)))
                    cell.profile.tag = indexPath.row
                    cell.profile.addGestureRecognizer(tap)
                    let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile2(_:)))
                    cell.profile2.tag = indexPath.row
                    cell.profile2.addGestureRecognizer(tap2)
                    if indexPath.row == self.statusesFed.count - 10 {
                        self.fetchMoreFed()
                    }
                }
                
                cell.content.handleMentionTap { (string) in
                if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
                    let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
                    impactFeedbackgenerator.prepare()
                    impactFeedbackgenerator.impactOccurred()
                }
                    let vc = FifthViewController()
                    vc.isYou = false
                    vc.isTapped = true
                    vc.userID = string
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                cell.content.handleHashtagTap { (string) in
                if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
                    let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
                    impactFeedbackgenerator.prepare()
                    impactFeedbackgenerator.impactOccurred()
                }
                    let vc = HashtagViewController()
                    vc.theHashtag = string
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                cell.content.handleURLTap { (string) in
                if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
                    let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
                    impactFeedbackgenerator.prepare()
                    impactFeedbackgenerator.impactOccurred()
                }
                    GlobalStruct.tappedURL = string
                    ViewController().openLink()
                }
                
                cell.backgroundColor = GlobalStruct.baseDarkTint
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TootImageCellF", for: indexPath) as! TootImageCell
                if self.statusesFed.isEmpty {} else {
                    cell.configure(self.statusesFed[indexPath.row])
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile(_:)))
                    cell.profile.tag = indexPath.row
                    cell.profile.addGestureRecognizer(tap)
                    let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile2(_:)))
                    cell.profile2.tag = indexPath.row
                    cell.profile2.addGestureRecognizer(tap2)
                    if indexPath.row == self.statusesFed.count - 10 {
                        self.fetchMoreFed()
                    }
                }
                
                cell.content.handleMentionTap { (string) in
                if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
                    let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
                    impactFeedbackgenerator.prepare()
                    impactFeedbackgenerator.impactOccurred()
                }
                    let vc = FifthViewController()
                    vc.isYou = false
                    vc.isTapped = true
                    vc.userID = string
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                cell.content.handleHashtagTap { (string) in
                if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
                    let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
                    impactFeedbackgenerator.prepare()
                    impactFeedbackgenerator.impactOccurred()
                }
                    let vc = HashtagViewController()
                    vc.theHashtag = string
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                cell.content.handleURLTap { (string) in
                if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
                    let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
                    impactFeedbackgenerator.prepare()
                    impactFeedbackgenerator.impactOccurred()
                }
                    GlobalStruct.tappedURL = string
                    ViewController().openLink()
                }
                
                cell.backgroundColor = GlobalStruct.baseDarkTint
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                return cell
            }
        }
    }
    
    @objc func viewProfile(_ gesture: UIGestureRecognizer) {
        let vc = FifthViewController()
        if self.tableView.alpha == 1 {
            if GlobalStruct.currentUser.id == (self.statusesHome[gesture.view!.tag].reblog?.account.id ?? self.statusesHome[gesture.view!.tag].account.id) {
                vc.isYou = true
            } else {
                vc.isYou = false
            }
            vc.pickedCurrentUser = self.statusesHome[gesture.view!.tag].reblog?.account ?? self.statusesHome[gesture.view!.tag].account
            self.navigationController?.pushViewController(vc, animated: true)
        } else if self.tableViewL.alpha == 1 {
            if GlobalStruct.currentUser.id == (self.statusesLocal[gesture.view!.tag].reblog?.account.id ?? self.statusesLocal[gesture.view!.tag].account.id) {
                vc.isYou = true
            } else {
                vc.isYou = false
            }
            vc.pickedCurrentUser = self.statusesLocal[gesture.view!.tag].reblog?.account ?? self.statusesLocal[gesture.view!.tag].account
            self.navigationController?.pushViewController(vc, animated: true)
        } else if self.tableViewF.alpha == 1 {
            if GlobalStruct.currentUser.id == (self.statusesFed[gesture.view!.tag].reblog?.account.id ?? self.statusesFed[gesture.view!.tag].account.id) {
                vc.isYou = true
            } else {
                vc.isYou = false
            }
            vc.pickedCurrentUser = self.statusesFed[gesture.view!.tag].reblog?.account ?? self.statusesFed[gesture.view!.tag].account
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func viewProfile2(_ gesture: UIGestureRecognizer) {
        let vc = FifthViewController()
        if self.tableView.alpha == 1 {
            if GlobalStruct.currentUser.id == (self.statusesHome[gesture.view!.tag].account.id) {
                vc.isYou = true
            } else {
                vc.isYou = false
            }
            vc.pickedCurrentUser = self.statusesHome[gesture.view!.tag].account
            self.navigationController?.pushViewController(vc, animated: true)
        } else if self.tableViewL.alpha == 1 {
            if GlobalStruct.currentUser.id == (self.statusesHome[gesture.view!.tag].account.id) {
                vc.isYou = true
            } else {
                vc.isYou = false
            }
            vc.pickedCurrentUser = self.statusesLocal[gesture.view!.tag].account
            self.navigationController?.pushViewController(vc, animated: true)
        } else if self.tableViewF.alpha == 1 {
            if GlobalStruct.currentUser.id == (self.statusesHome[gesture.view!.tag].account.id) {
                vc.isYou = true
            } else {
                vc.isYou = false
            }
            vc.pickedCurrentUser = self.statusesFed[gesture.view!.tag].account
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func fetchMoreHome() {
        let request = Timelines.home(range: .max(id: self.statusesHome.last?.id ?? "", limit: nil))
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                if stat.isEmpty {} else {
                    DispatchQueue.main.async {
                        let indexPaths = ((self.statusesHome.count)..<(self.statusesHome.count + stat.count)).map {
                            IndexPath(row: $0, section: 0)
                        }
                        self.statusesHome.append(contentsOf: stat)
                        self.tableView.beginUpdates()
                        self.tableView.insertRows(at: indexPaths, with: UITableView.RowAnimation.none)
                        self.tableView.endUpdates()

                        if UserDefaults.standard.value(forKey: "filterTimelines") as? Int == 1 {
                            self.statusesHome = self.statusesHome.filter({ (stat) -> Bool in
                                if stat.reblog == nil {
                                    return false
                                } else {
                                    return true
                                }
                            })
                            self.tableView.reloadData()
                        }
                        if UserDefaults.standard.value(forKey: "filterTimelines") as? Int == 2 {
                            self.statusesHome = self.statusesHome.filter({ (stat) -> Bool in
                                if stat.mediaAttachments.isEmpty {
                                    return false
                                } else {
                                    return true
                                }
                            })
                            self.tableView.reloadData()
                        }
                        
                    }
                }
            }
        }
    }
    
    func fetchMoreLocal() {
        let request = Timelines.public(local: true, range: .max(id: self.statusesLocal.last?.id ?? "", limit: nil))
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                if stat.isEmpty {} else {
                    DispatchQueue.main.async {
                        let indexPaths = ((self.statusesLocal.count)..<(self.statusesLocal.count + stat.count)).map {
                            IndexPath(row: $0, section: 0)
                        }
                        self.statusesLocal.append(contentsOf: stat)
                        self.tableViewL.beginUpdates()
                        self.tableViewL.insertRows(at: indexPaths, with: UITableView.RowAnimation.none)
                        self.tableViewL.endUpdates()

                        if UserDefaults.standard.value(forKey: "filterTimelines") as? Int == 1 {
                            self.statusesLocal = self.statusesLocal.filter({ (stat) -> Bool in
                                if stat.reblog == nil {
                                    return false
                                } else {
                                    return true
                                }
                            })
                            self.tableView.reloadData()
                        }
                        if UserDefaults.standard.value(forKey: "filterTimelines") as? Int == 2 {
                            self.statusesLocal = self.statusesLocal.filter({ (stat) -> Bool in
                                if stat.mediaAttachments.isEmpty {
                                    return false
                                } else {
                                    return true
                                }
                            })
                            self.tableView.reloadData()
                        }
                        
                    }
                }
            }
        }
    }
    
    func fetchMoreFed() {
        let request = Timelines.public(local: false, range: .max(id: self.statusesFed.last?.id ?? "", limit: nil))
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                if stat.isEmpty {} else {
                    DispatchQueue.main.async {
                        let indexPaths = ((self.statusesFed.count)..<(self.statusesFed.count + stat.count)).map {
                            IndexPath(row: $0, section: 0)
                        }
                        self.statusesFed.append(contentsOf: stat)
                        self.tableViewF.beginUpdates()
                        self.tableViewF.insertRows(at: indexPaths, with: UITableView.RowAnimation.none)
                        self.tableViewF.endUpdates()

                        if UserDefaults.standard.value(forKey: "filterTimelines") as? Int == 1 {
                            self.statusesFed = self.statusesFed.filter({ (stat) -> Bool in
                                if stat.reblog == nil {
                                    return false
                                } else {
                                    return true
                                }
                            })
                            self.tableView.reloadData()
                        }
                        if UserDefaults.standard.value(forKey: "filterTimelines") as? Int == 2 {
                            self.statusesFed = self.statusesFed.filter({ (stat) -> Bool in
                                if stat.mediaAttachments.isEmpty {
                                    return false
                                } else {
                                    return true
                                }
                            })
                            self.tableView.reloadData()
                        }
                        
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == self.tableViewIntro {
            
            self.textField.text = "\(self.altInstances[indexPath.row])"
            GlobalStruct.client = Client(baseURL: "https://\("\(self.altInstances[indexPath.row])")")
            let request = Clients.register(
                clientName: "Mast",
                redirectURI: "com.shi.Mast://success",
                scopes: [.read, .write, .follow, .push],
                website: "https://twitter.com/jpeguin"
            )
            GlobalStruct.client.run(request) { (application) in
                if application.value == nil {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Not a valid instance (may be closed or dead)", message: "Please enter an instance name like mastodon.social or mastodon.technology, or use one from the list to get started. You can sign in if you already have an account registered with the instance, or you can choose to sign up with a new account.", preferredStyle: .actionSheet)
                        let op1 = UIAlertAction(title: "Find out more".localized, style: .default , handler:{ (UIAlertAction) in
                            let queryURL = URL(string: "https://joinmastodon.org")!
                            UIApplication.shared.open(queryURL, options: [.universalLinksOnly: true]) { (success) in
                                if !success {
                                    UIApplication.shared.open(queryURL)
                                }
                            }
                        })
                        op1.setValue(UIImage(systemName: "link.circle")!, forKey: "image")
                        op1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
                        alert.addAction(op1)
                        alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
                        }))
                        if let presenter = alert.popoverPresentationController {
                            presenter.sourceView = self.view
                            presenter.sourceRect = self.view.bounds
                        }
                        self.present(alert, animated: true, completion: nil)
                    }
                } else {
                    let application = application.value!
                    GlobalStruct.currentInstance.clientID = application.clientID
                    GlobalStruct.currentInstance.clientSecret = application.clientSecret
                    GlobalStruct.currentInstance.returnedText = "\(self.altInstances[indexPath.row])"
                    GlobalStruct.currentInstance.redirect = "com.shi.Mast://success".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                    DispatchQueue.main.async {
                        let queryURL = URL(string: "https://\("\(self.altInstances[indexPath.row])")/oauth/authorize?response_type=code&redirect_uri=\(GlobalStruct.currentInstance.redirect)&scope=read%20write%20follow%20push&client_id=\(application.clientID)")!
                        UIApplication.shared.open(queryURL, options: [.universalLinksOnly: true]) { (success) in
                            if !success {
                                if (UserDefaults.standard.object(forKey: "linkdest") == nil) || (UserDefaults.standard.object(forKey: "linkdest") as! Int == 0) {
                                    self.safariVC = SFSafariViewController(url: queryURL)
                                    self.present(self.safariVC!, animated: true, completion: nil)
                                } else {
                                    UIApplication.shared.open(queryURL, options: [:], completionHandler: nil)
                                }
                            }
                        }
                    }
                }
            }
            
        } else if tableView == self.tableView {
            if self.statusesHome[indexPath.row].id == "loadmorehere" {
                if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
                    let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
                    impactFeedbackgenerator.prepare()
                    impactFeedbackgenerator.impactOccurred()
                }
                self.fetchGap()
            } else {
                let vc = DetailViewController()
                vc.pickedStatusesHome = [self.statusesHome[indexPath.row].reblog ?? self.statusesHome[indexPath.row]]
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else if tableView == self.tableViewL {
            let vc = DetailViewController()
            vc.pickedStatusesHome = [self.statusesLocal[indexPath.row].reblog ?? self.statusesLocal[indexPath.row]]
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = DetailViewController()
            vc.pickedStatusesHome = [self.statusesFed[indexPath.row].reblog ?? self.statusesFed[indexPath.row]]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? TootCell {
            cell.highlightCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? TootCell {
            cell.unhighlightCell()
        }
    }
    
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            guard let indexPath = configuration.identifier as? IndexPath else { return }
            if tableView == self.tableView {
                let vc = DetailViewController()
                vc.pickedStatusesHome = [self.statusesHome[indexPath.row].reblog ?? self.statusesHome[indexPath.row]]
                self.navigationController?.pushViewController(vc, animated: true)
            } else if tableView == self.tableViewL {
                let vc = DetailViewController()
                vc.pickedStatusesHome = [self.statusesLocal[indexPath.row].reblog ?? self.statusesLocal[indexPath.row]]
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = DetailViewController()
                vc.pickedStatusesHome = [self.statusesFed[indexPath.row].reblog ?? self.statusesFed[indexPath.row]]
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: {
            if tableView == self.tableView {
                if self.statusesHome[indexPath.row].id == "loadmorehere" {
                    return nil
                } else {
                    let vc = DetailViewController()
                    vc.fromContextMenu = true
                    vc.pickedStatusesHome = [self.statusesHome[indexPath.row].reblog ?? self.statusesHome[indexPath.row]]
                    return vc
                }
            } else if tableView == self.tableViewL {
                let vc = DetailViewController()
                vc.fromContextMenu = true
                vc.pickedStatusesHome = [self.statusesLocal[indexPath.row].reblog ?? self.statusesLocal[indexPath.row]]
                return vc
            } else {
                let vc = DetailViewController()
                vc.fromContextMenu = true
                vc.pickedStatusesHome = [self.statusesFed[indexPath.row].reblog ?? self.statusesFed[indexPath.row]]
                return vc
            }
        }, actionProvider: { suggestedActions in
            if tableView == self.tableView {
                if self.statusesHome[indexPath.row].id == "loadmorehere" {
                    return nil
                } else {
                    return self.makeContextMenu([self.statusesHome[indexPath.row].reblog ?? self.statusesHome[indexPath.row]], indexPath: indexPath, tableView: self.tableView)
                }
            } else if tableView == self.tableViewL {
                return self.makeContextMenu([self.statusesLocal[indexPath.row].reblog ?? self.statusesLocal[indexPath.row]], indexPath: indexPath, tableView: self.tableViewL)
            } else {
                return self.makeContextMenu([self.statusesFed[indexPath.row].reblog ?? self.statusesFed[indexPath.row]], indexPath: indexPath, tableView: self.tableViewF)
            }
        })
    }
    
    func makeContextMenu(_ status: [Status], indexPath: IndexPath, tableView: UITableView) -> UIMenu {
        let repl = UIAction(title: "Reply".localized, image: UIImage(systemName: "arrowshape.turn.up.left"), identifier: nil) { action in
        #if targetEnvironment(macCatalyst)
        GlobalStruct.macWindow = 2
            GlobalStruct.macReply = status
        let userActivity = NSUserActivity(activityType: "com.shi.Mast.openComposer2")
        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: userActivity, options: nil) { (e) in
          print("error", e)
        }
        #elseif !targetEnvironment(macCatalyst)
            let vc = TootViewController()
            vc.replyStatus = status
            self.show(UINavigationController(rootViewController: vc), sender: self)
            #endif
        }
        var boos = UIAction(title: "Boost".localized, image: UIImage(systemName: "arrow.2.circlepath"), identifier: nil) { action in
            ViewController().showNotifBanner("Boosted".localized, subtitle: "Toot".localized, style: BannerStyle.info)
            let request = Statuses.reblog(id: status.first?.id ?? "")
            GlobalStruct.client.run(request) { (statuses) in
                
            }
        }
        if status.first?.reblogged ?? false {
            boos = UIAction(title: "Remove Boost".localized, image: UIImage(systemName: "arrow.2.circlepath"), identifier: nil) { action in
                ViewController().showNotifBanner("Removed Boost".localized, subtitle: "Toot".localized, style: BannerStyle.info)
                let request = Statuses.unreblog(id: status.first?.id ?? "")
                GlobalStruct.client.run(request) { (statuses) in
                    
                }
            }
        }
        var like = UIAction(title: "Like".localized, image: UIImage(systemName: "heart"), identifier: nil) { action in
            ViewController().showNotifBanner("Liked".localized, subtitle: "Toot".localized, style: BannerStyle.info)
            GlobalStruct.allLikedStatuses.append(status.first?.id ?? "")
            if let cell = tableView.cellForRow(at: indexPath) as? TootCell {
                cell.configure(status.first!)
            } else if let cell = tableView.cellForRow(at: indexPath) as? TootImageCell {
                cell.configure(status.first!)
            }
            let request = Statuses.favourite(id: status.first?.id ?? "")
            GlobalStruct.client.run(request) { (statuses) in
                
            }
        }
        if status.first?.favourited ?? false || GlobalStruct.allLikedStatuses.contains(status.first?.reblog?.id ?? status.first?.id ?? "") {
            like = UIAction(title: "Remove Like".localized, image: UIImage(systemName: "heart.slash"), identifier: nil) { action in
                ViewController().showNotifBanner("Removed Like".localized, subtitle: "Toot".localized, style: BannerStyle.info)
                GlobalStruct.allLikedStatuses = GlobalStruct.allLikedStatuses.filter{$0 != status.first?.id ?? ""}
                if let cell = tableView.cellForRow(at: indexPath) as? TootCell {
                    cell.configure(status.first!)
                } else if let cell = tableView.cellForRow(at: indexPath) as? TootImageCell {
                    cell.configure(status.first!)
                }
                let request = Statuses.unfavourite(id: status.first?.id ?? "")
                GlobalStruct.client.run(request) { (statuses) in
                    
                }
            }
        }
        let shar = UIAction(title: "Share".localized, image: UIImage(systemName: "square.and.arrow.up"), identifier: nil) { action in
            self.shareThis(status)
        }
        let tran = UIAction(title: "Translate".localized, image: UIImage(systemName: "globe"), identifier: nil) { action in
            self.translateThis(status)
        }
        let mute = UIAction(title: "Mute Conversation".localized, image: UIImage(systemName: "eye.slash"), identifier: nil) { action in
            ViewController().showNotifBanner("Muted".localized, subtitle: "Conversation".localized, style: BannerStyle.info)
            let request = Statuses.mute(id: status.first?.id ?? "")
            GlobalStruct.client.run(request) { (statuses) in
                print("muted")
            }
        }
        let dupl = UIAction(title: "Duplicate".localized, image: UIImage(systemName: "doc.on.doc"), identifier: nil) { action in
            let vc = TootViewController()
            vc.duplicateStatus = status
            self.show(UINavigationController(rootViewController: vc), sender: self)
        }
        let delete = UIAction(title: "Delete".localized, image: UIImage(systemName: "trash"), identifier: nil) { action in
            
        }
        delete.attributes = .destructive
        
        let repo1 = UIAction(title: "Harassment".localized, image: UIImage(systemName: "flag"), identifier: nil) { action in
            ViewController().showNotifBanner("Reported".localized, subtitle: "Harassment".localized, style: BannerStyle.info)
            let request = Reports.report(accountID: status.first?.account.id ?? "", statusIDs: [status.first?.id ?? ""], reason: "Harassment")
            GlobalStruct.client.run(request) { (statuses) in
                
            }
        }
        repo1.attributes = .destructive
        let repo2 = UIAction(title: "No Content Warning".localized, image: UIImage(systemName: "flag"), identifier: nil) { action in
            ViewController().showNotifBanner("Reported".localized, subtitle: "No Content Warning".localized, style: BannerStyle.info)
            let request = Reports.report(accountID: status.first?.account.id ?? "", statusIDs: [status.first?.id ?? ""], reason: "No Content Warning")
            GlobalStruct.client.run(request) { (statuses) in
                
            }
        }
        repo2.attributes = .destructive
        let repo3 = UIAction(title: "Spam".localized, image: UIImage(systemName: "flag"), identifier: nil) { action in
            ViewController().showNotifBanner("Reported".localized, subtitle: "Spam".localized, style: BannerStyle.info)
            let request = Reports.report(accountID: status.first?.account.id ?? "", statusIDs: [status.first?.id ?? ""], reason: "Spam")
            GlobalStruct.client.run(request) { (statuses) in
                
            }
        }
        repo3.attributes = .destructive
        
        let rep = UIMenu(__title: "Report".localized, image: UIImage(systemName: "flag"), identifier: nil, options: [.destructive], children: [repo1, repo2, repo3])
        
        if GlobalStruct.currentUser.id == (status.first?.account.id ?? "") {
            
            let pin1 = UIAction(title: "Pin".localized, image: UIImage(systemName: "pin"), identifier: nil) { action in
                ViewController().showNotifBanner("Pinned".localized, subtitle: "Toot".localized, style: BannerStyle.info)
                let request = Statuses.pin(id: status.first?.id ?? "")
                GlobalStruct.client.run(request) { (statuses) in
                    if let stat = statuses.value {
                        DispatchQueue.main.async {
                            
                        }
                    }
                }
            }
            let pin2 = UIAction(title: "Unpin".localized, image: UIImage(systemName: "pin"), identifier: nil) { action in
                ViewController().showNotifBanner("Unpinned".localized, subtitle: "Toot".localized, style: BannerStyle.info)
                let request = Statuses.unpin(id: status.first?.id ?? "")
                GlobalStruct.client.run(request) { (statuses) in
                    if let stat = statuses.value {
                        DispatchQueue.main.async {
                            
                        }
                    }
                }
            }
            let del1 = UIAction(title: "Delete and Redraft".localized, image: UIImage(systemName: "pencil.circle"), identifier: nil) { action in
                let request = Statuses.delete(id: status.first?.id ?? "")
                GlobalStruct.client.run(request) { (statuses) in
                    DispatchQueue.main.async {
                        let vc = TootViewController()
                        vc.duplicateStatus = [status.first!]
                        self.show(UINavigationController(rootViewController: vc), sender: self)
                    }
                }
            }
            del1.attributes = .destructive
            let del2 = UIAction(title: "Delete".localized, image: UIImage(systemName: "xmark"), identifier: nil) { action in
                ViewController().showNotifBanner("Deleted".localized, subtitle: "Toot".localized, style: BannerStyle.info)
                let request = Statuses.delete(id: status.first?.id ?? "")
                GlobalStruct.client.run(request) { (statuses) in
                    DispatchQueue.main.async {
                    
                    }
                }
            }
            del2.attributes = .destructive
            if GlobalStruct.allPinned.contains(status.first!) {
                let more = UIMenu(__title: "More".localized, image: UIImage(systemName: "ellipsis.circle"), identifier: nil, options: [], children: [pin2, tran, del1, del2])
                if status.first!.visibility == .private {
                    return UIMenu(__title: "", image: nil, identifier: nil, children: [repl, like, shar, more])
                } else {
                    return UIMenu(__title: "", image: nil, identifier: nil, children: [repl, boos, like, shar, more])
                }
            } else {
                let more = UIMenu(__title: "More".localized, image: UIImage(systemName: "ellipsis.circle"), identifier: nil, options: [], children: [pin1, tran, del1, del2])
                if status.first!.visibility == .private {
                    return UIMenu(__title: "", image: nil, identifier: nil, children: [repl, like, shar, more])
                } else {
                    return UIMenu(__title: "", image: nil, identifier: nil, children: [repl, boos, like, shar, more])
                }
            }
            
        } else {
            let more = UIMenu(__title: "More".localized, image: UIImage(systemName: "ellipsis.circle"), identifier: nil, options: [], children: [tran, mute, dupl, rep])
            if status.first!.visibility == .private {
                return UIMenu(__title: "", image: nil, identifier: nil, children: [repl, like, shar, more])
            } else {
                return UIMenu(__title: "", image: nil, identifier: nil, children: [repl, boos, like, shar, more])
            }
        }
    }
    
    func shareThis(_ stat: [Status]) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let op1 = UIAlertAction(title: " \("Share Content".localized)", style: .default , handler:{ (UIAlertAction) in
            let textToShare = [stat.first?.content.stripHTML() ?? ""]
            let activityViewController = UIActivityViewController(activityItems: textToShare,  applicationActivities: nil)
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? DetailActionsCell {
                activityViewController.popoverPresentationController?.sourceView = cell.button4
                activityViewController.popoverPresentationController?.sourceRect = cell.button4.bounds
            }
            self.present(activityViewController, animated: true, completion: nil)
        })
        op1.setValue(UIImage(systemName: "doc.append")!, forKey: "image")
        op1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op1)
        let op2 = UIAlertAction(title: "Share Link".localized, style: .default , handler:{ (UIAlertAction) in
            let textToShare = [stat.first?.url?.absoluteString ?? ""]
            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? DetailActionsCell {
                activityViewController.popoverPresentationController?.sourceView = cell.button4
                activityViewController.popoverPresentationController?.sourceRect = cell.button4.bounds
            }
            self.present(activityViewController, animated: true, completion: nil)
        })
        op2.setValue(UIImage(systemName: "link")!, forKey: "image")
        op2.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op2)
        alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
            
        }))
        if let presenter = alert.popoverPresentationController {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? DetailActionsCell {
                presenter.sourceView = self.view
                presenter.sourceRect = self.view.bounds
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func translateThis(_ stat: [Status]) {
        let unreserved = "-._~/?"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        let bodyText = stat.first?.content.stripHTML() ?? ""
        let unreservedChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
        let unreservedCharset = NSCharacterSet(charactersIn: unreservedChars)
        var trans = bodyText.addingPercentEncoding(withAllowedCharacters: unreservedCharset as CharacterSet)
        trans = trans!.replacingOccurrences(of: "\n\n", with: "%20")
        let langStr = Locale.current.languageCode
        let urlString = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=\(langStr ?? "en")&dt=t&q=\(trans!)&ie=UTF-8&oe=UTF-8"
        guard let requestUrl = URL(string:urlString) else {
            return
        }
        let request = URLRequest(url:requestUrl)
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            if error == nil, let usableData = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: usableData, options: .mutableContainers) as! [Any]
                    var translatedText = ""
                    for i in (json[0] as! [Any]) {
                        translatedText = translatedText + ((i as! [Any])[0] as? String ?? "")
                    }
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: nil, message: translatedText as? String ?? "Could not translate tweet", preferredStyle: .actionSheet)
                        alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
                            
                        }))
                        let paragraphStyle = NSMutableParagraphStyle()
                        paragraphStyle.alignment = NSTextAlignment.left
                        let messageText = NSMutableAttributedString(
                            string: translatedText as? String ?? "Could not translate toot",
                            attributes: [
                                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                                NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
                            ]
                        )
                        alert.setValue(messageText, forKey: "attributedMessage")
                        if let presenter = alert.popoverPresentationController {
                            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? DetailActionsCell {
                                presenter.sourceView = self.view
                                presenter.sourceRect = self.view.bounds
                            }
                        }
                        self.present(alert, animated: true, completion: nil)
                    }
                } catch let error as NSError {
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    func reportThis(_ stat: [Status]) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let op1 = UIAlertAction(title: "Harassment".localized, style: .destructive , handler:{ (UIAlertAction) in
            let request = Reports.report(accountID: stat.first?.account.id ?? "", statusIDs: [stat.first?.id ?? ""], reason: "Harassment")
            GlobalStruct.client.run(request) { (statuses) in
                
            }
        })
        op1.setValue(UIImage(systemName: "flag")!, forKey: "image")
        op1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op1)
        let op2 = UIAlertAction(title: "No Content Warning".localized, style: .destructive , handler:{ (UIAlertAction) in
            let request = Reports.report(accountID: stat.first?.account.id ?? "", statusIDs: [stat.first?.id ?? ""], reason: "No Content Warning")
            GlobalStruct.client.run(request) { (statuses) in
                
            }
        })
        op2.setValue(UIImage(systemName: "flag")!, forKey: "image")
        op2.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op2)
        let op3 = UIAlertAction(title: "Spam".localized, style: .destructive , handler:{ (UIAlertAction) in
            let request = Reports.report(accountID: stat.first?.account.id ?? "", statusIDs: [stat.first?.id ?? ""], reason: "Spam")
            GlobalStruct.client.run(request) { (statuses) in
                
            }
        })
        op3.setValue(UIImage(systemName: "flag")!, forKey: "image")
        op3.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op3)
        alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
            
        }))
        if let presenter = alert.popoverPresentationController {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? DetailActionsCell {
                presenter.sourceView = self.view
                presenter.sourceRect = self.view.bounds
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func addTapped() {
        if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
            let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
            impactFeedbackgenerator.prepare()
            impactFeedbackgenerator.impactOccurred()
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "addTapped"), object: self)
    }
    
    func createLoginView(newInstance: Bool = false) {
        
        let statusBarOrientation = UIApplication.shared.statusBarOrientation
        if (statusBarOrientation != UIInterfaceOrientation.portrait
            && statusBarOrientation != UIInterfaceOrientation.portraitUpsideDown) {
            self.fullHe = UIScreen.main.bounds.width
            self.fullWid = UIScreen.main.bounds.height
        } else {
            self.fullHe = UIScreen.main.bounds.height
            self.fullWid = UIScreen.main.bounds.width
        }
        
        self.newInstance = newInstance
        self.loginBG.backgroundColor = UIColor(named: "lighterBaseWhite")
        UIApplication.shared.windows.first?.addSubview(self.loginBG)
        
        self.loginLogo.image = UIImage(named: "icon")
        self.loginLogo.contentMode = .scaleAspectFit
        self.loginLogo.backgroundColor = UIColor.clear
        self.loginLogo.layer.cornerRadius = 20
        self.loginLogo.layer.cornerCurve = .continuous
        self.loginLogo.layer.masksToBounds = true
        UIApplication.shared.windows.first?.addSubview(self.loginLogo)
        
        self.loginLabel.frame = CGRect(x: 50, y: self.view.bounds.height/2 - 57.5, width: self.view.bounds.width - 80, height: 35)
        self.loginLabel.text = "Instance name:".localized
        self.loginLabel.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.6)
        self.loginLabel.font = UIFont.systemFont(ofSize: 14)
//        UIApplication.shared.windows.first?.addSubview(self.loginLabel)
        
        self.textField.backgroundColor = UIColor(named: "baseWhite")!
        self.textField.borderStyle = .none
        self.textField.layer.cornerRadius = 10
        self.textField.layer.cornerCurve = .continuous
        self.textField.textColor = UIColor(named: "baseBlack")
        self.textField.spellCheckingType = .no
        self.textField.returnKeyType = .done
        self.textField.autocorrectionType = .no
        self.textField.autocapitalizationType = .none
        self.textField.keyboardType = .URL
        self.textField.delegate = self
        self.textField.attributedPlaceholder = NSAttributedString(string: "Instance name...",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray.withAlphaComponent(0.45)])
        self.textField.accessibilityLabel = "Enter Instance Name".localized
        UIApplication.shared.windows.first?.addSubview(self.textField)
        
        self.tableViewIntro = UITableView(frame: .zero, style: .insetGrouped)
        self.tableViewIntro = UITableView(frame: .zero, style: .insetGrouped)
        self.tableViewIntro.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell1")
        self.tableViewIntro.alpha = 1
        self.tableViewIntro.delegate = self
        self.tableViewIntro.dataSource = self
        self.tableViewIntro.backgroundColor = .clear
        self.tableViewIntro.separatorStyle = .singleLine
        self.tableViewIntro.separatorColor = UIColor(named: "baseBlack")?.withAlphaComponent(0.24)
        self.tableViewIntro.layer.masksToBounds = true
        self.tableViewIntro.estimatedRowHeight = UITableView.automaticDimension
        self.tableViewIntro.rowHeight = UITableView.automaticDimension
        UIApplication.shared.windows.first?.addSubview(self.tableViewIntro)
        self.tableViewIntro.tableFooterView = UIView()
        
        self.fetchAltInstances()
    }
    
    func fetchAltInstances() {
        let urlStr = "https://instances.social/api/1.0/instances/list?count=\(100)&include_closed=\(false)&include_down=\(false)"
        let url: URL = URL(string: urlStr)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer 8gVQzoU62VFjvlrdnBUyAW8slAekA5uyuwdMi0CBzwfWwyStkqQo80jTZemuSGO8QomSycdD1JYgdRUnJH0OVT3uYYUilPMenrRZupuMQLl9hVt6xnhV6bwdXVSAT1wR", forHTTPHeaderField: "Authorization")
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let task = session.dataTask(with: request) { (data, response, err) in
            do {
                let json = try JSONDecoder().decode(tagInstances.self, from: data ?? Data())
                DispatchQueue.main.async {
                    for x in json.instances {
                        self.altInstances.append(x.name)
                    }
                    self.altInstances.insert("social.nofftopia.com", at: 0)
                    self.altInstances.insert("mastodon.technology", at: 0)
                    self.altInstances.insert("mastodon.social", at: 0)
                    self.tableViewIntro.reloadData()
                }
            } catch {
                print("err")
            }
        }
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == self.tableViewIntro {
            return 60
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == self.tableViewIntro {
            let vw = UIView()
            vw.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 60)
            vw.backgroundColor = .clear
            let title = UILabel()
            title.frame = CGRect(x: (UIApplication.shared.windows.first?.safeAreaInsets.left ?? 0) + 10, y: 0, width: self.view.bounds.width - 20, height: 60)
            title.text = "Pick the instance you'd like to add an account from"
            title.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.25)
            title.font = UIFont.systemFont(ofSize: 14)
            title.numberOfLines = 0
            vw.addSubview(title)
            return vw
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == self.tableViewIntro {
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.accessoryType = .none
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        DispatchQueue.main.async {
            self.textField.resignFirstResponder()
        }
        let returnedText = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if returnedText == "" || returnedText == " " || returnedText == "  " {} else {
            DispatchQueue.main.async {
                if self.newInstance {
                    GlobalStruct.newInstance = InstanceData()
                    GlobalStruct.client = Client(baseURL: "https://\(returnedText)")
                    let request = Clients.register(
                        clientName: "Mast",
                        redirectURI: "com.shi.Mast://addNewInstance",
                        scopes: [.read, .write, .follow, .push],
                        website: "https://twitter.com/jpeguin"
                    )
                    GlobalStruct.client.run(request) { (application) in
                        if application.value == nil {
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: "Not a valid instance (may be closed or dead)", message: "Please enter an instance name like mastodon.social or mastodon.technology, or use one from the list to get started. You can sign in if you already have an account registered with the instance, or you can choose to sign up with a new account.", preferredStyle: .actionSheet)
                                let op1 = UIAlertAction(title: "Find out more".localized, style: .default , handler:{ (UIAlertAction) in
                                    let queryURL = URL(string: "https://joinmastodon.org")!
                                    UIApplication.shared.open(queryURL, options: [.universalLinksOnly: true]) { (success) in
                                        if !success {
                                            UIApplication.shared.open(queryURL)
                                        }
                                    }
                                })
                                op1.setValue(UIImage(systemName: "link.circle")!, forKey: "image")
                                op1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
                                alert.addAction(op1)
                                alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
                                }))
                                if let presenter = alert.popoverPresentationController {
                                    presenter.sourceView = self.view
                                    presenter.sourceRect = self.view.bounds
                                }
                                self.present(alert, animated: true, completion: nil)
                            }
                        } else {
                            let application = application.value!
                            GlobalStruct.newInstance?.clientID = application.clientID
                            GlobalStruct.newInstance?.clientSecret = application.clientSecret
                            GlobalStruct.newInstance?.returnedText = returnedText
                            GlobalStruct.newInstance?.redirect = "com.shi.Mast://addNewInstance".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                            DispatchQueue.main.async {
                                let queryURL = URL(string: "https://\(returnedText)/oauth/authorize?response_type=code&redirect_uri=\(GlobalStruct.newInstance!.redirect)&scope=read%20write%20follow%20push&client_id=\(application.clientID)")!
                                UIApplication.shared.open(queryURL, options: [.universalLinksOnly: true]) { (success) in
                                    if !success {
                                        if (UserDefaults.standard.object(forKey: "linkdest") == nil) || (UserDefaults.standard.object(forKey: "linkdest") as! Int == 0) {
                                            self.safariVC = SFSafariViewController(url: queryURL)
                                            self.present(self.safariVC!, animated: true, completion: nil)
                                        } else {
                                            UIApplication.shared.open(queryURL, options: [:], completionHandler: nil)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                } else {
                    GlobalStruct.client = Client(baseURL: "https://\(returnedText)")
                    let request = Clients.register(
                        clientName: "Mast",
                        redirectURI: "com.shi.Mast://success",
                        scopes: [.read, .write, .follow, .push],
                        website: "https://twitter.com/jpeguin"
                    )
                    GlobalStruct.client.run(request) { (application) in
                        if application.value == nil {
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: "Not a valid instance (may be closed or dead)", message: "Please enter an instance name like mastodon.social or mastodon.technology, or use one from the list to get started. You can sign in if you already have an account registered with the instance, or you can choose to sign up with a new account.", preferredStyle: .actionSheet)
                                let op1 = UIAlertAction(title: "Find out more".localized, style: .default , handler:{ (UIAlertAction) in
                                    let queryURL = URL(string: "https://joinmastodon.org")!
                                    UIApplication.shared.open(queryURL, options: [.universalLinksOnly: true]) { (success) in
                                        if !success {
                                            UIApplication.shared.open(queryURL)
                                        }
                                    }
                                })
                                op1.setValue(UIImage(systemName: "link.circle")!, forKey: "image")
                                op1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
                                alert.addAction(op1)
                                alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
                                }))
                                if let presenter = alert.popoverPresentationController {
                                    presenter.sourceView = self.view
                                    presenter.sourceRect = self.view.bounds
                                }
                                self.present(alert, animated: true, completion: nil)
                            }
                        } else {
                            let application = application.value!
                            GlobalStruct.currentInstance.clientID = application.clientID
                            GlobalStruct.currentInstance.clientSecret = application.clientSecret
                            GlobalStruct.currentInstance.returnedText = returnedText
                            GlobalStruct.currentInstance.redirect = "com.shi.Mast://success".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                            DispatchQueue.main.async {
                                let queryURL = URL(string: "https://\(returnedText)/oauth/authorize?response_type=code&redirect_uri=\(GlobalStruct.currentInstance.redirect)&scope=read%20write%20follow%20push&client_id=\(application.clientID)")!
                                UIApplication.shared.open(queryURL, options: [.universalLinksOnly: true]) { (success) in
                                    if !success {
                                        if (UserDefaults.standard.object(forKey: "linkdest") == nil) || (UserDefaults.standard.object(forKey: "linkdest") as! Int == 0) {
                                            self.safariVC = SFSafariViewController(url: queryURL)
                                            self.present(self.safariVC!, animated: true, completion: nil)
                                        } else {
                                            UIApplication.shared.open(queryURL, options: [:], completionHandler: nil)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                
            }
        }
        return true
    }
    
    @objc func logged() {
        self.loginBG.removeFromSuperview()
        self.loginLogo.removeFromSuperview()
        self.loginLabel.removeFromSuperview()
        self.textField.removeFromSuperview()
        self.tableViewIntro.removeFromSuperview()
        self.safariVC?.dismiss(animated: true, completion: nil)
        
        var request = URLRequest(url: URL(string: "https://\(GlobalStruct.currentInstance.returnedText)/oauth/token?grant_type=authorization_code&code=\(GlobalStruct.currentInstance.authCode)&redirect_uri=\(GlobalStruct.currentInstance.redirect)&client_id=\(GlobalStruct.currentInstance.clientID)&client_secret=\(GlobalStruct.currentInstance.clientSecret)&scope=read%20write%20follow%20push")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else { print("error"); return }
            guard let data = data else { return }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    
                    GlobalStruct.currentInstance.accessToken = (json["access_token"] as? String ?? "")
                    GlobalStruct.client.accessToken = (json["access_token"] as? String ?? "")
                    InstanceData.setCurrentInstance(instance: GlobalStruct.currentInstance)
                    
                    UserDefaults.standard.set(GlobalStruct.client.accessToken, forKey: "accessToken")
                    
                    let request2 = Accounts.currentUser()
                    GlobalStruct.client.run(request2) { (statuses) in
                        if let stat = (statuses.value) {
                            DispatchQueue.main.async {
                                var instances = InstanceData.getAllInstances()
                                instances.append(GlobalStruct.currentInstance)
                                UserDefaults.standard.set(try? PropertyListEncoder().encode(instances), forKey: "instances")
                                Account.addAccountToList(account: stat)
                            }
                        }
                    }
                    
                    self.initialFetches()
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    func removeTabbarItemsText() {
        if let items = self.tabBarController?.tabBar.items {
            for item in items {
                item.title = ""
            }
        }
    }
}

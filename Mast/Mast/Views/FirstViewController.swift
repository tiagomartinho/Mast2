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

class FirstViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
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
        GlobalStruct.currentTab = 1
        
        // Add button
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
        #if targetEnvironment(macCatalyst)
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(systemName: "square.on.square", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn1.addTarget(self, action: #selector(self.newWindow), for: .touchUpInside)
        btn1.accessibilityLabel = "New Window".localized
        let addButton = UIBarButtonItem(customView: btn1)
        self.navigationItem.setRightBarButton(addButton, animated: true)
        #elseif !targetEnvironment(macCatalyst)
        if UIDevice.current.userInterfaceIdiom == .pad && self.isSplitOrSlideOver == false {
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
            let btn1 = UIButton(type: .custom)
            btn1.setImage(UIImage(systemName: "square.on.square", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
            btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            btn1.addTarget(self, action: #selector(self.newWindow), for: .touchUpInside)
            btn1.accessibilityLabel = "New Window".localized
            let addButton = UIBarButtonItem(customView: btn1)
            self.navigationItem.setRightBarButton(addButton, animated: true)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = GlobalStruct.baseDarkTint
        self.title = "Feed".localized
        //        self.removeTabbarItemsText()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.logged), name: NSNotification.Name(rawValue: "logged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePosted), name: NSNotification.Name(rawValue: "updatePosted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.scrollTop1), name: NSNotification.Name(rawValue: "scrollTop1"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTable1), name: NSNotification.Name(rawValue: "refreshTable1"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notifChangeTint), name: NSNotification.Name(rawValue: "notifChangeTint"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openTootDetail), name: NSNotification.Name(rawValue: "openTootDetail1"), object: nil)
        
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
        
        let icon00 = UIApplicationShortcutIcon(systemImageName: "plus")
        let item00 = UIApplicationShortcutItem(type: "com.shi.Mast2.NewToot", localizedTitle: "New Toot".localized, localizedSubtitle: nil, icon: icon00, userInfo: nil)
        item00.accessibilityLabel = "New Toot"
        let icon0 = UIApplicationShortcutIcon(systemImageName: "bell")
        let item0 = UIApplicationShortcutItem(type: "com.shi.Mast2.Notifications", localizedTitle: "View Notiications".localized, localizedSubtitle: nil, icon: icon0, userInfo: nil)
        item0.accessibilityLabel = "View Notiications"
        let icon1 = UIApplicationShortcutIcon(systemImageName: "paperplane")
        let item1 = UIApplicationShortcutItem(type: "com.shi.Mast2.Messages", localizedTitle: "View Messages".localized, localizedSubtitle: nil, icon: icon1, userInfo: nil)
        item1.accessibilityLabel = "View Messages"
        let icon2 = UIApplicationShortcutIcon(systemImageName: "person.crop.circle")
        let item2 = UIApplicationShortcutItem(type: "com.shi.Mast2.Profile", localizedTitle: "View Profile".localized, localizedSubtitle: nil, icon: icon2, userInfo: nil)
        item2.accessibilityLabel = "View Profile"
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
        let request0 = Accounts.currentUser()
        GlobalStruct.client.run(request0) { (statuses) in
            if let stat = (statuses.value) {
                DispatchQueue.main.async {
                    GlobalStruct.currentUser = stat
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
        let request = Timelines.home()
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                DispatchQueue.main.async {
                    GlobalStruct.statusesHome = stat
                    self.tableView.reloadData()
                    self.statusesHome = stat
                }
            }
        }
        let request2 = Timelines.public(local: true, range: .default)
        GlobalStruct.client.run(request2) { (statuses) in
            if let stat = (statuses.value) {
                DispatchQueue.main.async {
                    GlobalStruct.statusesLocal = stat
                    self.tableViewL.reloadData()
                    self.statusesLocal = stat
                }
            }
        }
        let request3 = Timelines.public(local: false, range: .default)
        GlobalStruct.client.run(request3) { (statuses) in
            if let stat = (statuses.value) {
                DispatchQueue.main.async {
                    GlobalStruct.statusesFed = stat
                    self.tableViewF.reloadData()
                    self.statusesFed = stat
                }
            }
        }
        
        if UserDefaults.standard.value(forKey: "filterNotifications") as? Int == 0 {
            self.notTypes = []
        } else if UserDefaults.standard.value(forKey: "filterNotifications") as? Int == 1 {
            self.notTypes = GlobalStruct.notTypes.filter {$0 != NotificationType.mention}
        } else if UserDefaults.standard.value(forKey: "filterNotifications") as? Int == 2 {
            self.notTypes = GlobalStruct.notTypes.filter {$0 != NotificationType.favourite}
        } else if UserDefaults.standard.value(forKey: "filterNotifications") as? Int == 3 {
            self.notTypes = GlobalStruct.notTypes.filter {$0 != NotificationType.reblog}
        } else if UserDefaults.standard.value(forKey: "filterNotifications") as? Int == 4 {
            self.notTypes = GlobalStruct.notTypes.filter {$0 != NotificationType.direct}
        } else if UserDefaults.standard.value(forKey: "filterNotifications") as? Int == 5 {
            self.notTypes = GlobalStruct.notTypes.filter {$0 != NotificationType.follow}
        } else if UserDefaults.standard.value(forKey: "filterNotifications") as? Int == 6 {
            self.notTypes = GlobalStruct.notTypes.filter {$0 != NotificationType.poll}
        }
        
        let request4 = Notifications.all(range: .default, typesToExclude: self.notTypes)
        GlobalStruct.client.run(request4) { (statuses) in
            if let stat = (statuses.value) {
                DispatchQueue.main.async {
                    GlobalStruct.notifications = stat
                    #if targetEnvironment(macCatalyst)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshTable"), object: nil)
                    #elseif !targetEnvironment(macCatalyst)
                    if UIDevice.current.userInterfaceIdiom == .pad && self.isSplitOrSlideOver == false {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshTable"), object: nil)
                    }
                    #endif
                }
            }
        }
        let request5 = Timelines.conversations(range: .max(id: GlobalStruct.notificationsDirect.last?.id ?? "", limit: 5000))
        GlobalStruct.client.run(request5) { (statuses) in
            if let stat = (statuses.value) {
                DispatchQueue.main.async {
                    GlobalStruct.notificationsDirect = GlobalStruct.notificationsDirect + stat
                    #if targetEnvironment(macCatalyst)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshTable"), object: nil)
                    #elseif !targetEnvironment(macCatalyst)
                    if UIDevice.current.userInterfaceIdiom == .pad && self.isSplitOrSlideOver == false {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshTable"), object: nil)
                    }
                    #endif
                }
            }
        }
        
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
    
    @objc func refresh(_ sender: AnyObject) {
        let request = Timelines.home(range: .since(id: GlobalStruct.statusesHome.first?.id ?? "", limit: nil))
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
                        let indexPaths = (0..<stat.count).map {
                            IndexPath(row: $0, section: 0)
                        }
                        GlobalStruct.statusesHome = stat + GlobalStruct.statusesHome
                        self.tableView.beginUpdates()
                        UIView.setAnimationsEnabled(false)
                        var heights: CGFloat = 0
                        let _ = indexPaths.map {
                            if let cell = self.tableView.cellForRow(at: $0) as? TootCell {
                                heights += cell.bounds.height
                            }
                        }
                        self.tableView.insertRows(at: indexPaths, with: UITableView.RowAnimation.none)
                        self.tableView.setContentOffset(CGPoint(x: 0, y: heights), animated: false)
                        self.tableView.endUpdates()
                        UIView.setAnimationsEnabled(true)

                        if UserDefaults.standard.value(forKey: "filterTimelines") as? Int == 1 {
                            GlobalStruct.statusesHome = GlobalStruct.statusesHome.filter({ (stat) -> Bool in
                                if stat.reblog == nil {
                                    return false
                                } else {
                                    return true
                                }
                            })
                            self.tableView.reloadData()
                        }
                        if UserDefaults.standard.value(forKey: "filterTimelines") as? Int == 2 {
                            GlobalStruct.statusesHome = GlobalStruct.statusesHome.filter({ (stat) -> Bool in
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
        let request = Timelines.public(local: true, range: .since(id: GlobalStruct.statusesLocal.first?.id ?? "", limit: nil))
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
                        GlobalStruct.statusesLocal = stat + GlobalStruct.statusesLocal
                        self.tableViewL.beginUpdates()
                        UIView.setAnimationsEnabled(false)
                        var heights: CGFloat = 0
                        let _ = indexPaths.map {
                            if let cell = self.tableViewL.cellForRow(at: $0) as? TootCell {
                                heights += cell.bounds.height
                            }
                        }
                        self.tableViewL.insertRows(at: indexPaths, with: UITableView.RowAnimation.none)
                        self.tableViewL.setContentOffset(CGPoint(x: 0, y: heights), animated: false)
                        self.tableViewL.endUpdates()
                        UIView.setAnimationsEnabled(true)

                        if UserDefaults.standard.value(forKey: "filterTimelines") as? Int == 1 {
                            GlobalStruct.statusesLocal = GlobalStruct.statusesLocal.filter({ (stat) -> Bool in
                                if stat.reblog == nil {
                                    return false
                                } else {
                                    return true
                                }
                            })
                            self.tableView.reloadData()
                        }
                        if UserDefaults.standard.value(forKey: "filterTimelines") as? Int == 2 {
                            GlobalStruct.statusesLocal = GlobalStruct.statusesLocal.filter({ (stat) -> Bool in
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
        let request = Timelines.public(local: false, range: .since(id: GlobalStruct.statusesFed.first?.id ?? "", limit: nil))
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
                        GlobalStruct.statusesFed = stat + GlobalStruct.statusesFed
                        self.tableViewF.beginUpdates()
                        UIView.setAnimationsEnabled(false)
                        var heights: CGFloat = 0
                        let _ = indexPaths.map {
                            if let cell = self.tableViewF.cellForRow(at: $0) as? TootCell {
                                heights += cell.bounds.height
                            }
                        }
                        self.tableViewF.insertRows(at: indexPaths, with: UITableView.RowAnimation.none)
                        self.tableViewF.setContentOffset(CGPoint(x: 0, y: heights), animated: false)
                        self.tableViewF.endUpdates()
                        UIView.setAnimationsEnabled(true)

                        if UserDefaults.standard.value(forKey: "filterTimelines") as? Int == 1 {
                            GlobalStruct.statusesFed = GlobalStruct.statusesFed.filter({ (stat) -> Bool in
                                if stat.reblog == nil {
                                    return false
                                } else {
                                    return true
                                }
                            })
                            self.tableView.reloadData()
                        }
                        if UserDefaults.standard.value(forKey: "filterTimelines") as? Int == 2 {
                            GlobalStruct.statusesFed = GlobalStruct.statusesFed.filter({ (stat) -> Bool in
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
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let op1 = UIAlertAction(title: "All".localized, style: .default , handler:{ (UIAlertAction) in
            UserDefaults.standard.set(0, forKey: "filterTimelines")
            DispatchQueue.main.async {
                GlobalStruct.statusesHome = self.statusesHome
                self.tableView.reloadData()
                GlobalStruct.statusesLocal = self.statusesLocal
                self.tableViewL.reloadData()
                GlobalStruct.statusesFed = self.statusesFed
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
                GlobalStruct.statusesHome = self.statusesHome
                GlobalStruct.statusesHome = GlobalStruct.statusesHome.filter({ (stat) -> Bool in
                    if stat.reblog == nil {
                        return false
                    } else {
                        return true
                    }
                })
                self.tableView.reloadData()
                GlobalStruct.statusesLocal = self.statusesLocal
                GlobalStruct.statusesLocal = GlobalStruct.statusesLocal.filter({ (stat) -> Bool in
                    if stat.reblog == nil {
                        return false
                    } else {
                        return true
                    }
                })
                self.tableViewL.reloadData()
                GlobalStruct.statusesFed = self.statusesFed
                GlobalStruct.statusesFed = GlobalStruct.statusesFed.filter({ (stat) -> Bool in
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
                GlobalStruct.statusesHome = self.statusesHome
                GlobalStruct.statusesHome = GlobalStruct.statusesHome.filter({ (stat) -> Bool in
                    if stat.mediaAttachments.isEmpty {
                        return false
                    } else {
                        return true
                    }
                })
                self.tableView.reloadData()
                GlobalStruct.statusesLocal = self.statusesLocal
                GlobalStruct.statusesLocal = GlobalStruct.statusesLocal.filter({ (stat) -> Bool in
                    if stat.mediaAttachments.isEmpty {
                        return false
                    } else {
                        return true
                    }
                })
                self.tableViewL.reloadData()
                GlobalStruct.statusesFed = self.statusesFed
                GlobalStruct.statusesFed = GlobalStruct.statusesFed.filter({ (stat) -> Bool in
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
        if tableView == self.tableView {
            return GlobalStruct.statusesHome.count
        } else if tableView == self.tableViewL {
            return GlobalStruct.statusesLocal.count
        } else {
            return GlobalStruct.statusesFed.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            if GlobalStruct.statusesHome[indexPath.row].reblog?.mediaAttachments.isEmpty ?? GlobalStruct.statusesHome[indexPath.row].mediaAttachments.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TootCell", for: indexPath) as! TootCell
                if GlobalStruct.statusesHome.isEmpty {} else {
                    cell.configure(GlobalStruct.statusesHome[indexPath.row])
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile(_:)))
                    cell.profile.tag = indexPath.row
                    cell.profile.addGestureRecognizer(tap)
                    let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile2(_:)))
                    cell.profile2.tag = indexPath.row
                    cell.profile2.addGestureRecognizer(tap2)
                    if indexPath.row == GlobalStruct.statusesHome.count - 10 {
                        self.fetchMoreHome()
                    }
                }
                
                cell.content.handleMentionTap { (string) in
                    let vc = FifthViewController()
                    vc.isYou = false
                    vc.isTapped = true
                    vc.userID = string
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                cell.content.handleHashtagTap { (string) in
                    let vc = HashtagViewController()
                    vc.theHashtag = string
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                cell.content.handleURLTap { (string) in
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
                if GlobalStruct.statusesHome.isEmpty {} else {
                    cell.configure(GlobalStruct.statusesHome[indexPath.row])
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile(_:)))
                    cell.profile.tag = indexPath.row
                    cell.profile.addGestureRecognizer(tap)
                    let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile2(_:)))
                    cell.profile2.tag = indexPath.row
                    cell.profile2.addGestureRecognizer(tap2)
                    if indexPath.row == GlobalStruct.statusesHome.count - 10 {
                        self.fetchMoreHome()
                    }
                }
                
                cell.content.handleMentionTap { (string) in
                    let vc = FifthViewController()
                    vc.isYou = false
                    vc.isTapped = true
                    vc.userID = string
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                cell.content.handleHashtagTap { (string) in
                    let vc = HashtagViewController()
                    vc.theHashtag = string
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                cell.content.handleURLTap { (string) in
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
            if GlobalStruct.statusesLocal[indexPath.row].reblog?.mediaAttachments.isEmpty ?? GlobalStruct.statusesLocal[indexPath.row].mediaAttachments.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TootCellL", for: indexPath) as! TootCell
                if GlobalStruct.statusesLocal.isEmpty {} else {
                    cell.configure(GlobalStruct.statusesLocal[indexPath.row])
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile(_:)))
                    cell.profile.tag = indexPath.row
                    cell.profile.addGestureRecognizer(tap)
                    let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile2(_:)))
                    cell.profile2.tag = indexPath.row
                    cell.profile2.addGestureRecognizer(tap2)
                    if indexPath.row == GlobalStruct.statusesLocal.count - 10 {
                        self.fetchMoreLocal()
                    }
                }
                
                cell.content.handleMentionTap { (string) in
                    let vc = FifthViewController()
                    vc.isYou = false
                    vc.isTapped = true
                    vc.userID = string
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                cell.content.handleHashtagTap { (string) in
                    let vc = HashtagViewController()
                    vc.theHashtag = string
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                cell.content.handleURLTap { (string) in
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
                if GlobalStruct.statusesLocal.isEmpty {} else {
                    cell.configure(GlobalStruct.statusesLocal[indexPath.row])
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile(_:)))
                    cell.profile.tag = indexPath.row
                    cell.profile.addGestureRecognizer(tap)
                    let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile2(_:)))
                    cell.profile2.tag = indexPath.row
                    cell.profile2.addGestureRecognizer(tap2)
                    if indexPath.row == GlobalStruct.statusesLocal.count - 10 {
                        self.fetchMoreLocal()
                    }
                }
                
                cell.content.handleMentionTap { (string) in
                    let vc = FifthViewController()
                    vc.isYou = false
                    vc.isTapped = true
                    vc.userID = string
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                cell.content.handleHashtagTap { (string) in
                    let vc = HashtagViewController()
                    vc.theHashtag = string
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                cell.content.handleURLTap { (string) in
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
            if GlobalStruct.statusesFed[indexPath.row].reblog?.mediaAttachments.isEmpty ?? GlobalStruct.statusesFed[indexPath.row].mediaAttachments.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TootCellF", for: indexPath) as! TootCell
                if GlobalStruct.statusesFed.isEmpty {} else {
                    cell.configure(GlobalStruct.statusesFed[indexPath.row])
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile(_:)))
                    cell.profile.tag = indexPath.row
                    cell.profile.addGestureRecognizer(tap)
                    let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile2(_:)))
                    cell.profile2.tag = indexPath.row
                    cell.profile2.addGestureRecognizer(tap2)
                    if indexPath.row == GlobalStruct.statusesFed.count - 10 {
                        self.fetchMoreFed()
                    }
                }
                
                cell.content.handleMentionTap { (string) in
                    let vc = FifthViewController()
                    vc.isYou = false
                    vc.isTapped = true
                    vc.userID = string
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                cell.content.handleHashtagTap { (string) in
                    let vc = HashtagViewController()
                    vc.theHashtag = string
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                cell.content.handleURLTap { (string) in
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
                if GlobalStruct.statusesFed.isEmpty {} else {
                    cell.configure(GlobalStruct.statusesFed[indexPath.row])
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile(_:)))
                    cell.profile.tag = indexPath.row
                    cell.profile.addGestureRecognizer(tap)
                    let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile2(_:)))
                    cell.profile2.tag = indexPath.row
                    cell.profile2.addGestureRecognizer(tap2)
                    if indexPath.row == GlobalStruct.statusesFed.count - 10 {
                        self.fetchMoreFed()
                    }
                }
                
                cell.content.handleMentionTap { (string) in
                    let vc = FifthViewController()
                    vc.isYou = false
                    vc.isTapped = true
                    vc.userID = string
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                cell.content.handleHashtagTap { (string) in
                    let vc = HashtagViewController()
                    vc.theHashtag = string
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                cell.content.handleURLTap { (string) in
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
            if GlobalStruct.currentUser.id == (GlobalStruct.statusesHome[gesture.view!.tag].reblog?.account.id ?? GlobalStruct.statusesHome[gesture.view!.tag].account.id) {
                vc.isYou = true
            } else {
                vc.isYou = false
            }
            vc.pickedCurrentUser = GlobalStruct.statusesHome[gesture.view!.tag].reblog?.account ?? GlobalStruct.statusesHome[gesture.view!.tag].account
            self.navigationController?.pushViewController(vc, animated: true)
        } else if self.tableViewL.alpha == 1 {
            if GlobalStruct.currentUser.id == (GlobalStruct.statusesLocal[gesture.view!.tag].reblog?.account.id ?? GlobalStruct.statusesLocal[gesture.view!.tag].account.id) {
                vc.isYou = true
            } else {
                vc.isYou = false
            }
            vc.pickedCurrentUser = GlobalStruct.statusesLocal[gesture.view!.tag].reblog?.account ?? GlobalStruct.statusesLocal[gesture.view!.tag].account
            self.navigationController?.pushViewController(vc, animated: true)
        } else if self.tableViewF.alpha == 1 {
            if GlobalStruct.currentUser.id == (GlobalStruct.statusesFed[gesture.view!.tag].reblog?.account.id ?? GlobalStruct.statusesFed[gesture.view!.tag].account.id) {
                vc.isYou = true
            } else {
                vc.isYou = false
            }
            vc.pickedCurrentUser = GlobalStruct.statusesFed[gesture.view!.tag].reblog?.account ?? GlobalStruct.statusesFed[gesture.view!.tag].account
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func viewProfile2(_ gesture: UIGestureRecognizer) {
        let vc = FifthViewController()
        if self.tableView.alpha == 1 {
            if GlobalStruct.currentUser.id == (GlobalStruct.statusesHome[gesture.view!.tag].account.id) {
                vc.isYou = true
            } else {
                vc.isYou = false
            }
            vc.pickedCurrentUser = GlobalStruct.statusesHome[gesture.view!.tag].account
            self.navigationController?.pushViewController(vc, animated: true)
        } else if self.tableViewL.alpha == 1 {
            if GlobalStruct.currentUser.id == (GlobalStruct.statusesHome[gesture.view!.tag].account.id) {
                vc.isYou = true
            } else {
                vc.isYou = false
            }
            vc.pickedCurrentUser = GlobalStruct.statusesLocal[gesture.view!.tag].account
            self.navigationController?.pushViewController(vc, animated: true)
        } else if self.tableViewF.alpha == 1 {
            if GlobalStruct.currentUser.id == (GlobalStruct.statusesHome[gesture.view!.tag].account.id) {
                vc.isYou = true
            } else {
                vc.isYou = false
            }
            vc.pickedCurrentUser = GlobalStruct.statusesFed[gesture.view!.tag].account
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func fetchMoreHome() {
        let request = Timelines.home(range: .max(id: GlobalStruct.statusesHome.last?.id ?? "", limit: nil))
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                if stat.isEmpty {} else {
                    DispatchQueue.main.async {
                        let indexPaths = ((GlobalStruct.statusesHome.count)..<(GlobalStruct.statusesHome.count + stat.count)).map {
                            IndexPath(row: $0, section: 0)
                        }
                        GlobalStruct.statusesHome.append(contentsOf: stat)
                        self.tableView.beginUpdates()
                        self.tableView.insertRows(at: indexPaths, with: UITableView.RowAnimation.none)
                        self.tableView.endUpdates()

                        if UserDefaults.standard.value(forKey: "filterTimelines") as? Int == 1 {
                            GlobalStruct.statusesHome = GlobalStruct.statusesHome.filter({ (stat) -> Bool in
                                if stat.reblog == nil {
                                    return false
                                } else {
                                    return true
                                }
                            })
                            self.tableView.reloadData()
                        }
                        if UserDefaults.standard.value(forKey: "filterTimelines") as? Int == 2 {
                            GlobalStruct.statusesHome = GlobalStruct.statusesHome.filter({ (stat) -> Bool in
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
        let request = Timelines.public(local: true, range: .max(id: GlobalStruct.statusesLocal.last?.id ?? "", limit: nil))
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                if stat.isEmpty {} else {
                    DispatchQueue.main.async {
                        let indexPaths = ((GlobalStruct.statusesLocal.count)..<(GlobalStruct.statusesLocal.count + stat.count)).map {
                            IndexPath(row: $0, section: 0)
                        }
                        GlobalStruct.statusesLocal.append(contentsOf: stat)
                        self.tableViewL.beginUpdates()
                        self.tableViewL.insertRows(at: indexPaths, with: UITableView.RowAnimation.none)
                        self.tableViewL.endUpdates()

                        if UserDefaults.standard.value(forKey: "filterTimelines") as? Int == 1 {
                            GlobalStruct.statusesLocal = GlobalStruct.statusesLocal.filter({ (stat) -> Bool in
                                if stat.reblog == nil {
                                    return false
                                } else {
                                    return true
                                }
                            })
                            self.tableView.reloadData()
                        }
                        if UserDefaults.standard.value(forKey: "filterTimelines") as? Int == 2 {
                            GlobalStruct.statusesLocal = GlobalStruct.statusesLocal.filter({ (stat) -> Bool in
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
        let request = Timelines.public(local: false, range: .max(id: GlobalStruct.statusesFed.last?.id ?? "", limit: nil))
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                if stat.isEmpty {} else {
                    DispatchQueue.main.async {
                        let indexPaths = ((GlobalStruct.statusesFed.count)..<(GlobalStruct.statusesFed.count + stat.count)).map {
                            IndexPath(row: $0, section: 0)
                        }
                        GlobalStruct.statusesFed.append(contentsOf: stat)
                        self.tableViewF.beginUpdates()
                        self.tableViewF.insertRows(at: indexPaths, with: UITableView.RowAnimation.none)
                        self.tableViewF.endUpdates()

                        if UserDefaults.standard.value(forKey: "filterTimelines") as? Int == 1 {
                            GlobalStruct.statusesFed = GlobalStruct.statusesFed.filter({ (stat) -> Bool in
                                if stat.reblog == nil {
                                    return false
                                } else {
                                    return true
                                }
                            })
                            self.tableView.reloadData()
                        }
                        if UserDefaults.standard.value(forKey: "filterTimelines") as? Int == 2 {
                            GlobalStruct.statusesFed = GlobalStruct.statusesFed.filter({ (stat) -> Bool in
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
        if tableView == self.tableView {
            let vc = DetailViewController()
            vc.pickedStatusesHome = [GlobalStruct.statusesHome[indexPath.row].reblog ?? GlobalStruct.statusesHome[indexPath.row]]
            self.navigationController?.pushViewController(vc, animated: true)
        } else if tableView == self.tableViewL {
            let vc = DetailViewController()
            vc.pickedStatusesHome = [GlobalStruct.statusesLocal[indexPath.row].reblog ?? GlobalStruct.statusesLocal[indexPath.row]]
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = DetailViewController()
            vc.pickedStatusesHome = [GlobalStruct.statusesFed[indexPath.row].reblog ?? GlobalStruct.statusesFed[indexPath.row]]
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
                vc.pickedStatusesHome = [GlobalStruct.statusesHome[indexPath.row].reblog ?? GlobalStruct.statusesHome[indexPath.row]]
                self.navigationController?.pushViewController(vc, animated: true)
            } else if tableView == self.tableViewL {
                let vc = DetailViewController()
                vc.pickedStatusesHome = [GlobalStruct.statusesLocal[indexPath.row].reblog ?? GlobalStruct.statusesLocal[indexPath.row]]
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = DetailViewController()
                vc.pickedStatusesHome = [GlobalStruct.statusesFed[indexPath.row].reblog ?? GlobalStruct.statusesFed[indexPath.row]]
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: {
            if tableView == self.tableView {
                let vc = DetailViewController()
                vc.fromContextMenu = true
                vc.pickedStatusesHome = [GlobalStruct.statusesHome[indexPath.row].reblog ?? GlobalStruct.statusesHome[indexPath.row]]
                return vc
            } else if tableView == self.tableViewL {
                let vc = DetailViewController()
                vc.fromContextMenu = true
                vc.pickedStatusesHome = [GlobalStruct.statusesLocal[indexPath.row].reblog ?? GlobalStruct.statusesLocal[indexPath.row]]
                return vc
            } else {
                let vc = DetailViewController()
                vc.fromContextMenu = true
                vc.pickedStatusesHome = [GlobalStruct.statusesFed[indexPath.row].reblog ?? GlobalStruct.statusesFed[indexPath.row]]
                return vc
            }
        }, actionProvider: { suggestedActions in
            if tableView == self.tableView {
                return self.makeContextMenu([GlobalStruct.statusesHome[indexPath.row].reblog ?? GlobalStruct.statusesHome[indexPath.row]], indexPath: indexPath)
            } else if tableView == self.tableViewL {
                return self.makeContextMenu([GlobalStruct.statusesLocal[indexPath.row].reblog ?? GlobalStruct.statusesLocal[indexPath.row]], indexPath: indexPath)
            } else {
                return self.makeContextMenu([GlobalStruct.statusesFed[indexPath.row].reblog ?? GlobalStruct.statusesFed[indexPath.row]], indexPath: indexPath)
            }
        })
    }
    
    func makeContextMenu(_ status: [Status], indexPath: IndexPath) -> UIMenu {
        let repl = UIAction(title: "Reply".localized, image: UIImage(systemName: "arrowshape.turn.up.left"), identifier: nil) { action in
            let vc = TootViewController()
            vc.replyStatus = status
            self.show(UINavigationController(rootViewController: vc), sender: self)
        }
        var boos = UIAction(title: "Boost".localized, image: UIImage(systemName: "arrow.2.circlepath"), identifier: nil) { action in
            self.toggleBoostOn(status)
        }
        if status.first?.reblogged ?? false {
            boos = UIAction(title: "Remove Boost".localized, image: UIImage(systemName: "arrow.2.circlepath"), identifier: nil) { action in
                self.toggleBoostOff(status)
            }
        }
        var like = UIAction(title: "Like".localized, image: UIImage(systemName: "heart"), identifier: nil) { action in
            self.toggleLikeOn(status)
        }
        if status.first?.favourited ?? false {
            like = UIAction(title: "Remove Like".localized, image: UIImage(systemName: "heart.slash"), identifier: nil) { action in
                self.toggleLikeOff(status)
            }
        }
        let shar = UIAction(title: "Share".localized, image: UIImage(systemName: "square.and.arrow.up"), identifier: nil) { action in
            self.shareThis(status)
        }
        let tran = UIAction(title: "Translate".localized, image: UIImage(systemName: "globe"), identifier: nil) { action in
            self.translateThis(status)
        }
        let mute = UIAction(title: "Mute".localized, image: UIImage(systemName: "eye.slash"), identifier: nil) { action in
            self.muteThis(status)
        }
        let bloc = UIAction(title: "Block".localized, image: UIImage(systemName: "hand.raised"), identifier: nil) { action in
            self.blockThis(status)
        }
        let dupl = UIAction(title: "Duplicate".localized, image: UIImage(systemName: "doc.on.doc"), identifier: nil) { action in
            self.duplicateThis(status)
        }
        let delete = UIAction(title: "Delete".localized, image: UIImage(systemName: "trash"), identifier: nil) { action in
            
        }
        delete.attributes = .destructive
        
        let repo1 = UIAction(title: "Harassment".localized, image: UIImage(systemName: "flag"), identifier: nil) { action in
            let request = Reports.report(accountID: status.first?.account.id ?? "", statusIDs: [status.first?.id ?? ""], reason: "Harassment")
            GlobalStruct.client.run(request) { (statuses) in
                
            }
        }
        repo1.attributes = .destructive
        let repo2 = UIAction(title: "No Content Warning".localized, image: UIImage(systemName: "flag"), identifier: nil) { action in
            let request = Reports.report(accountID: status.first?.account.id ?? "", statusIDs: [status.first?.id ?? ""], reason: "No Content Warning")
            GlobalStruct.client.run(request) { (statuses) in
                
            }
        }
        repo2.attributes = .destructive
        let repo3 = UIAction(title: "Spam".localized, image: UIImage(systemName: "flag"), identifier: nil) { action in
            let request = Reports.report(accountID: status.first?.account.id ?? "", statusIDs: [status.first?.id ?? ""], reason: "Spam")
            GlobalStruct.client.run(request) { (statuses) in
                
            }
        }
        repo3.attributes = .destructive
        
        let rep = UIMenu(__title: "Report".localized, image: UIImage(systemName: "flag"), identifier: nil, options: [.destructive], children: [repo1, repo2, repo3])
        
        if GlobalStruct.currentUser.id == (status.first?.account.id ?? "") {
            
            let pin1 = UIAction(title: "Pin".localized, image: UIImage(systemName: "pin"), identifier: nil) { action in
                self.pinToot(status.first!)
            }
            let pin2 = UIAction(title: "Unpin".localized, image: UIImage(systemName: "pin"), identifier: nil) { action in
                self.unpinToot(status.first!)
            }
            let del1 = UIAction(title: "Delete and Redraft".localized, image: UIImage(systemName: "pencil.circle"), identifier: nil) { action in
                
            }
            del1.attributes = .destructive
            let del2 = UIAction(title: "Delete".localized, image: UIImage(systemName: "xmark"), identifier: nil) { action in
                
            }
            del2.attributes = .destructive
            
            if GlobalStruct.allPinned.contains(status.first!) {
                let more = UIMenu(__title: "More".localized, image: UIImage(systemName: "ellipsis.circle"), identifier: nil, options: [], children: [pin2, tran, del1, del2])
                return UIMenu(__title: "", image: nil, identifier: nil, children: [repl, boos, like, shar, more])
            } else {
                let more = UIMenu(__title: "More".localized, image: UIImage(systemName: "ellipsis.circle"), identifier: nil, options: [], children: [pin1, tran, del1, del2])
                return UIMenu(__title: "", image: nil, identifier: nil, children: [repl, boos, like, shar, more])
            }
            
        } else {
            let more = UIMenu(__title: "More".localized, image: UIImage(systemName: "ellipsis.circle"), identifier: nil, options: [], children: [tran, mute, bloc, dupl, rep])
            return UIMenu(__title: "", image: nil, identifier: nil, children: [repl, boos, like, shar, more])
        }
    }
    
    func pinToot(_ status: Status) {
        let request = Statuses.pin(id: status.id ?? "")
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = statuses.value {
                DispatchQueue.main.async {
                    
                }
            }
        }
    }
    
    func unpinToot(_ status: Status) {
        let request = Statuses.unpin(id: status.id ?? "")
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = statuses.value {
                DispatchQueue.main.async {
                    
                }
            }
        }
    }
    
    func toggleBoostOn(_ stat: [Status]) {
        let request = Statuses.reblog(id: stat.first?.id ?? "")
        GlobalStruct.client.run(request) { (statuses) in
            
        }
    }
    
    func toggleBoostOff(_ stat: [Status]) {
        let request = Statuses.unreblog(id: stat.first?.id ?? "")
        GlobalStruct.client.run(request) { (statuses) in
            
        }
    }
    
    func toggleLikeOn(_ stat: [Status]) {
        let request = Statuses.favourite(id: stat.first?.id ?? "")
        GlobalStruct.client.run(request) { (statuses) in
            
        }
    }
    
    func toggleLikeOff(_ stat: [Status]) {
        let request = Statuses.unfavourite(id: stat.first?.id ?? "")
        GlobalStruct.client.run(request) { (statuses) in
            
        }
    }
    
    func shareThis(_ stat: [Status]) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let op1 = UIAlertAction(title: " Share Content".localized, style: .default , handler:{ (UIAlertAction) in
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
    
    func muteThis(_ stat: [Status]) {
        
    }
    
    func blockThis(_ stat: [Status]) {
        
    }
    
    func duplicateThis(_ stat: [Status]) {
        
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
        NotificationCenter.default.post(name: Notification.Name(rawValue: "addTapped"), object: self)
    }
    
    func createLoginView(newInstance: Bool = false) {
        self.newInstance = newInstance
        self.loginBG.frame = self.view.frame
        self.loginBG.backgroundColor = GlobalStruct.baseDarkTint
        UIApplication.shared.windows.first?.addSubview(self.loginBG)
        
        self.loginLogo.frame = CGRect(x: self.view.bounds.width/2 - 40, y: self.view.bounds.height/4 - 40, width: 80, height: 80)
        self.loginLogo.image = UIImage(named: "logLogo")
        self.loginLogo.contentMode = .scaleAspectFit
        self.loginLogo.backgroundColor = UIColor.clear
        UIApplication.shared.windows.first?.addSubview(self.loginLogo)
        
        self.loginLabel.frame = CGRect(x: 50, y: self.view.bounds.height/2 - 57.5, width: self.view.bounds.width - 80, height: 35)
        self.loginLabel.text = "Instance name:".localized
        self.loginLabel.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.6)
        self.loginLabel.font = UIFont.systemFont(ofSize: 14)
        UIApplication.shared.windows.first?.addSubview(self.loginLabel)
        
        self.textField.frame = CGRect(x: 40, y: self.view.bounds.height/2 - 22.5, width: self.view.bounds.width - 80, height: 45)
        self.textField.backgroundColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.04)
        self.textField.borderStyle = .none
        self.textField.layer.cornerRadius = 5
        self.textField.textColor = UIColor(named: "baseBlack")
        self.textField.spellCheckingType = .no
        self.textField.returnKeyType = .done
        self.textField.autocorrectionType = .no
        self.textField.autocapitalizationType = .none
        self.textField.keyboardType = .URL
        self.textField.delegate = self
        self.textField.attributedPlaceholder = NSAttributedString(string: "mastodon.social",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        self.textField.accessibilityLabel = "Enter Instance".localized
        UIApplication.shared.windows.first?.addSubview(self.textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let returnedText = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if returnedText == "" || returnedText == " " || returnedText == "  " {} else {
            DispatchQueue.main.async {
                self.textField.resignFirstResponder()
                
                if self.newInstance {
                    GlobalStruct.newInstance = InstanceData()
                    GlobalStruct.client = Client(baseURL: "https://\(returnedText)")
                    let request = Clients.register(
                        clientName: "Mast",
                        redirectURI: "com.shi.Mast2://addNewInstance",
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
                            GlobalStruct.newInstance?.redirect = "com.shi.Mast2://addNewInstance".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
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
                        redirectURI: "com.shi.Mast2://success",
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
                            GlobalStruct.currentInstance.redirect = "com.shi.Mast2://success".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
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
                    
                    let center = UNUserNotificationCenter.current()
                    center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
                    
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

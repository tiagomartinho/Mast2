//
//  ThirdViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 19/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class ThirdViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
    var refreshControl = UIRefreshControl()
    let top1 = UIButton()
    var notificationsDirect: [Conversation] = []
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        #if targetEnvironment(macCatalyst)
        // Table
        let tableHeight = (self.navigationController?.navigationBar.bounds.height ?? 0)
        self.tableView.frame = CGRect(x: 0, y: tableHeight, width: self.view.bounds.width, height: (self.view.bounds.height) - tableHeight)
        #elseif !targetEnvironment(macCatalyst)
        if UIDevice.current.userInterfaceIdiom == .pad && self.isSplitOrSlideOver == false {
            // Table
            let tableHeight = (self.navigationController?.navigationBar.bounds.height ?? 0)
            self.tableView.frame = CGRect(x: 0, y: tableHeight, width: self.view.bounds.width, height: (self.view.bounds.height) - tableHeight)
        } else {
            // Table
            let tableHeight = (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + (self.navigationController?.navigationBar.bounds.height ?? 0)
            self.tableView.frame = CGRect(x: 0, y: tableHeight, width: self.view.bounds.width, height: (self.view.bounds.height) - tableHeight)
        }
        #endif
    }
    
    @objc func scrollTop3() {
        if self.tableView.alpha == 1 && !self.notificationsDirect.isEmpty {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        self.scrollTop3()
        return false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.view.backgroundColor = GlobalStruct.baseDarkTint
        GlobalStruct.currentTab = 3
        
        if self.notificationsDirect.isEmpty {
            self.initialFetches()
        }
        
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
    
    @objc func refreshTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func notifChangeTint() {
        self.tableView.reloadData()
        
        self.tableView.reloadInputViews()
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
    
    @objc func initialTimelineLoads() {
        if self.notificationsDirect.isEmpty {
            self.initialFetches()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = GlobalStruct.baseDarkTint
        self.title = "Messages".localized
//        self.removeTabbarItemsText()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.scrollTop3), name: NSNotification.Name(rawValue: "scrollTop3"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTable), name: NSNotification.Name(rawValue: "refreshTable"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notifChangeTint), name: NSNotification.Name(rawValue: "notifChangeTint"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openTootDetail), name: NSNotification.Name(rawValue: "openTootDetail3"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notifChangeBG), name: NSNotification.Name(rawValue: "notifChangeBG"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.goToIDNoti), name: NSNotification.Name(rawValue: "gotoidnoti3"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.initialTimelineLoads), name: NSNotification.Name(rawValue: "initialTimelineLoads"), object: nil)

        // Add button
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
        let btn2 = UIButton(type: .custom)
        btn2.setImage(UIImage(systemName: "gear", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        btn2.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn2.addTarget(self, action: #selector(self.settingsTapped), for: .touchUpInside)
        btn2.accessibilityLabel = "Settings".localized
        let settingsButton = UIBarButtonItem(customView: btn2)
        if UIDevice.current.userInterfaceIdiom == .pad && self.isSplitOrSlideOver == false {} else {
            self.navigationItem.setLeftBarButton(settingsButton, animated: true)
        }
        
        // Table
        self.tableView.register(DirectCell.self, forCellReuseIdentifier: "DirectCell")
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
        self.tableView.reloadData()
        
        if self.notificationsDirect.isEmpty {
            self.initialFetches()
        }
        
        self.refreshControl.addTarget(self, action: #selector(refresh(_:)), for: UIControl.Event.valueChanged)
        self.tableView.addSubview(self.refreshControl)
        
        // Top buttons
        let startHeight = (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + (self.navigationController?.navigationBar.bounds.height ?? 0)
        let symbolConfig2 = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
        
        self.top1.frame = CGRect(x: Int(self.view.bounds.width) - 48, y: Int(startHeight + 6), width: 38, height: 38)
        self.top1.setImage(UIImage(systemName: "chevron.up.circle.fill", withConfiguration: symbolConfig2)?.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal), for: .normal)
        self.top1.backgroundColor = GlobalStruct.baseDarkTint
        self.top1.layer.cornerRadius = 19
        self.top1.alpha = 0
        self.top1.addTarget(self, action: #selector(self.didTouchTop1), for: .touchUpInside)
        self.top1.accessibilityLabel = "Top".localized
        self.view.addSubview(self.top1)
    }
    
    func initialFetches() {
        let request5 = Timelines.conversations(range: .default)
        GlobalStruct.client.run(request5) { (statuses) in
            if let stat = (statuses.value) {
                DispatchQueue.main.async {
                    if stat.isEmpty {
                        self.createEmptyState()
                    }
                    self.notificationsDirect = stat
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func createEmptyState() {
        let emptyView = UIView()
        emptyView.backgroundColor = .clear
        emptyView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        emptyView.center = self.view.center
        self.view.addSubview(emptyView)
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        let emptyImage = UIImageView()
        emptyImage.image = UIImage(systemName: "wind", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.14), renderingMode: .alwaysOriginal)
        emptyImage.frame = CGRect(x: 30, y: 10, width: 140, height: 140)
        emptyView.addSubview(emptyImage)
        
        let emptyText = UILabel()
        emptyText.text = "Nothing to see here".localized
        emptyText.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.14)
        emptyText.textAlignment = .center
        emptyText.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        emptyText.frame = CGRect(x: 0, y: 150, width: 200, height: 50)
        emptyView.addSubview(emptyText)
    }
    
    @objc func didTouchTop1() {
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut, animations: {
            self.top1.alpha = 0
            self.top1.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        }) { (completed: Bool) in
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut, animations: {
            self.top1.alpha = 0
            self.top1.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        }) { (completed: Bool) in
        }
    }
    
    @objc func refresh(_ sender: AnyObject) {
        let request = Timelines.conversations(range: .since(id: self.notificationsDirect.first?.id ?? "", limit: nil))
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                if stat.isEmpty {
                    DispatchQueue.main.async {
                        self.refreshControl.endRefreshing()
                    }
                } else {
                    DispatchQueue.main.async {
                        let sta = (stat.filter {!self.notificationsDirect.contains($0)}).removeDuplicates()
                        self.refreshControl.endRefreshing()
                        if sta.isEmpty {} else {
                            self.top1.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                            UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut, animations: {
                                self.top1.alpha = 1
                                self.top1.transform = CGAffineTransform(scaleX: 1, y: 1)
                            }) { (completed: Bool) in
                            }
                        }
                        let indexPaths = (0..<sta.count).map {
                            IndexPath(row: $0, section: 0)
                        }
                        self.notificationsDirect = sta + self.notificationsDirect
                        self.tableView.beginUpdates()
                        UIView.setAnimationsEnabled(false)
                        var heights: CGFloat = 0
                        let _ = indexPaths.map {
                            if let cell = self.tableView.cellForRow(at: $0) as? DirectCell {
                                heights += cell.bounds.height
                            }
                        }
                        self.tableView.insertRows(at: indexPaths, with: UITableView.RowAnimation.none)
                        self.tableView.setContentOffset(CGPoint(x: 0, y: heights), animated: false)
                        self.tableView.endUpdates()
                        UIView.setAnimationsEnabled(true)
                    }
                }
            }
        }
    }
    
    @objc func settingsTapped() {
        if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
            let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
            impactFeedbackgenerator.prepare()
            impactFeedbackgenerator.impactOccurred()
        }
        self.show(UINavigationController(rootViewController: SettingsViewController()), sender: self)
    }
    
    @objc func addTapped() {
        if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
            let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
            impactFeedbackgenerator.prepare()
            impactFeedbackgenerator.impactOccurred()
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "addTapped"), object: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notificationsDirect.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DirectCell", for: indexPath) as! DirectCell
        if self.notificationsDirect.isEmpty {
            self.fetchDirect()
        } else {
            cell.configure(self.notificationsDirect[indexPath.row])
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile(_:)))
            cell.profile.tag = indexPath.row
            cell.profile.addGestureRecognizer(tap)
            if indexPath.row == self.notificationsDirect.count - 10 {
                self.fetchMoreNotificationsDirect()
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
            
        }
        cell.backgroundColor = GlobalStruct.baseDarkTint
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = bgColorView
        return cell
    }
    
    func fetchDirect() {
        let request = Timelines.conversations(range: .max(id: self.notificationsDirect.last?.id ?? "", limit: 5000))
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                DispatchQueue.main.async {
                    self.notificationsDirect = self.notificationsDirect + stat
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func fetchMoreNotificationsDirect() {
        let request = Timelines.conversations(range: .max(id: self.notificationsDirect.last?.id ?? "", limit: 5000))
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                if stat.isEmpty {} else {
                    DispatchQueue.main.async {
                        let indexPaths = ((self.notificationsDirect.count)..<(self.notificationsDirect.count + stat.count)).map {
                            IndexPath(row: $0, section: 0)
                        }
                        self.notificationsDirect.append(contentsOf: stat)
                        self.tableView.beginUpdates()
                        self.tableView.insertRows(at: indexPaths, with: UITableView.RowAnimation.none)
                        self.tableView.endUpdates()
                    }
                }
            }
        }
    }
    
    @objc func viewProfile(_ gesture: UIGestureRecognizer) {
        let vc = FifthViewController()
        if GlobalStruct.currentUser.id == (self.notificationsDirect[gesture.view!.tag].lastStatus!.account.id) {
            vc.isYou = true
        } else {
            vc.isYou = false
        }
        vc.pickedCurrentUser = self.notificationsDirect[gesture.view!.tag].lastStatus!.account
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var theUser = ""
        let ac = self.notificationsDirect[indexPath.row].accounts
        for x in ac {
            if x.acct == GlobalStruct.currentUser.acct {
                
            } else {
                theUser = x.username
            }
        }

        let controller = DMViewController()
        controller.mainStatus.append(self.notificationsDirect[indexPath.row].lastStatus!)
        controller.theUser = theUser
        self.navigationController?.pushViewController(controller, animated: true)
        
        let request = Timelines.markRead(id: self.notificationsDirect[indexPath.row].id)
        GlobalStruct.client.run(request) { (statuses) in
            DispatchQueue.main.async {
                GlobalStruct.markedReadIDs.append(self.notificationsDirect[indexPath.row].id)
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: { return nil }, actionProvider: { suggestedActions in
            if self.notificationsDirect[indexPath.row].unread {
                return self.makeContextMenu([self.notificationsDirect[indexPath.row]], indexPath: indexPath)
            } else {
                return nil
            }
        })
    }
    
    func makeContextMenu(_ status: [Conversation], indexPath: IndexPath) -> UIMenu {
        let op1 = UIAction(title: "Mark Read".localized, image: UIImage(systemName: "checkmark"), identifier: nil) { action in
            let request = Timelines.markRead(id: status.first?.id ?? "")
            GlobalStruct.client.run(request) { (statuses) in
                DispatchQueue.main.async {
                    if let cell = self.tableView.cellForRow(at: indexPath) as? DirectCell {
                        GlobalStruct.markedReadIDs.append(status.first?.id ?? "")
                        cell.configure2(false, id: self.notificationsDirect[indexPath.row].id)
                    }
                }
            }
        }
        return UIMenu(__title: "", image: nil, identifier: nil, children: [op1])
    }
    
    func removeTabbarItemsText() {
        if let items = self.tabBarController?.tabBar.items {
            for item in items {
                item.title = ""
            }
        }
    }
}


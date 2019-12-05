//
//  ProfileDirectoryViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 05/12/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class ProfileDirectoryViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
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
    var tableView2 = UITableView()
    var loginBG = UIView()
    var refreshControl = UIRefreshControl()
    let top1 = UIButton()
    let btn2 = UIButton(type: .custom)
    var userId = GlobalStruct.currentUser.id
    var statusesAccounts: [Account] = []
    var statusesAccounts2: [Account] = []
    let segment: UISegmentedControl = UISegmentedControl(items: ["Local".localized, "All".localized])
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let tab0 = (self.navigationController?.navigationBar.bounds.height ?? 0) + 10
        let startHeight = (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + tab0
        self.top1.frame = CGRect(x: Int(self.view.bounds.width) - 48, y: Int(startHeight + 6), width: 38, height: 38)
        
        #if targetEnvironment(macCatalyst)
        self.segment.frame = CGRect(x: 15, y: (self.navigationController?.navigationBar.bounds.height ?? 0) + 5, width: self.view.bounds.width - 30, height: segment.bounds.height)
        
        // Table
        let tableHeight = (self.navigationController?.navigationBar.bounds.height ?? 0) + (self.segment.bounds.height) + 10
        self.tableView.frame = CGRect(x: 0, y: tableHeight, width: self.view.bounds.width, height: (self.view.bounds.height) - tableHeight)
        self.tableView2.frame = CGRect(x: 0, y: tableHeight, width: self.view.bounds.width, height: (self.view.bounds.height) - tableHeight)
        #elseif !targetEnvironment(macCatalyst)
        if UIDevice.current.userInterfaceIdiom == .pad && self.isSplitOrSlideOver == false {
            self.segment.frame = CGRect(x: 15, y: (self.navigationController?.navigationBar.bounds.height ?? 0) + 5, width: self.view.bounds.width - 30, height: segment.bounds.height)
            
            // Table
            let tableHeight = (self.navigationController?.navigationBar.bounds.height ?? 0) + (self.segment.bounds.height) + 10
            self.tableView.frame = CGRect(x: 0, y: tableHeight, width: self.view.bounds.width, height: (self.view.bounds.height) - tableHeight)
            self.tableView2.frame = CGRect(x: 0, y: tableHeight, width: self.view.bounds.width, height: (self.view.bounds.height) - tableHeight)
        } else {
            self.segment.frame = CGRect(x: 15, y: (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + (self.navigationController?.navigationBar.bounds.height ?? 0) + 5, width: self.view.bounds.width - 30, height: segment.bounds.height)
            
            // Table
            let tab0 = (self.navigationController?.navigationBar.bounds.height ?? 0) + (self.segment.bounds.height) + 10
            let tableHeight = (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + tab0
            self.tableView.frame = CGRect(x: 0, y: tableHeight, width: self.view.bounds.width, height: (self.view.bounds.height) - tableHeight)
            self.tableView2.frame = CGRect(x: 0, y: tableHeight, width: self.view.bounds.width, height: (self.view.bounds.height) - tableHeight)
        }
        #endif
    }
    
    @objc func updatePosted() {
        print("toot toot")
    }
    
    @objc func scrollTop1() {
        if self.tableView.alpha == 1 {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        if self.tableView2.alpha == 1 {
            self.tableView2.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        GlobalStruct.currentTab = 999
        
        self.view.backgroundColor = GlobalStruct.baseDarkTint
    }
    
    @objc func refreshTable1() {
        self.tableView.reloadData()
        self.tableView2.reloadData()
    }
    
    @objc func notifChangeTint() {
        self.tableView.reloadData()
        self.tableView.reloadInputViews()
        self.tableView2.reloadData()
        self.tableView2.reloadInputViews()
    }
    
    @objc func notifChangeBG() {
        GlobalStruct.baseDarkTint = (UserDefaults.standard.value(forKey: "sync-startDarkTint") == nil || UserDefaults.standard.value(forKey: "sync-startDarkTint") as? Int == 0) ? UIColor(named: "baseWhite")! : UIColor(named: "baseWhite2")!
        self.view.backgroundColor = GlobalStruct.baseDarkTint
        self.navigationController?.navigationBar.backgroundColor = GlobalStruct.baseDarkTint
        self.navigationController?.navigationBar.barTintColor = GlobalStruct.baseDarkTint
        self.tableView.reloadData()
        self.tableView2.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = GlobalStruct.baseDarkTint
        self.title = "Profile Directory".localized
//        self.removeTabbarItemsText()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePosted), name: NSNotification.Name(rawValue: "updatePosted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.scrollTop1), name: NSNotification.Name(rawValue: "scrollTop1"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTable1), name: NSNotification.Name(rawValue: "refreshTable1"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notifChangeTint), name: NSNotification.Name(rawValue: "notifChangeTint"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notifChangeBG), name: NSNotification.Name(rawValue: "notifChangeBG"), object: nil)
        
        // Segmented control
        self.segment.selectedSegmentIndex = 0
        self.segment.addTarget(self, action: #selector(changeSegment(_:)), for: .valueChanged)
        self.view.addSubview(self.segment)

        // Add button
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(systemName: "plus", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn1.addTarget(self, action: #selector(self.addTapped), for: .touchUpInside)
        btn1.accessibilityLabel = "Create".localized
        let addButton = UIBarButtonItem(customView: btn1)
        if UIDevice.current.userInterfaceIdiom == .pad && self.isSplitOrSlideOver == false {} else {
            self.navigationItem.setRightBarButton(addButton, animated: true)
        }
        
        // Table
        self.tableView.register(FollowersCell.self, forCellReuseIdentifier: "FollowersCell")
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
        
        self.tableView2.register(FollowersCell.self, forCellReuseIdentifier: "FollowersCell2")
        self.tableView2.delegate = self
        self.tableView2.dataSource = self
        self.tableView2.separatorStyle = .singleLine
        self.tableView2.separatorColor = UIColor(named: "baseBlack")?.withAlphaComponent(0.24)
        self.tableView2.backgroundColor = UIColor.clear
        self.tableView2.layer.masksToBounds = true
        self.tableView2.estimatedRowHeight = UITableView.automaticDimension
        self.tableView2.rowHeight = UITableView.automaticDimension
        self.tableView2.showsVerticalScrollIndicator = true
        self.tableView2.tableFooterView = UIView()
        self.tableView2.alpha = 0
        self.view.addSubview(self.tableView2)
        
        self.statusesAccounts = []
        self.initialFetches()
        
        // Top buttons
        let symbolConfig2 = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
        
        self.top1.setImage(UIImage(systemName: "chevron.up.circle.fill", withConfiguration: symbolConfig2)?.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal), for: .normal)
        self.top1.backgroundColor = GlobalStruct.baseDarkTint
        self.top1.layer.cornerRadius = 30
        self.top1.alpha = 0
        self.top1.addTarget(self, action: #selector(self.didTouchTop1), for: .touchUpInside)
        self.top1.accessibilityLabel = "Top".localized
        self.view.addSubview(self.top1)
    }
    
    @objc func changeSegment(_ segment: UISegmentedControl) {
        if segment.selectedSegmentIndex == 0 {
            self.tableView.alpha = 1
            self.tableView2.alpha = 0
            self.tableView.reloadData()
        }
        if segment.selectedSegmentIndex == 1 {
            self.tableView.alpha = 0
            self.tableView2.alpha = 1
            self.tableView2.reloadData()
        }
        UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut, animations: {
            self.top1.alpha = 0
            self.top1.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        }) { (completed: Bool) in
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
    
    func initialFetches() {
        let request = ProfileDirectory.all(local: true, order: "active", range:  .max(id: self.statusesAccounts.last?.id ?? "", limit: nil))
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                DispatchQueue.main.async {
                    if stat.isEmpty {
                        self.createEmptyState()
                    }
                    self.statusesAccounts = self.statusesAccounts + stat
                    self.tableView.reloadData()
                }
            }
        }
        
        let request2 = ProfileDirectory.all(local: false, order: "active", range:  .max(id: self.statusesAccounts2.last?.id ?? "", limit: nil))
        GlobalStruct.client.run(request2) { (statuses) in
            if let stat = (statuses.value) {
                DispatchQueue.main.async {
                    self.statusesAccounts2 = self.statusesAccounts2 + stat
                    self.tableView2.reloadData()
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
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut, animations: {
            self.top1.alpha = 0
            self.top1.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        }) { (completed: Bool) in
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return self.statusesAccounts.count
        } else {
            return self.statusesAccounts2.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FollowersCell", for: indexPath) as! FollowersCell
            if self.statusesAccounts.isEmpty {} else {
                cell.configure(self.statusesAccounts[indexPath.row])
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile(_:)))
                cell.profile.tag = indexPath.row
                cell.profile.addGestureRecognizer(tap)
                if indexPath.row == self.statusesAccounts.count - 10 {
                    self.initialFetches()
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "FollowersCell2", for: indexPath) as! FollowersCell
            if self.statusesAccounts2.isEmpty {} else {
                cell.configure(self.statusesAccounts2[indexPath.row])
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile2(_:)))
                cell.profile.tag = indexPath.row
                cell.profile.addGestureRecognizer(tap)
                if indexPath.row == self.statusesAccounts2.count - 10 {
                    self.initialFetches()
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
    
    @objc func viewProfile(_ gesture: UIGestureRecognizer) {
        let vc = FifthViewController()
        if GlobalStruct.currentUser.id == (self.statusesAccounts[gesture.view!.tag].id) {
            vc.isYou = true
        } else {
            vc.isYou = false
        }
        vc.pickedCurrentUser = self.statusesAccounts[gesture.view!.tag]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func viewProfile2(_ gesture: UIGestureRecognizer) {
        let vc = FifthViewController()
        if GlobalStruct.currentUser.id == (self.statusesAccounts2[gesture.view!.tag].id) {
            vc.isYou = true
        } else {
            vc.isYou = false
        }
        vc.pickedCurrentUser = self.statusesAccounts2[gesture.view!.tag]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableView {
            tableView.deselectRow(at: indexPath, animated: true)
            let vc = FifthViewController()
            vc.isYou = false
            vc.pickedCurrentUser = self.statusesAccounts[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            tableView2.deselectRow(at: indexPath, animated: true)
            let vc = FifthViewController()
            vc.isYou = false
            vc.pickedCurrentUser = self.statusesAccounts2[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? TootCell {
            cell.highlightCell()
        }
    }
    
    @objc func addTapped() {
        if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
            let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
            impactFeedbackgenerator.prepare()
            impactFeedbackgenerator.impactOccurred()
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "addTapped"), object: self)
    }
    
    func removeTabbarItemsText() {
        if let items = self.tabBarController?.tabBar.items {
            for item in items {
                item.title = ""
            }
        }
    }
}


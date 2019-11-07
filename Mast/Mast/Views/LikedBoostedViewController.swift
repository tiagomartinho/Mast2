//
//  LikedBoostedViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 06/11/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class LikedBoostedViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
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
    let segment: UISegmentedControl = UISegmentedControl(items: ["Liked".localized, "Boosted".localized])
    var refreshControl = UIRefreshControl()
    let top1 = UIButton()
    let btn2 = UIButton(type: .custom)
    var userId = GlobalStruct.currentUser.id
    var statusesLiked: [Account] = []
    var statusesBoosted: [Account] = []
    var theStatus: [Status] = []
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
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
    }
    
    @objc func refreshTable1() {
        self.tableView.reloadData()
    }
    
    @objc func notifChangeTint() {
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "baseWhite")
        self.title = "Activity".localized
//        self.removeTabbarItemsText()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePosted), name: NSNotification.Name(rawValue: "updatePosted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.scrollTop1), name: NSNotification.Name(rawValue: "scrollTop1"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTable1), name: NSNotification.Name(rawValue: "refreshTable1"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notifChangeTint), name: NSNotification.Name(rawValue: "notifChangeTint"), object: nil)
        
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
        self.tableView2.reloadData()
        
        self.statusesLiked = []
        self.initialFetches()
        
        // Top buttons
        let tab0 = (self.navigationController?.navigationBar.bounds.height ?? 0) + 10
        let startHeight = (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + tab0
        let symbolConfig2 = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
        
        self.top1.frame = CGRect(x: Int(self.view.bounds.width) - 48, y: Int(startHeight + 6), width: 38, height: 38)
        self.top1.setImage(UIImage(systemName: "chevron.up.circle.fill", withConfiguration: symbolConfig2)?.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal), for: .normal)
        self.top1.backgroundColor = UIColor(named: "baseWhite")
        self.top1.layer.cornerRadius = 19
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
        let request = Statuses.favouritedBy(id: self.theStatus.first!.id, range: .max(id: self.statusesLiked.last?.id ?? "", limit: nil))
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                DispatchQueue.main.async {
                    self.statusesLiked = self.statusesLiked + stat
                    self.tableView.reloadData()
                }
            }
        }
        
        let request2 = Statuses.rebloggedBy(id: self.theStatus.first!.id, range: .max(id: self.statusesBoosted.last?.id ?? "", limit: nil))
        GlobalStruct.client.run(request2) { (statuses) in
            if let stat = (statuses.value) {
                DispatchQueue.main.async {
                    self.statusesBoosted = self.statusesBoosted + stat
                    self.tableView2.reloadData()
                }
            }
        }
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
            return self.statusesLiked.count
        } else {
            return self.statusesBoosted.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FollowersCell", for: indexPath) as! FollowersCell
            if self.statusesLiked.isEmpty {} else {
                cell.configure(self.statusesLiked[indexPath.row])
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile(_:)))
                cell.profile.tag = indexPath.row
                cell.profile.addGestureRecognizer(tap)
                if indexPath.row == self.statusesLiked.count - 10 {
                    self.initialFetches()
                }
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
            
            cell.backgroundColor = UIColor(named: "baseWhite")
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView = bgColorView
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FollowersCell2", for: indexPath) as! FollowersCell
            if self.statusesBoosted.isEmpty {} else {
                cell.configure(self.statusesBoosted[indexPath.row])
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile2(_:)))
                cell.profile.tag = indexPath.row
                cell.profile.addGestureRecognizer(tap)
                if indexPath.row == self.statusesBoosted.count - 10 {
                    self.initialFetches()
                }
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
            
            cell.backgroundColor = UIColor(named: "baseWhite")
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView = bgColorView
            return cell
        }
    }
    
    @objc func viewProfile(_ gesture: UIGestureRecognizer) {
        let vc = FifthViewController()
        vc.isYou = false
        vc.pickedCurrentUser = self.statusesLiked[gesture.view!.tag]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func viewProfile2(_ gesture: UIGestureRecognizer) {
        let vc = FifthViewController()
        vc.isYou = false
        vc.pickedCurrentUser = self.statusesBoosted[gesture.view!.tag]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: { return nil }, actionProvider: { suggestedActions in
            if tableView == self.tableView {
                return self.makeContextMenu([self.statusesLiked[indexPath.row]], indexPath: indexPath)
            } else {
                return self.makeContextMenu2([self.statusesBoosted[indexPath.row]], indexPath: indexPath)
            }
        })
    }
    
    func makeContextMenu(_ status: [Account], indexPath: IndexPath) -> UIMenu {
        let remove = UIAction(title: "Unfollow".localized, image: UIImage(systemName: "xmark"), identifier: nil) { action in
            
        }
        remove.attributes = .destructive
        return UIMenu(__title: "", image: nil, identifier: nil, children: [remove])
    }
    
    func makeContextMenu2(_ status: [Account], indexPath: IndexPath) -> UIMenu {
        let remove = UIAction(title: "Unfollow".localized, image: UIImage(systemName: "xmark"), identifier: nil) { action in
            
        }
        remove.attributes = .destructive
        return UIMenu(__title: "", image: nil, identifier: nil, children: [remove])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = FifthViewController()
        vc.isYou = false
        if tableView == self.tableView {
            vc.pickedCurrentUser = self.statusesLiked[indexPath.row]
        } else {
            vc.pickedCurrentUser = self.statusesBoosted[indexPath.row]
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? TootCell {
            cell.highlightCell()
        }
    }
    
    @objc func addTapped() {
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







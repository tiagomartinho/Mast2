//
//  DetailViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 17/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
    var pickedStatusesHome: [Status] = []
    var allPrevious: [Status] = []
    var allReplies: [Status] = []
    let detailPrev = UIButton()
    var isLiked = false
    var isBoosted = false
    let btn1 = UIButton(type: .custom)
    var fromContextMenu = false
    var isPassedID = false
    var passedID = ""
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let startHeight = (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + (self.navigationController?.navigationBar.bounds.height ?? 0)
        self.detailPrev.frame = CGRect(x: Int(self.view.bounds.width) - 48, y: Int(startHeight + 6), width: 38, height: 38)
        
        // Table
        #if targetEnvironment(macCatalyst)
        let tableHeight = (self.navigationController?.navigationBar.bounds.height ?? 0)
        self.tableView.frame = CGRect(x: 0, y: tableHeight, width: self.view.bounds.width, height: (self.view.bounds.height) - tableHeight)
        #elseif !targetEnvironment(macCatalyst)
        if self.fromContextMenu || UIDevice.current.userInterfaceIdiom == .pad && self.isSplitOrSlideOver == false {
            self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: (self.view.bounds.height))
        } else {
            let tableHeight = (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + (self.navigationController?.navigationBar.bounds.height ?? 0)
            self.tableView.frame = CGRect(x: 0, y: tableHeight, width: self.view.bounds.width, height: (self.view.bounds.height) - tableHeight)
        }
        #endif
    }
    
    @objc func updatePosted() {
        self.fetchReplies()
    }
    
    @objc func notifChangeTint() {
        self.tableView.reloadData()
        
        self.tableView.reloadInputViews()
    }
    
    func fetchFromID() {
        let request = Statuses.status(id: passedID)
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                DispatchQueue.main.async {
                    self.pickedStatusesHome = [stat]
                    if self.pickedStatusesHome.first?.reblogged ?? false {
                        self.isBoosted = true
                    } else {
                        self.isBoosted = false
                    }
                    if self.pickedStatusesHome.first?.favourited ?? false {
                        self.isLiked = true
                    } else {
                        self.isLiked = false
                    }
                    self.fetchReplies()
                }
            }
        }
    }
    
    @objc func notifChangeBG() {
        GlobalStruct.baseDarkTint = (UserDefaults.standard.value(forKey: "sync-startDarkTint") == nil || UserDefaults.standard.value(forKey: "sync-startDarkTint") as? Int == 0) ? UIColor(named: "baseWhite")! : UIColor(named: "baseWhite2")!
        self.view.backgroundColor = GlobalStruct.baseDarkTint
        self.navigationController?.navigationBar.backgroundColor = GlobalStruct.baseDarkTint
        self.navigationController?.navigationBar.barTintColor = GlobalStruct.baseDarkTint
        self.tableView.reloadData()
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        self.didTouchDetailPrev()
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = GlobalStruct.baseDarkTint
        self.title = "Detail".localized
        //        self.removeTabbarItemsText()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePosted), name: NSNotification.Name(rawValue: "updatePosted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notifChangeTint), name: NSNotification.Name(rawValue: "notifChangeTint"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notifChangeBG), name: NSNotification.Name(rawValue: "notifChangeBG"), object: nil)
        
        // Add button
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
        btn1.setImage(UIImage(systemName: "arrowshape.turn.up.left", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn1.addTarget(self, action: #selector(self.replyTapped), for: .touchUpInside)
        btn1.accessibilityLabel = "Reply".localized
        let addButton = UIBarButtonItem(customView: btn1)
        self.navigationItem.setRightBarButton(addButton, animated: true)
        
        // Table
        self.tableView.register(DetailCell.self, forCellReuseIdentifier: "DetailCell")
        self.tableView.register(DetailImageCell.self, forCellReuseIdentifier: "DetailImageCell")
        self.tableView.register(DetailActionsCell.self, forCellReuseIdentifier: "DetailActionsCell")
        self.tableView.register(TootCell.self, forCellReuseIdentifier: "PrevCell")
        self.tableView.register(TootImageCell.self, forCellReuseIdentifier: "PrevImageCell")
        self.tableView.register(TootCell.self, forCellReuseIdentifier: "RepliesCell")
        self.tableView.register(TootImageCell.self, forCellReuseIdentifier: "RepliesImageCell")
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
        
        let symbolConfig2 = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
        self.detailPrev.setImage(UIImage(systemName: "chevron.up.circle.fill", withConfiguration: symbolConfig2)?.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal), for: .normal)
        self.detailPrev.backgroundColor = UIColor.clear
        self.detailPrev.layer.cornerRadius = 19
        self.detailPrev.alpha = 0
        self.detailPrev.addTarget(self, action: #selector(self.didTouchDetailPrev), for: .touchUpInside)
        self.view.addSubview(self.detailPrev)
        
        if self.isPassedID {
            self.fetchFromID()
        } else {
            if self.pickedStatusesHome.first?.reblogged ?? false {
                self.isBoosted = true
            } else {
                self.isBoosted = false
            }
            if self.pickedStatusesHome.first?.favourited ?? false {
                self.isLiked = true
            } else {
                self.isLiked = false
            }
            self.fetchReplies()
        }
    }
    
    func fetchReplies() {
        let request = Statuses.context(id: self.pickedStatusesHome[0].id)
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                DispatchQueue.main.async {
                    self.allPrevious = (stat.ancestors)
                    self.allReplies = (stat.descendants)
                    self.tableView.reloadData()
                    if self.allPrevious.count == 0 {} else {
                        self.detailPrev.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                        UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut, animations: {
                            if self.fromContextMenu {
                                self.detailPrev.alpha = 0
                            } else {
                                self.detailPrev.alpha = 1
                            }
                            self.detailPrev.transform = CGAffineTransform(scaleX: 1, y: 1)
                        }) { (completed: Bool) in
                        }
                        var zCount = 0
                        var zHeights: CGFloat = 0
                        for _ in self.allReplies {
                            zHeights = CGFloat(zHeights) + CGFloat(self.tableView.rectForRow(at: IndexPath(row: zCount, section: 3)).height)
                            zCount += 1
                        }
                        let footerHe0 = self.tableView.bounds.height - self.tableView.rectForRow(at: IndexPath(row: 0, section: 1)).height - self.tableView.rectForRow(at: IndexPath(row: 0, section: 2)).height
                        let footerHe1 = (self.navigationController?.navigationBar.bounds.height ?? 0) + (UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0)
                        #if targetEnvironment(macCatalyst)
                        var footerHe = footerHe0 - zHeights
                        if footerHe < 0 {
                            footerHe = 0
                        }
                        let customViewFooter = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: footerHe))
                        self.tableView.tableFooterView = customViewFooter
                        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: false)
                        #elseif !targetEnvironment(macCatalyst)
                        if UIDevice.current.userInterfaceIdiom == .pad && self.isSplitOrSlideOver == false {
                            var footerHe = footerHe0 - zHeights - (self.navigationController?.navigationBar.bounds.height ?? 0)
                            if footerHe < 0 {
                                footerHe = 0
                            }
                            let customViewFooter = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: footerHe))
                            self.tableView.tableFooterView = customViewFooter
                            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: false)
                        } else {
                            var footerHe = footerHe0 - zHeights - footerHe1
                            if footerHe < 0 {
                                footerHe = 0
                            }
                            let customViewFooter = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: footerHe))
                            self.tableView.tableFooterView = customViewFooter
                            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: false)
                        }
                        #endif
                    }
                }
            }
        }

        let request7 = Accounts.statuses(id: GlobalStruct.currentUser.id, mediaOnly: false, pinnedOnly: true, excludeReplies: false, excludeReblogs: false, range: .default)
        GlobalStruct.client.run(request7) { (statuses) in
            if let stat = statuses.value {
                GlobalStruct.allPinned = stat
            }
        }
    }
    
    @objc func didTouchDetailPrev() {
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut, animations: {
            self.detailPrev.alpha = 0
            self.detailPrev.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        }) { (completed: Bool) in
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut, animations: {
            self.detailPrev.alpha = 0
            self.detailPrev.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        }) { (completed: Bool) in
        }
    }
    
    func removeTabbarItemsText() {
        if let items = self.tabBarController?.tabBar.items {
            for item in items {
                item.title = ""
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.allPrevious.count
        } else if section == 1 {
            return 1
        } else if section == 2 {
            return 1
        } else {
            return self.allReplies.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if self.allPrevious[indexPath.row].mediaAttachments.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PrevCell", for: indexPath) as! TootCell
                if self.allPrevious.isEmpty {} else {
                    cell.configure(self.allPrevious[indexPath.row])
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfilePrevious(_:)))
                    cell.profile.tag = indexPath.row
                    cell.profile.addGestureRecognizer(tap)
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
                let cell = tableView.dequeueReusableCell(withIdentifier: "PrevImageCell", for: indexPath) as! TootImageCell
                if self.allPrevious.isEmpty {} else {
                    cell.configure(self.allPrevious[indexPath.row])
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfilePrevious(_:)))
                    cell.profile.tag = indexPath.row
                    cell.profile.addGestureRecognizer(tap)
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
        } else if indexPath.section == 1 {
            if self.pickedStatusesHome.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! DetailCell
                cell.backgroundColor = GlobalStruct.baseDarkTint
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                return cell
            } else {
                if self.pickedStatusesHome[0].mediaAttachments.isEmpty {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! DetailCell
                    if self.pickedStatusesHome.isEmpty {} else {
                        cell.configure(self.pickedStatusesHome[0])
                        let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile(_:)))
                        cell.profile.tag = indexPath.row
                        cell.profile.addGestureRecognizer(tap)
                        cell.metrics.addTarget(self, action: #selector(self.metricsTapped), for: .touchUpInside)
                        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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
                    let cell = tableView.dequeueReusableCell(withIdentifier: "DetailImageCell", for: indexPath) as! DetailImageCell
                    if self.pickedStatusesHome.isEmpty {} else {
                        cell.configure(self.pickedStatusesHome[0])
                        let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile(_:)))
                        cell.profile.tag = indexPath.row
                        cell.profile.addGestureRecognizer(tap)
                        cell.metrics.addTarget(self, action: #selector(self.metricsTapped), for: .touchUpInside)
                        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailActionsCell", for: indexPath) as! DetailActionsCell
            if self.pickedStatusesHome.isEmpty {} else {
                cell.configure(self.pickedStatusesHome[0])
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }
            cell.button1.addTarget(self, action: #selector(self.replyTapped), for: .touchUpInside)
            cell.button1.accessibilityLabel = "Reply".localized
            cell.button2.addTarget(self, action: #selector(self.boostTapped), for: .touchUpInside)
            cell.button2.accessibilityLabel = "Boost".localized
            cell.button3.addTarget(self, action: #selector(self.likeTapped), for: .touchUpInside)
            cell.button3.accessibilityLabel = "Like".localized
            cell.button4.addTarget(self, action: #selector(self.shareTapped), for: .touchUpInside)
            cell.button4.accessibilityLabel = "Share".localized
            cell.button5.addTarget(self, action: #selector(self.moreTapped), for: .touchUpInside)
            cell.button5.accessibilityLabel = "More".localized
            cell.backgroundColor = UIColor(named: "lighterBaseWhite")
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView = bgColorView
            return cell
        } else {
            if self.allReplies[indexPath.row].mediaAttachments.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RepliesCell", for: indexPath) as! TootCell
//                cell.separatorInset = UIEdgeInsets(top: 0, left: 60000, bottom: 0, right: 0)
                
//                if self.allReplies[indexPath.row].inReplyToID == self.pickedStatusesHome[0].id {
//                    cell.inset(0)
//                } else {
//                    cell.inset(25)
//                }
                
                if self.allReplies.isEmpty {} else {
                    cell.configure(self.allReplies[indexPath.row])
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfileReply(_:)))
                    cell.profile.tag = indexPath.row
                    cell.profile.addGestureRecognizer(tap)
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
                
//                cell.contentView.backgroundColor = GlobalStruct.baseDarkTint
                cell.backgroundColor = GlobalStruct.baseDarkTint
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RepliesImageCell", for: indexPath) as! TootImageCell
//                cell.separatorInset = UIEdgeInsets(top: 0, left: 60000, bottom: 0, right: 0)
                
//                if self.allReplies[indexPath.row].inReplyToID == self.pickedStatusesHome[0].id {
//                    cell.inset(0)
//                } else {
//                    cell.inset(25)
//                }
                
                if self.allReplies.isEmpty {} else {
                    cell.configure(self.allReplies[indexPath.row])
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfileReply(_:)))
                    cell.profile.tag = indexPath.row
                    cell.profile.addGestureRecognizer(tap)
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
                
//                cell.contentView.backgroundColor = GlobalStruct.baseDarkTint
                cell.backgroundColor = GlobalStruct.baseDarkTint
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                return cell
            }
        }
    }
    
    @objc func metricsTapped() {
        if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
            let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
            impactFeedbackgenerator.prepare()
            impactFeedbackgenerator.impactOccurred()
        }
        let vc = LikedBoostedViewController()
        vc.theStatus = self.pickedStatusesHome
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func viewProfilePrevious(_ gesture: UIGestureRecognizer) {
        let vc = FifthViewController()
        if GlobalStruct.currentUser.id == (self.allPrevious[gesture.view!.tag].account.id) {
            vc.isYou = true
        } else {
            vc.isYou = false
        }
        vc.pickedCurrentUser = self.allPrevious[gesture.view!.tag].account
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func viewProfile(_ gesture: UIGestureRecognizer) {
        let vc = FifthViewController()
        if GlobalStruct.currentUser.id == (self.pickedStatusesHome[0].account.id) {
            vc.isYou = true
        } else {
            vc.isYou = false
        }
        vc.pickedCurrentUser = self.pickedStatusesHome[0].account
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func viewProfileReply(_ gesture: UIGestureRecognizer) {
        let vc = FifthViewController()
        if GlobalStruct.currentUser.id == (self.allReplies[gesture.view!.tag].account.id) {
            vc.isYou = true
        } else {
            vc.isYou = false
        }
        vc.pickedCurrentUser = self.allReplies[gesture.view!.tag].account
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func replyTapped() {
        if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
            let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
            impactFeedbackgenerator.prepare()
            impactFeedbackgenerator.impactOccurred()
        }
        #if targetEnvironment(macCatalyst)
        GlobalStruct.macWindow = 2
        GlobalStruct.macReply = self.pickedStatusesHome
        let userActivity = NSUserActivity(activityType: "com.shi.Mast.openComposer2")
        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: userActivity, options: nil) { (e) in
          print("error", e)
        }
        #elseif !targetEnvironment(macCatalyst)
        let vc = TootViewController()
        vc.replyStatus = self.pickedStatusesHome
        self.show(UINavigationController(rootViewController: vc), sender: self)
        #endif
    }
    
    @objc func boostTapped() {
        if self.pickedStatusesHome[0].visibility == .private {
            
        } else {
            if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
                let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
                impactFeedbackgenerator.prepare()
                impactFeedbackgenerator.impactOccurred()
            }
            if self.pickedStatusesHome.first?.reblogged ?? false || self.isBoosted {
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? DetailActionsCell {
                    ViewController().showNotifBanner("Removed Boost".localized, subtitle: "Toot".localized, style: BannerStyle.info)
                    cell.toggleBoostOff(self.pickedStatusesHome[0])
                    self.isBoosted = false
                    self.decreaseBoost()
                }
            } else {
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? DetailActionsCell {
                    ViewController().showNotifBanner("Boosted".localized, subtitle: "Toot".localized, style: BannerStyle.info)
                    cell.toggleBoostOn(self.pickedStatusesHome[0])
                    self.isBoosted = true
                    self.increaseBoost()
                }
            }
        }
    }
    
    @objc func likeTapped() {
        if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
            let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
            impactFeedbackgenerator.prepare()
            impactFeedbackgenerator.impactOccurred()
        }
        if self.pickedStatusesHome.first?.favourited ?? false || self.isLiked {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? DetailActionsCell {
                GlobalStruct.allLikedStatuses = GlobalStruct.allLikedStatuses.filter{$0 != self.pickedStatusesHome.first?.id ?? ""}
                ViewController().showNotifBanner("Removed Like".localized, subtitle: "Toot".localized, style: BannerStyle.info)
                cell.toggleLikeOff(self.pickedStatusesHome[0])
                self.isLiked = false
                self.decreaseLike()
            }
        } else {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? DetailActionsCell {
                GlobalStruct.allLikedStatuses.append(self.pickedStatusesHome.first?.id ?? "")
                ViewController().showNotifBanner("Liked".localized, subtitle: "Toot".localized, style: BannerStyle.info)
                cell.toggleLikeOn(self.pickedStatusesHome[0])
                self.isLiked = true
                self.increaseLike()
            }
        }
    }
    
    func increaseLike() {
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? DetailCell {
            cell.configureLike(self.pickedStatusesHome.first!, increase: true)
        }
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? DetailImageCell {
            cell.configureLike(self.pickedStatusesHome.first!, increase: true)
        }
    }
    
    func decreaseLike() {
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? DetailCell {
            cell.configureLike(self.pickedStatusesHome.first!, increase: false)
        }
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? DetailImageCell {
            cell.configureLike(self.pickedStatusesHome.first!, increase: false)
        }
    }
    
    func increaseBoost() {
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? DetailCell {
            cell.configureBoost(self.pickedStatusesHome.first!, increase: true)
        }
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? DetailImageCell {
            cell.configureBoost(self.pickedStatusesHome.first!, increase: true)
        }
    }
    
    func decreaseBoost() {
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? DetailCell {
            cell.configureBoost(self.pickedStatusesHome.first!, increase: false)
        }
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? DetailImageCell {
            cell.configureBoost(self.pickedStatusesHome.first!, increase: false)
        }
    }
    
    @objc func shareTapped() {
        if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
            let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
            impactFeedbackgenerator.prepare()
            impactFeedbackgenerator.impactOccurred()
        }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let op1 = UIAlertAction(title: " \("Share Content".localized)", style: .default , handler:{ (UIAlertAction) in
            let textToShare = [self.pickedStatusesHome.first?.content.stripHTML() ?? ""]
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
            let textToShare = [self.pickedStatusesHome.first?.url?.absoluteString ?? ""]
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
                presenter.sourceView = cell.button4
                presenter.sourceRect = cell.button4.bounds
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func pinToot() {
        let request = Statuses.pin(id: self.pickedStatusesHome.first?.id ?? "")
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = statuses.value {
                DispatchQueue.main.async {
                    
                }
            }
        }
    }
    
    func unpinToot() {
        let request = Statuses.unpin(id: self.pickedStatusesHome.first?.id ?? "")
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = statuses.value {
                DispatchQueue.main.async {
                    
                }
            }
        }
    }
    
    @objc func moreTapped() {
        if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
            let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
            impactFeedbackgenerator.prepare()
            impactFeedbackgenerator.impactOccurred()
        }
        if GlobalStruct.currentUser.id == (self.pickedStatusesHome.first?.account.id ?? "") {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            if GlobalStruct.allPinned.contains(self.pickedStatusesHome.first!) {
                let op1 = UIAlertAction(title: " \("Unpin".localized)", style: .default , handler:{ (UIAlertAction) in
                    ViewController().showNotifBanner("Unpinned".localized, subtitle: "Toot".localized, style: BannerStyle.info)
                    self.unpinToot()
                })
                op1.setValue(UIImage(systemName: "pin")!, forKey: "image")
                op1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
                alert.addAction(op1)
            } else {
                let op1 = UIAlertAction(title: " \("Pin".localized)", style: .default , handler:{ (UIAlertAction) in
                    ViewController().showNotifBanner("Pinned".localized, subtitle: "Toot".localized, style: BannerStyle.info)
                    self.pinToot()
                })
                op1.setValue(UIImage(systemName: "pin")!, forKey: "image")
                op1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
                alert.addAction(op1)
            }
            let op2 = UIAlertAction(title: " \("Translate".localized)", style: .default , handler:{ (UIAlertAction) in
                self.translateThis()
            })
            op2.setValue(UIImage(systemName: "globe")!, forKey: "image")
            op2.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op2)
            let op6 = UIAlertAction(title: " \("Delete and Redraft".localized)", style: .destructive , handler:{ (UIAlertAction) in
                let request = Statuses.delete(id: self.pickedStatusesHome[0].id)
                GlobalStruct.client.run(request) { (statuses) in
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                        let vc = TootViewController()
                        vc.duplicateStatus = self.pickedStatusesHome
                        self.show(UINavigationController(rootViewController: vc), sender: self)
                    }
                }
            })
            op6.setValue(UIImage(systemName: "pencil.circle")!, forKey: "image")
            op6.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op6)
            let op5 = UIAlertAction(title: " \("Delete".localized)", style: .destructive , handler:{ (UIAlertAction) in
                ViewController().showNotifBanner("Deleted".localized, subtitle: "Toot".localized, style: BannerStyle.info)
                let request = Statuses.delete(id: self.pickedStatusesHome[0].id)
                GlobalStruct.client.run(request) { (statuses) in
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            })
            op5.setValue(UIImage(systemName: "xmark")!, forKey: "image")
            op5.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op5)
            alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
                
            }))
            if let presenter = alert.popoverPresentationController {
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? DetailActionsCell {
                    presenter.sourceView = cell.button5
                    presenter.sourceRect = cell.button5.bounds
                }
            }
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let op1 = UIAlertAction(title: " \("Translate".localized)", style: .default , handler:{ (UIAlertAction) in
                self.translateThis()
            })
            op1.setValue(UIImage(systemName: "globe")!, forKey: "image")
            op1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op1)
            let op2 = UIAlertAction(title: "Mute Conversation".localized, style: .default , handler:{ (UIAlertAction) in
                ViewController().showNotifBanner("Muted".localized, subtitle: "Conversation".localized, style: BannerStyle.info)
                let request = Statuses.mute(id: self.pickedStatusesHome.first?.id ?? "")
                GlobalStruct.client.run(request) { (statuses) in
                    print("muted")
                }
            })
            op2.setValue(UIImage(systemName: "eye.slash")!, forKey: "image")
            op2.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op2)
            let op4 = UIAlertAction(title: " \("Duplicate".localized)", style: .default , handler:{ (UIAlertAction) in
                let vc = TootViewController()
                vc.duplicateStatus = self.pickedStatusesHome
                self.show(UINavigationController(rootViewController: vc), sender: self)
            })
            op4.setValue(UIImage(systemName: "doc.on.doc")!, forKey: "image")
            op4.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op4)
            let op5 = UIAlertAction(title: " \("Report".localized)", style: .destructive , handler:{ (UIAlertAction) in
                self.reportThis()
            })
            op5.setValue(UIImage(systemName: "flag")!, forKey: "image")
            op5.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op5)
            alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
                
            }))
            if let presenter = alert.popoverPresentationController {
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? DetailActionsCell {
                    presenter.sourceView = cell.button5
                    presenter.sourceRect = cell.button5.bounds
                }
            }
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func translateThis() {
        let unreserved = "-._~/?"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        let bodyText = self.pickedStatusesHome.first?.content.stripHTML() ?? ""
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
                        let alert = UIAlertController(title: nil, message: translatedText as? String ?? "Could not translate toot", preferredStyle: .actionSheet)
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
                                presenter.sourceView = cell.button5
                                presenter.sourceRect = cell.button5.bounds
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
    
    func reportThis() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let op1 = UIAlertAction(title: "Harassment".localized, style: .destructive , handler:{ (UIAlertAction) in
            ViewController().showNotifBanner("Reported".localized, subtitle: "Harassment".localized, style: BannerStyle.info)
            let request = Reports.report(accountID: self.pickedStatusesHome.first?.account.id ?? "", statusIDs: [self.pickedStatusesHome.first?.id ?? ""], reason: "Harassment")
            GlobalStruct.client.run(request) { (statuses) in
                
            }
        })
        op1.setValue(UIImage(systemName: "flag")!, forKey: "image")
        op1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op1)
        let op2 = UIAlertAction(title: "No Content Warning".localized, style: .destructive , handler:{ (UIAlertAction) in
            ViewController().showNotifBanner("Reported".localized, subtitle: "No Content Warning".localized, style: BannerStyle.info)
            let request = Reports.report(accountID: self.pickedStatusesHome.first?.account.id ?? "", statusIDs: [self.pickedStatusesHome.first?.id ?? ""], reason: "No Content Warning")
            GlobalStruct.client.run(request) { (statuses) in
                
            }
        })
        op2.setValue(UIImage(systemName: "flag")!, forKey: "image")
        op2.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op2)
        let op3 = UIAlertAction(title: "Spam".localized, style: .destructive , handler:{ (UIAlertAction) in
            ViewController().showNotifBanner("Reported".localized, subtitle: "Spam".localized, style: BannerStyle.info)
            let request = Reports.report(accountID: self.pickedStatusesHome.first?.account.id ?? "", statusIDs: [self.pickedStatusesHome.first?.id ?? ""], reason: "Spam")
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
                presenter.sourceView = cell.button5
                presenter.sourceRect = cell.button5.bounds
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let vc = DetailViewController()
            vc.pickedStatusesHome = [self.allPrevious[indexPath.row]]
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.section == 1 {
            
        } else if indexPath.section == 2 {
            
        } else {
            let vc = DetailViewController()
            vc.pickedStatusesHome = [self.allReplies[indexPath.row]]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            guard let indexPath = configuration.identifier as? IndexPath else { return }
            if indexPath.section == 0 {
                let vc = DetailViewController()
                vc.pickedStatusesHome = [self.allPrevious[indexPath.row]]
                self.navigationController?.pushViewController(vc, animated: true)
            } else if indexPath.section == 3 {
                let vc = DetailViewController()
                vc.pickedStatusesHome = [self.allReplies[indexPath.row]]
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: {
            if indexPath.section == 0 {
                let vc = DetailViewController()
                vc.fromContextMenu = true
                vc.pickedStatusesHome = [self.allPrevious[indexPath.row]]
                return vc
            } else if indexPath.section == 3 {
                let vc = DetailViewController()
                vc.fromContextMenu = true
                vc.pickedStatusesHome = [self.allReplies[indexPath.row]]
                return vc
            } else {
                return nil
            }
        }, actionProvider: { suggestedActions in
            if indexPath.section == 0 {
                return self.makeContextMenu([self.allPrevious[indexPath.row]], indexPath: indexPath)
            } else if indexPath.section == 3 {
                return self.makeContextMenu([self.allReplies[indexPath.row]], indexPath: indexPath)
            } else {
                return nil
            }
        })
    }
    
    func makeContextMenu(_ status: [Status], indexPath: IndexPath) -> UIMenu {
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
            if let cell = self.tableView.cellForRow(at: indexPath) as? TootCell {
                cell.configure(status.first!)
            } else if let cell = self.tableView.cellForRow(at: indexPath) as? TootImageCell {
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
                if let cell = self.tableView.cellForRow(at: indexPath) as? TootCell {
                    cell.configure(status.first!)
                } else if let cell = self.tableView.cellForRow(at: indexPath) as? TootImageCell {
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
    
}

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "baseWhite")
        self.title = "Detail".localized
        //        self.removeTabbarItemsText()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePosted), name: NSNotification.Name(rawValue: "updatePosted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notifChangeTint), name: NSNotification.Name(rawValue: "notifChangeTint"), object: nil)
        
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
        
        let startHeight = (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + (self.navigationController?.navigationBar.bounds.height ?? 0)
        let symbolConfig2 = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
        self.detailPrev.frame = CGRect(x: Int(self.view.bounds.width) - 48, y: Int(startHeight + 6), width: 38, height: 38)
        self.detailPrev.setImage(UIImage(systemName: "chevron.up.circle.fill", withConfiguration: symbolConfig2)?.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal), for: .normal)
        self.detailPrev.backgroundColor = UIColor(named: "baseWhite")
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
                        var footerHe = footerHe0 - zHeights
                        if footerHe < 0 {
                            footerHe = 0
                        }
                        let customViewFooter = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: footerHe))
                        self.tableView.tableFooterView = customViewFooter
                        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: false)
                    }
                }
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
                
                cell.backgroundColor = UIColor(named: "baseWhite")
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
                
                cell.backgroundColor = UIColor(named: "baseWhite")
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                return cell
            }
        } else if indexPath.section == 1 {
            if self.pickedStatusesHome.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! DetailCell
                cell.backgroundColor = UIColor(named: "baseWhite")
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
                    
                    cell.backgroundColor = UIColor(named: "baseWhite")
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
                    
                    cell.backgroundColor = UIColor(named: "baseWhite")
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
                if self.allReplies.isEmpty {} else {
                    cell.configure(self.allReplies[indexPath.row])
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfileReply(_:)))
                    cell.profile.tag = indexPath.row
                    cell.profile.addGestureRecognizer(tap)
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
                
                cell.backgroundColor = UIColor(named: "baseWhite")
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RepliesImageCell", for: indexPath) as! TootImageCell
                if self.allReplies.isEmpty {} else {
                    cell.configure(self.allReplies[indexPath.row])
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfileReply(_:)))
                    cell.profile.tag = indexPath.row
                    cell.profile.addGestureRecognizer(tap)
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
                
                cell.backgroundColor = UIColor(named: "baseWhite")
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                return cell
            }
        }
    }
    
    @objc func metricsTapped() {
        let vc = LikedBoostedViewController()
        vc.theStatus = self.pickedStatusesHome
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func viewProfilePrevious(_ gesture: UIGestureRecognizer) {
        let vc = FifthViewController()
        vc.isYou = false
        vc.pickedCurrentUser = self.allPrevious[gesture.view!.tag].account
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func viewProfile(_ gesture: UIGestureRecognizer) {
        let vc = FifthViewController()
        vc.isYou = false
        vc.pickedCurrentUser = self.pickedStatusesHome[0].account
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func viewProfileReply(_ gesture: UIGestureRecognizer) {
        let vc = FifthViewController()
        vc.isYou = false
        vc.pickedCurrentUser = self.allReplies[gesture.view!.tag].account
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func replyTapped() {
        let vc = TootViewController()
        vc.replyStatus = self.pickedStatusesHome
        self.show(UINavigationController(rootViewController: vc), sender: self)
    }
    
    @objc func boostTapped() {
        if self.pickedStatusesHome.first?.reblogged ?? false || self.isBoosted {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? DetailActionsCell {
                cell.toggleBoostOff(self.pickedStatusesHome[0])
                self.isBoosted = false
            }
        } else {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? DetailActionsCell {
                cell.toggleBoostOn(self.pickedStatusesHome[0])
                self.isBoosted = true
            }
        }
    }
    
    @objc func likeTapped() {
        if self.pickedStatusesHome.first?.favourited ?? false || self.isLiked {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? DetailActionsCell {
                cell.toggleLikeOff(self.pickedStatusesHome[0])
                self.isLiked = false
            }
        } else {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? DetailActionsCell {
                cell.toggleLikeOn(self.pickedStatusesHome[0])
                self.isLiked = true
            }
        }
    }
    
    @objc func shareTapped() {
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
        if GlobalStruct.currentUser.id == (self.pickedStatusesHome.first?.account.id ?? "") {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            if GlobalStruct.allPinned.contains(self.pickedStatusesHome.first!) {
                let op1 = UIAlertAction(title: " \("Unpin".localized)", style: .default , handler:{ (UIAlertAction) in
                    self.unpinToot()
                })
                op1.setValue(UIImage(systemName: "pin")!, forKey: "image")
                op1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
                alert.addAction(op1)
            } else {
                let op1 = UIAlertAction(title: " \("Pin".localized)", style: .default , handler:{ (UIAlertAction) in
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
                
            })
            op6.setValue(UIImage(systemName: "pencil.circle")!, forKey: "image")
            op6.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op6)
            let op5 = UIAlertAction(title: " \("Delete".localized)", style: .destructive , handler:{ (UIAlertAction) in
                
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
            let op2 = UIAlertAction(title: "Mute".localized, style: .default , handler:{ (UIAlertAction) in
                
            })
            op2.setValue(UIImage(systemName: "eye.slash")!, forKey: "image")
            op2.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op2)
            let op3 = UIAlertAction(title: " \("Block".localized)", style: .default , handler:{ (UIAlertAction) in
                let request = Accounts.block(id: self.pickedStatusesHome.first?.account.id ?? "")
                GlobalStruct.client.run(request) { (statuses) in
                    print("blocked")
                }
            })
            op3.setValue(UIImage(systemName: "hand.raised")!, forKey: "image")
            op3.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op3)
            let op4 = UIAlertAction(title: " \("Duplicate".localized)", style: .default , handler:{ (UIAlertAction) in
                
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
            let request = Reports.report(accountID: self.pickedStatusesHome.first?.account.id ?? "", statusIDs: [self.pickedStatusesHome.first?.id ?? ""], reason: "Harassment")
            GlobalStruct.client.run(request) { (statuses) in
                
            }
        })
        op1.setValue(UIImage(systemName: "flag")!, forKey: "image")
        op1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op1)
        let op2 = UIAlertAction(title: "No Content Warning".localized, style: .destructive , handler:{ (UIAlertAction) in
            let request = Reports.report(accountID: self.pickedStatusesHome.first?.account.id ?? "", statusIDs: [self.pickedStatusesHome.first?.id ?? ""], reason: "No Content Warning")
            GlobalStruct.client.run(request) { (statuses) in
                
            }
        })
        op2.setValue(UIImage(systemName: "flag")!, forKey: "image")
        op2.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op2)
        let op3 = UIAlertAction(title: "Spam".localized, style: .destructive , handler:{ (UIAlertAction) in
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
}

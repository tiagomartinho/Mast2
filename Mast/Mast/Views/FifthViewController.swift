//
//  FifthViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 11/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class FifthViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView = UITableView()
    var isYou = true
    var pickedCurrentUser: Account!
    var profileStatusesImages: [Status] = []
    var profileStatuses: [Status] = []
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            // Table
            let tableHeight = (self.navigationController?.navigationBar.bounds.height ?? 0)
            self.tableView.frame = CGRect(x: 0, y: tableHeight, width: self.view.bounds.width, height: (self.view.bounds.height) - tableHeight)
        } else {
            // Table
            let tableHeight = (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + (self.navigationController?.navigationBar.bounds.height ?? 0)
            self.tableView.frame = CGRect(x: 0, y: tableHeight, width: self.view.bounds.width, height: (self.view.bounds.height) - tableHeight)
        }
    }
    
    @objc func updatePosted() {
        print("toot toot")
    }
    
    @objc func scrollTop5() {
        if self.tableView.alpha == 1 {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        GlobalStruct.currentTab = 5
    }
    
    @objc func refreshTable() {
        DispatchQueue.main.async {
            if UIDevice.current.userInterfaceIdiom == .pad {
                self.tableView.reloadData()
                self.fetchMedia()
                self.fetchUserData()
            } else {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "baseWhite")
        self.title = "Profile".localized
//        self.removeTabbarItemsText()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.scrollTop5), name: NSNotification.Name(rawValue: "scrollTop5"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePosted), name: NSNotification.Name(rawValue: "updatePosted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTable), name: NSNotification.Name(rawValue: "refreshTable"), object: nil)

        // Add button
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(systemName: "plus", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn1.addTarget(self, action: #selector(self.addTapped), for: .touchUpInside)
        btn1.accessibilityLabel = "Create".localized
        let addButton = UIBarButtonItem(customView: btn1)
        if UIDevice.current.userInterfaceIdiom == .pad {} else {
            self.navigationItem.setRightBarButton(addButton, animated: true)
        }
        
        let btn2 = UIButton(type: .custom)
        btn2.setImage(UIImage(systemName: "gear", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        btn2.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn2.addTarget(self, action: #selector(self.settingsTapped), for: .touchUpInside)
        btn2.accessibilityLabel = "Settings".localized
        let settingsButton = UIBarButtonItem(customView: btn2)
        if self.isYou {
            if UIDevice.current.userInterfaceIdiom == .pad {} else {
                self.navigationItem.setLeftBarButton(settingsButton, animated: true)
            }
        }
        
        self.fetchMedia()
        self.fetchUserData()
        
        // Table
        self.tableView.register(ProfileCell.self, forCellReuseIdentifier: "ProfileCell")
        self.tableView.register(OtherProfileCell.self, forCellReuseIdentifier: "OtherProfileCell")
        self.tableView.register(ProfileImageCell.self, forCellReuseIdentifier: "ProfileImageCell")
        self.tableView.register(TootCell.self, forCellReuseIdentifier: "TootCell")
        self.tableView.register(TootImageCell.self, forCellReuseIdentifier: "TootImageCell")
        self.tableView.register(TootCell.self, forCellReuseIdentifier: "TootCell2")
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
    }
    
    func fetchMedia() {
        if GlobalStruct.currentUser == nil {} else {
            var theUser = GlobalStruct.currentUser.id
            if self.isYou {
                theUser = GlobalStruct.currentUser.id
            } else {
                theUser = self.pickedCurrentUser.id
            }
            let request = Accounts.statuses(id: theUser, mediaOnly: true, pinnedOnly: nil, excludeReplies: nil, excludeReblogs: true, range: .default)
            GlobalStruct.client.run(request) { (statuses) in
                if let stat = (statuses.value) {
                    DispatchQueue.main.async {
                        self.profileStatusesImages = stat
                        self.tableView.reloadSections(IndexSet([1]), with: .none)
                    }
                }
            }
        }
    }
    
    @objc func settingsTapped() {
        self.show(UINavigationController(rootViewController: SettingsViewController()), sender: self)
    }
    
    @objc func addTapped() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "addTapped"), object: self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return self.profileStatuses.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            if self.profileStatusesImages.count == 0 {
                return 0
            } else {
                return 150
            }
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 && self.profileStatusesImages.count != 0 {
            return 30
        } else if section == 2 {
            return 30
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let vw = UIView()
            vw.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 30)
            vw.backgroundColor = UIColor(named: "baseWhite")
            let title = UILabel()
            title.frame = CGRect(x: (UIApplication.shared.windows.first?.safeAreaInsets.left ?? 0) + 18, y: 0, width: self.view.bounds.width - 36, height: 30)
            title.text = "Recent Media".localized
            title.textColor = UIColor(named: "baseBlack")
            title.font = UIFont.boldSystemFont(ofSize: 16)
            vw.addSubview(title)
            return vw
        } else if section == 2 {
            var theUser = GlobalStruct.currentUser
            if self.isYou {
                theUser = GlobalStruct.currentUser
            } else {
                theUser = self.pickedCurrentUser
            }
            let vw = UIView()
            vw.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 30)
            vw.backgroundColor = UIColor(named: "baseWhite")
            let title = UILabel()
            title.frame = CGRect(x: (UIApplication.shared.windows.first?.safeAreaInsets.left ?? 0) + 18, y: 0, width: self.view.bounds.width - 36, height: 30)
            title.text = "\(theUser?.statusesCount ?? 0) Toots".localized
            title.textColor = UIColor(named: "baseBlack")
            title.font = UIFont.boldSystemFont(ofSize: 16)
            vw.addSubview(title)
            return vw
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if self.isYou {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
                if GlobalStruct.currentUser == nil {} else {
                    cell.configure(GlobalStruct.currentUser)
                    cell.more.addTarget(self, action: #selector(self.moreTapped), for: .touchUpInside)
                }
                cell.backgroundColor = UIColor(named: "baseWhite")
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "OtherProfileCell", for: indexPath) as! OtherProfileCell
                cell.configure(self.pickedCurrentUser)
                cell.more.addTarget(self, action: #selector(self.moreTapped), for: .touchUpInside)
                cell.backgroundColor = UIColor(named: "baseWhite")
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                return cell
            }
        } else if indexPath.section == 1 {
            if self.profileStatusesImages.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileImageCell", for: indexPath) as! ProfileImageCell
                cell.backgroundColor = UIColor(named: "baseWhite")
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor(named: "baseWhite")
                cell.selectedBackgroundView = bgColorView
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileImageCell", for: indexPath) as! ProfileImageCell
                cell.configure(self.profileStatusesImages)
                cell.backgroundColor = UIColor(named: "baseWhite")
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor(named: "baseWhite")
                cell.selectedBackgroundView = bgColorView
                return cell
            }
        } else {
            if self.profileStatuses[indexPath.row].mediaAttachments.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TootCell", for: indexPath) as! TootCell
                if self.profileStatuses.isEmpty {
                    self.fetchUserData()
                } else {
                    cell.configure(self.profileStatuses[indexPath.row])
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile(_:)))
                    cell.profile.tag = indexPath.row
                    cell.profile.addGestureRecognizer(tap)
                    if indexPath.row == self.profileStatuses.count - 10 {
                        self.fetchMoreUserData()
                    }
                }
                cell.backgroundColor = UIColor(named: "baseWhite")
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TootImageCell", for: indexPath) as! TootImageCell
                if self.profileStatuses.isEmpty {
                    self.fetchUserData()
                } else {
                    cell.configure(self.profileStatuses[indexPath.row])
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile(_:)))
                    cell.profile.tag = indexPath.row
                    cell.profile.addGestureRecognizer(tap)
                    if indexPath.row == self.profileStatuses.count - 10 {
                        self.fetchMoreUserData()
                    }
                }
                cell.backgroundColor = UIColor(named: "baseWhite")
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                return cell
            }
        }
    }
    
    @objc func moreTapped() {
        if self.isYou {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let op1 = UIAlertAction(title: "Pinned".localized, style: .default , handler:{ (UIAlertAction) in
                
            })
            op1.setValue(UIImage(systemName: "pin")!, forKey: "image")
            op1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op1)
            let op2 = UIAlertAction(title: "Liked".localized, style: .default , handler:{ (UIAlertAction) in
                
            })
            op2.setValue(UIImage(systemName: "heart")!, forKey: "image")
            op2.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op2)
            let op3 = UIAlertAction(title: "Muted".localized, style: .default , handler:{ (UIAlertAction) in
                
            })
            op3.setValue(UIImage(systemName: "eye.slash")!, forKey: "image")
            op3.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op3)
            let op4 = UIAlertAction(title: "Blocked".localized, style: .default , handler:{ (UIAlertAction) in
                
            })
            op4.setValue(UIImage(systemName: "hand.raised")!, forKey: "image")
            op4.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op4)
            let op5 = UIAlertAction(title: "Scheduled".localized, style: .default , handler:{ (UIAlertAction) in
                
            })
            op5.setValue(UIImage(systemName: "timer")!, forKey: "image")
            op5.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op5)
            let op6 = UIAlertAction(title: "Followers".localized, style: .default , handler:{ (UIAlertAction) in
                
            })
            op6.setValue(UIImage(systemName: "person.and.person")!, forKey: "image")
            op6.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op6)
            let op7 = UIAlertAction(title: "Follow Suggestions".localized, style: .default , handler:{ (UIAlertAction) in
                
            })
            op7.setValue(UIImage(systemName: "person.and.person")!, forKey: "image")
            op7.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op7)
            let op8 = UIAlertAction(title: "Endorsed".localized, style: .default , handler:{ (UIAlertAction) in
                
            })
            op8.setValue(UIImage(systemName: "star")!, forKey: "image")
            op8.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op8)
            let op9 = UIAlertAction(title: "Instance Details".localized, style: .default , handler:{ (UIAlertAction) in
                
            })
            op9.setValue(UIImage(systemName: "eyeglasses")!, forKey: "image")
            op9.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op9)
            let op10 = UIAlertAction(title: "Edit Account".localized, style: .default , handler:{ (UIAlertAction) in
                
            })
            op10.setValue(UIImage(systemName: "pencil.circle")!, forKey: "image")
            op10.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op10)
            let op11 = UIAlertAction(title: "Share Account".localized, style: .default , handler:{ (UIAlertAction) in
                
            })
            op11.setValue(UIImage(systemName: "square.and.arrow.up")!, forKey: "image")
            op11.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op11)
            alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
                
            }))
            if let presenter = alert.popoverPresentationController {
                presenter.sourceView = self.view
                presenter.sourceRect = self.view.bounds
            }
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let op1 = UIAlertAction(title: "Pinned".localized, style: .default , handler:{ (UIAlertAction) in
                
            })
            op1.setValue(UIImage(systemName: "pin")!, forKey: "image")
            op1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op1)
            let op2 = UIAlertAction(title: "Mention".localized, style: .default , handler:{ (UIAlertAction) in
                
            })
            op2.setValue(UIImage(systemName: "arrowshape.turn.up.left")!, forKey: "image")
            op2.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op2)
            let op3 = UIAlertAction(title: "Message".localized, style: .default , handler:{ (UIAlertAction) in
                
            })
            op3.setValue(UIImage(systemName: "paperplane")!, forKey: "image")
            op3.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op3)
            let op4 = UIAlertAction(title: "Followers".localized, style: .default , handler:{ (UIAlertAction) in
                
            })
            op4.setValue(UIImage(systemName: "person.and.person")!, forKey: "image")
            op4.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op4)
            let op5 = UIAlertAction(title: "Follow".localized, style: .default , handler:{ (UIAlertAction) in
                
            })
            op5.setValue(UIImage(systemName: "arrowshape.turn.up.left")!, forKey: "image")
            op5.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op5)
            let op6 = UIAlertAction(title: "Endorse".localized, style: .default , handler:{ (UIAlertAction) in
                
            })
            op6.setValue(UIImage(systemName: "star")!, forKey: "image")
            op6.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op6)
            let op7 = UIAlertAction(title: "Add to List".localized, style: .default , handler:{ (UIAlertAction) in
                
            })
            op7.setValue(UIImage(systemName: "arrowshape.turn.up.left")!, forKey: "image")
            op7.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op7)
            let op8 = UIAlertAction(title: "Mute".localized, style: .default , handler:{ (UIAlertAction) in
                
            })
            op8.setValue(UIImage(systemName: "eye.slash")!, forKey: "image")
            op8.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op8)
            let op9 = UIAlertAction(title: "Block".localized, style: .default , handler:{ (UIAlertAction) in
                
            })
            op9.setValue(UIImage(systemName: "hand.raised")!, forKey: "image")
            op9.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op9)
            let op10 = UIAlertAction(title: "Disable Boosts".localized, style: .default , handler:{ (UIAlertAction) in
                
            })
            op10.setValue(UIImage(systemName: "xmark")!, forKey: "image")
            op10.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op10)
            let op11 = UIAlertAction(title: "Share Account".localized, style: .default , handler:{ (UIAlertAction) in
                
            })
            op11.setValue(UIImage(systemName: "square.and.arrow.up")!, forKey: "image")
            op11.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op11)
            alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
                
            }))
            if let presenter = alert.popoverPresentationController {
                presenter.sourceView = self.view
                presenter.sourceRect = self.view.bounds
            }
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func viewProfile(_ gesture: UIGestureRecognizer) {
        let vc = FifthViewController()
        vc.isYou = false
        vc.pickedCurrentUser = self.profileStatuses[gesture.view!.tag].account
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func fetchUserData() {
        if GlobalStruct.currentUser == nil {} else {
            var theUser = GlobalStruct.currentUser.id
            if self.isYou {
                theUser = GlobalStruct.currentUser.id
            } else {
                theUser = self.pickedCurrentUser.id
            }
            let request = Accounts.statuses(id: theUser, mediaOnly: nil, pinnedOnly: false, excludeReplies: true, excludeReblogs: true, range: .max(id: self.profileStatuses.last?.id ?? "", limit: 5000))
            GlobalStruct.client.run(request) { (statuses) in
                if let stat = (statuses.value) {
                    if stat.isEmpty {} else {
                        DispatchQueue.main.async {
                            self.profileStatuses = stat
                            self.tableView.reloadSections(IndexSet([2]), with: .none)
                        }
                    }
                }
            }
        }
    }

    func fetchMoreUserData() {
        if GlobalStruct.currentUser == nil {} else {
            var theUser = GlobalStruct.currentUser.id
            if self.isYou {
                theUser = GlobalStruct.currentUser.id
            } else {
                theUser = self.pickedCurrentUser.id
            }
            let request = Accounts.statuses(id: theUser, mediaOnly: nil, pinnedOnly: false, excludeReplies: true, excludeReblogs: true, range: .max(id: self.profileStatuses.last?.id ?? "", limit: 5000))
            GlobalStruct.client.run(request) { (statuses) in
                if let stat = (statuses.value) {
                    if stat.isEmpty {} else {
                        DispatchQueue.main.async {
                            let indexPaths = ((self.profileStatuses.count)..<(self.profileStatuses.count + stat.count)).map {
                                IndexPath(row: $0, section: 2)
                            }
                            self.profileStatuses.append(contentsOf: stat)
                            self.tableView.beginUpdates()
                            self.tableView.insertRows(at: indexPaths, with: UITableView.RowAnimation.none)
                            self.tableView.endUpdates()
                        }
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 2 {
            let vc = DetailViewController()
            vc.pickedStatusesHome = [self.profileStatuses[indexPath.row]]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func removeTabbarItemsText() {
        if let items = self.tabBarController?.tabBar.items {
            for item in items {
                item.title = ""
            }
        }
    }
}

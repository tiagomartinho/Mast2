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
        
        // Table
        let tableHeight = (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + (self.navigationController?.navigationBar.bounds.height ?? 0)
        self.tableView.frame = CGRect(x: 0, y: tableHeight, width: self.view.bounds.width, height: (self.view.bounds.height) - tableHeight)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "baseWhite")
        self.title = "Profile".localized
        self.removeTabbarItemsText()

        // Add button
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(systemName: "plus", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn1.addTarget(self, action: #selector(self.addTapped), for: .touchUpInside)
        let addButton = UIBarButtonItem(customView: btn1)
        self.navigationItem.setRightBarButton(addButton, animated: true)
        
        let btn2 = UIButton(type: .custom)
        btn2.setImage(UIImage(systemName: "gear", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        btn2.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn2.addTarget(self, action: #selector(self.settingsTapped), for: .touchUpInside)
        let settingsButton = UIBarButtonItem(customView: btn2)
        if self.isYou {
            self.navigationItem.setLeftBarButton(settingsButton, animated: true)
        }
        
        self.fetchMedia()
        self.fetchUserData()
        
        // Table
        self.tableView.register(ProfileCell.self, forCellReuseIdentifier: "ProfileCell")
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
            title.frame = CGRect(x: 18, y: 0, width: self.view.bounds.width - 36, height: 30)
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
            title.frame = CGRect(x: 18, y: 0, width: self.view.bounds.width - 36, height: 30)
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
            if self.isYou {
                cell.configure(GlobalStruct.currentUser)
            } else {
                cell.configure(self.pickedCurrentUser)
            }
            cell.backgroundColor = UIColor(named: "baseWhite")
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView = bgColorView
            return cell
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
    
    @objc func viewProfile(_ gesture: UIGestureRecognizer) {
        let vc = FifthViewController()
        vc.isYou = false
        vc.pickedCurrentUser = self.profileStatuses[gesture.view!.tag].account
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func fetchUserData() {
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

    func fetchMoreUserData() {
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

//
//  FourthViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 11/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class FourthViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
    var statusesSuggested: [Account] = []
    var txt = ""
    
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
    
    @objc func scrollTop4() {
        if self.tableView.alpha == 1 {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.view.backgroundColor = GlobalStruct.baseDarkTint
        GlobalStruct.currentTab = 4
        
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
            let btn1 = UIButton(type: .custom)
            btn1.setImage(UIImage(systemName: "square.on.square", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
            btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            btn1.addTarget(self, action: #selector(self.newWindow), for: .touchUpInside)
            btn1.accessibilityLabel = "New Window".localized
            let addButton = UIBarButtonItem(customView: btn1)
            self.navigationItem.setRightBarButton(addButton, animated: true)
        } else {
            let btn1 = UIButton(type: .custom)
            btn1.setImage(UIImage(systemName: "magnifyingglass", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
            btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            btn1.addTarget(self, action: #selector(self.searchTapped), for: .touchUpInside)
            btn1.accessibilityLabel = "Search".localized
            let addButton = UIBarButtonItem(customView: btn1)
            self.navigationItem.setRightBarButton(addButton, animated: true)
        }
        #endif
    }
    
    @objc func refreshTable() {
        DispatchQueue.main.async {
            if UIDevice.current.userInterfaceIdiom == .pad && self.isSplitOrSlideOver == false {
                self.tableView.reloadData()
                self.fetchLists()
                self.initialFetches()
            } else {
                self.tableView.reloadData()
            }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = GlobalStruct.baseDarkTint
        self.title = "Explore".localized
//        self.removeTabbarItemsText()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.scrollTop4), name: NSNotification.Name(rawValue: "scrollTop4"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTable), name: NSNotification.Name(rawValue: "refreshTable"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notifChangeTint), name: NSNotification.Name(rawValue: "notifChangeTint"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openTootDetail), name: NSNotification.Name(rawValue: "openTootDetail4"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.fetchLists), name: NSNotification.Name(rawValue: "fetchLists"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.viewSearchDetail), name: NSNotification.Name(rawValue: "viewSearchDetail"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.viewSearchDetail2), name: NSNotification.Name(rawValue: "viewSearchDetail2"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.searchTapped), name: NSNotification.Name(rawValue: "searchTapped"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notifChangeBG), name: NSNotification.Name(rawValue: "notifChangeBG"), object: nil)

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
        
        self.fetchLists()
        self.initialFetches()
        
        // Table
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "addCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "addCell2")
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
        self.tableView.reloadData()
        
        self.refreshControl.addTarget(self, action: #selector(refresh(_:)), for: UIControl.Event.valueChanged)
        self.tableView.addSubview(self.refreshControl)
    }
    
    @objc func refresh(_ sender: AnyObject) {
        let request = Accounts.followSuggestions()
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                if stat.isEmpty {
                    DispatchQueue.main.async {
                        self.refreshControl.endRefreshing()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.refreshControl.endRefreshing()
                        self.statusesSuggested = stat
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func initialFetches() {
        let request = Accounts.followSuggestions()
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                DispatchQueue.main.async {
                    self.statusesSuggested = stat
                    self.tableView.reloadData()
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
    
    @objc func searchTapped() {
        if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
            let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
            impactFeedbackgenerator.prepare()
            impactFeedbackgenerator.impactOccurred()
        }
        let alert = UIAlertController(style: .actionSheet, message: nil)
        alert.addLocalePicker(type: .country) { info in
            // action with selected object
        }
        alert.addAction(title: "Dismiss", style: .cancel)
        alert.show()
    }
    
    @objc func fetchLists() {
        let request = Lists.all()
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                GlobalStruct.allLists = stat
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @objc func viewSearchDetail() {
        let vc = DetailViewController()
        vc.pickedStatusesHome = [GlobalStruct.statusSearched[0].reblog ?? GlobalStruct.statusSearched[0]]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func viewSearchDetail2() {
        let vc = FifthViewController()
        vc.isYou = false
        vc.pickedCurrentUser = GlobalStruct.statusSearched2[0]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return GlobalStruct.allLists.count + 1
        } else if section == 1 {
            return GlobalStruct.allCustomInstances.count + 1
        } else {
            return self.statusesSuggested.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        vw.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 30)
        vw.backgroundColor = GlobalStruct.baseDarkTint
        let title = UILabel()
        title.frame = CGRect(x: (UIApplication.shared.windows.first?.safeAreaInsets.left ?? 0) + 18, y: 0, width: self.view.bounds.width - 36, height: 30)
        if section == 0 {
            title.text = "Your Lists".localized
        } else if section == 1 {
            title.text = "Instance Timelines".localized
        } else {
            title.text = "Follow Suggestions".localized
        }
        title.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.4)
        title.font = UIFont.boldSystemFont(ofSize: 16)
        vw.addSubview(title)
        return vw
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.accessoryType = .none
            } else {
                cell.accessoryType = .disclosureIndicator
            }
        }
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                cell.accessoryType = .none
            } else {
                cell.accessoryType = .disclosureIndicator
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "addCell", for: indexPath)
                cell.backgroundColor = GlobalStruct.baseDarkTint
                let symbolConfig = UIImage.SymbolConfiguration(pointSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
                cell.imageView?.image = UIImage(systemName: "plus.circle", withConfiguration: symbolConfig) ?? UIImage()
                let descriptionSideString = NSMutableAttributedString(string: "Add New List".localized, attributes: [.foregroundColor: UIColor(named: "baseBlack")!.withAlphaComponent(1), .font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)])
                cell.textLabel?.attributedText = descriptionSideString
                cell.accessoryType = .none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "addCell2", for: indexPath)
                if GlobalStruct.allLists.isEmpty {
                    self.fetchLists()
                } else {
                    let descriptionSideString = NSMutableAttributedString(string: GlobalStruct.allLists[indexPath.row - 1].title, attributes: [.foregroundColor: UIColor(named: "baseBlack")!.withAlphaComponent(1), .font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)])
                    cell.textLabel?.attributedText = descriptionSideString
                }
                let symbolConfig = UIImage.SymbolConfiguration(pointSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
                cell.imageView?.image = UIImage(systemName: "list.bullet", withConfiguration: symbolConfig) ?? UIImage()
                cell.backgroundColor = GlobalStruct.baseDarkTint
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                return cell
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "addCell", for: indexPath)
                cell.backgroundColor = GlobalStruct.baseDarkTint
                let symbolConfig = UIImage.SymbolConfiguration(pointSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
                cell.imageView?.image = UIImage(systemName: "plus.circle", withConfiguration: symbolConfig) ?? UIImage()
                let descriptionSideString = NSMutableAttributedString(string: "Add Instance Timeline".localized, attributes: [.foregroundColor: UIColor(named: "baseBlack")!.withAlphaComponent(1), .font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)])
                cell.textLabel?.attributedText = descriptionSideString
                cell.accessoryType = .none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "addCell2", for: indexPath)
                if GlobalStruct.allCustomInstances.isEmpty {
                    
                } else {
                    let descriptionSideString = NSMutableAttributedString(string: GlobalStruct.allCustomInstances[indexPath.row - 1], attributes: [.foregroundColor: UIColor(named: "baseBlack")!.withAlphaComponent(1), .font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)])
                    cell.textLabel?.attributedText = descriptionSideString
                }
                let symbolConfig = UIImage.SymbolConfiguration(pointSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
                cell.imageView?.image = UIImage(systemName: "text.bubble", withConfiguration: symbolConfig) ?? UIImage()
                cell.backgroundColor = GlobalStruct.baseDarkTint
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FollowersCell", for: indexPath) as! FollowersCell
            if self.statusesSuggested.isEmpty {} else {
                cell.configure(self.statusesSuggested[indexPath.row])
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile(_:)))
                cell.profile.tag = indexPath.row
                cell.profile.addGestureRecognizer(tap)
                
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
        if GlobalStruct.currentUser.id == (self.statusesSuggested[gesture.view!.tag].id) {
            vc.isYou = true
        } else {
            vc.isYou = false
        }
        vc.pickedCurrentUser = self.statusesSuggested[gesture.view!.tag]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: { return nil }, actionProvider: { suggestedActions in
            if indexPath.section == 0 {
                if indexPath.row == 0 {
                    return nil
                } else {
                    return self.makeContextMenu([self.statusesSuggested[indexPath.row - 1]], indexPath: indexPath)
                }
            } else if indexPath.section == 1 {
                return self.makeContextMenu2([GlobalStruct.allCustomInstances[indexPath.row - 1]], indexPath: indexPath)
            } else {
                return self.makeContextMenu3([self.statusesSuggested[indexPath.row]], indexPath: indexPath)
            }
        })
    }
    
    func makeContextMenu(_ status: [Account], indexPath: IndexPath) -> UIMenu {
        let op1 = UIAction(title: "View List Members".localized, image: UIImage(systemName: "person.2.square.stack"), identifier: nil) { action in
            let vc = ListMembersViewController()
            vc.listID = GlobalStruct.allLists[indexPath.row - 1].id
            self.navigationController?.pushViewController(vc, animated: true)
        }
        let op2 = UIAction(title: "Edit List Name".localized, image: UIImage(systemName: "pencil.circle"), identifier: nil) { action in

            let alert = UIAlertController(style: .actionSheet, title: nil)
            let config: TextField1.Config = { textField in
                textField.becomeFirstResponder()
                textField.textColor = UIColor(named: "baseBlack")!
                textField.text = GlobalStruct.allLists[indexPath.row - 1].title
                textField.layer.borderWidth = 0
                textField.layer.cornerRadius = 8
                textField.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
                textField.backgroundColor = nil
                textField.keyboardAppearance = .default
                textField.keyboardType = .default
                textField.isSecureTextEntry = false
                textField.returnKeyType = .default
                textField.action { textField in
                    self.txt = textField.text ?? ""
                }
            }
            alert.addOneTextField(configuration: config)
            alert.addAction(title: "Update".localized, style: .default) { action in
            let request = Lists.update(id: GlobalStruct.allLists[indexPath.row - 1].id, title: self.txt)
                GlobalStruct.client.run(request) { (statuses) in
                    if let stat = (statuses.value) {
                        DispatchQueue.main.async {
                            self.fetchLists()
                        }
                    }
                }
            }
            alert.addAction(title: "Dismiss".localized, style: .cancel) { action in
                
            }
            alert.show()
            
        }
        let op3 = UIAction(title: "Delete".localized, image: UIImage(systemName: "xmark"), identifier: nil) { action in
            let request = Lists.delete(id: GlobalStruct.allLists[indexPath.row - 1].id)
            GlobalStruct.client.run(request) { (statuses) in
                DispatchQueue.main.async {
                    GlobalStruct.allLists.remove(at: indexPath.row - 1)
                    self.tableView.reloadData()
                }
            }
        }
        op3.attributes = .destructive
        return UIMenu(__title: "", image: nil, identifier: nil, children: [op1, op2, op3])
    }
    
    func makeContextMenu2(_ status: [String], indexPath: IndexPath) -> UIMenu {
        let remove = UIAction(title: "Remove".localized, image: UIImage(systemName: "xmark"), identifier: nil) { action in
            DispatchQueue.main.async {
                GlobalStruct.allCustomInstances.remove(at: indexPath.row - 1)
                UserDefaults.standard.set(GlobalStruct.allCustomInstances, forKey: "sync-customInstances")
                self.tableView.reloadData()
            }
        }
        remove.attributes = .destructive
        return UIMenu(__title: "", image: nil, identifier: nil, children: [remove])
    }
    
    func makeContextMenu3(_ status: [Account], indexPath: IndexPath) -> UIMenu {
        let remove = UIAction(title: "Follow".localized, image: UIImage(systemName: "arrow.upright.circle"), identifier: nil) { action in
            let request = Accounts.follow(id: status.first?.id ?? "", reblogs: true)
            GlobalStruct.client.run(request) { (statuses) in
                DispatchQueue.main.async {
                    self.statusesSuggested.remove(at: indexPath.row)
                    self.tableView.reloadData()
                }
            }
        }
        return UIMenu(__title: "", image: nil, identifier: nil, children: [remove])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if indexPath.row == 0 {

                let alert = UIAlertController(style: .actionSheet, title: nil)
                let config: TextField1.Config = { textField in
                    textField.becomeFirstResponder()
                    textField.textColor = UIColor(named: "baseBlack")!
                    textField.placeholder = "New list title...".localized
                    textField.layer.borderWidth = 0
                    textField.layer.cornerRadius = 8
                    textField.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
                    textField.backgroundColor = nil
                    textField.keyboardAppearance = .default
                    textField.keyboardType = .default
                    textField.isSecureTextEntry = false
                    textField.returnKeyType = .default
                    textField.action { textField in
                        self.txt = textField.text ?? ""
                    }
                }
                alert.addOneTextField(configuration: config)
                alert.addAction(title: "Create".localized, style: .default) { action in
                    let request = Lists.create(title: self.txt)
                    GlobalStruct.client.run(request) { (statuses) in
                        if let stat = (statuses.value) {
                            DispatchQueue.main.async {
                                self.fetchLists()
                            }
                        }
                    }
                }
                alert.addAction(title: "Dismiss".localized, style: .cancel) { action in
                    
                }
                alert.show()
                
            } else {
                let vc = ListViewController()
                vc.theListID = GlobalStruct.allLists[indexPath.row - 1].id
                vc.theList = GlobalStruct.allLists[indexPath.row - 1].title
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {

                let alert = UIAlertController(style: .actionSheet, title: nil)
                let config: TextField1.Config = { textField in
                    textField.becomeFirstResponder()
                    textField.textColor = UIColor(named: "baseBlack")!
                    textField.placeholder = "Instance timeline...".localized
                    textField.layer.borderWidth = 0
                    textField.layer.cornerRadius = 8
                    textField.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
                    textField.backgroundColor = nil
                    textField.keyboardAppearance = .default
                    textField.keyboardType = .URL
                    textField.autocapitalizationType = .none
                    textField.isSecureTextEntry = false
                    textField.returnKeyType = .default
                    textField.action { textField in
                        self.txt = textField.text ?? ""
                    }
                }
                alert.addOneTextField(configuration: config)
                alert.addAction(title: "Add".localized, style: .default) { action in
                    DispatchQueue.main.async {
                        if GlobalStruct.allCustomInstances.contains(self.txt.lowercased()) {} else {
                            GlobalStruct.allCustomInstances.append(self.txt.lowercased())
                            UserDefaults.standard.set(GlobalStruct.allCustomInstances, forKey: "sync-customInstances")
                            self.tableView.reloadData()
                        }
                        let vc = InstancesViewController()
                        vc.theInstance = self.txt.lowercased()
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                alert.addAction(title: "Dismiss".localized, style: .cancel) { action in
                    
                }
                alert.show()
                
            } else {
                DispatchQueue.main.async {
                    let vc = InstancesViewController()
                    vc.theInstance = GlobalStruct.allCustomInstances[indexPath.row - 1]
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        } else {
            let vc = FifthViewController()
            vc.isYou = false
            vc.pickedCurrentUser = self.statusesSuggested[indexPath.row]
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

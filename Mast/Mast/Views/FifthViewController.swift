//
//  FifthViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 11/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import Photos
import AVKit
import AVFoundation
import MobileCoreServices

class FifthViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, UIImagePickerControllerDelegate, CropViewControllerDelegate, UINavigationControllerDelegate {
    
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
    var isYou = true
    var pickedCurrentUser: Account!
    var profileStatusesImages: [Status] = []
    var profileStatuses: [Status] = []
    var isTapped: Bool = false
    var userID = ""
    var refreshControl = UIRefreshControl()
    var txt = ""
    let photoPickerView = UIImagePickerController()
    var cropViewController = CropViewController(image: UIImage())
    var editType = 0
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
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
        self.view.backgroundColor = GlobalStruct.baseDarkTint
        GlobalStruct.currentTab = 5
        
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
            if UIDevice.current.userInterfaceIdiom == .pad && self.isSplitOrSlideOver == false {
                self.tableView.reloadData()
                self.fetchMedia()
                self.fetchUserData()
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
        self.title = "Profile".localized
//        self.removeTabbarItemsText()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.scrollTop5), name: NSNotification.Name(rawValue: "scrollTop5"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePosted), name: NSNotification.Name(rawValue: "updatePosted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTable), name: NSNotification.Name(rawValue: "refreshTable"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notifChangeTint), name: NSNotification.Name(rawValue: "notifChangeTint"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openTootDetail), name: NSNotification.Name(rawValue: "openTootDetail5"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notifChangeBG), name: NSNotification.Name(rawValue: "notifChangeBG"), object: nil)

        // Add button
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
        let btn2 = UIButton(type: .custom)
        btn2.setImage(UIImage(systemName: "gear", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        btn2.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn2.addTarget(self, action: #selector(self.settingsTapped), for: .touchUpInside)
        btn2.accessibilityLabel = "Settings".localized
        let settingsButton = UIBarButtonItem(customView: btn2)
        if self.isYou {
            if UIDevice.current.userInterfaceIdiom == .pad && self.isSplitOrSlideOver == false {} else {
                self.navigationItem.setLeftBarButton(settingsButton, animated: true)
            }
        }
        
        GlobalStruct.isFollowing = false
        
        if self.isTapped {
            self.initialLoad()
        } else {
            self.fetchMedia()
            self.fetchUserData()
            self.fetchLists()
        }
        
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
        
        self.refreshControl.addTarget(self, action: #selector(refresh(_:)), for: UIControl.Event.valueChanged)
        self.tableView.addSubview(self.refreshControl)
    }
    
    @objc func refresh(_ sender: AnyObject) {
        self.fetchUserDataRefresh()
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
    
    func initialLoad() {
        let request = Accounts.search(query: self.userID)
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                DispatchQueue.main.async {
                    self.pickedCurrentUser = stat.first!
                    self.tableView.reloadSections(IndexSet([0]), with: .none)
                    self.fetchMedia()
                    self.fetchUserData()
                    self.fetchLists()
                }
            }
        }
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
    
    @objc func viewGallery() {
        let vc = GalleryMediaViewController()
        if self.isYou {
            vc.chosenUser = GlobalStruct.currentUser
        } else {
            vc.chosenUser = self.pickedCurrentUser
        }
        vc.profileStatusesImages = self.profileStatusesImages
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let vw = UIView()
            vw.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 30)
            vw.backgroundColor = GlobalStruct.baseDarkTint
            let title = UILabel()
            title.frame = CGRect(x: (UIApplication.shared.windows.first?.safeAreaInsets.left ?? 0) + 18, y: 0, width: self.view.bounds.width - 36, height: 30)
            title.text = "Recent Media".localized
            title.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.4)
            title.font = UIFont.boldSystemFont(ofSize: 16)
            vw.addSubview(title)
            
            let butt = UIButton()
            butt.frame = CGRect(x: self.view.bounds.width - (UIApplication.shared.windows.first?.safeAreaInsets.right ?? 0) - 48, y: 0, width: 30, height: 30)
            butt.setImage(UIImage(systemName: "arrow.right"), for: .normal)
            butt.contentMode = .scaleAspectFit
            butt.addTarget(self, action: #selector(self.viewGallery), for: .touchUpInside)
            butt.accessibilityLabel = "Gallery"
            vw.addSubview(butt)
            
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
            vw.backgroundColor = GlobalStruct.baseDarkTint
            let title = UILabel()
            title.frame = CGRect(x: (UIApplication.shared.windows.first?.safeAreaInsets.left ?? 0) + 18, y: 0, width: self.view.bounds.width - 36, height: 30)

            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            let formattedNumber = numberFormatter.string(from: NSNumber(value: theUser?.statusesCount ?? 0))
            
            if self.isYou {
                title.text = "\(formattedNumber ?? "0") Toots".localized
            } else {
                if theUser?.locked ?? false {
                    title.text = "Locked Account".localized
                } else {
                    title.text = "\(formattedNumber ?? "0") Toots".localized
                }
            }
            title.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.4)
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
                    cell.followers.addTarget(self, action: #selector(self.followersTapped), for: .touchUpInside)
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
                let cell = tableView.dequeueReusableCell(withIdentifier: "OtherProfileCell", for: indexPath) as! OtherProfileCell
                if let x = self.pickedCurrentUser {
                    cell.configure(x)
                }
                cell.more.addTarget(self, action: #selector(self.moreTapped), for: .touchUpInside)
                cell.followers.addTarget(self, action: #selector(self.followersTapped2), for: .touchUpInside)
                cell.following.addTarget(self, action: #selector(self.followTapped), for: .touchUpInside)
                
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
        } else if indexPath.section == 1 {
            if self.profileStatusesImages.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileImageCell", for: indexPath) as! ProfileImageCell
                cell.backgroundColor = GlobalStruct.baseDarkTint
                let bgColorView = UIView()
                bgColorView.backgroundColor = GlobalStruct.baseDarkTint
                cell.selectedBackgroundView = bgColorView
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileImageCell", for: indexPath) as! ProfileImageCell
                cell.configure(self.profileStatusesImages)
                cell.backgroundColor = GlobalStruct.baseDarkTint
                let bgColorView = UIView()
                bgColorView.backgroundColor = GlobalStruct.baseDarkTint
                cell.selectedBackgroundView = bgColorView
                return cell
            }
        } else {
            if self.profileStatuses[indexPath.row].reblog?.mediaAttachments.isEmpty ?? self.profileStatuses[indexPath.row].mediaAttachments.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TootCell", for: indexPath) as! TootCell
                if self.profileStatuses.isEmpty {
                    self.fetchUserData()
                } else {
                    cell.configure(self.profileStatuses[indexPath.row])
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile(_:)))
                    cell.profile.tag = indexPath.row
                    cell.profile.addGestureRecognizer(tap)
                    let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile2(_:)))
                    cell.profile2.tag = indexPath.row
                    cell.profile2.addGestureRecognizer(tap2)
                    if indexPath.row == self.profileStatuses.count - 10 {
                        self.fetchMoreUserData()
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
                if self.profileStatuses.isEmpty {
                    self.fetchUserData()
                } else {
                    cell.configure(self.profileStatuses[indexPath.row])
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile(_:)))
                    cell.profile.tag = indexPath.row
                    cell.profile.addGestureRecognizer(tap)
                    let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile2(_:)))
                    cell.profile2.tag = indexPath.row
                    cell.profile2.addGestureRecognizer(tap2)
                    if indexPath.row == self.profileStatuses.count - 10 {
                        self.fetchMoreUserData()
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
    
    @objc func followTapped() {
        if GlobalStruct.isFollowing {
            let request = Accounts.unfollow(id: self.pickedCurrentUser.id)
            GlobalStruct.client.run(request) { (statuses) in
                DispatchQueue.main.async {
                    if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? OtherProfileCell {
                        GlobalStruct.isFollowing = false
                        cell.configure(self.pickedCurrentUser)
                    }
                }
            }
        } else {
            let request = Accounts.follow(id: self.pickedCurrentUser.id, reblogs: true)
            GlobalStruct.client.run(request) { (statuses) in
                DispatchQueue.main.async {
                    if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? OtherProfileCell {
                        GlobalStruct.isFollowing = true
                        cell.configure(self.pickedCurrentUser)
                    }
                }
            }
        }
    }
    
    @objc func followersTapped() {
        let vc = FollowersViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func followersTapped2() {
        let vc = FollowersViewController()
        vc.userId = self.profileStatuses.first?.account.id ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func textLinks(_ theText: String) {
        let theText = theText
        let alert2 = UIAlertController(title: theText, message: nil, preferredStyle: .actionSheet)
        alert2.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
            
        }))
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.left
        let messageText = NSMutableAttributedString(
            string: theText,
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
            ]
        )
        alert2.setValue(messageText, forKey: "attributedTitle")
        if let presenter = alert2.popoverPresentationController {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileCell {
                presenter.sourceView = cell.more
                presenter.sourceRect = cell.more.bounds
            }
        }
        self.present(alert2, animated: true, completion: nil)
    }
    
    func viewLinks() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for x in GlobalStruct.currentUser.fields {
            let op1 = UIAlertAction(title: x.name, style: .default , handler:{ (UIAlertAction) in
                if let ur = URL(string: x.value.stripHTML()) {
                    if UIApplication.shared.canOpenURL(ur) {
                        GlobalStruct.tappedURL = ur
                        ViewController().openLink()
                    } else {
                        self.textLinks(x.value.stripHTML())
                    }
                }
            })
            if x.verifiedAt == nil {
                op1.setValue(UIImage(systemName: "link")!, forKey: "image")
            } else {
                op1.setValue(UIImage(systemName: "checkmark.seal")!, forKey: "image")
            }
            op1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op1)
        }
        alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
            
        }))
        if let presenter = alert.popoverPresentationController {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileCell {
                presenter.sourceView = cell.more
                presenter.sourceRect = cell.more.bounds
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func viewLinks2() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for x in self.pickedCurrentUser.fields {
            let op1 = UIAlertAction(title: x.name, style: .default , handler:{ (UIAlertAction) in
                if let ur = URL(string: x.value.stripHTML()) {
                    if UIApplication.shared.canOpenURL(ur) {
                        GlobalStruct.tappedURL = ur
                        ViewController().openLink()
                    } else {
                        self.textLinks(x.value.stripHTML())
                    }
                }
            })
            if x.verifiedAt == nil {
                op1.setValue(UIImage(systemName: "link")!, forKey: "image")
            } else {
                op1.setValue(UIImage(systemName: "checkmark.seal")!, forKey: "image")
            }
            op1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op1)
        }
        alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
            
        }))
        if let presenter = alert.popoverPresentationController {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? OtherProfileCell {
                presenter.sourceView = cell.more
                presenter.sourceRect = cell.more.bounds
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func moreTapped() {
        if self.isYou {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let op1 = UIAlertAction(title: " \("Pinned".localized)", style: .default , handler:{ (UIAlertAction) in
                let vc = PinnedViewController()
                vc.userId = GlobalStruct.currentUser.id
                self.navigationController?.pushViewController(vc, animated: true)
            })
            op1.setValue(UIImage(systemName: "pin")!, forKey: "image")
            op1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op1)
            
            if GlobalStruct.currentUser.fields.isEmpty {
                
            } else {
                let op90 = UIAlertAction(title: " \("Links".localized)", style: .default , handler:{ (UIAlertAction) in
                    self.viewLinks()
                })
                op90.setValue(UIImage(systemName: "link")!, forKey: "image")
                op90.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
                alert.addAction(op90)
            }
            
            let op2 = UIAlertAction(title: " \("Liked".localized)", style: .default , handler:{ (UIAlertAction) in
                let vc = LikedViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            })
            op2.setValue(UIImage(systemName: "heart")!, forKey: "image")
            op2.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op2)
            let op6 = UIAlertAction(title: "Friends".localized, style: .default , handler:{ (UIAlertAction) in
                let vc = FollowersViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            })
            op6.setValue(UIImage(systemName: "person.and.person")!, forKey: "image")
            op6.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op6)
            let op3 = UIAlertAction(title: "Muted".localized, style: .default , handler:{ (UIAlertAction) in
                let vc = MutedViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            })
            op3.setValue(UIImage(systemName: "eye.slash")!, forKey: "image")
            op3.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op3)
            let op4 = UIAlertAction(title: " \("Blocked".localized)", style: .default , handler:{ (UIAlertAction) in
                let vc = BlockedViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            })
            op4.setValue(UIImage(systemName: "hand.raised")!, forKey: "image")
            op4.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op4)
            let op7 = UIAlertAction(title: " \("More".localized)", style: .default , handler:{ (UIAlertAction) in
                self.moreOwnProfile()
            })
            op7.setValue(UIImage(systemName: "ellipsis")!, forKey: "image")
            op7.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op7)
            alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
                
            }))
            if let presenter = alert.popoverPresentationController {
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileCell {
                    presenter.sourceView = cell.more
                    presenter.sourceRect = cell.more.bounds
                }
            }
            self.present(alert, animated: true, completion: nil)
        } else {
            var friendText = "Follow".localized
            var friendImage = "person.crop.circle.badge.plus"
            if GlobalStruct.isFollowing {
                friendText = "Unfollow".localized
                friendImage = "person.crop.circle.badge.minus"
            } else {
                friendText = "Follow".localized
                friendImage = "person.crop.circle.badge.plus"
            }
            
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            if self.pickedCurrentUser.fields.isEmpty {
                
            } else {
                let op90 = UIAlertAction(title: " \("Links".localized)", style: .default , handler:{ (UIAlertAction) in
                    self.viewLinks2()
                })
                op90.setValue(UIImage(systemName: "link")!, forKey: "image")
                op90.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
                alert.addAction(op90)
            }
            
            let op2 = UIAlertAction(title: " \("Mention".localized)", style: .default , handler:{ (UIAlertAction) in
                let vc = TootViewController()
                vc.mentionAuthor = self.pickedCurrentUser.acct
                self.show(UINavigationController(rootViewController: vc), sender: self)
            })
            op2.setValue(UIImage(systemName: "arrowshape.turn.up.left")!, forKey: "image")
            op2.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op2)
            let op3 = UIAlertAction(title: " \("Message".localized)", style: .default , handler:{ (UIAlertAction) in
                
            })
            op3.setValue(UIImage(systemName: "paperplane")!, forKey: "image")
            op3.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op3)
            let op5 = UIAlertAction(title: " \(friendText)", style: .default , handler:{ (UIAlertAction) in
                if GlobalStruct.isFollowing {
                    let request = Accounts.unfollow(id: self.pickedCurrentUser.id)
                    GlobalStruct.client.run(request) { (statuses) in
                        DispatchQueue.main.async {
                            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? OtherProfileCell {
                                GlobalStruct.isFollowing = false
                                cell.configure(self.pickedCurrentUser)
                            }
                        }
                    }
                } else {
                    let request = Accounts.follow(id: self.pickedCurrentUser.id, reblogs: true)
                    GlobalStruct.client.run(request) { (statuses) in
                        DispatchQueue.main.async {
                            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? OtherProfileCell {
                                GlobalStruct.isFollowing = true
                                cell.configure(self.pickedCurrentUser)
                            }
                        }
                    }
                }
            })
            op5.setValue(UIImage(systemName: friendImage)!, forKey: "image")
            op5.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op5)
            let op4 = UIAlertAction(title: "Friends".localized, style: .default , handler:{ (UIAlertAction) in
                let vc = FollowersViewController()
                vc.userId = self.profileStatuses.first?.account.id ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
            })
            op4.setValue(UIImage(systemName: "person.and.person")!, forKey: "image")
            op4.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op4)
            let op8 = UIAlertAction(title: "Mute".localized, style: .default , handler:{ (UIAlertAction) in
                let request = Accounts.mute(id: self.profileStatuses.first?.account.id ?? "")
                GlobalStruct.client.run(request) { (statuses) in
                    print("muted")
                }
            })
            op8.setValue(UIImage(systemName: "eye.slash")!, forKey: "image")
            op8.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op8)
            let op9 = UIAlertAction(title: " \("Block".localized)", style: .default , handler:{ (UIAlertAction) in
                let request = Accounts.block(id: self.profileStatuses.first?.account.id ?? "")
                GlobalStruct.client.run(request) { (statuses) in
                    print("blocked")
                }
            })
            op9.setValue(UIImage(systemName: "hand.raised")!, forKey: "image")
            op9.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op9)
            let op7 = UIAlertAction(title: " \("More".localized)", style: .default , handler:{ (UIAlertAction) in
                self.moreOtherProfile()
            })
            op7.setValue(UIImage(systemName: "ellipsis")!, forKey: "image")
            op7.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op7)
            alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
                
            }))
            if let presenter = alert.popoverPresentationController {
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? OtherProfileCell {
                    presenter.sourceView = cell.more
                    presenter.sourceRect = cell.more.bounds
                }
            }
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func instanceDetails() {
        let theTitle = "\(GlobalStruct.currentInstanceDetails.first?.title.stripHTML() ?? "Instance") (\(GlobalStruct.currentInstanceDetails.first?.version ?? "1.0.0"))"
        let theMessage = "\(GlobalStruct.currentInstanceDetails.first?.stats.userCount ?? 0) users\n\(GlobalStruct.currentInstanceDetails.first?.stats.statusCount ?? 0) statuses\n\(GlobalStruct.currentInstanceDetails.first?.stats.domainCount ?? 0) domains\n\n\(GlobalStruct.currentInstanceDetails.first?.description.stripHTML() ?? "")"
        let alert = UIAlertController(title: theTitle, message: theMessage, preferredStyle: .actionSheet)
        let op1 = UIAlertAction(title: " \("Instance Admin Contact".localized)", style: .default , handler:{ (UIAlertAction) in
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.setSubject("Hello from Mast!")
                mail.mailComposeDelegate = self
                mail.setToRecipients([GlobalStruct.currentInstanceDetails.first?.email ?? "shihab.bus@gmail.com"])
                self.present(mail, animated: true)
            }
        })
        op1.setValue(UIImage(systemName: "person.crop.circle")!, forKey: "image")
        op1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op1)
        alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
            
        }))
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.left
        let titleText = NSMutableAttributedString(
            string: theTitle,
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
            ]
        )
        let messageText = NSMutableAttributedString(
            string: theMessage,
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
            ]
        )
        alert.setValue(titleText, forKey: "attributedTitle")
        alert.setValue(messageText, forKey: "attributedMessage")
        if let presenter = alert.popoverPresentationController {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileCell {
                presenter.sourceView = cell.more
                presenter.sourceRect = cell.more.bounds
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func editDisplayName() {
        let alert = UIAlertController(style: .actionSheet, title: nil)
        let config: TextField1.Config = { textField in
            textField.becomeFirstResponder()
            textField.textColor = UIColor(named: "baseBlack")!
            textField.text = GlobalStruct.currentUser.displayName
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
            let request = Accounts.updateCurrentUser(displayName: self.txt, note: nil, avatar: nil, header: nil, locked: nil)
            GlobalStruct.client.run(request) { (statuses) in
                if let stat = (statuses.value) {
                    let request0 = Accounts.currentUser()
                    GlobalStruct.client.run(request0) { (statuses) in
                        if let stat = (statuses.value) {
                            DispatchQueue.main.async {
                                GlobalStruct.currentUser = stat
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
        alert.addAction(title: "Dismiss".localized, style: .cancel) { action in
            
        }
        alert.show()
    }
    
    func editBio() {
        let alert = UIAlertController(style: .actionSheet, title: nil)
        let config: TextField1.Config = { textField in
            textField.becomeFirstResponder()
            textField.textColor = UIColor(named: "baseBlack")!
            textField.text = GlobalStruct.currentUser.note.stripHTML()
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
        let request = Accounts.updateCurrentUser(displayName: nil, note: self.txt, avatar: nil, header: nil, locked: nil)
            GlobalStruct.client.run(request) { (statuses) in
                if let stat = (statuses.value) {
                    let request0 = Accounts.currentUser()
                    GlobalStruct.client.run(request0) { (statuses) in
                        if let stat = (statuses.value) {
                            DispatchQueue.main.async {
                                GlobalStruct.currentUser = stat
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
        alert.addAction(title: "Dismiss".localized, style: .cancel) { action in
            
        }
        alert.show()
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        GlobalStruct.avaFile = "\(GlobalStruct.avaFile)\(Int.random(in: 10...5000000))"
        GlobalStruct.heaFile = "\(GlobalStruct.heaFile)\(Int.random(in: 10...5000000))"
        
        self.cropViewController.dismiss(animated: true, completion: nil)
        if self.editType == 0 {
            GlobalStruct.medType = 1
            let request = Accounts.updateCurrentUser(displayName: nil, note: nil, avatar: .png(image.pngData()), header: nil)
            GlobalStruct.client.run(request) { (statuses) in
                DispatchQueue.main.async {
                    self.updateProfileHere()
                }
            }
        } else {
            GlobalStruct.medType = 2
            let request = Accounts.updateCurrentUser(displayName: nil, note: nil, avatar: nil, header: .png(image.pngData()))
            GlobalStruct.client.run(request) { (statuses) in
                DispatchQueue.main.async {
                    self.updateProfileHere()
                }
            }
        }
    }
    
    @objc func updateProfileHere() {
        let request2 = Accounts.currentUser()
        GlobalStruct.client.run(request2) { (statuses) in
            if let stat = (statuses.value) {
                GlobalStruct.currentUser = stat
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String {
            if mediaType == "public.movie" || mediaType == kUTTypeGIF as String {} else {
                if let photoToAttach = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                    self.cropViewController = CropViewController(image: photoToAttach)
                    self.cropViewController.delegate = self
                    if self.editType == 0 {
                        self.cropViewController.aspectRatioPreset = .presetSquare
                    } else {
                        self.cropViewController.aspectRatioPreset = .preset3x1
                    }
                    self.cropViewController.aspectRatioLockEnabled = true
                    self.cropViewController.resetAspectRatioEnabled = false
                    self.cropViewController.aspectRatioPickerButtonHidden = true
                    self.cropViewController.title = "Resize Avatar"
                    self.getTopMostViewController()?.present(self.cropViewController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func getTopMostViewController() -> UIViewController? {
        var topMostViewController = UIApplication.shared.keyWindow?.rootViewController
        while let presentedViewController = topMostViewController?.presentedViewController {
            topMostViewController = presentedViewController
        }
        return topMostViewController
    }
    
    func editAccount() {
        let isItLocked = GlobalStruct.currentUser.locked
        var isItGoingToLock = false
        var lockText = "Lock Account".localized
        if isItLocked {
            lockText = "Unlock Account".localized
            isItGoingToLock = false
        } else {
            lockText = "Lock Account".localized
            isItGoingToLock = true
        }
        
        self.photoPickerView.navigationBar.isTranslucent = false
        self.photoPickerView.navigationBar.prefersLargeTitles = false
        self.photoPickerView.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(named: "baseBlack")!]
        self.photoPickerView.navigationBar.backgroundColor = GlobalStruct.baseDarkTint
        self.photoPickerView.navigationBar.barTintColor = GlobalStruct.baseDarkTint
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let op7 = UIAlertAction(title: "\("Edit Avatar".localized)", style: .default , handler:{ (UIAlertAction) in
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                if response {
                    self.editType = 0
                    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                        DispatchQueue.main.async {
                            self.photoPickerView.delegate = self
                            self.photoPickerView.sourceType = .photoLibrary
                            self.photoPickerView.mediaTypes = [kUTTypeImage as String]
                            self.getTopMostViewController()?.present(self.photoPickerView, animated: true, completion: nil)
                        }
                    }
                }
            }
        })
        op7.setValue(UIImage(systemName: "person.crop.circle")!, forKey: "image")
        op7.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op7)
        let op9 = UIAlertAction(title: "Edit Header".localized, style: .default , handler:{ (UIAlertAction) in
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                if response {
                    self.editType = 1
                    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                        DispatchQueue.main.async {
                            self.photoPickerView.delegate = self
                            self.photoPickerView.sourceType = .photoLibrary
                            self.photoPickerView.mediaTypes = [kUTTypeImage as String]
                            self.getTopMostViewController()?.present(self.photoPickerView, animated: true, completion: nil)
                        }
                    }
                }
            }
        })
        op9.setValue(UIImage(systemName: "person.crop.circle")!, forKey: "image")
        op9.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op9)
        let op10 = UIAlertAction(title: "\("Edit Display Name".localized)", style: .default , handler:{ (UIAlertAction) in
            self.editDisplayName()
        })
        op10.setValue(UIImage(systemName: "pencil.circle")!, forKey: "image")
        op10.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op10)
        let op11 = UIAlertAction(title: "\("Edit Bio".localized)", style: .default , handler:{ (UIAlertAction) in
            self.editBio()
        })
        op11.setValue(UIImage(systemName: "pencil.circle")!, forKey: "image")
        op11.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op11)
        let op12 = UIAlertAction(title: "\("Edit Links".localized)", style: .default , handler:{ (UIAlertAction) in
            
        })
        op12.setValue(UIImage(systemName: "link.circle")!, forKey: "image")
        op12.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
//        alert.addAction(op12)
        let op13 = UIAlertAction(title: lockText, style: .default , handler:{ (UIAlertAction) in

            let request = Accounts.updateCurrentUser(displayName: nil, note: nil, avatar: nil, header: nil, locked: isItGoingToLock)
            GlobalStruct.client.run(request) { (statuses) in
                if let stat = (statuses.value) {
                    let request0 = Accounts.currentUser()
                    GlobalStruct.client.run(request0) { (statuses) in
                        if let stat = (statuses.value) {
                            DispatchQueue.main.async {
                                GlobalStruct.currentUser = stat
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
            
        })
        op13.setValue(UIImage(systemName: "lock.circle")!, forKey: "image")
        op13.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op13)
        alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
            
        }))
        if let presenter = alert.popoverPresentationController {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileCell {
                presenter.sourceView = cell.more
                presenter.sourceRect = cell.more.bounds
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func moreOwnProfile() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let op5 = UIAlertAction(title: " \("Follow Requests".localized)", style: .default , handler:{ (UIAlertAction) in
            let vc = FollowRequestsViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        })
        op5.setValue(UIImage(systemName: "person.crop.circle.badge.plus")!, forKey: "image")
        op5.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op5)
        let op6 = UIAlertAction(title: " \("Scheduled".localized)", style: .default , handler:{ (UIAlertAction) in
            let vc = ScheduledViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        })
        op6.setValue(UIImage(systemName: "clock")!, forKey: "image")
        op6.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op6)
        let op7 = UIAlertAction(title: " \("Endorsed".localized)", style: .default , handler:{ (UIAlertAction) in
            let vc = EndorsedViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        })
        op7.setValue(UIImage(systemName: "star")!, forKey: "image")
        op7.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op7)
        let op9 = UIAlertAction(title: "Instance Details".localized, style: .default , handler:{ (UIAlertAction) in
            self.instanceDetails()
        })
        op9.setValue(UIImage(systemName: "eyeglasses")!, forKey: "image")
        op9.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op9)
        let op10 = UIAlertAction(title: " \("Edit Account".localized)", style: .default , handler:{ (UIAlertAction) in
            self.editAccount()
        })
        op10.setValue(UIImage(systemName: "pencil.circle")!, forKey: "image")
        op10.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op10)
        let op11 = UIAlertAction(title: " \("Share Account".localized)", style: .default , handler:{ (UIAlertAction) in
            let textToShare = [GlobalStruct.currentUser.url]
            let activityViewController = UIActivityViewController(activityItems: textToShare,  applicationActivities: nil)
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileCell {
                activityViewController.popoverPresentationController?.sourceView = cell.more
                activityViewController.popoverPresentationController?.sourceRect = cell.more.bounds
            }
            self.present(activityViewController, animated: true, completion: nil)
        })
        op11.setValue(UIImage(systemName: "square.and.arrow.up")!, forKey: "image")
        op11.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op11)
        alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
            
        }))
        if let presenter = alert.popoverPresentationController {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileCell {
                presenter.sourceView = cell.more
                presenter.sourceRect = cell.more.bounds
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func moreOtherProfile() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let op1 = UIAlertAction(title: " \("Pinned".localized)", style: .default , handler:{ (UIAlertAction) in
            let vc = PinnedViewController()
            vc.userId = self.profileStatuses.first?.account.id ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        })
        op1.setValue(UIImage(systemName: "pin")!, forKey: "image")
        op1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op1)
        let op6 = UIAlertAction(title: "Endorse".localized, style: .default , handler:{ (UIAlertAction) in
            let request = Accounts.endorse(id: self.profileStatuses.first?.account.id ?? "")
            GlobalStruct.client.run(request) { (statuses) in
                print("endorsed")
            }
        })
        op6.setValue(UIImage(systemName: "star")!, forKey: "image")
        op6.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op6)
        let op7 = UIAlertAction(title: "Add to List".localized, style: .default , handler:{ (UIAlertAction) in
            self.addToList()
        })
        op7.setValue(UIImage(systemName: "text.badge.plus")!, forKey: "image")
        op7.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op7)
//        let op10 = UIAlertAction(title: "Disable Boosts".localized, style: .default , handler:{ (UIAlertAction) in
//
//        })
//        op10.setValue(UIImage(systemName: "xmark")!, forKey: "image")
//        op10.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
//        alert.addAction(op10)
        let op11 = UIAlertAction(title: "Share Account".localized, style: .default , handler:{ (UIAlertAction) in
            let textToShare = [self.pickedCurrentUser.url]
            let activityViewController = UIActivityViewController(activityItems: textToShare,  applicationActivities: nil)
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? OtherProfileCell {
                activityViewController.popoverPresentationController?.sourceView = cell.more
                activityViewController.popoverPresentationController?.sourceRect = cell.more.bounds
            }
            self.present(activityViewController, animated: true, completion: nil)
        })
        op11.setValue(UIImage(systemName: "square.and.arrow.up")!, forKey: "image")
        op11.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op11)
        alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
            
        }))
        if let presenter = alert.popoverPresentationController {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? OtherProfileCell {
                presenter.sourceView = cell.more
                presenter.sourceRect = cell.more.bounds
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func addToList() {
        if GlobalStruct.allLists.count == 0 {

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
            alert.addAction(title: "Create and Add".localized, style: .default) { action in
                let request = Lists.create(title: self.txt)
                GlobalStruct.client.run(request) { (statuses) in
                    if let stat = (statuses.value) {
                        let request2 = Lists.add(accountIDs: [self.pickedCurrentUser.id], toList: stat.id)
                        GlobalStruct.client.run(request2) { (statuses) in
                            if let stat = (statuses.value) {
                                DispatchQueue.main.async {
                                    
                                }
                            }
                        }
                    }
                }
            }
            alert.addAction(title: "Dismiss".localized, style: .cancel) { action in
                
            }
            alert.show()
            
        } else {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            let op11 = UIAlertAction(title: "Create and Add".localized, style: .default , handler:{ (UIAlertAction) in
                
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
                alert.addAction(title: "Create and Add".localized, style: .default) { action in
                    let request = Lists.create(title: self.txt)
                    GlobalStruct.client.run(request) { (statuses) in
                        if let stat = (statuses.value) {
                            let request2 = Lists.add(accountIDs: [self.pickedCurrentUser.id], toList: stat.id)
                            GlobalStruct.client.run(request2) { (statuses) in
                                if let stat = (statuses.value) {
                                    DispatchQueue.main.async {
                                        
                                    }
                                }
                            }
                        }
                    }
                }
                alert.addAction(title: "Dismiss".localized, style: .cancel) { action in
                    
                }
                alert.show()
                
            })
            op11.setValue(UIImage(systemName: "plus")!, forKey: "image")
            op11.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(op11)
            for x in GlobalStruct.allLists {
                let op1 = UIAlertAction(title: x.title, style: .default , handler:{ (UIAlertAction) in
                    let request = Lists.add(accountIDs: [self.pickedCurrentUser.id], toList: x.id)
                    GlobalStruct.client.run(request) { (statuses) in
                        if let stat = (statuses.value) {
                            DispatchQueue.main.async {
                                
                            }
                        }
                    }
                })
                op1.setValue(UIImage(systemName: "list.bullet")!, forKey: "image")
                op1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
                alert.addAction(op1)
            }
            
            alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
                
            }))
            if let presenter = alert.popoverPresentationController {
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? OtherProfileCell {
                    presenter.sourceView = cell.more
                    presenter.sourceRect = cell.more.bounds
                }
            }
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func viewProfile(_ gesture: UIGestureRecognizer) {
        let vc = FifthViewController()
        if GlobalStruct.currentUser.id == (self.profileStatuses[gesture.view!.tag].account.id) {
            vc.isYou = true
        } else {
            vc.isYou = false
        }
        vc.pickedCurrentUser = self.profileStatuses[gesture.view!.tag].reblog?.account ?? self.profileStatuses[gesture.view!.tag].account
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func viewProfile2(_ gesture: UIGestureRecognizer) {
        let vc = FifthViewController()
        if GlobalStruct.currentUser.id == (self.profileStatuses[gesture.view!.tag].account.id) {
            vc.isYou = true
        } else {
            vc.isYou = false
        }
        vc.pickedCurrentUser = self.profileStatuses[gesture.view!.tag].account
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func fetchUserDataRefresh() {
        if GlobalStruct.currentUser == nil {} else {
            var theUser = GlobalStruct.currentUser.id
            if self.isYou {
                theUser = GlobalStruct.currentUser.id
            } else {
                theUser = self.pickedCurrentUser.id
            }
            let request = Accounts.statuses(id: theUser, mediaOnly: nil, pinnedOnly: false, excludeReplies: false, excludeReblogs: false, range: .since(id: self.profileStatuses.first?.id ?? "", limit: 5000))
            GlobalStruct.client.run(request) { (statuses) in
                if let stat = (statuses.value) {
                    if stat.isEmpty {
                        DispatchQueue.main.async {
                            self.refreshControl.endRefreshing()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.refreshControl.endRefreshing()
                            let indexPaths = (0..<stat.count).map {
                                IndexPath(row: $0, section: 2)
                            }
                            self.profileStatuses = stat + self.profileStatuses
                            self.tableView.beginUpdates()
                            UIView.setAnimationsEnabled(false)
                            var heights: CGFloat = 0
                            let _ = indexPaths.map {
                                if let cell = self.tableView.cellForRow(at: $0) as? TootCell {
                                    heights += cell.bounds.height
                                }
                            }
                            self.tableView.insertRows(at: indexPaths, with: UITableView.RowAnimation.none)
//                            self.tableView.setContentOffset(CGPoint(x: 0, y: heights), animated: false)
                            self.tableView.endUpdates()
                            UIView.setAnimationsEnabled(true)
                        }
                    }
                }
            }
        }
    }

    func fetchUserData() {
        if GlobalStruct.currentUser == nil {} else {
            var theUser = GlobalStruct.currentUser.id
            if self.isYou {
                theUser = GlobalStruct.currentUser.id
            } else {
                theUser = self.pickedCurrentUser.id
            }
            let request = Accounts.statuses(id: theUser, mediaOnly: nil, pinnedOnly: false, excludeReplies: false, excludeReblogs: false, range: .max(id: self.profileStatuses.last?.id ?? "", limit: 5000))
            GlobalStruct.client.run(request) { (statuses) in
                if let stat = (statuses.value) {
                    if stat.isEmpty {
                        DispatchQueue.main.async {
                            self.refreshControl.endRefreshing()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.refreshControl.endRefreshing()
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
            let request = Accounts.statuses(id: theUser, mediaOnly: nil, pinnedOnly: false, excludeReplies: false, excludeReblogs: false, range: .max(id: self.profileStatuses.last?.id ?? "", limit: 5000))
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
            vc.pickedStatusesHome = [self.profileStatuses[indexPath.row].reblog ?? self.profileStatuses[indexPath.row]]
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

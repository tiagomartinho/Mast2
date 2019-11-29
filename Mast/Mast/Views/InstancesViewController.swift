//
//  InstancesViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 10/11/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class InstancesViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
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
    var loginBG = UIView()
    var refreshControl = UIRefreshControl()
    let top1 = UIButton()
    let btn2 = UIButton(type: .custom)
    var userId = GlobalStruct.currentUser.id
    var statusesInstance: [Status] = []
    var theInstanceID: String = ""
    var theInstance: String = ""
    let btn1 = UIButton(type: .custom)
    var txt = ""
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Table
        let tableHeight = (self.navigationController?.navigationBar.bounds.height ?? 0)
        self.tableView.frame = CGRect(x: 0, y: tableHeight, width: self.view.bounds.width, height: (self.view.bounds.height) - tableHeight)
    }
    
    @objc func updatePosted() {
        print("toot toot")
    }
    
    @objc func scrollTop1() {
        if self.tableView.alpha == 1 {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        GlobalStruct.currentTab = 999
        
        self.view.backgroundColor = GlobalStruct.baseDarkTint
    }
    
    @objc func refreshTable1() {
        self.tableView.reloadData()
    }
    
    @objc func notifChangeTint() {
        self.tableView.reloadData()
        
        self.tableView.reloadInputViews()
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
        self.title = self.theInstance
//        self.removeTabbarItemsText()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePosted), name: NSNotification.Name(rawValue: "updatePosted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.scrollTop1), name: NSNotification.Name(rawValue: "scrollTop1"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTable1), name: NSNotification.Name(rawValue: "refreshTable1"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notifChangeTint), name: NSNotification.Name(rawValue: "notifChangeTint"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openTootDetail), name: NSNotification.Name(rawValue: "openTootDetail6"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notifChangeBG), name: NSNotification.Name(rawValue: "notifChangeBG"), object: nil)
        
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
        
        self.initialFetches()
        
        // Top buttons
        let tab0 = (self.navigationController?.navigationBar.bounds.height ?? 0) + 10
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
    }
    
    func initialFetches() {
        let request = Timelines.public(local: true, range: .max(id: "", limit: nil))
        let testClient = Client(
            baseURL: "https://\(self.theInstance)",
            accessToken: GlobalStruct.currentInstance.accessToken
        )
        testClient.run(request) { (statuses) in
            if let stat = (statuses.value) {
                DispatchQueue.main.async {
                    if stat.isEmpty {
                        self.createEmptyState()
                    }
                    self.theInstanceID = stat.first?.id ?? ""
                    self.statusesInstance = stat
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
    
    @objc func refresh(_ sender: AnyObject) {
        let request = Lists.accounts(id: self.theInstanceID)
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                if stat.isEmpty {
                    DispatchQueue.main.async {
                        self.refreshControl.endRefreshing()
                    }
                } else {
                    DispatchQueue.main.async {
                        
                        stat.map({
                            let request1 = Accounts.statuses(id: $0.id, range: .since(id: self.statusesInstance.first?.id ?? "", limit: nil))
                            GlobalStruct.client.run(request1) { (statuses) in
                                if let stat = (statuses.value) {
                                    if stat != nil {
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
                                            self.statusesInstance = stat + self.statusesInstance
                                            self.statusesInstance = self.statusesInstance.sorted(by: { $0.createdAt > $1.createdAt })
                                            self.tableView.beginUpdates()
                                            UIView.setAnimationsEnabled(false)
                                            var heights: CGFloat = 0
                                            let _ = indexPaths.map {
                                                if let cell = self.tableView.cellForRow(at: $0) as? TootCell {
                                                    heights += cell.bounds.height
                                                }
                                                if let cell = self.tableView.cellForRow(at: $0) as? TootImageCell {
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
                        })
                        
                    }
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
        return self.statusesInstance.count
    }
    
    func fetchMore() {
        let request = Timelines.public(local: true, range: .max(id: self.statusesInstance.last?.id ?? "", limit: nil))
        let testClient = Client(
            baseURL: "https://\(self.txt)",
            accessToken: GlobalStruct.currentInstance.accessToken
        )
        testClient.run(request) { (statuses) in
            if let stat = (statuses.value) {
                DispatchQueue.main.async {
                    let indexPaths = ((self.statusesInstance.count)..<(self.statusesInstance.count + stat.count)).map {
                        IndexPath(row: $0, section: 0)
                    }
                    self.statusesInstance.append(contentsOf: stat)
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: indexPaths, with: UITableView.RowAnimation.none)
                    self.tableView.endUpdates()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.statusesInstance[indexPath.row].reblog?.mediaAttachments.isEmpty ?? self.statusesInstance[indexPath.row].mediaAttachments.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TootCell", for: indexPath) as! TootCell
            if self.statusesInstance.isEmpty {} else {
                cell.configure(self.statusesInstance[indexPath.row])
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile(_:)))
                cell.profile.tag = indexPath.row
                cell.profile.addGestureRecognizer(tap)
                let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile2(_:)))
                cell.profile2.tag = indexPath.row
                cell.profile2.addGestureRecognizer(tap2)
                if indexPath.row == self.statusesInstance.count - 10 {
                    self.fetchMore()
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "TootImageCell", for: indexPath) as! TootImageCell
            if self.statusesInstance.isEmpty {} else {
                cell.configure(self.statusesInstance[indexPath.row])
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile(_:)))
                cell.profile.tag = indexPath.row
                cell.profile.addGestureRecognizer(tap)
                let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile2(_:)))
                cell.profile2.tag = indexPath.row
                cell.profile2.addGestureRecognizer(tap2)
                if indexPath.row == self.statusesInstance.count - 10 {
                    self.fetchMore()
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
        if GlobalStruct.currentUser.id == (self.statusesInstance[gesture.view!.tag].account.id) {
            vc.isYou = true
        } else {
            vc.isYou = false
        }
        vc.pickedCurrentUser = self.statusesInstance[gesture.view!.tag].reblog?.account ?? self.statusesInstance[gesture.view!.tag].account
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func viewProfile2(_ gesture: UIGestureRecognizer) {
        let vc = FifthViewController()
        if GlobalStruct.currentUser.id == (self.statusesInstance[gesture.view!.tag].account.id) {
            vc.isYou = true
        } else {
            vc.isYou = false
        }
        vc.pickedCurrentUser = self.statusesInstance[gesture.view!.tag].account
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = DetailViewController()
        vc.pickedStatusesHome = [self.statusesInstance[indexPath.row].reblog ?? self.statusesInstance[indexPath.row]]
        self.navigationController?.pushViewController(vc, animated: true)
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
            let vc = DetailViewController()
            vc.pickedStatusesHome = [self.statusesInstance[indexPath.row].reblog ?? self.statusesInstance[indexPath.row]]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: {
            let vc = DetailViewController()
            vc.fromContextMenu = true
            vc.pickedStatusesHome = [self.statusesInstance[indexPath.row].reblog ?? self.statusesInstance[indexPath.row]]
            return vc
        }, actionProvider: { suggestedActions in
            return self.makeContextMenu([self.statusesInstance[indexPath.row].reblog ?? self.statusesInstance[indexPath.row]], indexPath: indexPath)
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
        let more = UIMenu(__title: "More".localized, image: UIImage(systemName: "ellipsis.circle"), identifier: nil, options: [], children: [tran, mute, dupl, rep])
        return UIMenu(__title: "", image: nil, identifier: nil, children: [repl, shar, more])
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
            ViewController().showNotifBanner("Reported".localized, subtitle: "Harassment".localized, style: BannerStyle.info)
            let request = Reports.report(accountID: stat.first?.account.id ?? "", statusIDs: [stat.first?.id ?? ""], reason: "Harassment")
            GlobalStruct.client.run(request) { (statuses) in
                
            }
        })
        op1.setValue(UIImage(systemName: "flag")!, forKey: "image")
        op1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op1)
        let op2 = UIAlertAction(title: "No Content Warning".localized, style: .destructive , handler:{ (UIAlertAction) in
            ViewController().showNotifBanner("Reported".localized, subtitle: "No Content Warning".localized, style: BannerStyle.info)
            let request = Reports.report(accountID: stat.first?.account.id ?? "", statusIDs: [stat.first?.id ?? ""], reason: "No Content Warning")
            GlobalStruct.client.run(request) { (statuses) in
                
            }
        })
        op2.setValue(UIImage(systemName: "flag")!, forKey: "image")
        op2.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op2)
        let op3 = UIAlertAction(title: "Spam".localized, style: .destructive , handler:{ (UIAlertAction) in
            ViewController().showNotifBanner("Reported".localized, subtitle: "Spam".localized, style: BannerStyle.info)
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
    
    func removeTabbarItemsText() {
        if let items = self.tabBarController?.tabBar.items {
            for item in items {
                item.title = ""
            }
        }
    }
}



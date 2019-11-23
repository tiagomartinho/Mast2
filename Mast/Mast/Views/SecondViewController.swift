//
//  SecondViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 11/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class SecondViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
    let segment: UISegmentedControl = UISegmentedControl(items: ["Activity".localized, "Metrics".localized])
    var refreshControl = UIRefreshControl()
    let top1 = UIButton()
    let btn2 = UIButton(type: .custom)
    var notTypes: [NotificationType] = []
    
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
    
    @objc func scrollTop2() {
        if self.tableView.alpha == 1 {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut, animations: {
                self.top1.alpha = 0
                self.top1.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            }) { (completed: Bool) in
            }
        }
        if self.tableView2.alpha == 1 {
            self.tableView2.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.view.backgroundColor = GlobalStruct.baseDarkTint
        GlobalStruct.currentTab = 2
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = GlobalStruct.baseDarkTint
        self.title = "Notifications".localized
//        self.removeTabbarItemsText()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.scrollTop2), name: NSNotification.Name(rawValue: "scrollTop2"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTable), name: NSNotification.Name(rawValue: "refreshTable"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notifChangeTint), name: NSNotification.Name(rawValue: "notifChangeTint"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openTootDetail), name: NSNotification.Name(rawValue: "openTootDetail2"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notifChangeBG), name: NSNotification.Name(rawValue: "notifChangeBG"), object: nil)
        
        // Segmented control
        self.segment.selectedSegmentIndex = 0
        self.segment.addTarget(self, action: #selector(changeSegment(_:)), for: .valueChanged)
        self.view.addSubview(self.segment)

        // Add button
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
        btn2.setImage(UIImage(systemName: "line.horizontal.3.decrease", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        btn2.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn2.addTarget(self, action: #selector(self.sortTapped), for: .touchUpInside)
        btn2.accessibilityLabel = "Sort".localized
        let settingsButton = UIBarButtonItem(customView: btn2)
        self.navigationItem.setLeftBarButton(settingsButton, animated: true)
        
        if GlobalStruct.notifications.isEmpty {
            let request4 = Notifications.all(range: .default, typesToExclude: self.notTypes)
            GlobalStruct.client.run(request4) { (statuses) in
                if let stat = (statuses.value) {
                    DispatchQueue.main.async {
                        GlobalStruct.notifications = stat
                        #if targetEnvironment(macCatalyst)
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshTable"), object: nil)
                        #elseif !targetEnvironment(macCatalyst)
                        if UIDevice.current.userInterfaceIdiom == .pad && self.isSplitOrSlideOver == false {
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshTable"), object: nil)
                        }
                        #endif
                    }
                }
            }
        }
        
        // Table
        self.tableView.register(NotificationsCell.self, forCellReuseIdentifier: "NotificationsCell")
        self.tableView.register(NotificationsImageCell.self, forCellReuseIdentifier: "NotificationsImageCell")
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
        
        self.tableView2 = UITableView(frame: .zero, style: .insetGrouped)
        self.tableView2.register(GraphCell.self, forCellReuseIdentifier: "GraphCell")
        self.tableView2.register(GraphCell2.self, forCellReuseIdentifier: "GraphCell2")
        self.tableView2.delegate = self
        self.tableView2.dataSource = self
        self.tableView2.separatorStyle = .singleLine
        self.tableView2.separatorColor = UIColor(named: "baseBlack")?.withAlphaComponent(0.24)
        self.tableView2.backgroundColor = UIColor(named: "lighterBaseWhite")!
        self.tableView2.layer.masksToBounds = true
        self.tableView2.estimatedRowHeight = UITableView.automaticDimension
        self.tableView2.rowHeight = UITableView.automaticDimension
        self.tableView2.showsVerticalScrollIndicator = true
        self.tableView2.tableFooterView = UIView()
        self.tableView2.alpha = 0
        self.view.addSubview(self.tableView2)
        self.tableView2.reloadData()
        
        // Top buttons
        let tab0 = (self.navigationController?.navigationBar.bounds.height ?? 0) + (self.segment.bounds.height) + 10
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
        let request = Notifications.all(range: .since(id: GlobalStruct.notifications.first?.id ?? "", limit: nil), typesToExclude: self.notTypes)
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                if stat.isEmpty {
                    DispatchQueue.main.async {
                        self.refreshControl.endRefreshing()
                    }
                } else {
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
                        GlobalStruct.notifications = stat + GlobalStruct.notifications
                        self.tableView.beginUpdates()
                        UIView.setAnimationsEnabled(false)
                        var heights: CGFloat = 0
                        let _ = indexPaths.map {
                            if let cell = self.tableView.cellForRow(at: $0) as? NotificationsCell {
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableView2 {
            return 230
        } else {
            return UITableView.automaticDimension
        }
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
    
    func filterNots() {
        DispatchQueue.main.async {
            GlobalStruct.notifications = []
            self.tableView.reloadData()
        }
        let request = Notifications.all(range: .default, typesToExclude: self.notTypes)
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                DispatchQueue.main.async {
                    GlobalStruct.notifications = stat
                    if stat.count > 0 {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    @objc func sortTapped() {
        if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
            let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
            impactFeedbackgenerator.prepare()
            impactFeedbackgenerator.impactOccurred()
        }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let op1 = UIAlertAction(title: "All".localized, style: .default , handler:{ (UIAlertAction) in
            self.notTypes = []
            self.filterNots()
            UserDefaults.standard.set(0, forKey: "filterNotifications")
        })
        if UserDefaults.standard.value(forKey: "filterNotifications") as? Int == 0 {
            op1.setValue(UIImage(systemName: "checkmark.circle.fill")!, forKey: "image")
        } else {
            op1.setValue(UIImage(systemName: "circle")!, forKey: "image")
        }
        op1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op1)
        let op2 = UIAlertAction(title: "Mentions".localized, style: .default , handler:{ (UIAlertAction) in
            self.notTypes = GlobalStruct.notTypes.filter {$0 != NotificationType.mention}
            self.filterNots()
            UserDefaults.standard.set(1, forKey: "filterNotifications")
        })
        if UserDefaults.standard.value(forKey: "filterNotifications") as? Int == 1 {
            op2.setValue(UIImage(systemName: "checkmark.circle.fill")!, forKey: "image")
        } else {
            op2.setValue(UIImage(systemName: "circle")!, forKey: "image")
        }
        op2.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op2)
        let op3 = UIAlertAction(title: "Likes".localized, style: .default , handler:{ (UIAlertAction) in
            self.notTypes = GlobalStruct.notTypes.filter {$0 != NotificationType.favourite}
            self.filterNots()
            UserDefaults.standard.set(2, forKey: "filterNotifications")
        })
        if UserDefaults.standard.value(forKey: "filterNotifications") as? Int == 2 {
            op3.setValue(UIImage(systemName: "checkmark.circle.fill")!, forKey: "image")
        } else {
            op3.setValue(UIImage(systemName: "circle")!, forKey: "image")
        }
        op3.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op3)
        let op4 = UIAlertAction(title: "Boosts".localized, style: .default , handler:{ (UIAlertAction) in
            self.notTypes = GlobalStruct.notTypes.filter {$0 != NotificationType.reblog}
            self.filterNots()
            UserDefaults.standard.set(3, forKey: "filterNotifications")
        })
        if UserDefaults.standard.value(forKey: "filterNotifications") as? Int == 3 {
            op4.setValue(UIImage(systemName: "checkmark.circle.fill")!, forKey: "image")
        } else {
            op4.setValue(UIImage(systemName: "circle")!, forKey: "image")
        }
        op4.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op4)
        let op5 = UIAlertAction(title: "Messages".localized, style: .default , handler:{ (UIAlertAction) in
        self.notTypes = GlobalStruct.notTypes.filter {$0 != NotificationType.direct}
        self.filterNots()
            UserDefaults.standard.set(4, forKey: "filterNotifications")
        })
        if UserDefaults.standard.value(forKey: "filterNotifications") as? Int == 4 {
            op5.setValue(UIImage(systemName: "checkmark.circle.fill")!, forKey: "image")
        } else {
            op5.setValue(UIImage(systemName: "circle")!, forKey: "image")
        }
        op5.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op5)
        let op6 = UIAlertAction(title: "Follows".localized, style: .default , handler:{ (UIAlertAction) in
            self.notTypes = GlobalStruct.notTypes.filter {$0 != NotificationType.follow}
            self.filterNots()
            UserDefaults.standard.set(5, forKey: "filterNotifications")
        })
        if UserDefaults.standard.value(forKey: "filterNotifications") as? Int == 5 {
            op6.setValue(UIImage(systemName: "checkmark.circle.fill")!, forKey: "image")
        } else {
            op6.setValue(UIImage(systemName: "circle")!, forKey: "image")
        }
        op6.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op6)
        let op7 = UIAlertAction(title: "Polls".localized, style: .default , handler:{ (UIAlertAction) in
            self.notTypes = GlobalStruct.notTypes.filter {$0 != NotificationType.poll}
            self.filterNots()
            UserDefaults.standard.set(6, forKey: "filterNotifications")
        })
        if UserDefaults.standard.value(forKey: "filterNotifications") as? Int == 6 {
            op7.setValue(UIImage(systemName: "checkmark.circle.fill")!, forKey: "image")
        } else {
            op7.setValue(UIImage(systemName: "circle")!, forKey: "image")
        }
        op7.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op7)
        alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
            
        }))
        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = self.btn2
            presenter.sourceRect = self.btn2.bounds
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func addTapped() {
        if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
            let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
            impactFeedbackgenerator.prepare()
            impactFeedbackgenerator.impactOccurred()
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "addTapped"), object: self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.tableView {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return GlobalStruct.notifications.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            if GlobalStruct.notifications.isEmpty {
                self.fetchNotifications()
                let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationsCell", for: indexPath) as! NotificationsCell
                cell.backgroundColor = GlobalStruct.baseDarkTint
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                return cell
            } else {
                if GlobalStruct.notifications[indexPath.row].status?.mediaAttachments.isEmpty ?? true {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationsCell", for: indexPath) as! NotificationsCell
                    cell.configure(GlobalStruct.notifications[indexPath.row])
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile(_:)))
                    cell.profile.tag = indexPath.row
                    cell.profile.addGestureRecognizer(tap)
                    let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile2(_:)))
                    cell.profile2.tag = indexPath.row
                    cell.profile2.addGestureRecognizer(tap2)
                    if indexPath.row == GlobalStruct.notifications.count - 10 {
                        self.fetchMoreNotifications()
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
                    let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationsImageCell", for: indexPath) as! NotificationsImageCell
                    cell.configure(GlobalStruct.notifications[indexPath.row])
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile(_:)))
                    cell.profile.tag = indexPath.row
                    cell.profile.addGestureRecognizer(tap)
                    let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile2(_:)))
                    cell.profile2.tag = indexPath.row
                    cell.profile2.addGestureRecognizer(tap2)
                    if indexPath.row == GlobalStruct.notifications.count - 10 {
                        self.fetchMoreNotifications()
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
        } else {
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "GraphCell", for: indexPath) as! GraphCell
                if GlobalStruct.notifications.isEmpty {} else {
                    cell.configure()
                }
                cell.backgroundColor = GlobalStruct.baseDarkTint
                let bgColorView = UIView()
                bgColorView.backgroundColor = .clear
                cell.selectedBackgroundView = bgColorView
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "GraphCell2", for: indexPath) as! GraphCell2
                if GlobalStruct.notifications.isEmpty {} else {
                    cell.configure()
                }
                cell.backgroundColor = GlobalStruct.baseDarkTint
                let bgColorView = UIView()
                bgColorView.backgroundColor = .clear
                cell.selectedBackgroundView = bgColorView
                return cell
            }
        }
    }
    
    func fetchNotifications() {
        let request = Notifications.all(range: .default)
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                DispatchQueue.main.async {
                    GlobalStruct.notifications = stat
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func fetchMoreNotifications() {
        let request = Notifications.all(range: .max(id: GlobalStruct.notifications.last?.id ?? "", limit: nil), typesToExclude: self.notTypes)
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                if stat.isEmpty {} else {
                    DispatchQueue.main.async {
                        let indexPaths = ((GlobalStruct.notifications.count)..<(GlobalStruct.notifications.count + stat.count)).map {
                            IndexPath(row: $0, section: 0)
                        }
                        GlobalStruct.notifications.append(contentsOf: stat)
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
        if self.tableView.alpha == 1 {
            if let stat = GlobalStruct.notifications[gesture.view!.tag].status {
                if GlobalStruct.currentUser.id == (stat.account.id) {
                    vc.isYou = true
                } else {
                    vc.isYou = false
                }
                vc.pickedCurrentUser = stat.account
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                if GlobalStruct.currentUser.id == (GlobalStruct.notifications[gesture.view!.tag].account.id) {
                    vc.isYou = true
                } else {
                    vc.isYou = false
                }
                vc.pickedCurrentUser = GlobalStruct.notifications[gesture.view!.tag].account
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @objc func viewProfile2(_ gesture: UIGestureRecognizer) {
        let vc = FifthViewController()
        if GlobalStruct.currentUser.id == (GlobalStruct.notifications[gesture.view!.tag].account.id) {
            vc.isYou = true
        } else {
            vc.isYou = false
        }
        vc.pickedCurrentUser = GlobalStruct.notifications[gesture.view!.tag].account
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == self.tableView {
            if GlobalStruct.notifications[indexPath.row].type == .direct {
                
            } else if GlobalStruct.notifications[indexPath.row].type == .follow {
                let vc = FifthViewController()
                vc.isYou = false
                vc.pickedCurrentUser = GlobalStruct.notifications[indexPath.row].account
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = DetailViewController()
                vc.pickedStatusesHome = [GlobalStruct.notifications[indexPath.row].status!]
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            
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

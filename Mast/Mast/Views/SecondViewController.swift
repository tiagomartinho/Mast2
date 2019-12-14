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
    let btn3 = UIButton(type: .custom)
    var notTypes: [NotificationType] = []
    var notifications: [Notificationt] = []
    var gapFirstID = ""
    var gapLastID = ""
    var gapLastStat: Notificationt? = nil
    var initialLoadPos = 0
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let tab0 = (self.navigationController?.navigationBar.bounds.height ?? 0) + (self.segment.bounds.height) + 10
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
    
    @objc func scrollTop2() {
        if self.tableView.alpha == 1 && !self.notifications.isEmpty && self.tableView.hasRowAtIndexPath(indexPath: IndexPath(row: 0, section: 0) as NSIndexPath) {
            if self.notifications.isEmpty {
                
            } else {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut, animations: {
                    self.top1.alpha = 0
                    self.top1.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                }) { (completed: Bool) in
                }
            }
        }
        if self.tableView2.alpha == 1 && self.tableView2.hasRowAtIndexPath(indexPath: IndexPath(row: 0, section: 0) as NSIndexPath) {
            self.tableView2.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        self.scrollTop2()
        return false
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let cell = self.tableView.indexPathsForVisibleRows?.first {
            self.markersPost(self.notifications[cell.row].id)
        }
    }
    
    func markersPost(_ notificationsID: String) {
        let urlStr = "\(GlobalStruct.client.baseURL)/api/v1/markers"
        let url: URL = URL(string: urlStr)!
        var request01 = URLRequest(url: url)
        request01.httpMethod = "POST"
        request01.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request01.addValue("application/json", forHTTPHeaderField: "Accept")
        request01.addValue("Bearer \(GlobalStruct.client.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let paraHome: [String: Any?] = [
            "last_read_id": notificationsID
        ]
        let params: [String: Any?] = [
            "notifications": paraHome,
        ]
        do {
            request01.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        let task = session.dataTask(with: request01) { data, response, err in
            do {
                let model = try JSONDecoder().decode(Marker.self, from: data ?? Data())
                print("marker1 - \(model.notifications?.lastReadID ?? "")")
            } catch {
                print("error")
            }
        }
        task.resume()
    }
    
    func markersGet() {
        let urlStr = "\(GlobalStruct.client.baseURL)/api/v1/markers/?timeline=notifications"
        let url: URL = URL(string: urlStr)!
        var request01 = URLRequest(url: url)
        request01.httpMethod = "GET"
        request01.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request01.addValue("application/json", forHTTPHeaderField: "Accept")
        request01.addValue("Bearer \(GlobalStruct.client.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let task = session.dataTask(with: request01) { data, response, err in
            do {
                let model = try JSONDecoder().decode(Marker.self, from: data ?? Data())
                let request0 = Notifications.notification(id: model.notifications?.lastReadID ?? "")
                GlobalStruct.client.run(request0) { (statuses) in
                    if let stat = (statuses.value) {
                        DispatchQueue.main.async {
                            self.notifications = [stat]
                            let request = Notifications.all(range: .max(id: model.notifications?.lastReadID ?? "", limit: 5000))
                            GlobalStruct.client.run(request) { (statuses) in
                                if let stat = (statuses.value) {
                                    DispatchQueue.main.async {
                                        if stat.isEmpty {
                                            if self.notifications.isEmpty {
                                                let request4 = Notifications.all(range: .default, typesToExclude: self.notTypes)
                                                GlobalStruct.client.run(request4) { (statuses) in
                                                    if let stat = (statuses.value) {
                                                        DispatchQueue.main.async {
                                                            self.notifications = self.notifications + stat
                                                            self.tableView.reloadData()
                                                            self.tableView2.reloadData()
                                                        }
                                                    }
                                                }
                                            }
                                        } else {
                                            self.notifications = self.notifications + stat
                                            self.tableView.reloadData()
                                            self.tableView2.reloadData()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } catch {
                if self.notifications.isEmpty {
                    let request4 = Notifications.all(range: .default, typesToExclude: self.notTypes)
                    GlobalStruct.client.run(request4) { (statuses) in
                        if let stat = (statuses.value) {
                            DispatchQueue.main.async {
                                self.notifications = self.notifications + stat
                                self.tableView.reloadData()
                                self.tableView2.reloadData()
                            }
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    func fetchGap2() {
        let request = Notifications.all(range: .min(id: self.gapFirstID, limit: nil))
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
                        let y = self.notifications.split(separator: self.gapLastStat ?? self.notifications.first!)
                        self.gapFirstID = stat.first?.id ?? ""
                        if self.notifications.contains(stat.first!) || stat.count < 15 {
                            
                        } else {
                            self.gapLastID = stat.first?.id ?? ""
                            let z = stat.first!
                            z.id = "loadmorehere"
                            self.gapLastStat = z
                        }
                        let fi = (y.first?.count ?? 0)
                        let indexPaths = (0..<(fi + stat.count)).map {
                            IndexPath(row: $0, section: 0)
                        }
                        if y.first?.isEmpty ?? true {
                            if y.last?.isEmpty ?? true {
                                self.notifications = stat
                            } else {
                                self.notifications = stat + y.last!
                            }
                        } else if y.last?.isEmpty ?? true {
                            self.notifications = y.first! + stat
                        } else {
                            self.notifications = y.first! + stat + y.last!
                        }
                        UIView.setAnimationsEnabled(false)
                        self.tableView.reloadData()
                        let _ = indexPaths.map {
                            if let cell = self.tableView.cellForRow(at: $0) as? LoadMoreCell {
                                cell.configureBack()
                            }
                        }
                        self.tableView.scrollToRow(at: IndexPath(row: fi + stat.count, section: 0), at: .top, animated: false)
                        UIView.setAnimationsEnabled(true)
                    }
                }
            }
        }
    }
    
    func fetchGap() {
        let request = Notifications.all(range: .max(id: self.gapLastID, limit: nil))
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
                        
                        let y = self.notifications.split(separator: self.gapLastStat ?? self.notifications.last!)
                        
                        if self.notifications.contains(stat.last!) || stat.count < 15 {
                            
                        } else {
                            self.gapLastID = stat.last?.id ?? ""
                            let z = stat.last!
                            z.id = "loadmorehere"
                            self.gapLastStat = z
                        }
                        
                        let fi = (y.first?.count ?? 0)
                        let indexPaths = (0..<(fi + stat.count - 1)).map {
                            IndexPath(row: $0, section: 0)
                        }
                        if y.first?.isEmpty ?? true {
                            if y.last?.isEmpty ?? true {
                                self.notifications = stat
                            } else {
                                self.notifications = stat + y.last!
                            }
                        } else if y.last?.isEmpty ?? true {
                            self.notifications = y.first! + stat
                        } else {
                            self.notifications = y.first! + stat + y.last!
                        }
                        UIView.setAnimationsEnabled(false)
                        let _ = indexPaths.map {
                            if let cell = self.tableView.cellForRow(at: $0) as? LoadMoreCell {
                                cell.configureBack()
                            }
                        }
                        self.tableView.reloadData()
                        UIView.setAnimationsEnabled(true)
                    }
                }
            }
        }
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
    
    @objc func goToIDNoti() {
        sleep(2)
        let request = Notifications.notification(id: GlobalStruct.curIDNoti)
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                DispatchQueue.main.async {
                    if let x = stat.status {
                        let vc = DetailViewController()
                        vc.pickedStatusesHome = [x]
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        let vc = FifthViewController()
                        vc.isYou = false
                        vc.isTapped = true
                        vc.userID = stat.account.id
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    }
    
    @objc func updateLayout1() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
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
        NotificationCenter.default.addObserver(self, selector: #selector(self.goToIDNoti), name: NSNotification.Name(rawValue: "gotoidnoti2"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateLayout1), name: NSNotification.Name(rawValue: "updateLayout1"), object: nil)
        
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
        
        btn3.setImage(UIImage(systemName: "arrow.clockwise", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        btn3.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn3.addTarget(self, action: #selector(refresh(_:)), for: .touchUpInside)
        btn3.accessibilityLabel = "Sort".localized
        let refButton = UIBarButtonItem(customView: btn3)
        #if targetEnvironment(macCatalyst)
        self.navigationItem.setRightBarButton(refButton, animated: true)
        #elseif !targetEnvironment(macCatalyst)
        if UIDevice.current.userInterfaceIdiom == .pad && self.isSplitOrSlideOver == false {
            self.navigationItem.setRightBarButton(refButton, animated: true)
        }
        #endif
        
        if UserDefaults.standard.value(forKey: "filterNotifications") as? Int == 0 {
            self.notTypes = []
        } else if UserDefaults.standard.value(forKey: "filterNotifications") as? Int == 1 {
            self.notTypes = GlobalStruct.notTypes.filter {$0 != NotificationType.mention}
        } else if UserDefaults.standard.value(forKey: "filterNotifications") as? Int == 2 {
            self.notTypes = GlobalStruct.notTypes.filter {$0 != NotificationType.favourite}
        } else if UserDefaults.standard.value(forKey: "filterNotifications") as? Int == 3 {
            self.notTypes = GlobalStruct.notTypes.filter {$0 != NotificationType.reblog}
        } else if UserDefaults.standard.value(forKey: "filterNotifications") as? Int == 4 {
            self.notTypes = GlobalStruct.notTypes.filter {$0 != NotificationType.direct}
        } else if UserDefaults.standard.value(forKey: "filterNotifications") as? Int == 5 {
            self.notTypes = GlobalStruct.notTypes.filter {$0 != NotificationType.follow}
        } else if UserDefaults.standard.value(forKey: "filterNotifications") as? Int == 6 {
            self.notTypes = GlobalStruct.notTypes.filter {$0 != NotificationType.poll}
        }
        
        self.markersGet()
        
        // Table
        self.tableView.register(NotificationsCell.self, forCellReuseIdentifier: "NotificationsCell")
        self.tableView.register(NotificationsImageCell.self, forCellReuseIdentifier: "NotificationsImageCell")
        self.tableView.register(LoadMoreCell.self, forCellReuseIdentifier: "LoadMoreCell")
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
        let symbolConfig2 = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
        
        self.top1.setImage(UIImage(systemName: "chevron.up.circle.fill", withConfiguration: symbolConfig2)?.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal), for: .normal)
        self.top1.backgroundColor = GlobalStruct.baseDarkTint
        self.top1.layer.cornerRadius = 30
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
        let request = Notifications.all(range: .since(id: self.notifications.first?.id ?? "", limit: nil), typesToExclude: self.notTypes)
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
                        
                        self.gapFirstID = self.notifications.first?.id ?? ""
                        if self.notifications.contains(stat.last!) || stat.count < 15 {
                            
                        } else {
                            self.gapLastID = stat.last?.id ?? ""
                            let z = stat.last!
                            z.id = "loadmorehere"
                            self.gapLastStat = z
                        }
                        
                        let indexPaths = (0..<stat.count).map {
                            IndexPath(row: $0, section: 0)
                        }
                        self.notifications = stat + self.notifications
                        self.tableView.beginUpdates()
                        UIView.setAnimationsEnabled(false)
                        var heights: CGFloat = 0
                        let _ = indexPaths.map {
                            if let cell = self.tableView.cellForRow(at: $0) as? NotificationsCell {
                                heights += cell.bounds.height
                            }
                            if let cell = self.tableView.cellForRow(at: $0) as? NotificationsImageCell {
                                heights += cell.bounds.height
                            }
                            if let cell = self.tableView.cellForRow(at: $0) as? LoadMoreCell {
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
            self.notifications = []
            self.tableView.reloadData()
        }
        let request = Notifications.all(range: .default, typesToExclude: self.notTypes)
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                DispatchQueue.main.async {
                    self.notifications = stat
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
            return self.notifications.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            if self.notifications.isEmpty {
                self.markersGet()
                let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationsCell", for: indexPath) as! NotificationsCell
                cell.backgroundColor = GlobalStruct.baseDarkTint
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                return cell
            } else {
                if self.notifications[indexPath.row].id == "loadmorehere" {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "LoadMoreCell", for: indexPath) as! LoadMoreCell
                    cell.backgroundColor = UIColor(named: "lighterBaseWhite")!
                    let bgColorView = UIView()
                    bgColorView.backgroundColor = UIColor.clear
                    cell.selectedBackgroundView = bgColorView
                    return cell
                    
                } else if self.notifications[indexPath.row].status?.mediaAttachments.isEmpty ?? true {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationsCell", for: indexPath) as! NotificationsCell
                    cell.configure(self.notifications[indexPath.row])
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile(_:)))
                    cell.profile.tag = indexPath.row
                    let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile2(_:)))
                    cell.profile2.tag = indexPath.row
                    if self.notifications[indexPath.row].type == .mention || self.notifications[indexPath.row].type == .follow {
                        cell.profile.addGestureRecognizer(tap2)
                    } else {
                        cell.profile.addGestureRecognizer(tap)
                    }
                    cell.profile2.addGestureRecognizer(tap2)
                    if indexPath.row == self.notifications.count - 10 {
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
                    cell.configure(self.notifications[indexPath.row])
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile(_:)))
                    cell.profile.tag = indexPath.row
                    let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile2(_:)))
                    cell.profile2.tag = indexPath.row
                    if self.notifications[indexPath.row].type == .mention || self.notifications[indexPath.row].type == .follow {
                        cell.profile.addGestureRecognizer(tap2)
                    } else {
                        cell.profile.addGestureRecognizer(tap)
                    }
                    cell.profile2.addGestureRecognizer(tap2)
                    if indexPath.row == self.notifications.count - 10 {
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
                if self.notifications.isEmpty {} else {
                    cell.configure(self.notifications)
                }
                cell.backgroundColor = GlobalStruct.baseDarkTint
                let bgColorView = UIView()
                bgColorView.backgroundColor = .clear
                cell.selectedBackgroundView = bgColorView
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "GraphCell2", for: indexPath) as! GraphCell2
                if self.notifications.isEmpty {} else {
                    cell.configure(self.notifications)
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
                    self.notifications = stat
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func fetchMoreNotifications() {
        let request = Notifications.all(range: .max(id: self.notifications.last?.id ?? "", limit: nil), typesToExclude: self.notTypes)
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                if stat.isEmpty {} else {
                    DispatchQueue.main.async {
                        let indexPaths = ((self.notifications.count)..<(self.notifications.count + stat.count)).map {
                            IndexPath(row: $0, section: 0)
                        }
                        self.notifications.append(contentsOf: stat)
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
            if let stat = self.notifications[gesture.view!.tag].status {
                if GlobalStruct.currentUser.id == (stat.account.id) {
                    vc.isYou = true
                } else {
                    vc.isYou = false
                }
                vc.pickedCurrentUser = stat.account
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                if GlobalStruct.currentUser.id == (self.notifications[gesture.view!.tag].account.id) {
                    vc.isYou = true
                } else {
                    vc.isYou = false
                }
                vc.pickedCurrentUser = self.notifications[gesture.view!.tag].account
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @objc func viewProfile2(_ gesture: UIGestureRecognizer) {
        let vc = FifthViewController()
        if GlobalStruct.currentUser.id == (self.notifications[gesture.view!.tag].account.id) {
            vc.isYou = true
        } else {
            vc.isYou = false
        }
        vc.pickedCurrentUser = self.notifications[gesture.view!.tag].account
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for x in self.tableView.visibleCells {
            if let z = x as? LoadMoreCell {
                if let indexPath = self.tableView.indexPath(for: z) {
                    let rectOfCellInTableView = self.tableView.rectForRow(at: indexPath)
                    let rectOfCellInSuperview = self.tableView.convert(rectOfCellInTableView, to: self.tableView.superview)
                    let pos = rectOfCellInSuperview.origin.y
                    if pos < self.view.bounds.height/2 {
                        if self.initialLoadPos == 1 {
                            self.initialLoadPos = 0
                            z.configureBack()
                        }
                    } else {
                        if self.initialLoadPos == 0 {
                            self.initialLoadPos = 1
                            z.configureBack2()
                        }
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == self.tableView {
            if self.notifications[indexPath.row].id == "loadmorehere" {
                if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
                    let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
                    impactFeedbackgenerator.prepare()
                    impactFeedbackgenerator.impactOccurred()
                }
                if let cell = self.tableView.cellForRow(at: indexPath) as? LoadMoreCell {
                    cell.configure()
                }
                
                let rectOfCellInTableView = self.tableView.rectForRow(at: indexPath)
                let rectOfCellInSuperview = self.tableView.convert(rectOfCellInTableView, to: self.tableView.superview)
                let pos = rectOfCellInSuperview.origin.y
                if pos < self.view.bounds.height/2 {
                    self.fetchGap2()
                } else {
                    self.fetchGap()
                }
                
            } else {
                if self.notifications[indexPath.row].type == .direct {
                    
                } else if self.notifications[indexPath.row].type == .follow {
                    let vc = FifthViewController()
                    vc.isYou = false
                    vc.pickedCurrentUser = self.notifications[indexPath.row].account
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let vc = DetailViewController()
                    vc.pickedStatusesHome = [self.notifications[indexPath.row].status!]
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        } else {
            
        }
    }
    
//    func tableView(_ tableView: UITableView,
//                   contextMenuConfigurationForRowAt indexPath: IndexPath,
//                   point: CGPoint) -> UIContextMenuConfiguration? {
//        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: { return nil }, actionProvider: { suggestedActions in
//            if tableView == self.tableView {
//                if self.notifications[indexPath.row].id == "loadmorehere" {
//                    return nil
//                } else {
//                    return self.makeContextMenu([self.notifications[indexPath.row]], indexPath: indexPath)
//                }
//            } else {
//                return nil
//            }
//        })
//    }
    
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            guard let indexPath = configuration.identifier as? IndexPath else { return }
            if tableView == self.tableView && self.notifications[indexPath.row].type == .mention {
                let vc = DetailViewController()
                guard let stat = self.notifications[indexPath.row].status else { return }
                vc.pickedStatusesHome = [stat]
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                return
            }
        }
    }
    
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: {
            if tableView == self.tableView && self.notifications[indexPath.row].type == .mention {
                if self.notifications[indexPath.row].id == "loadmorehere" {
                    return nil
                } else {
                    let vc = DetailViewController()
                    guard let stat = self.notifications[indexPath.row].status else { return nil }
                    vc.fromContextMenu = true
                    vc.pickedStatusesHome = [stat]
                    return vc
                }
            } else {
                return nil
            }
        }, actionProvider: { suggestedActions in
            if tableView == self.tableView && self.notifications[indexPath.row].type == .mention {
                if self.notifications[indexPath.row].id == "loadmorehere" {
                    return nil
                } else {
                    guard let stat = self.notifications[indexPath.row].status else { return nil }
                    return self.makeContextMenu([stat], indexPath: indexPath, tableView: self.tableView)
                }
            } else if tableView == self.tableView {
//                if self.notifications[indexPath.row].id == "loadmorehere" {
//                    return nil
//                } else {
//                    return self.makeContextMenuNoti([self.notifications[indexPath.row]], indexPath: indexPath)
//                }
                return nil
            } else {
                return nil
            }
        })
    }
    
//    func makeContextMenuNoti(_ notifications: [Notificationt], indexPath: IndexPath) -> UIMenu {
//        let remove = UIAction(title: "Remove".localized, image: UIImage(systemName: "xmark"), identifier: nil) { action in
//            let noti = notifications[0].id
//            self.notifications = self.notifications.filter { $0 != self.notifications[indexPath.row] }
//            self.tableView.deleteRows(at: [indexPath], with: .none)
//            let request = Notifications.dismiss(id: noti)
//            GlobalStruct.client.run(request) { (statuses) in
//                DispatchQueue.main.async {
//
//                }
//            }
//        }
//        remove.attributes = .destructive
//        return UIMenu(__title: "", image: nil, identifier: nil, children: [remove])
//    }
    
    func makeContextMenu(_ status: [Status], indexPath: IndexPath, tableView: UITableView) -> UIMenu {
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
            GlobalStruct.allBoostedStatuses.append(status.first?.id ?? "")
            GlobalStruct.allUnboostedStatuses = GlobalStruct.allUnboostedStatuses.filter{$0 != status.first?.id ?? ""}
            let request = Statuses.reblog(id: status.first?.id ?? "")
            GlobalStruct.client.run(request) { (statuses) in
                
            }
        }
        if status.first?.reblogged ?? false || GlobalStruct.allBoostedStatuses.contains(status.first?.reblog?.id ?? status.first?.id ?? "") {
            boos = UIAction(title: "Remove Boost".localized, image: UIImage(systemName: "arrow.2.circlepath"), identifier: nil) { action in
                ViewController().showNotifBanner("Removed Boost".localized, subtitle: "Toot".localized, style: BannerStyle.info)
                GlobalStruct.allUnboostedStatuses.append(status.first?.id ?? "")
                GlobalStruct.allBoostedStatuses = GlobalStruct.allBoostedStatuses.filter{$0 != status.first?.id ?? ""}
                let request = Statuses.unreblog(id: status.first?.id ?? "")
                GlobalStruct.client.run(request) { (statuses) in
                    
                }
            }
        }
        var like = UIAction(title: "Like".localized, image: UIImage(systemName: "heart"), identifier: nil) { action in
            ViewController().showNotifBanner("Liked".localized, subtitle: "Toot".localized, style: BannerStyle.info)
            GlobalStruct.allLikedStatuses.append(status.first?.id ?? "")
            GlobalStruct.allDislikedStatuses = GlobalStruct.allDislikedStatuses.filter{$0 != status.first?.id ?? ""}
            if let cell = tableView.cellForRow(at: indexPath) as? TootCell {
                cell.configure(status.first!)
            } else if let cell = tableView.cellForRow(at: indexPath) as? TootImageCell {
                cell.configure(status.first!)
            }
            let request = Statuses.favourite(id: status.first?.id ?? "")
            GlobalStruct.client.run(request) { (statuses) in
                
            }
        }
        if status.first?.favourited ?? false || GlobalStruct.allLikedStatuses.contains(status.first?.reblog?.id ?? status.first?.id ?? "") {
            like = UIAction(title: "Remove Like".localized, image: UIImage(systemName: "heart.slash"), identifier: nil) { action in
                ViewController().showNotifBanner("Removed Like".localized, subtitle: "Toot".localized, style: BannerStyle.info)
                GlobalStruct.allDislikedStatuses.append(status.first?.id ?? "")
                GlobalStruct.allLikedStatuses = GlobalStruct.allLikedStatuses.filter{$0 != status.first?.id ?? ""}
                if let cell = tableView.cellForRow(at: indexPath) as? TootCell {
                    cell.configure(status.first!)
                } else if let cell = tableView.cellForRow(at: indexPath) as? TootImageCell {
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
        
        
//        let remove0 = UIAction(title: "Remove".localized, image: UIImage(systemName: "xmark"), identifier: nil) { action in
//            let request = Notifications.dismiss(id: self.notifications[indexPath.row].id)
//            GlobalStruct.client.run(request) { (statuses) in
//                DispatchQueue.main.async {
//                    self.tableView.deleteRows(at: [indexPath], with: .none)
//                    self.notifications.remove(at: indexPath.row)
//                }
//            }
//        }
//        remove0.attributes = .destructive
        
        
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
//            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? DetailActionsCell {
                activityViewController.popoverPresentationController?.sourceView = self.view
                activityViewController.popoverPresentationController?.sourceRect = self.view.bounds
//            }
            self.present(activityViewController, animated: true, completion: nil)
        })
        op1.setValue(UIImage(systemName: "doc.append")!, forKey: "image")
        op1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op1)
        let op2 = UIAlertAction(title: "Share Link".localized, style: .default , handler:{ (UIAlertAction) in
            let textToShare = [stat.first?.url?.absoluteString ?? ""]
            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
//            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? DetailActionsCell {
                activityViewController.popoverPresentationController?.sourceView = self.view
                activityViewController.popoverPresentationController?.sourceRect = self.view.bounds
//            }
            self.present(activityViewController, animated: true, completion: nil)
        })
        op2.setValue(UIImage(systemName: "link")!, forKey: "image")
        op2.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op2)
        alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
            
        }))
        if let presenter = alert.popoverPresentationController {
//            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? DetailActionsCell {
                presenter.sourceView = self.view
                presenter.sourceRect = self.view.bounds
//            }
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
//                            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? DetailActionsCell {
                                presenter.sourceView = self.view
                                presenter.sourceRect = self.view.bounds
//                            }
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
//            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? DetailActionsCell {
                presenter.sourceView = self.view
                presenter.sourceRect = self.view.bounds
//            }
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

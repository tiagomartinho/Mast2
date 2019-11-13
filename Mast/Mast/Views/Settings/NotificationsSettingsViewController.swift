//
//  NotificationsSettingsViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 13/11/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class NotificationsSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
    var notifArray = ["Mentions", "Likes", "Boosts", "Follows"]
    
    override func viewDidLayoutSubviews() {
        self.tableView.frame = CGRect(x: self.view.safeAreaInsets.left, y: 0, width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: self.view.bounds.height)
    }
    
    @objc func notifChangeBG() {
        GlobalStruct.baseDarkTint = (UserDefaults.standard.value(forKey: "sync-startDarkTint") == nil || UserDefaults.standard.value(forKey: "sync-startDarkTint") as? Int == 0) ? UIColor(named: "baseWhite")! : UIColor(named: "baseWhite2")!
        self.navigationController?.navigationBar.backgroundColor = GlobalStruct.baseDarkTint
        self.navigationController?.navigationBar.barTintColor = GlobalStruct.baseDarkTint
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "lighterBaseWhite")
        self.title = "Push Notifications".localized
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(named: "baseBlack")!]
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notifChangeBG), name: NSNotification.Name(rawValue: "notifChangeBG"), object: nil)
        
        self.tableView = UITableView(frame: .zero, style: .insetGrouped)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "settingsCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.layer.masksToBounds = true
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.showsVerticalScrollIndicator = false
        self.view.addSubview(self.tableView)
        self.tableView.reloadData()
    }
    
    //MARK: TableView
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notifArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
        cell.backgroundColor = GlobalStruct.baseDarkTint
        
        let descriptionSideString = NSMutableAttributedString(string: self.notifArray[indexPath.row], attributes: [.foregroundColor: UIColor(named: "baseBlack")!, .font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)])
        cell.textLabel?.attributedText = descriptionSideString

        if indexPath.row == 0 {
            let switchView = UISwitch(frame: .zero)
            if UserDefaults.standard.value(forKey: "pnmentions") as? Int != nil {
                if UserDefaults.standard.value(forKey: "pnmentions") as? Int == 0 {
                    switchView.setOn(true, animated: false)
                } else {
                    switchView.setOn(false, animated: false)
                }
            } else {
                switchView.setOn(true, animated: false)
            }
            switchView.onTintColor = GlobalStruct.baseTint
            switchView.tintColor = GlobalStruct.baseTint
            switchView.tag = indexPath.row
            switchView.addTarget(self, action: #selector(self.switchMentions(_:)), for: .valueChanged)
            cell.accessoryView = switchView
            cell.selectionStyle = .none
        } else if indexPath.row == 1 {
            let switchView = UISwitch(frame: .zero)
            if UserDefaults.standard.value(forKey: "pnlikes") as? Int != nil {
                if UserDefaults.standard.value(forKey: "pnlikes") as? Int == 0 {
                    switchView.setOn(true, animated: false)
                } else {
                    switchView.setOn(false, animated: false)
                }
            } else {
                switchView.setOn(true, animated: false)
            }
            switchView.onTintColor = GlobalStruct.baseTint
            switchView.tintColor = GlobalStruct.baseTint
            switchView.tag = indexPath.row
            switchView.addTarget(self, action: #selector(self.switchLikes(_:)), for: .valueChanged)
            cell.accessoryView = switchView
            cell.selectionStyle = .none
        } else if indexPath.row == 2 {
            let switchView = UISwitch(frame: .zero)
            if UserDefaults.standard.value(forKey: "pnboosts") as? Int != nil {
                if UserDefaults.standard.value(forKey: "pnboosts") as? Int == 0 {
                    switchView.setOn(true, animated: false)
                } else {
                    switchView.setOn(false, animated: false)
                }
            } else {
                switchView.setOn(true, animated: false)
            }
            switchView.onTintColor = GlobalStruct.baseTint
            switchView.tintColor = GlobalStruct.baseTint
            switchView.tag = indexPath.row
            switchView.addTarget(self, action: #selector(self.switchBoosts(_:)), for: .valueChanged)
            cell.accessoryView = switchView
            cell.selectionStyle = .none
        } else {
            let switchView = UISwitch(frame: .zero)
            if UserDefaults.standard.value(forKey: "pnfollows") as? Int != nil {
                if UserDefaults.standard.value(forKey: "pnfollows") as? Int == 0 {
                    switchView.setOn(true, animated: false)
                } else {
                    switchView.setOn(false, animated: false)
                }
            } else {
                switchView.setOn(true, animated: false)
            }
            switchView.onTintColor = GlobalStruct.baseTint
            switchView.tintColor = GlobalStruct.baseTint
            switchView.tag = indexPath.row
            switchView.addTarget(self, action: #selector(self.switchFollows(_:)), for: .valueChanged)
            cell.accessoryView = switchView
            cell.selectionStyle = .none
        }
        
        return cell
    }
    
    @objc func switchMentions(_ sender: UISwitch!) {
        print("table row switch Changed \(sender.tag)")
        print("The switch is \(sender.isOn ? "ON" : "OFF")")
        
        if sender.isOn {
            UserDefaults.standard.set(0, forKey: "pnmentions")
            self.updateRegister()
        } else {
            UserDefaults.standard.set(1, forKey: "pnmentions")
            self.updateRegister()
        }
    }
    
    @objc func switchLikes(_ sender: UISwitch!) {
        print("table row switch Changed \(sender.tag)")
        print("The switch is \(sender.isOn ? "ON" : "OFF")")
        
        if sender.isOn {
            UserDefaults.standard.set(0, forKey: "pnlikes")
            self.updateRegister()
        } else {
            UserDefaults.standard.set(1, forKey: "pnlikes")
            self.updateRegister()
        }
    }
    
    @objc func switchBoosts(_ sender: UISwitch!) {
        print("table row switch Changed \(sender.tag)")
        print("The switch is \(sender.isOn ? "ON" : "OFF")")
        
        if sender.isOn {
            UserDefaults.standard.set(0, forKey: "pnboosts")
            self.updateRegister()
        } else {
            UserDefaults.standard.set(1, forKey: "pnboosts")
            self.updateRegister()
        }
    }
    
    @objc func switchFollows(_ sender: UISwitch!) {
        print("table row switch Changed \(sender.tag)")
        print("The switch is \(sender.isOn ? "ON" : "OFF")")
        
        if sender.isOn {
            UserDefaults.standard.set(0, forKey: "pnfollows")
            self.updateRegister()
        } else {
            UserDefaults.standard.set(1, forKey: "pnfollows")
            self.updateRegister()
        }
    }
    
    func updateRegister() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}







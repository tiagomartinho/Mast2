//
//  LockSettingsViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 20/11/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class LockSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView = UITableView()
    let firstSection = ["App Lock".localized]
    let secondSection = ["Immediately".localized, "After 1 Minute".localized, "After 5 Minutes".localized, "After 15 Minutes".localized, "After 1 Hour".localized]
    
    override func viewDidLayoutSubviews() {
        self.tableView.frame = CGRect(x: self.view.safeAreaInsets.left, y: 0, width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: self.view.bounds.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "lighterBaseWhite")
        self.title = "App Lock".localized
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(named: "baseBlack")!]
        
        self.tableView = UITableView(frame: .zero, style: .insetGrouped)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "settingsCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "settingsCell2")
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if UserDefaults.standard.value(forKey: "sync-lock") as? Int == 1 {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.firstSection.count
        } else {
            return self.secondSection.count
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            cell.accessoryType = .none
        } else {
            if indexPath.row == (UserDefaults.standard.value(forKey: "sync-lockTime") as! Int) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "settingsCell")
            cell.textLabel?.text = self.firstSection[indexPath.row]
            cell.detailTextLabel?.numberOfLines = 0
            cell.detailTextLabel?.text = "Present a biometric lock when launching the app to protect your activity".localized
            cell.backgroundColor = GlobalStruct.baseDarkTint
            let switchView = UISwitch(frame: .zero)
            if UserDefaults.standard.value(forKey: "sync-lock") as? Int != nil {
                if UserDefaults.standard.value(forKey: "sync-lock") as? Int == 0 {
                    switchView.setOn(false, animated: false)
                } else {
                    switchView.setOn(true, animated: false)
                }
            } else {
                switchView.setOn(false, animated: false)
            }
            
            switchView.onTintColor = GlobalStruct.baseTint
            switchView.tintColor = GlobalStruct.baseTint
            switchView.tag = indexPath.row
            switchView.addTarget(self, action: #selector(self.switchLock(_:)), for: .valueChanged)
            cell.accessoryView = switchView
            cell.selectionStyle = .none
            return cell
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell2", for: indexPath)
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "settingsCell2")
            cell.textLabel?.text = self.secondSection[indexPath.row]
            cell.backgroundColor = GlobalStruct.baseDarkTint
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        UserDefaults.standard.set(indexPath.row, forKey: "sync-lockTime")
        self.tableView.reloadData()
    }
    
    //MARK: Switches
    
    @objc func switchLock(_ sender: UISwitch!) {
        print("table row switch Changed \(sender.tag)")
        print("The switch is \(sender.isOn ? "ON" : "OFF")")
        
        if sender.isOn {
            UserDefaults.standard.set(1, forKey: "sync-lock")
            self.tableView.reloadData()
        } else {
            UserDefaults.standard.set(0, forKey: "sync-lock")
            self.tableView.reloadData()
        }
    }
}



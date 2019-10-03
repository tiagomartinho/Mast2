//
//  TintSettingsViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 03/10/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class TintSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView = UITableView()
    
    override func viewDidLayoutSubviews() {
        self.tableView.frame = CGRect(x: self.view.safeAreaInsets.left, y: 0, width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: self.view.bounds.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "lighterBaseWhite")
        self.title = "App Tint".localized
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : GlobalStruct.baseTint]
        
        self.tableView = UITableView(frame: .zero, style: .insetGrouped)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "settingsCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "settingsCell1")
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
        return GlobalStruct.arrayCols.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (UserDefaults.standard.value(forKey: "sync-startTint") as! Int) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
        cell.backgroundColor = UIColor(named: "baseWhite")
        
        let symbolConfig0 = UIImage.SymbolConfiguration(pointSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        let clockImage = UIImage(systemName: "circle.fill", withConfiguration: symbolConfig0)
        let tintedClockImage = clockImage?.withTintColor(GlobalStruct.arrayCols[indexPath.row], renderingMode: .alwaysOriginal)
        let attachment = NSTextAttachment(image: tintedClockImage!)
        let clockString = NSAttributedString(attachment: attachment)
        let descriptionSideString = NSMutableAttributedString(string: "   \(GlobalStruct.colNames[indexPath.row])", attributes: [.foregroundColor: UIColor(named: "baseBlack")!, .font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)])
        descriptionSideString.insert(clockString, at: 0)
        cell.textLabel?.attributedText = descriptionSideString
        if indexPath.row == (UserDefaults.standard.value(forKey: "sync-startTint") as! Int) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        DispatchQueue.main.async {
            GlobalStruct.baseTint = GlobalStruct.arrayCols[indexPath.row]
            UserDefaults.standard.set(indexPath.row, forKey: "sync-startTint")
            self.tableView.reloadData()
            UIWindow().tintColor = GlobalStruct.baseTint
            for x in UIApplication.shared.windows {
                x.tintColor = GlobalStruct.baseTint
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: "notifChangeTint"), object: self)
            self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : GlobalStruct.baseTint]
        }
    }
}





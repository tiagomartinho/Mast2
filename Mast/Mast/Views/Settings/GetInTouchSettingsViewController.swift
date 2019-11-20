//
//  GetInTouchSettingsViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 08/11/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import SafariServices
import MessageUI

class GetInTouchSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {
    
    var tableView = UITableView()
    let firstSection = ["\("Mast \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "")") Twitter", "Developer Twitter"]
    let secondSection = ["\("Mast \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "")") Website", "Developer Website"]
    let thirdSection = ["Email"]
    var safariVC: SFSafariViewController?
    
    override func viewDidLayoutSubviews() {
        self.tableView.frame = CGRect(x: self.view.safeAreaInsets.left, y: 0, width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: self.view.bounds.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "lighterBaseWhite")
        self.title = "Get in Touch".localized
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(named: "baseBlack")!]
        
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.firstSection.count
        } else if section == 1 {
            return self.secondSection.count
        } else {
            return self.thirdSection.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "settingsCell")
            cell.textLabel?.text = self.firstSection[indexPath.row]
            cell.backgroundColor = GlobalStruct.baseDarkTint
            return cell
        } else if indexPath.section == 1 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "settingsCell")
            cell.textLabel?.text = self.secondSection[indexPath.row]
            cell.backgroundColor = GlobalStruct.baseDarkTint
            return cell
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "settingsCell")
            cell.textLabel?.text = self.thirdSection[indexPath.row]
            cell.backgroundColor = GlobalStruct.baseDarkTint
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let twUrl = URL(string: "twitter://user?screen_name=TheMastApp")!
                let twUrlWeb = URL(string: "https://www.twitter.com/TheMastApp")!
                if UIApplication.shared.canOpenURL(twUrl) {
                    UIApplication.shared.open(twUrl, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.open(twUrlWeb, options: [.universalLinksOnly: true]) { (success) in
                        if !success {
//                            self.safariVC = SFSafariViewController(url: twUrlWeb)
//                            self.safariVC?.modalPresentationStyle = .formSheet
//                            self.present(self.safariVC!, animated: true, completion: nil)
                            UIApplication.shared.open(twUrlWeb)
                        }
                    }
                }
            } else if indexPath.row == 1 {
                let twUrl = URL(string: "twitter://user?screen_name=JPEGuin")!
                let twUrlWeb = URL(string: "https://www.twitter.com/JPEGuin")!
                if UIApplication.shared.canOpenURL(twUrl) {
                    UIApplication.shared.open(twUrl, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.open(twUrlWeb, options: [.universalLinksOnly: true]) { (success) in
                        if !success {
//                            self.safariVC = SFSafariViewController(url: twUrlWeb)
//                            self.safariVC?.modalPresentationStyle = .formSheet
//                            self.present(self.safariVC!, animated: true, completion: nil)
                            UIApplication.shared.open(twUrlWeb)
                        }
                    }
                }
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let z = URL(string: "https://www.thebluebird.app")!
//                self.safariVC = SFSafariViewController(url: z)
//                self.safariVC?.modalPresentationStyle = .formSheet
//                self.present(self.safariVC!, animated: true, completion: nil)
                UIApplication.shared.open(z)
            } else if indexPath.row == 1 {
                let z = URL(string: "https://www.thebluebird.app")!
//                self.safariVC = SFSafariViewController(url: z)
//                self.safariVC?.modalPresentationStyle = .formSheet
//                self.present(self.safariVC!, animated: true, completion: nil)
                UIApplication.shared.open(z)
            }
        } else {
            if indexPath.row == 0 {
                if MFMailComposeViewController.canSendMail() {
                    let mail = MFMailComposeViewController()
                    mail.mailComposeDelegate = self
                    mail.setToRecipients(["shihab.bus@gmail.com"])
                    mail.setSubject("Hello from Mast!")
                    self.present(mail, animated: true)
                } else {
                    // show failure alert
                }
            }
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}






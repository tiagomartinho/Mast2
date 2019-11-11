//
//  SettingsViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 17/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
    let firstSection = ["App Icon".localized, "App Tint".localized, "App Haptics".localized]
    let firstSectionPad = ["App Icon".localized, "App Tint".localized]
    let secondSection = ["Hide Sensitive Media".localized, "Default Visibility".localized, "Default Browser".localized, "Siri Shortcuts".localized, "\("App Lock".localized)"]
    let accountSection = ["\("Accounts".localized)"]
    let thirdSection = ["Mast \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "")", "Get in Touch".localized]
    
    override func viewDidLayoutSubviews() {
        self.tableView.frame = CGRect(x: self.view.safeAreaInsets.left, y: 0, width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: self.view.bounds.height)
    }
    
    @objc func notifChangeTint() {
        self.tableView.reloadData()
        
        self.tableView.reloadInputViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "lighterBaseWhite")
        self.title = "Settings".localized
        
//        self.removeTabbarItemsText()
        
        // Add button
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
        let btn2 = UIButton(type: .custom)
        btn2.setImage(UIImage(systemName: "xmark", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        btn2.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn2.addTarget(self, action: #selector(self.crossTapped), for: .touchUpInside)
        btn2.accessibilityLabel = "Dismiss".localized
        let settingsButton = UIBarButtonItem(customView: btn2)
        self.navigationItem.setRightBarButton(settingsButton, animated: true)
        
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(named: "baseBlack")!]
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notifChangeTint), name: NSNotification.Name(rawValue: "notifChangeTint"), object: nil)
        
        self.tableView = UITableView(frame: .zero, style: .insetGrouped)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "settingsCell1")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "settingsCell2")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "settingsCell3")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "settingsCell4")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "settingsCell5")
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
    
    @objc func otherTapped() {
        
    }
    
    @objc func crossTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func removeTabbarItemsText() {
        if let items = self.tabBarController?.tabBar.items {
            for item in items {
                item.title = ""
            }
        }
    }
    
    //MARK: TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            if UIDevice.current.userInterfaceIdiom == .pad && self.isSplitOrSlideOver == false {
                return self.firstSectionPad.count
            } else {
                return self.firstSection.count
            }
        } else if section == 2 {
            return self.secondSection.count
        } else if section == 3 {
            return self.accountSection.count
        } else {
            return self.thirdSection.count
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            cell.accessoryType = .disclosureIndicator
        } else if indexPath.section == 1 && indexPath.row == 0 {
            cell.accessoryType = .disclosureIndicator
        } else if indexPath.section == 1 && indexPath.row == 1 {
            cell.accessoryType = .disclosureIndicator
        } else if indexPath.section == 2 {
            cell.accessoryType = .disclosureIndicator
        } else if indexPath.section == 3 {
            cell.accessoryType = .disclosureIndicator
        } else if indexPath.section == 4 {
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.accessoryType = .none
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: UIFont.preferredFont(forTextStyle: .headline).pointSize)
        var firstSectionToUse = self.firstSection
        if UIDevice.current.userInterfaceIdiom == .pad && self.isSplitOrSlideOver == false {
            firstSectionToUse = self.firstSectionPad
        }
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell2", for: indexPath)
            cell.imageView?.image = (UIImage(systemName: "lock.circle.fill", withConfiguration: symbolConfig) ?? UIImage()).withTintColor(UIColor.white)
            cell.textLabel?.text = "Mast Pro"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
            cell.textLabel?.textColor = UIColor.white
            cell.backgroundColor = GlobalStruct.baseTint
            cell.selectionStyle = .none
            return cell
            
//            if GlobalStruct.iapPurchased {
//                let cell = tableView.dequeueReusableCell(withIdentifier: "IAPCell2", for: indexPath) as! IAPCell2
//                cell.selectionStyle = .none
//                cell.backgroundColor = UIColor(named: "baseWhite")
//                return cell
//            } else {
//                let cell = tableView.dequeueReusableCell(withIdentifier: "IAPCell", for: indexPath) as! IAPCell
//                cell.selectionStyle = .none
//                cell.backgroundColor = UIColor(named: "baseWhite")
//                return cell
//            }
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell2", for: indexPath)
            cell.textLabel?.text = firstSectionToUse[indexPath.row]
            if indexPath.row == 0 {
                cell.imageView?.image = UIImage(systemName: "app", withConfiguration: symbolConfig) ?? UIImage()
            } else if indexPath.row == 1 {
                cell.imageView?.image = UIImage(systemName: "paintbrush", withConfiguration: symbolConfig) ?? UIImage()
            } else if indexPath.row == 2 {
                cell.imageView?.image = UIImage(systemName: "bolt", withConfiguration: symbolConfig) ?? UIImage()
                let switchView = UISwitch(frame: .zero)
                
                if UserDefaults.standard.value(forKey: "sync-haptics") as? Int != nil {
                    if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
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
                switchView.addTarget(self, action: #selector(self.switchHaptics(_:)), for: .valueChanged)
                cell.accessoryView = switchView
                cell.selectionStyle = .none
            } else {
                cell.accessoryType = .none
            }
            cell.backgroundColor = UIColor(named: "baseWhite")
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell3", for: indexPath)
            cell.textLabel?.text = self.secondSection[indexPath.row]
            
            if indexPath.row == 0 {
                cell.imageView?.image = UIImage(systemName: "exclamationmark.circle", withConfiguration: symbolConfig) ?? UIImage()
                let switchView = UISwitch(frame: .zero)
                
                if UserDefaults.standard.value(forKey: "sync-sensitive") as? Int != nil {
                    if UserDefaults.standard.value(forKey: "sync-sensitive") as? Int == 0 {
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
                switchView.addTarget(self, action: #selector(self.switchSensitive(_:)), for: .valueChanged)
                cell.accessoryView = switchView
                cell.selectionStyle = .none
            } else if indexPath.row == 1 {
                cell.imageView?.image = UIImage(systemName: "globe", withConfiguration: symbolConfig) ?? UIImage()
                cell.accessoryType = .none
            } else if indexPath.row == 2 {
                cell.imageView?.image = UIImage(systemName: "link", withConfiguration: symbolConfig) ?? UIImage()
                cell.accessoryType = .none
            } else if indexPath.row == 3 {
                cell.imageView?.image = UIImage(systemName: "mic", withConfiguration: symbolConfig) ?? UIImage()
                cell.accessoryType = .none
            } else {
                cell.imageView?.image = UIImage(systemName: "lock", withConfiguration: symbolConfig) ?? UIImage()
                cell.accessoryType = .none
            }
            cell.backgroundColor = UIColor(named: "baseWhite")
            return cell
        } else if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell5", for: indexPath)
            cell.imageView?.image = UIImage(systemName: "person.crop.circle", withConfiguration: symbolConfig) ?? UIImage()
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = self.accountSection[indexPath.row]
            cell.backgroundColor = UIColor(named: "baseWhite")
            return cell
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell4", for: indexPath)
            cell.accessoryType = .none
            if indexPath.row == 0 {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: "settingsCell4")
                cell.textLabel?.text = self.thirdSection[indexPath.row]
                cell.detailTextLabel?.text = "\("Designed and hand-crafted with \u{2665} by".localized) Shihab"
                cell.accessoryType = .disclosureIndicator
            } else {
                cell.textLabel?.text = self.thirdSection[indexPath.row]
                cell.accessoryType = .disclosureIndicator
            }
            cell.backgroundColor = UIColor(named: "baseWhite")
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
//            if GlobalStruct.iapPurchased {
//                SKStoreReviewController.requestReview()
//            } else {
//                if UserDefaults.standard.value(forKey: "sync-haptics") as? Int != nil {
//                    if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
//                        let imp = UIImpactFeedbackGenerator(style: .medium)
//                        imp.impactOccurred()
//                    }
//                } else {
//                    let imp = UIImpactFeedbackGenerator(style: .medium)
//                    imp.impactOccurred()
//                }
//                let vc = IAPSetttingsViewController()
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let vc = IconSettingsViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            if indexPath.row == 1 {
                let vc = TintSettingsViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 1 {
                let vc = VisibilitySettingsViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            if indexPath.row == 2 {
                let vc = BrowserSettingsViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else if indexPath.section == 3 {
            if indexPath.row == 0 {
                let vc = AccountsSettingsViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            if indexPath.row == 0 {
                
            } else {
                let vc = GetInTouchSettingsViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    //MARK: Switches
    
    @objc func switchHaptics(_ sender: UISwitch!) {
        print("table row switch Changed \(sender.tag)")
        print("The switch is \(sender.isOn ? "ON" : "OFF")")
        
        if sender.isOn {
            UserDefaults.standard.set(0, forKey: "sync-haptics")
        } else {
            UserDefaults.standard.set(1, forKey: "sync-haptics")
        }
    }
    
    @objc func switchSensitive(_ sender: UISwitch!) {
        print("table row switch Changed \(sender.tag)")
        print("The switch is \(sender.isOn ? "ON" : "OFF")")
        
        if sender.isOn {
            UserDefaults.standard.set(0, forKey: "sync-sensitive")
        } else {
            UserDefaults.standard.set(1, forKey: "sync-sensitive")
        }
    }
}

extension UITableViewCell {
    func enable(on: Bool) {
        for view in contentView.subviews {
            view.isUserInteractionEnabled = on
            view.alpha = on ? 1 : 0.5
        }
    }
}

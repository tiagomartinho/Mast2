//
//  SettingsViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 17/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

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
    let firstSection = ["App Icon".localized, "App Tint".localized, "Dark Mode Tint".localized, "Push Notifications".localized, "App Haptics".localized]
    let firstSectionPad = ["App Icon".localized, "App Tint".localized, "Dark Mode Tint".localized, "Push Notifications".localized]
    let firstSectionMac = ["App Tint".localized, "Dark Mode Tint".localized]
    let secondSection = ["Hide Sensitive Content".localized, "Upload Videos as GIFs".localized, "Default Visibility".localized, "Default Keyboard".localized, "Default Browser".localized, "Default Scan Mode".localized, "Siri Shortcuts".localized, "\("App Lock".localized)"]
    let secondSectionMac = ["Hide Sensitive Content".localized, "Upload Videos as GIFs".localized, "Default Visibility".localized]
    let accountSection = ["\("Accounts".localized)"]
    let thirdSection = ["Get in Touch".localized]
    
    override func viewDidLayoutSubviews() {
        self.tableView.frame = CGRect(x: self.view.safeAreaInsets.left, y: 0, width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: self.view.bounds.height)
    }
    
    @objc func notifChangeTint() {
        self.tableView.reloadData()
        
        self.tableView.reloadInputViews()
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
        self.title = "Settings".localized
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notifChangeBG), name: NSNotification.Name(rawValue: "notifChangeBG"), object: nil)
        
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
        
        self.navigationController?.navigationBar.backgroundColor = GlobalStruct.baseDarkTint
        self.navigationController?.navigationBar.barTintColor = GlobalStruct.baseDarkTint
        
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
        if UserDefaults.standard.value(forKey: "sync-haptics") as? Int == 0 {
            let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
            impactFeedbackgenerator.prepare()
            impactFeedbackgenerator.impactOccurred()
        }
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
            #if targetEnvironment(macCatalyst)
            return 0
            #elseif !targetEnvironment(macCatalyst)
            return 1
            #endif
        } else if section == 1 {
            #if targetEnvironment(macCatalyst)
            return self.firstSectionMac.count
            #elseif !targetEnvironment(macCatalyst)
            if UIDevice.current.userInterfaceIdiom == .pad && self.isSplitOrSlideOver == false {
                return self.firstSectionPad.count
            } else {
                return self.firstSection.count
            }
            #endif
        } else if section == 2 {
            #if targetEnvironment(macCatalyst)
            return self.secondSectionMac.count
            #elseif !targetEnvironment(macCatalyst)
            return self.secondSection.count
            #endif
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
        } else if indexPath.section == 1 && indexPath.row == 2 {
            cell.accessoryType = .disclosureIndicator
        } else if indexPath.section == 1 && indexPath.row == 3 {
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
        #if targetEnvironment(macCatalyst)
        firstSectionToUse = self.firstSectionMac
        #elseif !targetEnvironment(macCatalyst)
        if UIDevice.current.userInterfaceIdiom == .pad && self.isSplitOrSlideOver == false {
            firstSectionToUse = self.firstSectionPad
        }
        #endif
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell2", for: indexPath)
            if GlobalStruct.iapPurchased {
                cell.imageView?.image = (UIImage(systemName: "heart.circle.fill", withConfiguration: symbolConfig) ?? UIImage()).withTintColor(.white, renderingMode: .alwaysOriginal)
                cell.textLabel?.text = "You have Mast Pro".localized
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
                cell.textLabel?.textColor = UIColor.white
                cell.backgroundColor = GlobalStruct.baseTint
                cell.selectionStyle = .none
                cell.accessoryType = .none
            } else {
                cell.imageView?.image = (UIImage(systemName: "lock.circle.fill", withConfiguration: symbolConfig) ?? UIImage()).withTintColor(.white, renderingMode: .alwaysOriginal)
                cell.textLabel?.text = "Mast Pro"
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
                cell.textLabel?.textColor = UIColor.white
                cell.backgroundColor = GlobalStruct.baseTint
                cell.selectionStyle = .none
            }
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell2", for: indexPath)
            cell.textLabel?.text = firstSectionToUse[indexPath.row]
            #if targetEnvironment(macCatalyst)
            if indexPath.row == 0 {
                cell.imageView?.image = UIImage(systemName: "paintbrush", withConfiguration: symbolConfig) ?? UIImage()
            } else if indexPath.row == 1 {
                cell.imageView?.image = UIImage(systemName: "moon.circle", withConfiguration: symbolConfig) ?? UIImage()
            } else if indexPath.row == 2 {
                cell.imageView?.image = UIImage(systemName: "app.badge", withConfiguration: symbolConfig) ?? UIImage()
            } else {
                cell.accessoryType = .none
            }
            #elseif !targetEnvironment(macCatalyst)
            if indexPath.row == 0 {
                cell.imageView?.image = UIImage(systemName: "app", withConfiguration: symbolConfig) ?? UIImage()
            } else if indexPath.row == 1 {
                cell.imageView?.image = UIImage(systemName: "paintbrush", withConfiguration: symbolConfig) ?? UIImage()
            } else if indexPath.row == 2 {
                cell.imageView?.image = UIImage(systemName: "moon.circle", withConfiguration: symbolConfig) ?? UIImage()
            } else if indexPath.row == 3 {
                cell.imageView?.image = UIImage(systemName: "app.badge", withConfiguration: symbolConfig) ?? UIImage()
            } else if indexPath.row == 4 {
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
            #endif
            cell.backgroundColor = GlobalStruct.baseDarkTint
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
                cell.imageView?.image = UIImage(systemName: "paperclip.circle", withConfiguration: symbolConfig) ?? UIImage()
                let switchView = UISwitch(frame: .zero)
                
                if UserDefaults.standard.value(forKey: "sync-uploadgif") as? Int != nil {
                    if UserDefaults.standard.value(forKey: "sync-uploadgif") as? Int == 0 {
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
                switchView.addTarget(self, action: #selector(self.switchUploadgif(_:)), for: .valueChanged)
                cell.accessoryView = switchView
                cell.selectionStyle = .none
            } else if indexPath.row == 2 {
                cell.imageView?.image = UIImage(systemName: "keyboard", withConfiguration: symbolConfig) ?? UIImage()
                cell.accessoryType = .none
            } else if indexPath.row == 3 {
                cell.imageView?.image = UIImage(systemName: "globe", withConfiguration: symbolConfig) ?? UIImage()
                cell.accessoryType = .none
            } else if indexPath.row == 4 {
                cell.imageView?.image = UIImage(systemName: "link", withConfiguration: symbolConfig) ?? UIImage()
                cell.accessoryType = .none
            } else if indexPath.row == 5 {
                cell.imageView?.image = UIImage(systemName: "doc.text.viewfinder", withConfiguration: symbolConfig) ?? UIImage()
                cell.accessoryType = .none
            } else if indexPath.row == 6 {
                cell.imageView?.image = UIImage(systemName: "mic", withConfiguration: symbolConfig) ?? UIImage()
                cell.accessoryType = .none
            } else {
                cell.imageView?.image = UIImage(systemName: "lock", withConfiguration: symbolConfig) ?? UIImage()
                cell.accessoryType = .none
            }
            cell.backgroundColor = GlobalStruct.baseDarkTint
            return cell
        } else if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell5", for: indexPath)
            cell.imageView?.image = UIImage(systemName: "person.crop.circle", withConfiguration: symbolConfig) ?? UIImage()
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = self.accountSection[indexPath.row]
            cell.backgroundColor = GlobalStruct.baseDarkTint
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell4", for: indexPath)
            cell.imageView?.image = UIImage(systemName: "hand.point.right", withConfiguration: symbolConfig) ?? UIImage()
            cell.accessoryType = .none
            cell.textLabel?.text = self.thirdSection[indexPath.row]
            cell.accessoryType = .disclosureIndicator
            cell.backgroundColor = GlobalStruct.baseDarkTint
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if GlobalStruct.iapPurchased {
                SKStoreReviewController.requestReview()
            } else {
                let vc = IAPSettingsViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else if indexPath.section == 1 {
            #if targetEnvironment(macCatalyst)
            if indexPath.row == 0 {
                let vc = TintSettingsViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            if indexPath.row == 1 {
                let vc = DarkModeSettingsViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            if indexPath.row == 2 {
                let vc = NotificationsSettingsViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            #elseif !targetEnvironment(macCatalyst)
            if indexPath.row == 0 {
                let vc = IconSettingsViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            if indexPath.row == 1 {
                let vc = TintSettingsViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            if indexPath.row == 2 {
                let vc = DarkModeSettingsViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            if indexPath.row == 3 {
                let vc = NotificationsSettingsViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            #endif
        } else if indexPath.section == 2 {
            if indexPath.row == 2 {
                #if !targetEnvironment(macCatalyst)
                if GlobalStruct.iapPurchased {
                    let vc = VisibilitySettingsViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let vc = IAPSettingsViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                #elseif targetEnvironment(macCatalyst)
                let vc = VisibilitySettingsViewController()
                self.navigationController?.pushViewController(vc, animated: true)
                #endif
            }
            if indexPath.row == 3 {
                #if !targetEnvironment(macCatalyst)
                if GlobalStruct.iapPurchased {
                    let vc = BrowserSettingsViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let vc = IAPSettingsViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                #elseif targetEnvironment(macCatalyst)
                let vc = BrowserSettingsViewController()
                self.navigationController?.pushViewController(vc, animated: true)
                #endif
            }
            if indexPath.row == 4 {
                #if !targetEnvironment(macCatalyst)
                if GlobalStruct.iapPurchased {
                    let vc = KeyboardSettingsViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let vc = IAPSettingsViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                #elseif targetEnvironment(macCatalyst)
                let vc = KeyboardSettingsViewController()
                self.navigationController?.pushViewController(vc, animated: true)
                #endif
            }
            if indexPath.row == 5 {
                #if !targetEnvironment(macCatalyst)
                if GlobalStruct.iapPurchased {
                    let vc = ScanSettingsViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let vc = IAPSettingsViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                #elseif targetEnvironment(macCatalyst)
                let vc = ScanSettingsViewController()
                self.navigationController?.pushViewController(vc, animated: true)
                #endif
            }
            if indexPath.row == 6 {
                #if !targetEnvironment(macCatalyst)
                if GlobalStruct.iapPurchased {
                    let vc = ShortcutsSettingsViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let vc = IAPSettingsViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                #elseif targetEnvironment(macCatalyst)
                let vc = ShortcutsSettingsViewController()
                self.navigationController?.pushViewController(vc, animated: true)
                #endif
            }
            if indexPath.row == 7 {
                #if !targetEnvironment(macCatalyst)
                if GlobalStruct.iapPurchased {
                    let vc = LockSettingsViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let vc = IAPSettingsViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                #elseif targetEnvironment(macCatalyst)
                let vc = LockSettingsViewController()
                self.navigationController?.pushViewController(vc, animated: true)
                #endif
            }
        } else if indexPath.section == 3 {
            if indexPath.row == 0 {
                let vc = AccountsSettingsViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            let vc = GetInTouchSettingsViewController()
            self.navigationController?.pushViewController(vc, animated: true)
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
    
    @objc func switchUploadgif(_ sender: UISwitch!) {
        print("table row switch Changed \(sender.tag)")
        print("The switch is \(sender.isOn ? "ON" : "OFF")")
        
        if sender.isOn {
            UserDefaults.standard.set(0, forKey: "sync-uploadgif")
        } else {
            UserDefaults.standard.set(1, forKey: "sync-uploadgif")
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

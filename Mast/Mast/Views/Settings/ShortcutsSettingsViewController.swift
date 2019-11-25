//
//  ShortcutsSettingsViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 20/11/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import CoreSpotlight
import IntentsUI
import MobileCoreServices

class ShortcutsSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, INUIAddVoiceShortcutViewControllerDelegate {
    
    var tableView = UITableView()
    let firstSection = ["Create Toot".localized, "View Notifications".localized, "View Messages".localized]
    var latestTapped = 0
    
    override func viewDidLayoutSubviews() {
        self.tableView.frame = CGRect(x: self.view.safeAreaInsets.left, y: 0, width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: self.view.bounds.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "lighterBaseWhite")
        self.title = "Siri Shortcuts".localized
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
        
        if let userP = UserDefaults.standard.value(forKey: "siriPhrases") as? [String] {
            for _ in self.firstSection {
                GlobalStruct.siriPhrases.append("")
            }
            GlobalStruct.siriPhrases = userP
            if GlobalStruct.siriPhrases.count < self.firstSection.count {
                for _ in 0..<(self.firstSection.count - GlobalStruct.siriPhrases.count) {
                    GlobalStruct.siriPhrases.append("")
                }
            }
        } else {
            for _ in self.firstSection {
                GlobalStruct.siriPhrases.append("")
            }
        }

        self.tableView.reloadData()
    }
    
    //MARK: TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.firstSection.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
        cell = UITableViewCell(style: .subtitle, reuseIdentifier: "settingsCell")
        cell.textLabel?.text = self.firstSection[indexPath.row]
        cell.backgroundColor = GlobalStruct.baseDarkTint
        
        if GlobalStruct.siriPhrases[indexPath.row] == "" {
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .regular)
            let addButton = UIButton()
            let plusImage = UIImage(systemName: "plus", withConfiguration: symbolConfig)
            let tintedPlusImage = plusImage?.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal)
            addButton.setImage(tintedPlusImage, for: .normal)
            addButton.sizeToFit()
            addButton.setTitleColor(GlobalStruct.baseTint, for: .normal)
            addButton.backgroundColor = .clear
            addButton.tag = indexPath.row
            addButton.addTarget(self, action: #selector(addSiri), for: .touchUpInside)
            cell.accessoryView = addButton
        } else {
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .regular)
            let addButton = UIButton()
            let plusImage = UIImage(systemName: "ellipsis", withConfiguration: symbolConfig)
            let tintedPlusImage = plusImage?.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal)
            addButton.setImage(tintedPlusImage, for: .normal)
            addButton.sizeToFit()
            addButton.setTitleColor(GlobalStruct.baseTint, for: .normal)
            addButton.backgroundColor = .clear
            addButton.tag = indexPath.row
            addButton.addTarget(self, action: #selector(addSiri), for: .touchUpInside)
            cell.accessoryView = addButton
            cell.detailTextLabel?.text = "\"\(GlobalStruct.siriPhrases[indexPath.row])\""
        }
        
        return cell
    }
    
    @objc func addSiri(_ button: UIButton) {
        #if !targetEnvironment(macCatalyst)
        let imp = UIImpactFeedbackGenerator(style: .light)
        imp.impactOccurred()
        
        self.latestTapped = button.tag
        
        if self.latestTapped == 0 {
            let activity1 = NSUserActivity(activityType: "com.shi.Mast.newToot")
            activity1.title = "Create a new toot".localized
            let attributes = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String)
            attributes.contentDescription = "Create a new toot".localized
            activity1.contentAttributeSet = attributes
            activity1.isEligibleForSearch = true
            activity1.isEligibleForPrediction = true
            activity1.persistentIdentifier = "com.shi.Allegory.newToot"
            activity1.suggestedInvocationPhrase = "Create a new toot".localized
            activity1.persistentIdentifier = String(button.tag)
            self.view.userActivity = activity1
            activity1.becomeCurrent()
            let shortcut = INShortcut(userActivity: activity1)
            let vc = INUIAddVoiceShortcutViewController(shortcut: shortcut)
            vc.delegate = self
            present(vc, animated: true, completion: nil)
        } else if self.latestTapped == 1 {
            let activity1 = NSUserActivity(activityType: "com.shi.Mast.viewNotifs")
            activity1.title = "View your notifications".localized
            let attributes = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String)
            attributes.contentDescription = "View your notifications".localized
            activity1.contentAttributeSet = attributes
            activity1.isEligibleForSearch = true
            activity1.isEligibleForPrediction = true
            activity1.persistentIdentifier = "com.shi.Mast.viewNotifs"
            activity1.suggestedInvocationPhrase = "View your notifications".localized
            activity1.persistentIdentifier = String(button.tag)
            self.view.userActivity = activity1
            activity1.becomeCurrent()
            let shortcut = INShortcut(userActivity: activity1)
            let vc = INUIAddVoiceShortcutViewController(shortcut: shortcut)
            vc.delegate = self
            present(vc, animated: true, completion: nil)
        } else if self.latestTapped == 2 {
            let activity1 = NSUserActivity(activityType: "com.shi.Mast.viewMessages")
            activity1.title = "View your messages".localized
            let attributes = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String)
            attributes.contentDescription = "View your messages".localized
            activity1.contentAttributeSet = attributes
            activity1.isEligibleForSearch = true
            activity1.isEligibleForPrediction = true
            activity1.persistentIdentifier = "com.shi.Mast.viewMessages"
            activity1.suggestedInvocationPhrase = "View your messages".localized
            activity1.persistentIdentifier = String(button.tag)
            self.view.userActivity = activity1
            activity1.becomeCurrent()
            let shortcut = INShortcut(userActivity: activity1)
            let vc = INUIAddVoiceShortcutViewController(shortcut: shortcut)
            vc.delegate = self
            present(vc, animated: true, completion: nil)
        }
        #endif
    }
    
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        if let cell = self.tableView.cellForRow(at: IndexPath(row: self.latestTapped, section: 0)) {
            GlobalStruct.siriPhrases[self.latestTapped] = "\(voiceShortcut?.invocationPhrase ?? "")"
            UserDefaults.standard.set(GlobalStruct.siriPhrases, forKey: "siriPhrases")
            
            let phrase = "\(voiceShortcut?.invocationPhrase ?? "Phrase Added")"
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .regular)
            let addButton = UIButton()
            let plusImage = UIImage(systemName: "ellipsis", withConfiguration: symbolConfig)
            let tintedPlusImage = plusImage?.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal)
            addButton.setImage(tintedPlusImage, for: .normal)
            addButton.sizeToFit()
            addButton.setTitleColor(GlobalStruct.baseTint, for: .normal)
            addButton.backgroundColor = .clear
            addButton.addTarget(self, action: #selector(addSiri), for: .touchUpInside)
            cell.accessoryView = addButton
            cell.detailTextLabel?.text = "\"\(phrase)\""
            self.tableView.reloadData()
        }
        dismiss(animated: true, completion: nil)
    }
    
    func addVoiceShortcutViewControllerDidCancel(
        _ controller: INUIAddVoiceShortcutViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}


//
//  TootViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 17/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import Photos
import AVKit
import AVFoundation
import MobileCoreServices
import Vision
import VisionKit
import MediaPlayer

class TootViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate, VNDocumentCameraViewControllerDelegate, UIAdaptivePresentationControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
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
    var keyHeight: CGFloat = 0
    var moreButton = UIButton()
    var images: [PHAsset] = []
    var selectedImages: [Int] = []
    var replyStatus: [Status] = []
    let photoPickerView = UIImagePickerController()
    var allPrevious: [Status] = []
    var placeholderLabel = UILabel()
    var txt = ""
    var contentWarning = ""
    var scheduleTime: String?
    var defaultVisibility: Visibility = .public
    var formatToolbar = UIToolbar()
    let btn1 = UIButton(type: .custom)
    let btn2 = UIButton(type: .custom)
    var x0 = UIBarButtonItem()
    var x1 = UIBarButtonItem()
    var x2 = UIBarButtonItem()
    var x3 = UIBarButtonItem()
    var x4 = UIBarButtonItem()
    var x5 = UIBarButtonItem()
    var x6 = UIBarButtonItem()
    var x7 = UIBarButtonItem()
    var gifVidDataToAttachArray: [Data] = []
    var photoToAttachArray: [Data] = []
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        self.saveToDrafts()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Text view
        self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: (self.view.bounds.height) - self.keyHeight)
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
            cell.textView.frame.size.height = (self.view.bounds.height) - self.keyHeight
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "lighterBaseWhite")
        self.title = "New Toot".localized
//        self.removeTabbarItemsText()
        
        self.navigationController?.presentationController?.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.addEmoji), name: NSNotification.Name(rawValue: "addEmoji"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.addCurrentDraft), name: NSNotification.Name(rawValue: "addCurrentDraft"), object: nil)
        
        if let x = UserDefaults.standard.value(forKey: "sync-allDrafts") as? [String] {
            GlobalStruct.allDrafts = x
        }
        
        // Add button
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
        btn1.setImage(UIImage(systemName: "checkmark", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn1.addTarget(self, action: #selector(self.tickTapped), for: .touchUpInside)
        btn1.accessibilityLabel = "Post".localized
        let addButton = UIBarButtonItem(customView: btn1)
        self.navigationItem.setRightBarButton(addButton, animated: true)
        
        btn2.setImage(UIImage(systemName: "xmark", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        btn2.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn2.addTarget(self, action: #selector(self.crossTapped), for: .touchUpInside)
        btn2.accessibilityLabel = "Dismiss".localized
        let settingsButton = UIBarButtonItem(customView: btn2)
        self.navigationItem.setLeftBarButton(settingsButton, animated: true)
        
        if UserDefaults.standard.value(forKey: "sync-chosenVisibility") as? Int == 0 {
            self.defaultVisibility = .public
        } else if UserDefaults.standard.value(forKey: "sync-chosenVisibility") as? Int == 1 {
            self.defaultVisibility = .unlisted
        } else if UserDefaults.standard.value(forKey: "sync-chosenVisibility") as? Int == 2 {
            self.defaultVisibility = .private
        } else {
            self.defaultVisibility = .direct
        }
        
        // Table
        self.tableView.register(ComposeCell.self, forCellReuseIdentifier: "ComposeCell")
        self.tableView.register(TootCell.self, forCellReuseIdentifier: "PrevCell")
        self.tableView.register(TootImageCell.self, forCellReuseIdentifier: "PrevImageCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.separatorColor = UIColor(named: "baseBlack")?.withAlphaComponent(0.24)
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.layer.masksToBounds = true
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.tableFooterView = UIView()
        self.view.addSubview(self.tableView)
        
        if self.replyStatus.isEmpty {

        } else {
            self.fetchReplies()
        }
    }
    
    func fetchReplies() {
        let request = Statuses.context(id: self.replyStatus[0].id)
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                DispatchQueue.main.async {
                    self.allPrevious = (stat.ancestors)
                    self.allPrevious.append(self.replyStatus[0])
                    self.tableView.reloadData()
                    if self.allPrevious.count == 0 {} else {
                        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: false)
                        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
                            cell.textView.becomeFirstResponder()

                            UIView.setAnimationsEnabled(false)
                            self.tableView.beginUpdates()
                            self.tableView.endUpdates()
                            UIView.setAnimationsEnabled(true)
                        }
                    }
                }
            }
        }
    }
    
    @objc func addCurrentDraft() {
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
            cell.textView.text = GlobalStruct.currentDraft
            GlobalStruct.allDrafts = GlobalStruct.allDrafts.filter { (draft) -> Bool in
                if draft == GlobalStruct.currentDraft {
                    return false
                } else {
                    return true
                }
            }
            UserDefaults.standard.set(GlobalStruct.allDrafts, forKey: "sync-allDrafts")
            cell.textView.becomeFirstResponder()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 && (!replyStatus.isEmpty) {
            return 30
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 && (!replyStatus.isEmpty) {
            let vw = UIView()
            vw.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 30)
            vw.backgroundColor = UIColor(named: "baseWhite")
            let replyText = UITextView()
            replyText.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 30)
            replyText.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize, weight: .regular)
            replyText.backgroundColor = UIColor(named: "baseWhite")
            replyText.showsVerticalScrollIndicator = false
            replyText.showsHorizontalScrollIndicator = false
            replyText.alwaysBounceVertical = true
            replyText.isScrollEnabled = true
            replyText.textContainerInset = UIEdgeInsets(top: 5, left: 18, bottom: 5, right: 18)
            replyText.isEditable = false
            replyText.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.6)
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 13)
            let upImage = UIImage(systemName: "arrow.turn.down.right", withConfiguration: symbolConfig)
            let tintedUpImage = upImage?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.36), renderingMode: .alwaysOriginal)
            let attachment = NSTextAttachment()
            attachment.image = tintedUpImage
            let attString = NSAttributedString(attachment: attachment)
            let normalFont = UIFont.systemFont(ofSize: 14)
            let attStringNewLine = NSMutableAttributedString(string: "", attributes: [NSAttributedString.Key.font : normalFont, NSAttributedString.Key.foregroundColor : UIColor(named: "baseBlack")!.withAlphaComponent(0.36)])
            let attStringNewLine2 = NSMutableAttributedString(string: " \("Replying to".localized) @\(replyStatus.first?.account.acct ?? "")", attributes: [NSAttributedString.Key.font : normalFont, NSAttributedString.Key.foregroundColor : UIColor(named: "baseBlack")!.withAlphaComponent(0.36)])
            attStringNewLine.append(attString)
            attStringNewLine.append(attStringNewLine2)
            replyText.attributedText = attStringNewLine
            vw.addSubview(replyText)
            return vw
        } else {
            return nil
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.allPrevious.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            var he: CGFloat = (self.view.bounds.height) - self.keyHeight - 94
            if he < 0 {
                he = 0
            }
            return he
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if self.allPrevious[indexPath.row].mediaAttachments.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PrevCell", for: indexPath) as! TootCell
                if self.allPrevious.isEmpty {} else {
                    cell.configure(self.allPrevious[indexPath.row])
                }
                cell.backgroundColor = UIColor(named: "baseWhite")
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PrevImageCell", for: indexPath) as! TootImageCell
                if self.allPrevious.isEmpty {} else {
                    cell.configure(self.allPrevious[indexPath.row])
                }
                cell.backgroundColor = UIColor(named: "baseWhite")
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ComposeCell", for: indexPath) as! ComposeCell
            cell.backgroundColor = UIColor(named: "lighterBaseWhite")
            cell.textView.delegate = self

            let symbolConfig6 = UIImage.SymbolConfiguration(pointSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .regular)
            formatToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 70))
            formatToolbar.tintColor = UIColor(named: "baseBlack")!
            formatToolbar.barStyle = UIBarStyle.default
            formatToolbar.isTranslucent = true
            let fixedS = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
            fixedS.width = 8
            
            var visibilityIcon = "globe"
            if self.defaultVisibility == .public {
                visibilityIcon = "globe"
            } else if self.defaultVisibility == .unlisted {
                visibilityIcon = "lock.open"
            } else if self.defaultVisibility == .private {
                visibilityIcon = "lock"
            } else {
                visibilityIcon = "paperplane"
            }
            
            x1 = UIBarButtonItem(image: UIImage(systemName: "plus.circle", withConfiguration: symbolConfig6)!.withTintColor(UIColor(named: "baseBlack")!, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(self.cameraPicker))
            x1.accessibilityLabel = "Add Media".localized
            x2 = UIBarButtonItem(image: UIImage(systemName: visibilityIcon, withConfiguration: symbolConfig6)!.withTintColor(UIColor(named: "baseBlack")!, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(self.visibilityTap))
            x2.accessibilityLabel = "Visibility".localized
            x3 = UIBarButtonItem(image: UIImage(systemName: "exclamationmark.shield", withConfiguration: symbolConfig6)!.withTintColor(UIColor(named: "baseBlack")!, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(self.contentTap))
            x3.accessibilityLabel = "Add Spoiler".localized
            x4 = UIBarButtonItem(image: UIImage(systemName: "smiley", withConfiguration: symbolConfig6)!.withTintColor(UIColor(named: "baseBlack")!, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(self.smileyTap))
            x4.accessibilityLabel = "Emoticons".localized
            x5 = UIBarButtonItem(image: UIImage(systemName: "clock", withConfiguration: symbolConfig6)!.withTintColor(UIColor(named: "baseBlack")!, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(self.scheduleTap))
            x5.accessibilityLabel = "Schedule Toot".localized
            x6 = UIBarButtonItem(image: UIImage(systemName: "doc.text", withConfiguration: symbolConfig6)!.withTintColor(UIColor(named: "baseBlack")!, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(self.viewDrafts))
            x6.accessibilityLabel = "Drafts".localized
            x7 = UIBarButtonItem(title: "\(GlobalStruct.maxChars)", style: .plain, target: self, action: #selector(self.viewMore))
            x7.accessibilityLabel = "Characters".localized
            formatToolbar.items = [
                x1,
                fixedS,
                x2,
                fixedS,
                x3,
                fixedS,
                x4,
                fixedS,
                x5,
                fixedS,
                x6,
                UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil),
                x7
            ]
            formatToolbar.sizeToFit()
            cell.textView.inputAccessoryView = formatToolbar
            
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView = bgColorView
            return cell
        }
    }
    
    @objc func viewDrafts() {
        let alert = UIAlertController(style: .actionSheet, message: nil)
        alert.addDraftsPicker(type: .country) { info in
            // action with selected object
        }
        alert.addAction(title: "Dismiss".localized, style: .cancel) { action in
            
        }
        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = self.x6.value(forKey: "view") as? UIView
            presenter.sourceRect = (self.x6.value(forKey: "view") as? UIView)?.bounds ?? self.view.bounds
        }
        if UIDevice.current.userInterfaceIdiom == .pad && self.isSplitOrSlideOver == false {
            alert.show()
        } else {
            getTopMostViewController()?.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func visibilityTap() {
        let symbolConfig6 = UIImage.SymbolConfiguration(pointSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .regular)
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let op1 = UIAlertAction(title: "Public".localized, style: .default , handler:{ (UIAlertAction) in
            self.defaultVisibility = .public
            self.x2 = UIBarButtonItem(image: UIImage(systemName: "globe", withConfiguration: symbolConfig6)!.withTintColor(UIColor(named: "baseBlack")!, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(self.visibilityTap))
            self.x2.accessibilityLabel = "Visibility".localized
            self.formatToolbar.items?[2] = self.x2
        })
        op1.setValue(UIImage(systemName: "globe")!, forKey: "image")
        op1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op1)
        let op3 = UIAlertAction(title: "Unlisted".localized, style: .default , handler:{ (UIAlertAction) in
            self.defaultVisibility = .unlisted
            self.x2 = UIBarButtonItem(image: UIImage(systemName: "lock.open", withConfiguration: symbolConfig6)!.withTintColor(UIColor(named: "baseBlack")!, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(self.visibilityTap))
            self.x2.accessibilityLabel = "Visibility".localized
            self.formatToolbar.items?[2] = self.x2
        })
        op3.setValue(UIImage(systemName: "lock.open")!, forKey: "image")
        op3.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op3)
        let op4 = UIAlertAction(title: " \("Followers".localized)", style: .default , handler:{ (UIAlertAction) in
            self.defaultVisibility = .private
            self.x2 = UIBarButtonItem(image: UIImage(systemName: "lock", withConfiguration: symbolConfig6)!.withTintColor(UIColor(named: "baseBlack")!, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(self.visibilityTap))
            self.x2.accessibilityLabel = "Visibility".localized
            self.formatToolbar.items?[2] = self.x2
        })
        op4.setValue(UIImage(systemName: "lock")!, forKey: "image")
        op4.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op4)
        let op6 = UIAlertAction(title: "Direct".localized, style: .default , handler:{ (UIAlertAction) in
            self.defaultVisibility = .direct
            self.x2 = UIBarButtonItem(image: UIImage(systemName: "paperplane", withConfiguration: symbolConfig6)!.withTintColor(UIColor(named: "baseBlack")!, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(self.visibilityTap))
            self.x2.accessibilityLabel = "Visibility".localized
            self.formatToolbar.items?[2] = self.x2
        })
        op6.setValue(UIImage(systemName: "paperplane")!, forKey: "image")
        op6.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op6)
        alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
            
        }))
        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = self.x2.value(forKey: "view") as? UIView
            presenter.sourceRect = (self.x2.value(forKey: "view") as? UIView)?.bounds ?? self.view.bounds
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func contentTap() {
        let alert = UIAlertController(style: .actionSheet, title: nil)
        let config: TextField1.Config = { textField in
            textField.becomeFirstResponder()
            textField.textColor = UIColor(named: "baseBlack")!
            if self.contentWarning == "" {
                textField.placeholder = "Content warning...".localized
            } else {
                textField.text = self.contentWarning
            }
            textField.layer.borderWidth = 0
            textField.layer.cornerRadius = 8
            textField.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
            textField.backgroundColor = nil
            textField.keyboardAppearance = .default
            textField.keyboardType = .URL
            textField.autocapitalizationType = .none
            textField.isSecureTextEntry = false
            textField.returnKeyType = .default
            textField.action { textField in
                self.txt = textField.text ?? ""
            }
        }
        alert.addOneTextField(configuration: config)
        alert.addAction(title: "Add".localized, style: .default) { action in
            self.contentWarning = self.txt
        }
        alert.addAction(title: "Dismiss".localized, style: .cancel) { action in
            
        }
        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = self.x3.value(forKey: "view") as? UIView
            presenter.sourceRect = (self.x3.value(forKey: "view") as? UIView)?.bounds ?? self.view.bounds
        }
        if UIDevice.current.userInterfaceIdiom == .pad && self.isSplitOrSlideOver == false {
            alert.show()
        } else {
            getTopMostViewController()?.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func pollTap() {
        
    }
    
    @objc func addEmoji() {
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
            if cell.textView.text.count == 0 {
                cell.textView.text = ":\(GlobalStruct.emoticonToAdd):"
            } else {
                cell.textView.text = "\(cell.textView.text ?? ""):\(GlobalStruct.emoticonToAdd):"
            }
            cell.textView.becomeFirstResponder()
        }
    }
    
    @objc func smileyTap() {
        let alert = UIAlertController(style: .actionSheet, message: nil)
        alert.addEmoticonPicker(type: .country) { info in
            // action with selected object
        }
        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = self.x4.value(forKey: "view") as? UIView
            presenter.sourceRect = (self.x4.value(forKey: "view") as? UIView)?.bounds ?? self.view.bounds
        }
        alert.addAction(title: "Dismiss", style: .cancel)
        if UIDevice.current.userInterfaceIdiom == .pad && self.isSplitOrSlideOver == false {
            let height:NSLayoutConstraint = NSLayoutConstraint(item: alert.view!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 350)
            alert.view.addConstraint(height)
            alert.show()
        } else {
            getTopMostViewController()?.present(alert, animated: true, completion: nil)
        }
    }
    
    func getTopMostViewController() -> UIViewController? {
        var topMostViewController = UIApplication.shared.keyWindow?.rootViewController
        while let presentedViewController = topMostViewController?.presentedViewController {
            topMostViewController = presentedViewController
        }
        return topMostViewController
    }
    
    @objc func scheduleTap() {
        let alert = UIAlertController(style: .actionSheet, title: nil)
        alert.addDatePicker(mode: .dateAndTime, date: Date().adjust(.minute, offset: 5), minimumDate: Date().adjust(.minute, offset: 5), maximumDate: Date().adjust(.year, offset: 10)) { date in
            self.txt = date.iso8601String
        }
        alert.addAction(title: "Schedule".localized, style: .default) { action in
            self.scheduleTime = self.txt
        }
        if self.scheduleTime != nil {
            alert.addAction(title: "Remove Scheduled Toot".localized, style: .destructive) { action in
                self.scheduleTime = nil
            }
        }
        alert.addAction(title: "Dismiss".localized, style: .cancel) { action in
            
        }
        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = self.x5.value(forKey: "view") as? UIView
            presenter.sourceRect = (self.x5.value(forKey: "view") as? UIView)?.bounds ?? self.view.bounds
        }
        if UIDevice.current.userInterfaceIdiom == .pad && self.isSplitOrSlideOver == false {
            alert.show()
        } else {
            getTopMostViewController()?.present(alert, animated: true, completion: nil)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: true)
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
            cell.textView.becomeFirstResponder()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
            placeholderLabel = UILabel()
            placeholderLabel.text = "What's happening?".localized
            placeholderLabel.font = UIFont.systemFont(ofSize: (cell.textView.font?.pointSize)!)
            placeholderLabel.sizeToFit()
            cell.textView.addSubview(placeholderLabel)
            placeholderLabel.frame.origin = CGPoint(x: 25, y: 10)
            placeholderLabel.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.3)
            
            cell.textView.becomeFirstResponder()
            if cell.textView.text.isEmpty {
                self.isModalInPresentation = false
            } else {
                self.isModalInPresentation = true
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == "" {
            self.placeholderLabel.isHidden = false
            self.placeholderLabel.alpha = 1
        } else {
            self.placeholderLabel.isHidden = true
            self.placeholderLabel.alpha = 0
        }
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
            var maxChars = GlobalStruct.maxChars - (cell.textView.text?.count ?? 0)
//            self.title = "\(maxChars)"
//            if maxChars < 1 {
//                self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemRed]
//                btn1.setImage(UIImage(systemName: "checkmark", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
//            } else if maxChars < 20 {
//                self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemOrange]
//                btn1.setImage(UIImage(systemName: "checkmark", withConfiguration: symbolConfig)?.withTintColor(GlobalStruct.baseTint.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
//            } else {
//                self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "baseBlack")!]
//                btn1.setImage(UIImage(systemName: "checkmark", withConfiguration: symbolConfig)?.withTintColor(GlobalStruct.baseTint.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
//            }
            
            self.x7 = UIBarButtonItem(title: "\(maxChars)", style: .plain, target: self, action: #selector(self.viewMore))
            self.x7.accessibilityLabel = "Characters".localized
            self.formatToolbar.items?[12] = self.x7
            
            if cell.textView.text.isEmpty {
                self.isModalInPresentation = false
                btn1.setImage(UIImage(systemName: "checkmark", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
            } else {
                self.isModalInPresentation = true
            }
        }

        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
//            cell.textView.resignFirstResponder()
//        }
    }
    
    private func getPhotosAndVideos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d || mediaType = %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.image.rawValue)
        fetchOptions.fetchLimit = 100
        let imagesAndVideos = PHAsset.fetchAssets(with: fetchOptions)
        let rangeLength = min(imagesAndVideos.count, 100)
        let range = NSRange(location: 0, length: 100 != 0 ? rangeLength: 100)
        let indexes = NSIndexSet(indexesIn: range)
        imagesAndVideos.enumerateObjects(at: indexes as IndexSet, options: []) { asset, index, stop in
            self.images.append(asset)
        }
    }
    
    private func checkAuthorizationForPhotoLibraryAndGet() {
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == PHAuthorizationStatus.authorized) {
            self.getPhotosAndVideos()
        } else {
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                if (newStatus == PHAuthorizationStatus.authorized) {
                    self.getPhotosAndVideos()
                }
            })
        }
    }
    
    func moreAudio() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let op1 = UIAlertAction(title: " \("Audio from Documents".localized)".localized, style: .default , handler:{ (UIAlertAction) in
            
        })
        op1.setValue(UIImage(systemName: "doc.text.magnifyingglass")!, forKey: "image")
        op1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op1)
        let op2 = UIAlertAction(title: "  \("Record Audio".localized)".localized, style: .default , handler:{ (UIAlertAction) in
            
        })
        op2.setValue(UIImage(systemName: "mic")!, forKey: "image")
        op2.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op2)
        alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
            
        }))
        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = self.x6.value(forKey: "view") as? UIView
            presenter.sourceRect = (self.x6.value(forKey: "view") as? UIView)?.bounds ?? self.view.bounds
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func viewMore() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let op9 = UIAlertAction(title: "Clear All".localized, style: .destructive , handler:{ (UIAlertAction) in
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
                cell.textView.text = ""
            }
        })
        op9.setValue(UIImage(systemName: "xmark")!, forKey: "image")
        op9.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op9)
        alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
            
        }))
        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = self.x6.value(forKey: "view") as? UIView
            presenter.sourceRect = (self.x6.value(forKey: "view") as? UIView)?.bounds ?? self.view.bounds
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func tickTapped() {
        self.dismiss(animated: true, completion: nil)
        
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
            var theReplyID: String? = nil
            var theSensitive = false
            var theSpoiler: String? = nil
            var theVisibility = Visibility.public
            var theMainText = cell.textView.text ?? ""
            if self.replyStatus.isEmpty {
                
            } else {
                theReplyID = self.replyStatus.first?.id ?? nil
                theSensitive = self.replyStatus.first?.sensitive ?? false
                if self.contentWarning == "" {
                    theSpoiler = self.replyStatus.first?.spoilerText ?? self.contentWarning
                } else {
                    theSpoiler = self.contentWarning
                }
                if self.defaultVisibility == .public {
                    theVisibility = self.replyStatus.first?.visibility ?? self.defaultVisibility
                }
                theMainText = "@\(self.replyStatus.first?.account.acct ?? "") \(theMainText)"
            }
            let request = Statuses.create(status: theMainText, replyToID: theReplyID, mediaIDs: [], sensitive: theSensitive, spoilerText: theSpoiler, scheduledAt: self.scheduleTime, poll: nil, visibility: theVisibility)
            GlobalStruct.client.run(request) { (statuses) in
                if let _ = (statuses.value) {
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "updatePosted"), object: nil)
                    }
                }
            }
        }
    }
    
    @objc func crossTapped() {
        self.saveToDrafts()
    }
    
    func saveToDrafts() {
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
            if cell.textView.text.isEmpty {
                self.dismiss(animated: true, completion: nil)
            } else {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    cell.textView.resignFirstResponder()
                }
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let op1 = UIAlertAction(title: "Save Draft".localized, style: .default , handler:{ (UIAlertAction) in
                    if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
                        GlobalStruct.allDrafts.append(cell.textView.text ?? "")
                        UserDefaults.standard.set(GlobalStruct.allDrafts, forKey: "sync-allDrafts")
                        self.dismiss(animated: true, completion: nil)
                    }
                })
                op1.setValue(UIImage(systemName: "doc.append")!, forKey: "image")
                op1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
                alert.addAction(op1)
                let op2 = UIAlertAction(title: "Discard".localized, style: .destructive , handler:{ (UIAlertAction) in
                    self.dismiss(animated: true, completion: nil)
                })
                op2.setValue(UIImage(systemName: "xmark")!, forKey: "image")
                op2.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
                alert.addAction(op2)
                alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
                    cell.textView.becomeFirstResponder()
                }))
                if let presenter = alert.popoverPresentationController {
                    presenter.sourceView = self.btn2
                    presenter.sourceRect = self.btn2.bounds
                }
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let fileURL = urls.first!
        if let theData = NSData(contentsOf: fileURL) {
//            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
//                let attachment = NSTextAttachment()
//                attachment.image = UIImage(data: theData as Data)
//                let imWidth = attachment.image!.size.width
//                let imHeight = attachment.image!.size.height
//                let ratio = imWidth/imHeight
//                attachment.bounds = CGRect(x: 5, y: 5, width: cell.textView.frame.size.width - 15, height: ((cell.textView.frame.size.width - 15)/ratio) - 10)
//
//                let normalFont = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
//                let attStringNewLine = NSMutableAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font : normalFont, NSAttributedString.Key.foregroundColor : UIColor(named: "baseBlack")!])
//                let attString = NSAttributedString(attachment: attachment)
//
//                guard let selectedRange = cell.textView.selectedTextRange else {
//                    return
//                }
//                let cursorIndex = self.textView.offset(from: self.textView.beginningOfDocument, to: selectedRange.start)
//                cell.textView.textStorage.insert(attString, at: cursorIndex)
//                if cell.textView.text.isEmpty {} else {
//                    cell.textView.textStorage.insert(attStringNewLine, at: cursorIndex)
//                }
//                cell.textView.textStorage.append(attStringNewLine)
//                self.hapticPatternType3()
//                self.fromScan = true
//            }
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.photoPickerView.dismiss(animated: true, completion: {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
                cell.textView.becomeFirstResponder()
            }
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String {
            if mediaType == "public.movie" || mediaType == kUTTypeGIF as String {
                let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as! NSURL
                do {
                    let gifVidDataToAttach = try NSData(contentsOf: videoURL as URL, options: .mappedIfSafe) as Data
                    self.gifVidDataToAttachArray.append(gifVidDataToAttach)
                } catch {
                    print("error")
                }
            } else {
                if let photoToAttach = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage ?? UIImage()).pngData() {
                    self.photoToAttachArray.append(photoToAttach)
                }
            }
        }
        self.photoPickerView.dismiss(animated: true, completion: nil)
    }
    
    func textFromImage(_ image1: UIImage) {
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
            let request = VNRecognizeTextRequest { request, error in
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    return
                }
                for observation in observations {
                    guard let bestCandidate = observation.topCandidates(1).first else {
                        continue
                    }
                    var bestString = " \(bestCandidate.string)"
                    if cell.textView.text.isEmpty {
                        bestString = bestCandidate.string
                    }
                    let normalFont = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
                    let attStringVision = NSMutableAttributedString(string: bestString, attributes: [NSAttributedString.Key.font : normalFont, NSAttributedString.Key.foregroundColor : UIColor(named: "baseBlack")!])
                    cell.textView.textStorage.append(attStringVision)
                    let newPosition = cell.textView.endOfDocument
                    cell.textView.selectedTextRange = cell.textView.textRange(from: newPosition, to: newPosition)
                }
            }
            request.recognitionLevel = .accurate
            let requests = [request]
            guard let img = image1.cgImage else {
                return
            }
            let handler = VNImageRequestHandler(cgImage: img, options: [:])
            try? handler.perform(requests)
        }
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true, completion: {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
                cell.textView.becomeFirstResponder()
            }
        })
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        print(error)
        controller.dismiss(animated: true, completion: {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
                cell.textView.becomeFirstResponder()
            }
        })
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                return
            }
            for observation in observations {
                guard let bestCandidate = observation.topCandidates(1).first else {
                    continue
                }
                var bestString = " \(bestCandidate.string)"

                if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
                    if cell.textView.text.isEmpty {
                        bestString = bestCandidate.string
                    }
                    let normalFont = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
                    let attStringVision = NSMutableAttributedString(string: bestString, attributes: [NSAttributedString.Key.font : normalFont, NSAttributedString.Key.foregroundColor : UIColor(named: "baseBlack")!])
                    cell.textView.textStorage.append(attStringVision)
                    let newPosition = cell.textView.endOfDocument
                    cell.textView.selectedTextRange = cell.textView.textRange(from: newPosition, to: newPosition)
                }
                
            }
        }
        if (UserDefaults.standard.value(forKey: "sync-scanMode") as? Int) == 0 {
            request.recognitionLevel = .accurate
        } else if (UserDefaults.standard.value(forKey: "sync-scanMode") as? Int) == 1 {
            request.recognitionLevel = .fast
        }
        let requests = [request]
        for i in 0 ..< scan.pageCount {
            let image1 = scan.imageOfPage(at: i)
            guard let img = image1.cgImage else {
                return
            }
            let handler = VNImageRequestHandler(cgImage: img, options: [:])
            try? handler.perform(requests)
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    func cameraVisionText() {
        let visionPickerView = VNDocumentCameraViewController()
        visionPickerView.delegate = self
        self.present(visionPickerView, animated: true)
    }
    
    @objc func cameraPicker() {
        if UIDevice.current.userInterfaceIdiom == .phone {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
                cell.textView.resignFirstResponder()
            }
        }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let camA = UIAlertAction(title: "Camera".localized, style: .default , handler:{ (UIAlertAction) in
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                if response {
                    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                        DispatchQueue.main.async {
                            self.photoPickerView.delegate = self
                            self.photoPickerView.sourceType = .camera
                            self.photoPickerView.mediaTypes = [kUTTypeImage as String]
                            self.photoPickerView.allowsEditing = false
                            self.present(self.photoPickerView, animated: true, completion: nil)
                        }
                    }
                }
            }
        })
        camA.setValue(UIImage(systemName: "camera")!, forKey: "image")
        camA.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(camA)
        let galA = UIAlertAction(title: "Image Gallery".localized, style: .default , handler:{ (UIAlertAction) in
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                if response {
                    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                        DispatchQueue.main.async {
                            self.photoPickerView.delegate = self
                            self.photoPickerView.sourceType = .photoLibrary
                            self.photoPickerView.mediaTypes = [kUTTypeImage as String]
                            self.present(self.photoPickerView, animated: true, completion: nil)
                        }
                    }
                }
            }
        })
        galA.setValue(UIImage(systemName: "photo")!, forKey: "image")
        galA.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(galA)
        let galA2 = UIAlertAction(title: " \("Image from Documents".localized)", style: .default , handler:{ (UIAlertAction) in
            let types: [String] = [kUTTypePNG as String, kUTTypeJPEG as String]
            let documentPicker = UIDocumentPickerViewController(documentTypes: types, in: .import)
            documentPicker.delegate = self
            self.present(documentPicker, animated: true, completion: nil)
        })
        galA2.setValue(UIImage(systemName: "doc.text.magnifyingglass")!, forKey: "image")
        galA2.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(galA2)
        let scanA = UIAlertAction(title: " \("Scan Documents".localized)", style: .default , handler:{ (UIAlertAction) in
            self.cameraVisionText()
        })
        scanA.setValue(UIImage(systemName: "doc.text.viewfinder")!, forKey: "image")
        scanA.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(scanA)
        alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
                cell.textView.becomeFirstResponder()
            }
        }))
        
        let op1 = UIAlertAction(title: "Poll".localized, style: .default , handler:{ (UIAlertAction) in
            
        })
        op1.setValue(UIImage(systemName: "chart.bar")!, forKey: "image")
        op1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op1)
        let op3 = UIAlertAction(title: "  \("Audio".localized)", style: .default , handler:{ (UIAlertAction) in
            self.moreAudio()
        })
        op3.setValue(UIImage(systemName: "mic")!, forKey: "image")
        op3.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op3)
        let op4 = UIAlertAction(title: "  \("Now Playing".localized)", style: .default , handler:{ (UIAlertAction) in
            let player = MPMusicPlayerController.systemMusicPlayer
            if let mediaItem = player.nowPlayingItem {
                let title: String = mediaItem.value(forProperty: MPMediaItemPropertyTitle) as? String ?? ""
                let artist: String = mediaItem.value(forProperty: MPMediaItemPropertyArtist) as? String ?? ""
                if title == "" {
                    if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
                        cell.textView.becomeFirstResponder()
                    }
                } else {
                    if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
                        if cell.textView.text.count == 0 {
                            cell.textView.text = "Listening to \(title), by \(artist) 🎵"
                        } else {
                            cell.textView.text = "\(cell.textView.text ?? "")\n\nListening to \(title), by \(artist) 🎵"
                        }
                        cell.textView.becomeFirstResponder()
                    }
                }
            } else {
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
                    cell.textView.becomeFirstResponder()
                }
            }
        })
        op4.setValue(UIImage(systemName: "music.note")!, forKey: "image")
        op4.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op4)
        
        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = self.x1.value(forKey: "view") as? UIView
            presenter.sourceRect = (self.x1.value(forKey: "view") as? UIView)?.bounds ?? self.view.bounds
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height - (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0) - 4
            self.keyHeight = CGFloat(keyboardHeight)
            self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: (self.view.bounds.height) - self.keyHeight)
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
                cell.textView.frame.size.height = (self.view.bounds.height) - self.keyHeight
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        self.keyHeight = CGFloat(0)
        self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: (self.view.bounds.height) - self.keyHeight)
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
            cell.textView.frame.size.height = (self.view.bounds.height) - self.keyHeight
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

extension PHAsset {
    func getURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
                completionHandler(contentEditingInput?.fullSizeImageURL as URL?)
            })
        } else if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }
}

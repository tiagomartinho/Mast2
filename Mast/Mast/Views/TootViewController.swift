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
    var mentionAuthor: String = ""
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
    var x42 = UIBarButtonItem()
    var x5 = UIBarButtonItem()
    var x6 = UIBarButtonItem()
    var x7 = UIBarButtonItem()
    var containsMedia = false
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        self.saveToDrafts()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Text view
        self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: (self.view.bounds.height) - self.keyHeight)
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
            if self.containsMedia == false {
                cell.textView.frame.size.height = (self.view.bounds.height) - self.keyHeight
                cell.layoutIfNeeded()
                UIView.setAnimationsEnabled(false)
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
                UIView.setAnimationsEnabled(true)
            } else {
                cell.textView.frame.size.height = (self.view.bounds.height) - self.keyHeight - 145
                cell.layoutIfNeeded()
                UIView.setAnimationsEnabled(false)
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
                UIView.setAnimationsEnabled(true)
            }
        }
    }
    
    @objc func notifChangeBG() {
        GlobalStruct.baseDarkTint = (UserDefaults.standard.value(forKey: "sync-startDarkTint") == nil || UserDefaults.standard.value(forKey: "sync-startDarkTint") as? Int == 0) ? UIColor(named: "baseWhite")! : UIColor(named: "baseWhite2")!
        self.navigationController?.navigationBar.backgroundColor = GlobalStruct.baseDarkTint
        self.navigationController?.navigationBar.barTintColor = GlobalStruct.baseDarkTint
        self.tableView.reloadData()
    }
    
    @objc func becomeFirst() {
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
            cell.textView.becomeFirstResponder()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        GlobalStruct.gifVidDataToAttachArray = []
        GlobalStruct.photoToAttachArray = []
        GlobalStruct.gifVidDataToAttachArrayImage = []
        GlobalStruct.photoToAttachArrayImage = []
        GlobalStruct.mediaIDs = []
    }
    
    @objc func pollAdded() {
        let symbolConfig6 = UIImage.SymbolConfiguration(pointSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .regular)
        self.x42 = UIBarButtonItem(image: UIImage(systemName: "chart.bar.fill", withConfiguration: symbolConfig6)!.withTintColor(UIColor(named: "baseBlack")!, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(self.removePoll))
        self.x42.accessibilityLabel = "Remove Poll".localized
        self.formatToolbar.items?[8] = self.x42
    }
    
    @objc func removePoll() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let op1 = UIAlertAction(title: "Remove Poll".localized, style: .default , handler:{ (UIAlertAction) in
            GlobalStruct.newPollPost = []
            let symbolConfig6 = UIImage.SymbolConfiguration(pointSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .regular)
            self.x42 = UIBarButtonItem(image: UIImage(systemName: "chart.bar", withConfiguration: symbolConfig6)!.withTintColor(UIColor(named: "baseBlack")!, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(self.addPoll))
            self.x42.accessibilityLabel = "Add Poll".localized
            self.formatToolbar.items?[8] = self.x42
        })
        op1.setValue(UIImage(systemName: "xmark")!, forKey: "image")
        op1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op1)
        alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
                cell.textView.becomeFirstResponder()
            }
        }))
        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = self.x42.value(forKey: "view") as? UIView
            presenter.sourceRect = (self.x42.value(forKey: "view") as? UIView)?.bounds ?? self.view.bounds
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(self.paste(_:)) {
            return UIPasteboard.general.image != nil
        } else {
            return false
        }
    }
    
    @objc override func paste(_ sender: Any?) {
        let pasteboard = UIPasteboard.general
        if pasteboard.hasImages {
            if let theData = pasteboard.image?.pngData() {
                GlobalStruct.photoToAttachArray.append(theData as Data)
                GlobalStruct.photoToAttachArrayImage.append(pasteboard.image ?? UIImage())
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
                    cell.textView.text = "\(cell.textView.text ?? "")"
                    cell.textView.becomeFirstResponder()
                    cell.configure(GlobalStruct.photoToAttachArrayImage, isVideo: false, videoURLs: [])
                    cell.layoutIfNeeded()
                    
                    UIView.setAnimationsEnabled(false)
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                    UIView.setAnimationsEnabled(true)
                }
                self.containsMedia = true
                if GlobalStruct.gifVidDataToAttachArray.isEmpty {
                    
                } else {
                    GlobalStruct.mediaIDs = []
                }
//                for x in GlobalStruct.photoToAttachArray {
                    let request = Media.upload(media: .png(GlobalStruct.photoToAttachArray.last ?? Data()))
                    GlobalStruct.client.run(request) { (statuses) in
                        if let stat = (statuses.value) {
                            GlobalStruct.mediaIDs.append(stat.id)
                        }
                    }
//                }
            }
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
        NotificationCenter.default.addObserver(self, selector: #selector(self.notifChangeBG), name: NSNotification.Name(rawValue: "notifChangeBG"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.becomeFirst), name: NSNotification.Name(rawValue: "becomeFirst"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.pollAdded), name: NSNotification.Name(rawValue: "pollAdded"), object: nil)
        
        if let x = UserDefaults.standard.value(forKey: "sync-allDrafts") as? [String] {
            GlobalStruct.allDrafts = x
        }
        
        // Add button
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
        btn1.setImage(UIImage(systemName: "checkmark", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.45), renderingMode: .alwaysOriginal), for: .normal)
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
            vw.backgroundColor = GlobalStruct.baseDarkTint
            let replyText = UITextView()
            replyText.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 30)
            replyText.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize, weight: .regular)
            replyText.backgroundColor = GlobalStruct.baseDarkTint
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
                cell.backgroundColor = GlobalStruct.baseDarkTint
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PrevImageCell", for: indexPath) as! TootImageCell
                if self.allPrevious.isEmpty {} else {
                    cell.configure(self.allPrevious[indexPath.row])
                }
                cell.backgroundColor = GlobalStruct.baseDarkTint
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
            fixedS.width = 6
            
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
            x3.accessibilityLabel = "Spoiler Text".localized
            x4 = UIBarButtonItem(image: UIImage(systemName: "smiley", withConfiguration: symbolConfig6)!.withTintColor(UIColor(named: "baseBlack")!, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(self.smileyTap))
            x4.accessibilityLabel = "Emoticons".localized
            x42 = UIBarButtonItem(image: UIImage(systemName: "chart.bar", withConfiguration: symbolConfig6)!.withTintColor(UIColor(named: "baseBlack")!, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(self.addPoll))
            x42.accessibilityLabel = "Add Poll".localized
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
                x42,
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
    
    @objc func addPoll() {
        self.show(UINavigationController(rootViewController: NewPollViewController()), sender: self)
    }
    
    @objc func viewDrafts() {
        if GlobalStruct.allDrafts.isEmpty {
            let alert = UIAlertController(title: "No Drafts".localized, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
                    cell.textView.becomeFirstResponder()
                }
            }))
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignment.left
            let messageText = NSMutableAttributedString(
                string: "No Drafts".localized,
                attributes: [
                    NSAttributedString.Key.paragraphStyle: paragraphStyle,
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
                ]
            )
            alert.setValue(messageText, forKey: "attributedTitle")
            if let presenter = alert.popoverPresentationController {
                presenter.sourceView = self.x6.value(forKey: "view") as? UIView
                presenter.sourceRect = (self.x6.value(forKey: "view") as? UIView)?.bounds ?? self.view.bounds
            }
            self.present(alert, animated: true, completion: nil)
        } else {
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
        if self.contentWarning == "" {
            alert.addAction(title: "Add".localized, style: .default) { action in
                self.contentWarning = self.txt
                
                let symbolConfig6 = UIImage.SymbolConfiguration(pointSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .regular)
                self.x3 = UIBarButtonItem(image: UIImage(systemName: "exclamationmark.shield.fill", withConfiguration: symbolConfig6)!.withTintColor(UIColor(named: "baseBlack")!, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(self.contentTap))
                self.x3.accessibilityLabel = "Spoiler Text".localized
                self.formatToolbar.items?[4] = self.x3
            }
        } else {
            alert.addAction(title: "Update".localized, style: .default) { action in
                self.contentWarning = self.txt
                
                let symbolConfig6 = UIImage.SymbolConfiguration(pointSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .regular)
                self.x3 = UIBarButtonItem(image: UIImage(systemName: "exclamationmark.shield.fill", withConfiguration: symbolConfig6)!.withTintColor(UIColor(named: "baseBlack")!, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(self.contentTap))
                self.x3.accessibilityLabel = "Spoiler Text".localized
                self.formatToolbar.items?[4] = self.x3
            }
            alert.addAction(title: "Remove".localized, style: .destructive) { action in
                self.contentWarning = ""
                
                let symbolConfig6 = UIImage.SymbolConfiguration(pointSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .regular)
                self.x3 = UIBarButtonItem(image: UIImage(systemName: "exclamationmark.shield", withConfiguration: symbolConfig6)!.withTintColor(UIColor(named: "baseBlack")!, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(self.contentTap))
                self.x3.accessibilityLabel = "Spoiler Text".localized
                self.formatToolbar.items?[4] = self.x3
            }
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
            
            let symbolConfig6 = UIImage.SymbolConfiguration(pointSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .regular)
            self.x5 = UIBarButtonItem(image: UIImage(systemName: "clock.fill", withConfiguration: symbolConfig6)!.withTintColor(UIColor(named: "baseBlack")!, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(self.scheduleTap))
            self.x5.accessibilityLabel = "Schedule Toot".localized
            self.formatToolbar.items?[10] = self.x5
        }
        if self.scheduleTime != nil {
            alert.addAction(title: "Remove Scheduled Toot".localized, style: .destructive) { action in
                self.scheduleTime = nil
                
                let symbolConfig6 = UIImage.SymbolConfiguration(pointSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .regular)
                self.x5 = UIBarButtonItem(image: UIImage(systemName: "clock", withConfiguration: symbolConfig6)!.withTintColor(UIColor(named: "baseBlack")!, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(self.scheduleTap))
                self.x5.accessibilityLabel = "Schedule Toot".localized
                self.formatToolbar.items?[10] = self.x5
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
        if self.replyStatus.isEmpty {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
                if self.mentionAuthor == "" {
                    placeholderLabel = UILabel()
                    placeholderLabel.text = "What's happening?".localized
                    placeholderLabel.font = UIFont.systemFont(ofSize: (cell.textView.font?.pointSize)!)
                    placeholderLabel.sizeToFit()
                    cell.textView.addSubview(placeholderLabel)
                    placeholderLabel.frame.origin = CGPoint(x: 25, y: 10)
                    placeholderLabel.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.3)
                } else {
                    let theText = "@\(self.mentionAuthor) "
                    cell.textView.text = theText
                }
                cell.textView.becomeFirstResponder()
                if cell.textView.text.isEmpty {
                    self.isModalInPresentation = false
                } else {
                    self.isModalInPresentation = true
                }
            }
        } else {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
                if let statusAuthor = self.replyStatus.first {
                    var mentionedAccountsOnStatus = statusAuthor.mentions.compactMap { $0.acct }
                    var allAccounts = [statusAuthor.account.acct] + (mentionedAccountsOnStatus)
                    if mentionedAccountsOnStatus.contains(statusAuthor.account.acct) {
                        mentionedAccountsOnStatus = mentionedAccountsOnStatus.filter{ $0 != statusAuthor.account.acct }
                        allAccounts = [statusAuthor.account.acct] + (mentionedAccountsOnStatus)
                    }
                    let allUsers = allAccounts.map{ "@\($0)" }
                    var theText = allUsers.reduce("") { $0 + $1 + " " }
                    theText = theText.replacingOccurrences(of: "@\(GlobalStruct.currentUser.username)", with: "")
                    theText = theText.replacingOccurrences(of: "  ", with: " ")
                    cell.textView.text = theText
                }
            }
            self.fetchReplies()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
            if GlobalStruct.photoToAttachArrayImage.isEmpty {
                cell.textView.frame.size.height = (self.view.bounds.height) - self.keyHeight
            } else {
                cell.textView.frame.size.height = (self.view.bounds.height) - self.keyHeight - 145
            }
        }
        if textView.text == "" {
            self.placeholderLabel.isHidden = false
            self.placeholderLabel.alpha = 1
            
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
            self.btn1.setImage(UIImage(systemName: "checkmark", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.45), renderingMode: .alwaysOriginal), for: .normal)
        } else {
            self.placeholderLabel.isHidden = true
            self.placeholderLabel.alpha = 0
            
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
            self.btn1.setImage(UIImage(systemName: "checkmark", withConfiguration: symbolConfig)?.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal), for: .normal)
        }
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
            let maxChars = GlobalStruct.maxChars - (cell.textView.text?.count ?? 0)
            self.x7 = UIBarButtonItem(title: "\(maxChars)", style: .plain, target: self, action: #selector(self.viewMore))
            self.x7.accessibilityLabel = "Characters".localized
            self.formatToolbar.items?[14] = self.x7
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
            let types: [String] = [kUTTypeMP3 as String, kUTTypeAudio as String, kUTTypeWaveformAudio as String, kUTTypeAudio as String]
            let documentPicker = UIDocumentPickerViewController(documentTypes: types, in: .import)
            documentPicker.delegate = self
            self.present(documentPicker, animated: true, completion: nil)
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
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
            if cell.textView.text == "" {
                
            } else {
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let op9 = UIAlertAction(title: "Clear All".localized, style: .destructive , handler:{ (UIAlertAction) in
                    if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
                        cell.textView.text = ""
                    }
                    self.x7 = UIBarButtonItem(title: "\(GlobalStruct.maxChars)", style: .plain, target: self, action: #selector(self.viewMore))
                    self.x7.accessibilityLabel = "Characters".localized
                    self.formatToolbar.items?[14] = self.x7
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
        }
    }
    
    @objc func tickTapped() {
        if self.containsMedia == false {
            self.dismiss(animated: true, completion: nil)
        }
        
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
            var theReplyID: String? = nil
            var theSensitive = false
            var theSpoiler: String? = nil
            var theVisibility = Visibility.public
            let theMainText = cell.textView.text ?? ""
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
            }
            
            if self.containsMedia == false {
                let request = Statuses.create(status: theMainText, replyToID: theReplyID, mediaIDs: [], sensitive: theSensitive, spoilerText: theSpoiler, scheduledAt: self.scheduleTime, poll: GlobalStruct.newPollPost, visibility: theVisibility)
                GlobalStruct.client.run(request) { (statuses) in
                    if let _ = (statuses.value) {
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "updatePosted"), object: nil)
                        }
                    }
                }
            } else {
                var y = GlobalStruct.photoToAttachArray.count
                if GlobalStruct.photoToAttachArray.isEmpty {
                    y = GlobalStruct.gifVidDataToAttachArray.count
                }
                if GlobalStruct.mediaIDs.count == y {
                    let request = Statuses.create(status: theMainText, replyToID: theReplyID, mediaIDs: GlobalStruct.mediaIDs, sensitive: theSensitive, spoilerText: theSpoiler, scheduledAt: self.scheduleTime, poll: GlobalStruct.newPollPost, visibility: theVisibility)
                    GlobalStruct.client.run(request) { (statuses) in
                        if let _ = (statuses.value) {
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "updatePosted"), object: nil)
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                } else {
                    let alert = UIAlertController(title: "Please wait for all media to finish uploading".localized, message: nil, preferredStyle: .actionSheet)
                    alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
                        cell.textView.becomeFirstResponder()
                    }))
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.alignment = NSTextAlignment.left
                    let messageText = NSMutableAttributedString(
                        string: "Please wait for all media to finish uploading".localized,
                        attributes: [
                            NSAttributedString.Key.paragraphStyle: paragraphStyle,
                            NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
                        ]
                    )
                    alert.setValue(messageText, forKey: "attributedTitle")
                    if let presenter = alert.popoverPresentationController {
                        presenter.sourceView = self.btn1
                        presenter.sourceRect = self.btn1.bounds
                    }
                    self.present(alert, animated: true, completion: nil)
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
        let ext = fileURL.pathExtension
        let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext as CFString, nil)
        if UTTypeConformsTo((uti?.takeRetainedValue())!, kUTTypeMP3) || UTTypeConformsTo((uti?.takeRetainedValue())!, kUTTypeWaveformAudio) || UTTypeConformsTo((uti?.takeRetainedValue())!, kUTTypeAudio) {

            if let theData = NSData(contentsOf: fileURL) {
                GlobalStruct.gifVidDataToAttachArray.append(theData as Data)
                GlobalStruct.gifVidDataToAttachArrayImage.append(UIImage(data: theData as Data) ?? UIImage())
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
                    cell.textView.text = "\(cell.textView.text ?? "")"
                    cell.textView.becomeFirstResponder()
                    cell.configure(GlobalStruct.gifVidDataToAttachArrayImage, isVideo: true, videoURLs: [fileURL])
                    cell.layoutIfNeeded()
                    
                    UIView.setAnimationsEnabled(false)
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                    UIView.setAnimationsEnabled(true)
                }
                self.containsMedia = true
                if GlobalStruct.photoToAttachArray.isEmpty {
                    
                } else {
                    GlobalStruct.mediaIDs = []
                }
//                for x in GlobalStruct.gifVidDataToAttachArray {
                    let request = Media.upload(media: .mp3(GlobalStruct.gifVidDataToAttachArray.last ?? Data()))
                    GlobalStruct.client.run(request) { (statuses) in
                        if let stat = (statuses.value) {
                            GlobalStruct.mediaIDs.append(stat.id)
                        }
                    }
//                }
            }
            
        } else {
            
            if let theData = NSData(contentsOf: fileURL) {
                GlobalStruct.photoToAttachArray.append(theData as Data)
                GlobalStruct.photoToAttachArrayImage.append(UIImage(data: theData as Data) ?? UIImage())
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
                    cell.textView.text = "\(cell.textView.text ?? "")"
                    cell.textView.becomeFirstResponder()
                    cell.configure(GlobalStruct.photoToAttachArrayImage, isVideo: false, videoURLs: [])
                    cell.layoutIfNeeded()
                    
                    UIView.setAnimationsEnabled(false)
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                    UIView.setAnimationsEnabled(true)
                }
                self.containsMedia = true
                if GlobalStruct.gifVidDataToAttachArray.isEmpty {
                    
                } else {
                    GlobalStruct.mediaIDs = []
                }
//                for x in GlobalStruct.photoToAttachArray {
                    let request = Media.upload(media: .png(GlobalStruct.photoToAttachArray.last ?? Data()))
                    GlobalStruct.client.run(request) { (statuses) in
                        if let stat = (statuses.value) {
                            GlobalStruct.mediaIDs.append(stat.id)
                        }
                    }
//                }
            }
            
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
                    GlobalStruct.gifVidDataToAttachArray = [gifVidDataToAttach]
                    GlobalStruct.gifVidDataToAttachArrayImage = [(self.thumbnailForVideoAtURL(url: videoURL) ?? UIImage())]
                    if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
                        cell.textView.text = "\(cell.textView.text ?? "")"
                        cell.textView.becomeFirstResponder()
                        cell.configure(GlobalStruct.gifVidDataToAttachArrayImage, isVideo: true, videoURLs: [(videoURL as URL)])
                        cell.layoutIfNeeded()

                        UIView.setAnimationsEnabled(false)
                        self.tableView.beginUpdates()
                        self.tableView.endUpdates()
                        UIView.setAnimationsEnabled(true)
                    }
                    self.containsMedia = true
                    if GlobalStruct.photoToAttachArray.isEmpty {
                        
                    } else {
                        GlobalStruct.mediaIDs = []
                    }
//                    for x in GlobalStruct.gifVidDataToAttachArray {
                        let request = Media.upload(media: .gif(GlobalStruct.gifVidDataToAttachArray.last ?? Data()))
                        GlobalStruct.client.run(request) { (statuses) in
                            if let stat = (statuses.value) {
                                GlobalStruct.mediaIDs.append(stat.id)
                            }
                        }
//                    }
                } catch {
                    print("error")
                }
            } else {
                if let photoToAttach = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage ?? UIImage()).pngData() {
                    GlobalStruct.photoToAttachArray.append(photoToAttach)
                    GlobalStruct.photoToAttachArrayImage.append(info[UIImagePickerController.InfoKey.originalImage] as? UIImage ?? UIImage())
                    if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
                        cell.textView.text = "\(cell.textView.text ?? "")"
                        cell.textView.becomeFirstResponder()
                        cell.configure(GlobalStruct.photoToAttachArrayImage, isVideo: false, videoURLs: [])
                        cell.layoutIfNeeded()

                        UIView.setAnimationsEnabled(false)
                        self.tableView.beginUpdates()
                        self.tableView.endUpdates()
                        UIView.setAnimationsEnabled(true)
                    }
                    self.containsMedia = true
                    if GlobalStruct.gifVidDataToAttachArray.isEmpty {
                        
                    } else {
                        GlobalStruct.mediaIDs = []
                    }
//                    for x in GlobalStruct.photoToAttachArray {
                        let request = Media.upload(media: .png(GlobalStruct.photoToAttachArray.last ?? Data()))
                        GlobalStruct.client.run(request) { (statuses) in
                            if let stat = (statuses.value) {
                                GlobalStruct.mediaIDs.append(stat.id)
                            }
                        }
//                    }
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
                            self.photoPickerView.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
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
        let galA = UIAlertAction(title: "Gallery".localized, style: .default , handler:{ (UIAlertAction) in
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                if response {
                    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                        DispatchQueue.main.async {
                            self.photoPickerView.delegate = self
                            self.photoPickerView.sourceType = .photoLibrary
                            self.photoPickerView.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
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
//        let op3 = UIAlertAction(title: "  \("Audio".localized)", style: .default , handler:{ (UIAlertAction) in
//            self.moreAudio()
//        })
//        op3.setValue(UIImage(systemName: "mic")!, forKey: "image")
//        op3.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
//        alert.addAction(op3)
        let op3 = UIAlertAction(title: "  \("Audio".localized)".localized, style: .default , handler:{ (UIAlertAction) in
            let types: [String] = [kUTTypeMP3 as String, kUTTypeWaveformAudio as String, kUTTypeAudio as String]
            let documentPicker = UIDocumentPickerViewController(documentTypes: types, in: .import)
            documentPicker.delegate = self
            self.present(documentPicker, animated: true, completion: nil)
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
//            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
//                if self.containsMedia == false {
//                    cell.textView.frame.size.height = (self.view.bounds.height) - self.keyHeight
//                    cell.layoutIfNeeded()
//                    UIView.setAnimationsEnabled(false)
//                    self.tableView.beginUpdates()
//                    self.tableView.endUpdates()
//                    UIView.setAnimationsEnabled(true)
//                } else {
//                    cell.textView.frame.size.height = (self.view.bounds.height) - self.keyHeight - 145
//                    cell.layoutIfNeeded()
//                    UIView.setAnimationsEnabled(false)
//                    self.tableView.beginUpdates()
//                    self.tableView.endUpdates()
//                    UIView.setAnimationsEnabled(true)
//                }
//            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        self.keyHeight = CGFloat(0)
        self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: (self.view.bounds.height) - self.keyHeight)
//        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
//            if self.containsMedia == false {
//                cell.textView.frame.size.height = (self.view.bounds.height) - self.keyHeight
//                cell.layoutIfNeeded()
//                UIView.setAnimationsEnabled(false)
//                self.tableView.beginUpdates()
//                self.tableView.endUpdates()
//                UIView.setAnimationsEnabled(true)
//            } else {
//                cell.textView.frame.size.height = (self.view.bounds.height) - self.keyHeight - 145
//                cell.layoutIfNeeded()
//                UIView.setAnimationsEnabled(false)
//                self.tableView.beginUpdates()
//                self.tableView.endUpdates()
//                UIView.setAnimationsEnabled(true)
//            }
//        }
    }
    
    func removeTabbarItemsText() {
        if let items = self.tabBarController?.tabBar.items {
            for item in items {
                item.title = ""
            }
        }
    }
    
    private func thumbnailForVideoAtURL(url: NSURL) -> UIImage? {
        let asset = AVAsset(url: url as URL)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        
        var time = asset.duration
        time.value = min(time.value, 2)
        
        do {
            let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            print("error")
            return nil
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

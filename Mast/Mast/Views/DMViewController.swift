//
//  DMViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 26/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import MessageKit
import AVKit
import AVFoundation
import SafariServices
import Photos
import MobileCoreServices
import InputBarAccessoryView

class DMViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, MessageCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    var statusBarView = UIView()
    var messages: [MessageType] = []
    var mainStatus: [Status] = []
    var allPrevious: [Status] = []
    var allReplies: [Status] = []
    var allPosts: [Status] = []
    var player = AVPlayer()
    var safariVC: SFSafariViewController?
    var lastUser = ""
    let imag = UIImagePickerController()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func removeTabbarItemsText() {
        if let items = self.tabBarController?.tabBar.items {
            for item in items {
                item.title = ""
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "baseWhite")
        self.title = "500"
        self.removeTabbarItemsText()
        
        GlobalStruct.medType = 0
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.backgroundColor = UIColor(named: "baseWhite")
        
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.setMessageOutgoingAvatarSize(.zero)
        
        messageInputBar.backgroundColor = UIColor(named: "baseWhite")
        if UIDevice.current.userInterfaceIdiom == .pad {
            messageInputBar.separatorLine.isHidden = false
        } else {
            messageInputBar.separatorLine.isHidden = true
        }
        messageInputBar.separatorLine.height = 2
        messageInputBar.separatorLine.backgroundColor = UIColor(named: "lighterBaseWhite")
        messageInputBar.separatorLine.tintColor = UIColor(named: "lighterBaseWhite")
        messageInputBar.backgroundView.backgroundColor = UIColor(named: "baseWhite")
        messageInputBar.contentView.backgroundColor = UIColor(named: "baseWhite")
        messageInputBar.inputTextView.backgroundColor = UIColor(named: "baseWhite")
        messageInputBar.inputTextView.placeholderLabel.text = "  Message..."
        messageInputBar.inputTextView.placeholderTextColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.3)
        messageInputBar.inputTextView.textColor = UIColor(named: "baseBlack")!
        messageInputBar.inputTextView.layer.borderColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.2).cgColor
        messageInputBar.inputTextView.layer.cornerRadius = 0
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 11, left: 10, bottom: 4, right: 10)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 9, left: 2, bottom: 5, right: 5)
        messageInputBar.setRightStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.sendButton.imageView?.backgroundColor = UIColor.clear
        messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: false)
        messageInputBar.sendButton.image = UIImage(systemName: "paperplane", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal)
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.imageView?.layer.cornerRadius = 0
        messageInputBar.sendButton.addTarget(self, action: #selector(self.didTouchSend), for: .touchUpInside)
        messageInputBar.sendButton
            .onEnabled { item in
                UIView.animate(withDuration: 0.3, animations: {
                    self.messageInputBar.sendButton.image = UIImage(systemName: "paperplane.fill", withConfiguration: symbolConfig)?.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal)
                })
            }.onDisabled { item in
                UIView.animate(withDuration: 0.3, animations: {
                    self.messageInputBar.sendButton.image = UIImage(systemName: "paperplane", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.4), renderingMode: .alwaysOriginal)
                })
        }
        let allButton = InputBarButtonItem()
            .configure {
                $0.contentHorizontalAlignment = .left
                $0.setSize(CGSize(width: 40, height: 40), animated: false)
                $0.addTarget(self, action: #selector(self.didTouchOther), for: .touchUpInside)
            }
        allButton.image = UIImage(systemName: "plus.circle.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.2), renderingMode: .alwaysOriginal)
        let bottomItems = [allButton]
        messageInputBar.setStackViewItems(bottomItems, forStack: .left, animated: false)
        
        if self.mainStatus.isEmpty {} else {
            let request = Statuses.context(id: self.mainStatus[0].reblog?.id ?? self.mainStatus[0].id)
            GlobalStruct.client.run(request) { (statuses) in
                if let stat = (statuses.value) {
                    self.allPrevious = (stat.ancestors)
                    self.allReplies = (stat.descendants)
                    DispatchQueue.main.async {
                        let _ = (stat.ancestors + self.mainStatus + stat.descendants).map({
                            var theType = "0"
                            if $0.account.acct == GlobalStruct.currentUser.acct {
                                theType = "1"
                            } else {
                                self.lastUser = $0.account.acct
                            }
                            
                            let theText = NSMutableAttributedString(string: $0.content.stripHTML())
                            if $0.account.acct == GlobalStruct.currentUser.acct {
                                theText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)], range: theText.mutableString.range(of: theText.string))
                            } else {
                                theText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(named: "baseBlack")!, NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)], range: theText.mutableString.range(of: theText.string))
                            }
                            let sender = Sender(id: theType, displayName: "\($0.account.acct)")
                            let x = MockMessage.init(attributedText: theText, sender: sender, messageId: $0.id, date: $0.createdAt)
                            self.messages.append(x)
                            self.allPosts.append($0)
                            if $0.mediaAttachments.isEmpty {} else {
                                let url = URL(string: $0.mediaAttachments.first?.previewURL ?? "")
                                let imageData = try! Data(contentsOf: url!)
                                let image1 = UIImage(data: imageData)
                                let y = MockMessage.init(image: image1!, sender: sender, messageId: $0.id, date: $0.createdAt)
                                self.messages.append(y)
                                self.allPosts.append($0)
                            }
                        })
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToBottom()
                    }
                }
            }
        }
    }
    
    @objc func didTouchOther() {
        
    }
    
    @objc func updateThread() {
        let request = Statuses.context(id: self.mainStatus[0].reblog?.id ?? self.mainStatus[0].id)
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                DispatchQueue.main.async {
                    self.allPrevious = (stat.ancestors)
                    self.allReplies = (stat.descendants)
                    
                    self.messages = []
                    self.allPosts = []
                    
                    let _ = (self.allPrevious + self.mainStatus + self.allReplies).map({
                        var theType = "0"
                        if $0.account.acct == GlobalStruct.currentUser.acct {
                            theType = "1"
                        } else {
                            self.lastUser = $0.account.acct
                        }
                        
                        let sender = Sender(id: theType, displayName: "\($0.account.acct)")
                        let x = MockMessage.init(text: $0.content.stripHTML(), sender: sender, messageId: $0.id, date: $0.createdAt)
                        self.messages.append(x)
                        self.allPosts.append($0)
                        
                        if $0.mediaAttachments.isEmpty {} else {
                            let url = URL(string: $0.mediaAttachments.first?.previewURL ?? "")
                            let imageData = try! Data(contentsOf: url!)
                            let image1 = UIImage(data: imageData)
                            let y = MockMessage.init(image: image1!, sender: sender, messageId: $0.id, date: $0.createdAt)
                            self.messages.append(y)
                            self.allPosts.append($0)
                        }
                        
                        self.messagesCollectionView.reloadData()
                    })
                }
            }
        }
    }
    
    func currentSender() -> SenderType {
        return Sender(id: "1", displayName: "\(GlobalStruct.currentUser.acct)")
    }
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        let pos: CGPoint = cell.convert(CGPoint.zero, to: messagesCollectionView)
        let indexPath = messagesCollectionView.indexPathForItem(at: pos)
        let vc = FifthViewController()
        vc.isYou = false
        vc.pickedCurrentUser = self.allPosts[indexPath?.section ?? 0].account
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        let pos: CGPoint = cell.convert(CGPoint.zero, to: messagesCollectionView)
        let indexPath = messagesCollectionView.indexPathForItem(at: pos)
    }
    
    @objc func didTouchSend(sender: UIButton) {
        guard let thText = self.messageInputBar.inputTextView.text else { return }
    }
    
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messages.count else { return false }
        return messages[indexPath.section].sender.displayName == messages[indexPath.section + 1].sender.displayName
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let avString = self.allPosts[indexPath.section].account.avatar
        let url = URL(string: avString)
        let imageData = try! Data(contentsOf: url!)
        let image1 = UIImage(data: imageData)
        let avatar = Avatar(image: image1, initials: "")
        avatarView.set(avatar: avatar)
        avatarView.isHidden = isNextMessageSameSender(at: indexPath)
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? GlobalStruct.baseTint : UIColor(named: "lighterBaseWhite")!
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if !isPreviousMessageSameSender(at: indexPath) {
            return 20
        }
        return 0
    }
    
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        return messages[indexPath.section].sender.displayName == messages[indexPath.section - 1].sender.displayName
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = MessageKitDateFormatter.shared.string(from: message.sentDate)
        if !isPreviousMessageSameSender(at: indexPath) {
            return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2), NSAttributedString.Key.foregroundColor: UIColor(named: "baseBlack")!.withAlphaComponent(0.4)])
        }
        return nil
    }
}

struct MockMessage: MessageType {
    var messageId: String
    var sender: SenderType
    var sentDate: Date
    var kind: MessageKind
    
    private init(kind: MessageKind, sender: SenderType, messageId: String, date: Date) {
        self.kind = kind
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
    }
    
    init(custom: Any?, sender: SenderType, messageId: String, date: Date) {
        self.init(kind: .custom(custom), sender: sender, messageId: messageId, date: date)
    }
    
    init(text: String, sender: SenderType, messageId: String, date: Date) {
        self.init(kind: .text(text), sender: sender, messageId: messageId, date: date)
    }
    
    init(attributedText: NSAttributedString, sender: SenderType, messageId: String, date: Date) {
        self.init(kind: .attributedText(attributedText), sender: sender, messageId: messageId, date: date)
    }
    
    init(image: UIImage, sender: SenderType, messageId: String, date: Date) {
        let mediaItem = ImageMediaItem(image: image)
        self.init(kind: .photo(mediaItem), sender: sender, messageId: messageId, date: date)
    }
}

struct ImageMediaItem: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }
}


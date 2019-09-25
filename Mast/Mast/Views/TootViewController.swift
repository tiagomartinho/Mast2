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

class TootViewController: UIViewController, UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let textView = UITextView()
    var keyHeight: CGFloat = 0
    var moreButton = UIButton()
    var collectionView1: UICollectionView!
    var images: [PHAsset] = []
    var divider = UIView()
    var selectedImages: [Int] = []
    var replyStatus: [Status] = []
    var replyText = UITextView()
    var divider2 = UIView()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Text view
        if self.keyHeight > 0 {
            if self.replyStatus.isEmpty {
                self.textView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: (self.view.bounds.height) - self.keyHeight - 62)
            } else {
                self.textView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: (self.view.bounds.height) - self.keyHeight - 132)
            }
        } else {
            if self.replyStatus.isEmpty {
                self.textView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: (self.view.bounds.height) - self.keyHeight - 95)
            } else {
                self.textView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: (self.view.bounds.height) - self.keyHeight - 165)
            }
        }
        
        var keyboardY0 = self.keyHeight + self.view.safeAreaInsets.bottom + 45
        if self.keyHeight > 0 {
            keyboardY0 = self.keyHeight + 47
        }
        let keyboardY = self.view.bounds.height - keyboardY0
        self.moreButton.frame = CGRect(x: self.view.bounds.width - 50, y: keyboardY, width: 30, height: 30)
        
        var keyboardY02 = self.keyHeight + self.view.safeAreaInsets.bottom + 55
        if self.keyHeight > 0 {
            keyboardY02 = self.keyHeight + 57
        }
        let keyboardY2 = self.view.bounds.height - keyboardY02
        collectionView1.frame = CGRect(x: CGFloat(0), y: CGFloat(keyboardY2), width: CGFloat(UIScreen.main.bounds.width - 65), height: CGFloat(50))
        
        self.divider.frame = CGRect(x: CGFloat(0), y: CGFloat(keyboardY2 - 6), width: CGFloat(UIScreen.main.bounds.width), height: CGFloat(0.6))
        
        self.divider2.frame = CGRect(x: CGFloat(0), y: CGFloat(keyboardY2 - 76), width: CGFloat(UIScreen.main.bounds.width), height: CGFloat(0.6))
        
        self.replyText.frame = CGRect(x: CGFloat(0), y: CGFloat(keyboardY2 - 76), width: CGFloat(UIScreen.main.bounds.width), height: CGFloat(70))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "baseWhite")
        self.title = "New Toot".localized
        self.removeTabbarItemsText()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Add button
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(systemName: "checkmark", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn1.addTarget(self, action: #selector(self.tickTapped), for: .touchUpInside)
        let addButton = UIBarButtonItem(customView: btn1)
        self.navigationItem.setRightBarButton(addButton, animated: true)
        
        let btn2 = UIButton(type: .custom)
        btn2.setImage(UIImage(systemName: "xmark", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        btn2.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn2.addTarget(self, action: #selector(self.crossTapped), for: .touchUpInside)
        let settingsButton = UIBarButtonItem(customView: btn2)
        self.navigationItem.setLeftBarButton(settingsButton, animated: true)
        
        // Text view
        let normalFont = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        self.textView.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        self.textView.textStorage.setAttributes([NSAttributedString.Key.font : normalFont, NSAttributedString.Key.foregroundColor : UIColor(named: "baseBlack")!], range: NSRange(location: 0, length: self.textView.text.count))
        self.textView.backgroundColor = UIColor.clear
        self.textView.showsVerticalScrollIndicator = false
        self.textView.showsHorizontalScrollIndicator = false
        self.textView.delegate = self
        self.textView.adjustsFontForContentSizeCategory = true
        self.textView.isSelectable = true
        self.textView.alwaysBounceVertical = true
        self.textView.isUserInteractionEnabled = true
        self.textView.isScrollEnabled = true
        self.textView.textContainerInset = UIEdgeInsets(top: 5, left: 18, bottom: 5, right: 18)
        self.view.addSubview(self.textView)
        self.textView.becomeFirstResponder()
        
        self.moreButton.backgroundColor = UIColor.clear
        let downImage = UIImage(systemName: "ellipsis", withConfiguration: symbolConfig)
        let tintedDownImage = downImage?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.6), renderingMode: .alwaysOriginal)
        self.moreButton.setImage(tintedDownImage, for: .normal)
        self.moreButton.addTarget(self, action: #selector(self.viewMore), for: .touchUpInside)
        self.moreButton.adjustsImageWhenHighlighted = false
        self.moreButton.isAccessibilityElement = true
        self.moreButton.accessibilityTraits = .button
        self.moreButton.accessibilityLabel = "More".localized
        self.view.addSubview(self.moreButton)
        
        self.divider.backgroundColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.2)
        self.view.addSubview(self.divider)
        
        self.checkAuthorizationForPhotoLibraryAndGet()
        
        let layout = ColumnFlowLayout2(
            cellsPerRow: 10,
            minimumInteritemSpacing: 15,
            minimumLineSpacing: 15,
            sectionInset: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        )
        layout.scrollDirection = .horizontal
        var keyboardY02 = self.keyHeight + self.view.safeAreaInsets.bottom + 55
        if self.keyHeight > 0 {
            keyboardY02 = self.keyHeight + 57
        }
        let keyboardY2 = self.view.bounds.height - keyboardY02
        collectionView1 = UICollectionView(frame: CGRect(x: CGFloat(0), y: CGFloat(keyboardY2), width: CGFloat(UIScreen.main.bounds.width - 65), height: CGFloat(50)), collectionViewLayout: layout)
        collectionView1.backgroundColor = UIColor.clear
        collectionView1.delegate = self
        collectionView1.dataSource = self
        collectionView1.showsHorizontalScrollIndicator = false
        collectionView1.register(ComposeImageCell.self, forCellWithReuseIdentifier: "ComposeImageCell")
        self.view.addSubview(collectionView1)
        
        self.collectionView1.reloadData()
        
        self.replyText.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize, weight: .regular)
        self.replyText.backgroundColor = UIColor(named: "lighterBaseWhite")
        self.replyText.showsVerticalScrollIndicator = false
        self.replyText.showsHorizontalScrollIndicator = false
        self.replyText.alwaysBounceVertical = true
        self.replyText.isScrollEnabled = true
        self.replyText.textContainerInset = UIEdgeInsets(top: 5, left: 18, bottom: 5, right: 18)
        self.replyText.isEditable = false
        self.replyText.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.6)
        if self.replyStatus.isEmpty {
            self.replyText.alpha = 0
            self.divider2.alpha = 0
        } else {
            self.replyText.alpha = 1
            self.divider2.alpha = 1

            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 12)
            
            let upImage = UIImage(systemName: "arrow.turn.down.right", withConfiguration: symbolConfig)
            let tintedUpImage = upImage?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.36), renderingMode: .alwaysOriginal)
            let attachment = NSTextAttachment()
            attachment.image = tintedUpImage
            let attString = NSAttributedString(attachment: attachment)
            
            let upImage2 = UIImage(systemName: "heart", withConfiguration: symbolConfig)
            let tintedUpImage2 = upImage2?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.36), renderingMode: .alwaysOriginal)
            let attachment2 = NSTextAttachment()
            attachment2.image = tintedUpImage2
            let attString2 = NSAttributedString(attachment: attachment2)
            
            let upImage3 = UIImage(systemName: "arrow.2.circlepath", withConfiguration: symbolConfig)
            let tintedUpImage3 = upImage3?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.36), renderingMode: .alwaysOriginal)
            let attachment3 = NSTextAttachment()
            attachment3.image = tintedUpImage3
            let attString3 = NSAttributedString(attachment: attachment3)
            
            let normalFont = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize)
            let attStringNewLine = NSMutableAttributedString(string: "", attributes: [NSAttributedString.Key.font : normalFont, NSAttributedString.Key.foregroundColor : UIColor(named: "baseBlack")!.withAlphaComponent(0.36)])
            let attStringNewLine2 = NSMutableAttributedString(string: " @\(self.replyStatus.first?.account.username ?? ""):  ", attributes: [NSAttributedString.Key.font : normalFont, NSAttributedString.Key.foregroundColor : UIColor(named: "baseBlack")!.withAlphaComponent(0.36)])
            
            let attStringNewLine3 = NSMutableAttributedString(string: " \(self.replyStatus.first?.favouritesCount ?? 0) ", attributes: [NSAttributedString.Key.font : normalFont, NSAttributedString.Key.foregroundColor : UIColor(named: "baseBlack")!.withAlphaComponent(0.36)])
            let attStringNewLine4 = NSMutableAttributedString(string: " \(self.replyStatus.first?.reblogsCount ?? 0)", attributes: [NSAttributedString.Key.font : normalFont, NSAttributedString.Key.foregroundColor : UIColor(named: "baseBlack")!.withAlphaComponent(0.36)])
            
            let attStringNewLine5 = NSMutableAttributedString(string: "\n\(self.replyStatus.first?.content.stripHTML() ?? "")", attributes: [NSAttributedString.Key.font : normalFont, NSAttributedString.Key.foregroundColor : UIColor(named: "baseBlack")!.withAlphaComponent(0.7)])
            
            attStringNewLine.append(attString)
            attStringNewLine.append(attStringNewLine2)
            attStringNewLine.append(attString2)
            attStringNewLine.append(attStringNewLine3)
            attStringNewLine.append(attString3)
            attStringNewLine.append(attStringNewLine4)
            attStringNewLine.append(attStringNewLine5)
            self.replyText.attributedText = attStringNewLine
        }
        self.view.addSubview(self.replyText)
        
        if self.replyStatus.isEmpty {
            
        } else {
            if self.replyStatus.first?.mentions.isEmpty ?? true {
                self.textView.text = "@\(self.replyStatus.first?.account.username ?? "") "
            } else {
                self.textView.text = "@\(self.replyStatus.first?.account.username ?? "") "
                let _ = self.replyStatus.first?.mentions.map {
                    if $0.username == GlobalStruct.currentUser.username {
                        
                    } else {
                        self.textView.text = "\(self.textView.text ?? "")@\($0.username) "
                    }
                }
            }
        }
        
        self.divider2.backgroundColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.2)
        self.view.addSubview(self.divider2)
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
    
    @objc func viewMore() {
        
    }
    
    @objc func tickTapped() {
        self.dismiss(animated: true, completion: nil)
        
        var theReplyID: String? = nil
        var theSensitive = false
        var theSpoiler: String? = nil
        var theVisibility = Visibility.public
        if self.replyStatus.isEmpty {
            
        } else {
            theReplyID = self.replyStatus.first?.id ?? nil
            theSensitive = self.replyStatus.first?.sensitive ?? false
            theSpoiler = self.replyStatus.first?.spoilerText ?? nil
            theVisibility = self.replyStatus.first?.visibility ?? Visibility.public
        }
        
        let request = Statuses.create(status: self.textView.text ?? "", replyToID: theReplyID, mediaIDs: [], sensitive: theSensitive, spoilerText: theSpoiler, scheduledAt: nil, poll: nil, visibility: theVisibility)
        GlobalStruct.client.run(request) { (statuses) in
            if let _ = (statuses.value) {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updatePosted"), object: nil)
                }
            }
        }
    }
    
    @objc func crossTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.images.count == 0 {
            return 1
        } else {
            return self.images.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ComposeImageCell", for: indexPath) as! ComposeImageCell
        if self.images.isEmpty {
            DispatchQueue.main.async {
                let symbolConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .regular)
                cell.image.image = UIImage(systemName: "plus.circle.fill", withConfiguration: symbolConfig)?.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal)
                cell.image.layer.masksToBounds = true
                cell.image.backgroundColor = UIColor(named: "baseWhite")
                cell.image.layer.masksToBounds = true
                cell.image.layer.borderColor = UIColor.black.cgColor
                cell.image.contentMode = .scaleAspectFill
            }
        } else {
            cell.configure()
            if indexPath.item == 0 {
                DispatchQueue.main.async {
                    let symbolConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .regular)
                    cell.image.image = UIImage(systemName: "plus.circle.fill", withConfiguration: symbolConfig)?.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal)
                    cell.image.layer.masksToBounds = true
                    cell.image.backgroundColor = UIColor(named: "baseWhite")
                    cell.image.layer.masksToBounds = true
                    cell.image.layer.borderColor = UIColor.black.cgColor
                    cell.image.contentMode = .scaleAspectFill
                }
            } else {
                let _ = self.images[indexPath.item - 1].getURL { (link) in
                    DispatchQueue.main.async {
                        cell.image.sd_setImage(with: link, completed: nil)
                        cell.image.layer.masksToBounds = true
                        cell.image.backgroundColor = UIColor(named: "baseWhite")
                        cell.image.layer.masksToBounds = true
                        cell.image.layer.borderColor = UIColor.black.cgColor
                        cell.image.contentMode = .scaleAspectFill
                        if self.selectedImages.contains(indexPath.item - 1) {
                            cell.layer.borderColor = GlobalStruct.baseTint.cgColor
                            cell.layer.cornerRadius = 5
                            cell.layer.borderWidth = 3
                            cell.layer.masksToBounds = true
                        } else {
                            cell.layer.borderWidth = 0
                        }
                    }
                }
            }
        }
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            
        } else {
            if self.selectedImages.contains(indexPath.item - 1) {
                self.selectedImages = self.selectedImages.filter {$0 != indexPath.item - 1}
                self.collectionView1.reloadItems(at: [IndexPath(item: indexPath.item, section: 0)])
            } else {
                self.selectedImages.append(indexPath.item - 1)
                self.collectionView1.reloadItems(at: [IndexPath(item: indexPath.item, section: 0)])
            }
        }
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.keyHeight = CGFloat(keyboardHeight)
            var keyboardY0 = self.keyHeight + self.view.safeAreaInsets.bottom + 45
            if self.keyHeight > 0 {
                keyboardY0 = self.keyHeight + 47
            }
            let keyboardY = self.view.bounds.height - keyboardY0
            self.moreButton.frame = CGRect(x: self.view.bounds.width - 50, y: keyboardY, width: 30, height: 30)
            
            var keyboardY02 = self.keyHeight + self.view.safeAreaInsets.bottom + 55
            if self.keyHeight > 0 {
                keyboardY02 = self.keyHeight + 57
            }
            let keyboardY2 = self.view.bounds.height - keyboardY02
            collectionView1.frame = CGRect(x: CGFloat(0), y: CGFloat(keyboardY2), width: CGFloat(UIScreen.main.bounds.width - 65), height: CGFloat(50))
            
            self.divider.frame = CGRect(x: CGFloat(0), y: CGFloat(keyboardY2 - 6), width: CGFloat(UIScreen.main.bounds.width), height: CGFloat(0.6))

            if self.replyStatus.isEmpty {
                self.textView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: (self.view.bounds.height) - self.keyHeight - 62)
            } else {
                self.textView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: (self.view.bounds.height) - self.keyHeight - 132)
            }
            
            self.divider2.frame = CGRect(x: CGFloat(0), y: CGFloat(keyboardY2 - 76), width: CGFloat(UIScreen.main.bounds.width), height: CGFloat(0.6))
            
            self.replyText.frame = CGRect(x: CGFloat(0), y: CGFloat(keyboardY2 - 76), width: CGFloat(UIScreen.main.bounds.width), height: CGFloat(70))
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        self.keyHeight = CGFloat(0)
        var keyboardY0 = self.keyHeight + self.view.safeAreaInsets.bottom + 45
        if self.keyHeight > 0 {
            keyboardY0 = self.keyHeight + 47
        }
        let keyboardY = self.view.bounds.height - keyboardY0
        self.moreButton.frame = CGRect(x: self.view.bounds.width - 50, y: keyboardY, width: 30, height: 30)
        
        var keyboardY02 = self.keyHeight + self.view.safeAreaInsets.bottom + 55
        if self.keyHeight > 0 {
            keyboardY02 = self.keyHeight + 57
        }
        let keyboardY2 = self.view.bounds.height - keyboardY02
        collectionView1.frame = CGRect(x: CGFloat(0), y: CGFloat(keyboardY2), width: CGFloat(UIScreen.main.bounds.width - 65), height: CGFloat(50))
        
        self.divider.frame = CGRect(x: CGFloat(0), y: CGFloat(keyboardY2 - 6), width: CGFloat(UIScreen.main.bounds.width), height: CGFloat(0.6))
        
        if self.replyStatus.isEmpty {
            self.textView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: (self.view.bounds.height) - self.keyHeight - 95)
        } else {
            self.textView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: (self.view.bounds.height) - self.keyHeight - 165)
        }
        
        self.divider2.frame = CGRect(x: CGFloat(0), y: CGFloat(keyboardY2 - 76), width: CGFloat(UIScreen.main.bounds.width), height: CGFloat(0.6))
        
        self.replyText.frame = CGRect(x: CGFloat(0), y: CGFloat(keyboardY2 - 76), width: CGFloat(UIScreen.main.bounds.width), height: CGFloat(70))
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

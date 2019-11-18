//
//  ShareViewController.swift
//  MastShare
//
//  Created by Shihab Mehboob on 18/11/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import UIKit
import MobileCoreServices

class ShareViewController: UIViewController, UITextViewDelegate, UINavigationBarDelegate {
    
    let textView = UITextView()
    let cancelLabel = UIButton()
    let tootLabel = UIButton()
    let countLabel = UILabel()
    var keyHeight: CGFloat = 0
    var defaultVisibility: Visibility = .public
    var formatToolbar = UIToolbar()
    var x1 = UIBarButtonItem()
    var x2 = UIBarButtonItem()
    var maxChars = 500
    let btn1 = UIButton(type: .custom)
    let btn2 = UIButton(type: .custom)
    let navbar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.textView.frame = CGRect(x: 0, y: 50 + self.view.safeAreaInsets.top, width: self.view.bounds.width, height: self.view.bounds.height - self.keyHeight - 50 - self.view.safeAreaInsets.top)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "lighterBaseWhite")!
        self.view.tintColor = UIColor(named: "baseBlack")!
        
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(named: "baseBlack")!]
        self.navigationController?.navigationBar.backgroundColor = UIColor(named: "baseWhite")!
        self.navigationController?.navigationBar.barTintColor = UIColor(named: "baseWhite")!
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
        btn1.setImage(UIImage(systemName: "checkmark", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.45), renderingMode: .alwaysOriginal), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn1.addTarget(self, action: #selector(self.tickTapped), for: .touchUpInside)
        btn1.accessibilityLabel = "Post".localized
        let addButton = UIBarButtonItem(customView: btn1)
        
        btn2.setImage(UIImage(systemName: "xmark", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        btn2.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn2.addTarget(self, action: #selector(self.crossTapped), for: .touchUpInside)
        btn2.accessibilityLabel = "Dismiss".localized
        let settingsButton = UIBarButtonItem(customView: btn2)

        navbar.backgroundColor = UIColor(named: "baseWhite")!
        navbar.delegate = self
        let navItem = UINavigationItem()
        navItem.title = "New Toot".localized
        navItem.leftBarButtonItem = settingsButton
        navItem.rightBarButtonItem = addButton
        navbar.items = [navItem]
        view.addSubview(navbar)
    }
    
    override func loadView() {
        super.loadView()
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.keyHeight = keyboardHeight
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.setNeedsStatusBarAppearanceUpdate()
        self.setUpView()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let maxChars = self.maxChars - (self.textView.text?.count ?? 0)
        self.x2 = UIBarButtonItem(title: "\(maxChars)", style: .plain, target: self, action: #selector(self.viewMore))
        self.x2.accessibilityLabel = "Characters".localized
        self.formatToolbar.items?[2] = self.x2
        
        if textView.text == "" {
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
            self.btn1.setImage(UIImage(systemName: "checkmark", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(0.45), renderingMode: .alwaysOriginal), for: .normal)
        } else {
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
            self.btn1.setImage(UIImage(systemName: "checkmark", withConfiguration: symbolConfig)?.withTintColor(UIColor(red: 156/255, green: 143/255, blue: 247/255, alpha: 1), renderingMode: .alwaysOriginal), for: .normal)
        }
    }
    
    func setUpView() {
        let theTempText: NSExtensionItem = self.extensionContext?.inputItems.first as! NSExtensionItem
        let theText = theTempText.attributedContentText?.string ?? ""
        
        textView.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.85)
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 18, bottom: 10, right: 18)
        textView.text = "\(theText)"
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = UIColor(named: "lighterBaseWhite")!
        textView.delegate = self
        self.view.addSubview(textView)
        
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
        
        x1 = UIBarButtonItem(image: UIImage(systemName: visibilityIcon, withConfiguration: symbolConfig6)!.withTintColor(UIColor(named: "baseBlack")!, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(self.visibilityTap))
        x1.accessibilityLabel = "Visibility".localized
        x2 = UIBarButtonItem(title: "\(self.maxChars)", style: .plain, target: self, action: #selector(self.viewMore))
        x2.accessibilityLabel = "Characters".localized
        formatToolbar.items = [
            x1,
            UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil),
            x2
        ]
        formatToolbar.sizeToFit()
        self.textView.inputAccessoryView = formatToolbar
        
        self.textView.becomeFirstResponder()
        
        for y in extensionContext!.inputItems {
            if let inputItem = y as? NSExtensionItem {
                for x in inputItem.attachments! {
                    if x.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
                        x.loadItem(forTypeIdentifier: kUTTypeImage as String) { [unowned self] (imageData, error) in
                            DispatchQueue.main.async {
                                if let item = imageData as? Data {
                                    self.textView.frame = CGRect(x: 20, y: 90, width: UIScreen.main.bounds.size.width - 40, height: UIScreen.main.bounds.size.height - 190 - CGFloat(self.keyHeight))
                                }  else if let url = imageData as? URL {
                                    let data = try? Data(contentsOf: url)
                                    self.textView.frame = CGRect(x: 20, y: 90, width: UIScreen.main.bounds.size.width - 40, height: UIScreen.main.bounds.size.height - 190 - CGFloat(self.keyHeight))
                                } else if let imageData = imageData as? UIImage {
                                    self.textView.frame = CGRect(x: 20, y: 90, width: UIScreen.main.bounds.size.width - 40, height: UIScreen.main.bounds.size.height - 190 - CGFloat(self.keyHeight))
                                }
                            }
                        }
                    } else if x.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                        x.loadItem(forTypeIdentifier: kUTTypeURL as String) { [unowned self] (url, error) in
                            DispatchQueue.main.async {
                                if let shareURL = url as? NSURL {
                                    self.textView.text = "\(theText)\n\n\(shareURL)"
                                    let maxChars = self.maxChars - (self.textView.text?.count ?? 0)
                                    self.x2 = UIBarButtonItem(title: "\(maxChars)", style: .plain, target: self, action: #selector(self.viewMore))
                                    self.x2.accessibilityLabel = "Characters".localized
                                    self.formatToolbar.items?[2] = self.x2
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc func visibilityTap() {
        let symbolConfig6 = UIImage.SymbolConfiguration(pointSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .regular)
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let op1 = UIAlertAction(title: "Public".localized, style: .default , handler:{ (UIAlertAction) in
            self.defaultVisibility = .public
            self.x1 = UIBarButtonItem(image: UIImage(systemName: "globe", withConfiguration: symbolConfig6)!.withTintColor(UIColor(named: "baseBlack")!, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(self.visibilityTap))
            self.x1.accessibilityLabel = "Visibility".localized
            self.formatToolbar.items?[0] = self.x1
        })
        op1.setValue(UIImage(systemName: "globe")!, forKey: "image")
        op1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op1)
        let op3 = UIAlertAction(title: "Unlisted".localized, style: .default , handler:{ (UIAlertAction) in
            self.defaultVisibility = .unlisted
            self.x1 = UIBarButtonItem(image: UIImage(systemName: "lock.open", withConfiguration: symbolConfig6)!.withTintColor(UIColor(named: "baseBlack")!, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(self.visibilityTap))
            self.x1.accessibilityLabel = "Visibility".localized
            self.formatToolbar.items?[0] = self.x1
        })
        op3.setValue(UIImage(systemName: "lock.open")!, forKey: "image")
        op3.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op3)
        let op4 = UIAlertAction(title: " \("Followers".localized)", style: .default , handler:{ (UIAlertAction) in
            self.defaultVisibility = .private
            self.x1 = UIBarButtonItem(image: UIImage(systemName: "lock", withConfiguration: symbolConfig6)!.withTintColor(UIColor(named: "baseBlack")!, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(self.visibilityTap))
            self.x1.accessibilityLabel = "Visibility".localized
            self.formatToolbar.items?[0] = self.x1
        })
        op4.setValue(UIImage(systemName: "lock")!, forKey: "image")
        op4.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op4)
        let op6 = UIAlertAction(title: "Direct".localized, style: .default , handler:{ (UIAlertAction) in
            self.defaultVisibility = .direct
            self.x1 = UIBarButtonItem(image: UIImage(systemName: "paperplane", withConfiguration: symbolConfig6)!.withTintColor(UIColor(named: "baseBlack")!, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(self.visibilityTap))
            self.x1.accessibilityLabel = "Visibility".localized
            self.formatToolbar.items?[0] = self.x1
        })
        op6.setValue(UIImage(systemName: "paperplane")!, forKey: "image")
        op6.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op6)
        alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
            
        }))
        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = self.x1.value(forKey: "view") as? UIView
            presenter.sourceRect = (self.x1.value(forKey: "view") as? UIView)?.bounds ?? self.view.bounds
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func viewMore() {
        
    }
    
    @objc func crossTapped() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        textView.resignFirstResponder()
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: CGFloat(1.4),
                       initialSpringVelocity: CGFloat(3),
                       options: UIView.AnimationOptions.allowUserInteraction,
                       animations: {
                        
        }, completion: { test in
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        })
    }
    
    @objc func tickTapped() {
        var client = Client(baseURL: "")
        if let userDefaults = UserDefaults(suiteName: "group.com.shi.Mast.wormhole") {
            let value1 = userDefaults.string(forKey: "key1")
            let value2 = userDefaults.string(forKey: "key2")
            client = Client(
                baseURL: "https://\(value2 ?? "")",
                accessToken: value1 ?? ""
            )
        }
        let request = Statuses.create(status: self.textView.text, replyToID: nil, mediaIDs: [], sensitive: false, spoilerText: nil, visibility: self.defaultVisibility)
        client.run(request) { (statuses) in
            if let _ = (statuses.value) {
                DispatchQueue.main.async {
                    self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                }
            }
        }
    }
    
}

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}


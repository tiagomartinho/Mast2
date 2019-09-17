//
//  FirstViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 11/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

class FirstViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var tableView = UITableView()
    var loginBG = UIView()
    var loginLogo = UIImageView()
    var loginLabel = UILabel()
    var textField = PaddedTextField()
    var safariVC: SFSafariViewController?
    let segment: UISegmentedControl = UISegmentedControl(items: ["Home".localized, "Local".localized, "All".localized])
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Table
        let tableHeight = (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + (self.navigationController?.navigationBar.bounds.height ?? 0) + (self.segment.bounds.height) + 10
        self.tableView.frame = CGRect(x: 0, y: tableHeight, width: self.view.bounds.width, height: (self.view.bounds.height) - tableHeight)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "baseWhite")
        self.title = "Feed".localized
        self.removeTabbarItemsText()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.logged), name: NSNotification.Name(rawValue: "logged"), object: nil)
        
        if UserDefaults.standard.object(forKey: "clientID") == nil {} else {
            GlobalStruct.clientID = UserDefaults.standard.object(forKey: "clientID") as! String
        }
        if UserDefaults.standard.object(forKey: "clientSecret") == nil {} else {
            GlobalStruct.clientSecret = UserDefaults.standard.object(forKey: "clientSecret") as! String
        }
        if UserDefaults.standard.object(forKey: "authCode") == nil {} else {
            GlobalStruct.authCode = UserDefaults.standard.object(forKey: "authCode") as! String
        }
        if UserDefaults.standard.object(forKey: "returnedText") == nil {} else {
            GlobalStruct.returnedText = UserDefaults.standard.object(forKey: "returnedText") as! String
        }
        
        // Segmented control
        self.segment.frame = CGRect(x: 15, y: (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + (self.navigationController?.navigationBar.bounds.height ?? 0) + 5, width: self.view.bounds.width - 30, height: segment.bounds.height)
        self.segment.selectedSegmentIndex = 0
        self.view.addSubview(self.segment)

        // Add button
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(systemName: "plus", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn1.addTarget(self, action: #selector(self.addTapped), for: .touchUpInside)
        let addButton = UIBarButtonItem(customView: btn1)
        self.navigationItem.setRightBarButton(addButton, animated: true)
        
        let btn2 = UIButton(type: .custom)
        btn2.setImage(UIImage(systemName: "arrow.up.arrow.down", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        btn2.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn2.addTarget(self, action: #selector(self.sortTapped), for: .touchUpInside)
        let settingsButton = UIBarButtonItem(customView: btn2)
        self.navigationItem.setLeftBarButton(settingsButton, animated: true)
        
        // Log in
        if UserDefaults.standard.object(forKey: "accessToken") == nil {
            self.createLoginView()
        } else {
            GlobalStruct.returnedText = UserDefaults.standard.object(forKey: "returnedText") as? String ?? ""
            GlobalStruct.accessToken = UserDefaults.standard.object(forKey: "accessToken") as? String ?? ""
            GlobalStruct.client = Client(
                baseURL: "https://\(GlobalStruct.returnedText)",
                accessToken: GlobalStruct.accessToken
            )
            let request2 = Accounts.currentUser()
            GlobalStruct.client.run(request2) { (statuses) in
                if let stat = (statuses.value) {
                    DispatchQueue.main.async {
                        GlobalStruct.currentUser = stat
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "refProf"), object: nil)
                    }
                }
            }
            let request = Timelines.home()
            GlobalStruct.client.run(request) { (statuses) in
                if let stat = (statuses.value) {
                    DispatchQueue.main.async {
                        GlobalStruct.statusesHome = stat
                        self.tableView.reloadData()
                    }
                }
            }
        }
        
        // Table
        self.tableView.register(TootCell.self, forCellReuseIdentifier: "TootCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .singleLine
        self.tableView.separatorColor = UIColor(named: "baseBlack")?.withAlphaComponent(0.24)
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.layer.masksToBounds = true
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.showsVerticalScrollIndicator = true
        self.view.addSubview(self.tableView)
    }
    
    @objc func sortTapped() {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        GlobalStruct.statusesHome.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TootCell", for: indexPath) as! TootCell
        
        if GlobalStruct.statusesHome.isEmpty {} else {
            cell.username.text = GlobalStruct.statusesHome[indexPath.row].account.displayName
            cell.usertag.text = "@\(GlobalStruct.statusesHome[indexPath.row].account.username)"
            cell.content.text = GlobalStruct.statusesHome[indexPath.row].content.stripHTML()
            cell.configure(GlobalStruct.statusesHome[indexPath.row].account.avatar)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile(_:)))
            cell.profile.tag = indexPath.row
            cell.profile.addGestureRecognizer(tap)
        }
        
        cell.backgroundColor = UIColor(named: "baseWhite")
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = bgColorView
        return cell
    }
    
    @objc func viewProfile(_ gesture: UIGestureRecognizer) {
        let vc = FourthViewController()
        vc.isYou = false
        vc.pickedCurrentUser = GlobalStruct.statusesHome[gesture.view!.tag].account
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let vc = DetailViewController()
        vc.pickedStatusesHome = [GlobalStruct.statusesHome[indexPath.row]]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell = self.tableView.cellForRow(at: indexPath) as? TootCell {
            cell.highlightCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = self.tableView.cellForRow(at: indexPath) as? TootCell {
            cell.unhighlightCell()
        }
    }
    
    func tableView(_ tableView: UITableView, willCommitMenuWithAnimator animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            
        }
    }
    
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: {
            nil
        }, actionProvider: { suggestedActions in
            return self.makeContextMenu([GlobalStruct.statusesHome[indexPath.row]], indexPath: indexPath)
        })
    }
    
    func makeContextMenu(_ status: [Status], indexPath: IndexPath) -> UIMenu {
        let repl = UIAction(__title: "Reply".localized, image: UIImage(systemName: "arrowshape.turn.up.left"), identifier: nil) { action in
            
        }
        let boos = UIAction(__title: "Boost".localized, image: UIImage(systemName: "arrow.2.circlepath"), identifier: nil) { action in
            
        }
        let like = UIAction(__title: "Like".localized, image: UIImage(systemName: "star"), identifier: nil) { action in
            
        }
        let shar = UIAction(__title: "Share".localized, image: UIImage(systemName: "square.and.arrow.up"), identifier: nil) { action in
            
        }
        
        let tran = UIAction(__title: "Translate".localized, image: UIImage(systemName: "globe"), identifier: nil) { action in
            
        }
        let mute = UIAction(__title: "Mute".localized, image: UIImage(systemName: "eye.slash"), identifier: nil) { action in
            
        }
        let bloc = UIAction(__title: "Block".localized, image: UIImage(systemName: "hand.raised"), identifier: nil) { action in
            
        }
        let dupl = UIAction(__title: "Duplicate".localized, image: UIImage(systemName: "doc.on.doc"), identifier: nil) { action in
            
        }
        let repo = UIAction(__title: "Report".localized, image: UIImage(systemName: "xmark.octagon"), identifier: nil) { action in
            
        }
        let delete = UIAction(__title: "Delete".localized, image: UIImage(systemName: "trash"), identifier: nil) { action in
            
        }
        delete.attributes = .destructive
        let more = UIMenu(__title: "More".localized, image: UIImage(systemName: "ellipsis"), identifier: nil, options: [], children: [tran, mute, bloc, dupl, repo, delete])
        
        return UIMenu(__title: "", image: nil, identifier: nil, children: [repl, boos, like, shar, more])
    }
    
    @objc func addTapped() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "addTapped"), object: self)
    }
    
    func createLoginView(newInstance: Bool = false) {
        self.loginBG.frame = self.view.frame
        self.loginBG.backgroundColor = UIColor(named: "baseWhite")
        UIApplication.shared.windows.first?.addSubview(self.loginBG)
        
        self.loginLogo.frame = CGRect(x: self.view.bounds.width/2 - 40, y: self.view.bounds.height/4 - 40, width: 80, height: 80)
        self.loginLogo.image = UIImage(named: "logLogo")
        self.loginLogo.contentMode = .scaleAspectFit
        self.loginLogo.backgroundColor = UIColor.clear
        UIApplication.shared.windows.first?.addSubview(self.loginLogo)
        
        self.loginLabel.frame = CGRect(x: 50, y: self.view.bounds.height/2 - 57.5, width: self.view.bounds.width - 80, height: 35)
        self.loginLabel.text = "Instance name:".localized
        self.loginLabel.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.6)
        self.loginLabel.font = UIFont.systemFont(ofSize: 14)
        UIApplication.shared.windows.first?.addSubview(self.loginLabel)
        
        self.textField.frame = CGRect(x: 40, y: self.view.bounds.height/2 - 22.5, width: self.view.bounds.width - 80, height: 45)
        self.textField.backgroundColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.04)
        self.textField.borderStyle = .none
        self.textField.layer.cornerRadius = 10
        self.textField.textColor = UIColor(named: "baseBlack")
        self.textField.spellCheckingType = .no
        self.textField.returnKeyType = .done
        self.textField.autocorrectionType = .no
        self.textField.autocapitalizationType = .none
        self.textField.keyboardType = .URL
        self.textField.delegate = self
        self.textField.attributedPlaceholder = NSAttributedString(string: "mastodon.social",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        UIApplication.shared.windows.first?.addSubview(self.textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let returnedText = textField.text ?? ""
        if returnedText == "" || returnedText == " " || returnedText == "  " {} else {
            DispatchQueue.main.async {
                self.textField.resignFirstResponder()
                GlobalStruct.client = Client(baseURL: "https://\(returnedText)")
                let request = Clients.register(
                    clientName: "Mast",
                    redirectURI: "com.shi.Mast2://success",
                    scopes: [.read, .write, .follow, .push],
                    website: "https://twitter.com/jpeguin"
                )
                GlobalStruct.client.run(request) { (application) in
                    if application.value == nil {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Not a valid instance (may be closed or dead)", message: "Please enter an instance name like mastodon.social or mastodon.technology, or use one from the list to get started. You can sign in if you already have an account registered with the instance, or you can choose to sign up with a new account.", preferredStyle: .actionSheet)
                            let op1 = UIAlertAction(title: "Find out more".localized, style: .destructive , handler:{ (UIAlertAction) in
                                let queryURL = URL(string: "https://joinmastodon.org")!
                                UIApplication.shared.open(queryURL, options: [.universalLinksOnly: true]) { (success) in
                                    if !success {
                                        UIApplication.shared.open(queryURL)
                                    }
                                }
                            })
                            op1.setValue(UIImage(systemName: "trash")!, forKey: "image")
                            op1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
                            alert.addAction(op1)
                            alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
                            }))
                            if let presenter = alert.popoverPresentationController {
                                presenter.sourceView = self.view
                                presenter.sourceRect = self.view.bounds
                            }
                            self.present(alert, animated: true, completion: nil)
                        }
                    } else {
                        let application = application.value!
                        GlobalStruct.clientID = application.clientID
                        GlobalStruct.clientSecret = application.clientSecret
                        GlobalStruct.returnedText = returnedText
                        DispatchQueue.main.async {
                            let queryURL = URL(string: "https://\(returnedText)/oauth/authorize?response_type=code&redirect_uri=\("com.shi.Mast2://success".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&scope=read%20write%20follow%20push&client_id=\(application.clientID)")!
                            UIApplication.shared.open(queryURL, options: [.universalLinksOnly: true]) { (success) in
                                if !success {
                                    if (UserDefaults.standard.object(forKey: "linkdest") == nil) || (UserDefaults.standard.object(forKey: "linkdest") as! Int == 0) {
                                        self.safariVC = SFSafariViewController(url: queryURL)
                                        self.present(self.safariVC!, animated: true, completion: nil)
                                    } else {
                                        UIApplication.shared.open(queryURL, options: [:], completionHandler: nil)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return true
    }
    
    @objc func logged() {
        self.loginBG.removeFromSuperview()
        self.loginLogo.removeFromSuperview()
        self.loginLabel.removeFromSuperview()
        self.textField.removeFromSuperview()
        self.safariVC?.dismiss(animated: true, completion: nil)
        
        var request = URLRequest(url: URL(string: "https://\(GlobalStruct.returnedText)/oauth/token?grant_type=authorization_code&code=\(GlobalStruct.authCode)&redirect_uri=\("com.shi.Mast2://success".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&client_id=\(GlobalStruct.clientID)&client_secret=\(GlobalStruct.clientSecret)&scope=read%20write%20follow%20push")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else { print("error"); return }
            guard let data = data else { return }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    GlobalStruct.accessToken = (json["access_token"] as? String ?? "")
                    
                    UserDefaults.standard.set(GlobalStruct.clientID, forKey: "clientID")
                    UserDefaults.standard.set(GlobalStruct.clientSecret, forKey: "clientSecret")
                    UserDefaults.standard.set(GlobalStruct.authCode, forKey: "authCode")
                    UserDefaults.standard.set(GlobalStruct.accessToken, forKey: "accessToken")
                    UserDefaults.standard.set(GlobalStruct.returnedText, forKey: "returnedText")
                    
                    let request2 = Accounts.currentUser()
                    GlobalStruct.client.run(request2) { (statuses) in
                        if let stat = (statuses.value) {
                            DispatchQueue.main.async {
                                GlobalStruct.currentUser = stat
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "refProf"), object: nil)
                            }
                        }
                    }
                    let request = Timelines.home()
                    GlobalStruct.client.run(request) { (statuses) in
                        if let stat = (statuses.value) {
                            DispatchQueue.main.async {
                                GlobalStruct.statusesHome = stat
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    func removeTabbarItemsText() {
        if let items = self.tabBarController?.tabBar.items {
            for item in items {
                item.title = ""
            }
        }
    }
}

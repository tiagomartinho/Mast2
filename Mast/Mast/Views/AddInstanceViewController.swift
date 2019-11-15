//
//  AddInstanceViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 08/11/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

class AddInstanceViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
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
    var loginBG = UIView()
    var loginLogo = UIImageView()
    var loginLabel = UILabel()
    var textField = PaddedTextField()
    var safariVC: SFSafariViewController?
    var newInstance: Bool = false
    var altInstances: [String] = []
    var tableView = UITableView()
    var keyHeight: CGFloat = 0
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.textField.frame = CGRect(x: self.view.safeAreaInsets.left + 20, y: (self.navigationController?.navigationBar.frame.height ?? 0) + 20, width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right - 40, height: 50)
        let part1 = (self.navigationController?.navigationBar.frame.height ?? 0) + 90 + self.keyHeight
        self.tableView.frame = CGRect(x: self.view.safeAreaInsets.left, y: (self.navigationController?.navigationBar.frame.height ?? 0) + 90, width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: self.view.bounds.height - part1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createLoginView(newInstance: true)
        
        self.view.backgroundColor = UIColor(named: "lighterBaseWhite")
        self.title = "Add New Instance".localized
        
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(named: "baseBlack")!]
        
        self.navigationController?.navigationBar.backgroundColor = GlobalStruct.baseDarkTint
        self.navigationController?.navigationBar.barTintColor = GlobalStruct.baseDarkTint
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Add button
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
        let btn2 = UIButton(type: .custom)
        btn2.setImage(UIImage(systemName: "xmark", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        btn2.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn2.addTarget(self, action: #selector(self.crossTapped), for: .touchUpInside)
        btn2.accessibilityLabel = "Dismiss".localized
        let settingsButton = UIBarButtonItem(customView: btn2)
        self.navigationItem.setRightBarButton(settingsButton, animated: true)
        
        self.tableView = UITableView(frame: .zero, style: .insetGrouped)
        self.tableView = UITableView(frame: .zero, style: .insetGrouped)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell1")
        self.tableView.alpha = 1
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = .clear
        self.tableView.separatorStyle = .singleLine
        self.tableView.separatorColor = UIColor(named: "baseBlack")?.withAlphaComponent(0.24)
        self.tableView.layer.masksToBounds = true
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        self.tableView.rowHeight = UITableView.automaticDimension
        self.view.addSubview(self.tableView)
        self.tableView.tableFooterView = UIView()
        
        self.fetchAltInstances()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.newInstanceLogged), name: NSNotification.Name(rawValue: "newInstanceLogged"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.textField.becomeFirstResponder()
    }
    
    @objc func crossTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.keyHeight = CGFloat(keyboardHeight)

            let part1 = (self.navigationController?.navigationBar.frame.height ?? 0) + 90 + self.keyHeight
            self.tableView.frame = CGRect(x: self.view.safeAreaInsets.left, y: (self.navigationController?.navigationBar.frame.height ?? 0) + 90, width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: self.view.bounds.height - part1)
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            self.keyHeight = CGFloat(0)

            let part1 = (self.navigationController?.navigationBar.frame.height ?? 0) + 90
            self.tableView.frame = CGRect(x: self.view.safeAreaInsets.left, y: (self.navigationController?.navigationBar.frame.height ?? 0) + 90, width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: self.view.bounds.height - part1)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        vw.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 60)
        vw.backgroundColor = .clear
        let title = UILabel()
        title.frame = CGRect(x: (UIApplication.shared.windows.first?.safeAreaInsets.left ?? 0) + 10, y: 0, width: self.view.bounds.width - 20, height: 60)
        title.text = "Pick the instance you'd like to add an account from"
        title.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.25)
        title.font = UIFont.systemFont(ofSize: 14)
        title.numberOfLines = 0
        vw.addSubview(title)
        return vw
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.accessoryType = .disclosureIndicator
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.altInstances.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell1", for: indexPath)
        cell.textLabel?.text = self.altInstances[indexPath.row]
        cell.textLabel?.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.85)
        cell.backgroundColor = UIColor(named: "baseWhite")!
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(named: "baseWhite")!
        cell.selectedBackgroundView = bgColorView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.textField.text = "\(self.altInstances[indexPath.row])"
        GlobalStruct.newInstance = InstanceData()
        GlobalStruct.newClient = Client(baseURL: "https://\("\(self.altInstances[indexPath.row])")")
        let request = Clients.register(
            clientName: "Mast",
            redirectURI: "com.shi.Mast://addNewInstance",
            scopes: [.read, .write, .follow, .push],
            website: "https://twitter.com/jpeguin"
        )
        GlobalStruct.newClient.run(request) { (application) in
            if application.value == nil {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Not a valid instance (may be closed or dead)", message: "Please enter an instance name like mastodon.social or mastodon.technology, or use one from the list to get started. You can sign in if you already have an account registered with the instance, or you can choose to sign up with a new account.", preferredStyle: .actionSheet)
                    let op1 = UIAlertAction(title: "Find out more".localized, style: .default , handler:{ (UIAlertAction) in
                        let queryURL = URL(string: "https://joinmastodon.org")!
                        UIApplication.shared.open(queryURL, options: [.universalLinksOnly: true]) { (success) in
                            if !success {
                                UIApplication.shared.open(queryURL)
                            }
                        }
                    })
                    op1.setValue(UIImage(systemName: "link.circle")!, forKey: "image")
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
                GlobalStruct.newInstance?.clientID = application.clientID
                GlobalStruct.newInstance?.clientSecret = application.clientSecret
                GlobalStruct.newInstance?.returnedText = "\(self.altInstances[indexPath.row])"
                GlobalStruct.newInstance?.redirect = "com.shi.Mast://addNewInstance".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                DispatchQueue.main.async {
                    let queryURL = URL(string: "https://\("\(self.altInstances[indexPath.row])")/oauth/authorize?response_type=code&redirect_uri=\(GlobalStruct.newInstance!.redirect)&scope=read%20write%20follow%20push&client_id=\(application.clientID)")!
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
    
    func fetchAltInstances() {
        let urlStr = "https://instances.social/api/1.0/instances/list?count=\(100)&include_closed=\(false)&include_down=\(false)"
        let url: URL = URL(string: urlStr)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer 8gVQzoU62VFjvlrdnBUyAW8slAekA5uyuwdMi0CBzwfWwyStkqQo80jTZemuSGO8QomSycdD1JYgdRUnJH0OVT3uYYUilPMenrRZupuMQLl9hVt6xnhV6bwdXVSAT1wR", forHTTPHeaderField: "Authorization")
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let task = session.dataTask(with: request) { (data, response, err) in
            do {
                let json = try JSONDecoder().decode(tagInstances.self, from: data ?? Data())
                DispatchQueue.main.async {
                    for x in json.instances {
                        self.altInstances.append(x.name)
                    }
                    self.altInstances.insert("mastodon.technology", at: 0)
                    self.altInstances.insert("mastodon.social", at: 0)
                    self.tableView.reloadData()
                }
            } catch {
                print("err")
            }
        }
        task.resume()
    }
    
    func createLoginView(newInstance: Bool = false) {
        self.newInstance = newInstance
        self.loginBG.frame = self.view.frame
        self.loginBG.backgroundColor = GlobalStruct.baseDarkTint
//        self.view.addSubview(self.loginBG)
        
        self.loginLogo.frame = CGRect(x: self.view.bounds.width/2 - 40, y: self.view.bounds.height/4 - 40, width: 80, height: 80)
        self.loginLogo.image = UIImage(named: "logLogo")
        self.loginLogo.contentMode = .scaleAspectFit
        self.loginLogo.backgroundColor = UIColor.clear
//        self.view.addSubview(self.loginLogo)
        
        self.loginLabel.frame = CGRect(x: 50, y: self.view.bounds.height/2 - 57.5, width: self.view.bounds.width - 80, height: 35)
        self.loginLabel.text = "Instance name:".localized
        self.loginLabel.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.6)
        self.loginLabel.font = UIFont.systemFont(ofSize: 14)
//        self.view.addSubview(self.loginLabel)
        
        self.textField.backgroundColor = UIColor(named: "baseWhite")!
        self.textField.borderStyle = .none
        self.textField.layer.cornerRadius = 8
        self.textField.layer.cornerCurve = .continuous
        self.textField.textColor = UIColor(named: "baseBlack")
        self.textField.spellCheckingType = .no
        self.textField.returnKeyType = .done
        self.textField.autocorrectionType = .no
        self.textField.autocapitalizationType = .none
        self.textField.keyboardType = .URL
        self.textField.delegate = self
        self.textField.attributedPlaceholder = NSAttributedString(string: "Instance name...",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray.withAlphaComponent(0.45)])
        self.textField.accessibilityLabel = "Enter Instance Name".localized
        self.view.addSubview(self.textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        DispatchQueue.main.async {
            self.textField.resignFirstResponder()
        }
        let returnedText = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if returnedText == "" || returnedText == " " || returnedText == "  " {} else {
            DispatchQueue.main.async {
                if self.newInstance {
                    GlobalStruct.newInstance = InstanceData()
                    GlobalStruct.newClient = Client(baseURL: "https://\(returnedText)")
                    let request = Clients.register(
                        clientName: "Mast",
                        redirectURI: "com.shi.Mast://addNewInstance",
                        scopes: [.read, .write, .follow, .push],
                        website: "https://twitter.com/jpeguin"
                    )
                    GlobalStruct.newClient.run(request) { (application) in
                        if application.value == nil {
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: "Not a valid instance (may be closed or dead)", message: "Please enter an instance name like mastodon.social or mastodon.technology, or use one from the list to get started. You can sign in if you already have an account registered with the instance, or you can choose to sign up with a new account.", preferredStyle: .actionSheet)
                                let op1 = UIAlertAction(title: "Find out more".localized, style: .default , handler:{ (UIAlertAction) in
                                    let queryURL = URL(string: "https://joinmastodon.org")!
                                    UIApplication.shared.open(queryURL, options: [.universalLinksOnly: true]) { (success) in
                                        if !success {
                                            UIApplication.shared.open(queryURL)
                                        }
                                    }
                                })
                                op1.setValue(UIImage(systemName: "link.circle")!, forKey: "image")
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
                            GlobalStruct.newInstance?.clientID = application.clientID
                            GlobalStruct.newInstance?.clientSecret = application.clientSecret
                            GlobalStruct.newInstance?.returnedText = returnedText
                            GlobalStruct.newInstance?.redirect = "com.shi.Mast://addNewInstance".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                            DispatchQueue.main.async {
                                let queryURL = URL(string: "https://\(returnedText)/oauth/authorize?response_type=code&redirect_uri=\(GlobalStruct.newInstance!.redirect)&scope=read%20write%20follow%20push&client_id=\(application.clientID)")!
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
                    
                } else {
                    GlobalStruct.client = Client(baseURL: "https://\(returnedText)")
                    let request = Clients.register(
                        clientName: "Mast",
                        redirectURI: "com.shi.Mast://success",
                        scopes: [.read, .write, .follow, .push],
                        website: "https://twitter.com/jpeguin"
                    )
                    GlobalStruct.client.run(request) { (application) in
                        if application.value == nil {
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: "Not a valid instance (may be closed or dead)", message: "Please enter an instance name like mastodon.social or mastodon.technology, or use one from the list to get started. You can sign in if you already have an account registered with the instance, or you can choose to sign up with a new account.", preferredStyle: .actionSheet)
                                let op1 = UIAlertAction(title: "Find out more".localized, style: .default , handler:{ (UIAlertAction) in
                                    let queryURL = URL(string: "https://joinmastodon.org")!
                                    UIApplication.shared.open(queryURL, options: [.universalLinksOnly: true]) { (success) in
                                        if !success {
                                            UIApplication.shared.open(queryURL)
                                        }
                                    }
                                })
                                op1.setValue(UIImage(systemName: "link.circle")!, forKey: "image")
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
                            GlobalStruct.currentInstance.clientID = application.clientID
                            GlobalStruct.currentInstance.clientSecret = application.clientSecret
                            GlobalStruct.currentInstance.returnedText = returnedText
                            DispatchQueue.main.async {
                                let queryURL = URL(string: "https://\(returnedText)/oauth/authorize?response_type=code&redirect_uri=\("com.shi.Mast://success".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&scope=read%20write%20follow%20push&client_id=\(application.clientID)")!
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
        }
        return true
    }
    
    @objc func newInstanceLogged() {
        self.safariVC?.dismiss(animated: true, completion: nil)
        
        var request = URLRequest(url: URL(string: "https://\(GlobalStruct.newInstance!.returnedText)/oauth/token?grant_type=authorization_code&code=\(GlobalStruct.newInstance!.authCode)&redirect_uri=\(GlobalStruct.newInstance!.redirect)&client_id=\(GlobalStruct.newInstance!.clientID)&client_secret=\(GlobalStruct.newInstance!.clientSecret)&scope=read%20write%20follow%20push")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else { print("error"); return }
            guard let data = data else { return }
            guard let newInstance = GlobalStruct.newInstance else {
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    
                    if let access1 = (json["access_token"] as? String) {
                        
                        GlobalStruct.client = GlobalStruct.newClient
                        newInstance.accessToken = access1
                        InstanceData.setCurrentInstance(instance: newInstance)
                        
                        UserDefaults.standard.set(GlobalStruct.client.accessToken, forKey: "accessToken")
                        
                        let request2 = Accounts.currentUser()
                        GlobalStruct.client.run(request2) { (statuses) in
                            if let stat = (statuses.value) {
                                DispatchQueue.main.async {
                                    var instances = InstanceData.getAllInstances()
                                    instances.append(newInstance)
                                    UserDefaults.standard.set(try? PropertyListEncoder().encode(instances), forKey: "instances")
                                    Account.addAccountToList(account: stat)
                                    FirstViewController().initialFetches()
                                    self.dismiss(animated: true, completion: nil)
                                    
                                    #if targetEnvironment(macCatalyst)
                                    let rootController = ColumnViewController()
                                    let nav0 = VerticalTabBarController()
                                    let nav1 = ScrollMainViewController()

                                    let nav01 = UINavigationController(rootViewController: FirstViewController())
                                    let nav02 = UINavigationController(rootViewController: SecondViewController())
                                    let nav03 = UINavigationController(rootViewController: ThirdViewController())
                                    let nav04 = UINavigationController(rootViewController: FourthViewController())
                                    let nav05 = UINavigationController(rootViewController: FifthViewController())
                                    nav1.viewControllers = [nav01, nav02, nav03, nav04, nav05]

                                    rootController.viewControllers = [nav0, nav1]
                                    self.window?.rootViewController = rootController
                                    self.window!.makeKeyAndVisible()
                                    #elseif !targetEnvironment(macCatalyst)
                                    if UIDevice.current.userInterfaceIdiom == .pad && self.isSplitOrSlideOver == false {
                                        let rootController = ColumnViewController()
                                        let nav0 = VerticalTabBarController()
                                        let nav1 = ScrollMainViewController()

                                        let nav01 = UINavigationController(rootViewController: FirstViewController())
                                        let nav02 = UINavigationController(rootViewController: SecondViewController())
                                        let nav03 = UINavigationController(rootViewController: ThirdViewController())
                                        let nav04 = UINavigationController(rootViewController: FourthViewController())
                                        let nav05 = UINavigationController(rootViewController: FifthViewController())
                                        nav1.viewControllers = [nav01, nav02, nav03, nav04, nav05]

                                        rootController.viewControllers = [nav0, nav1]
                                        UIApplication.shared.keyWindow?.rootViewController = rootController
                                        UIApplication.shared.keyWindow?.makeKeyAndVisible()
                                    } else {
                                        UIApplication.shared.keyWindow?.rootViewController = ViewController()
                                    }
                                    #endif
                                    
                                }
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
    
}

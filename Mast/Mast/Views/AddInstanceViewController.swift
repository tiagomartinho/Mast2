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

class AddInstanceViewController: UIViewController, UITextFieldDelegate {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "baseWhite")
        self.createLoginView(newInstance: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.newInstanceLogged), name: NSNotification.Name(rawValue: "newInstanceLogged"), object: nil)
    }
    
    func createLoginView(newInstance: Bool = false) {
        self.newInstance = newInstance
        self.loginBG.frame = self.view.frame
        self.loginBG.backgroundColor = UIColor(named: "baseWhite")
        self.view.addSubview(self.loginBG)
        
        self.loginLogo.frame = CGRect(x: self.view.bounds.width/2 - 40, y: self.view.bounds.height/4 - 40, width: 80, height: 80)
        self.loginLogo.image = UIImage(named: "logLogo")
        self.loginLogo.contentMode = .scaleAspectFit
        self.loginLogo.backgroundColor = UIColor.clear
        self.view.addSubview(self.loginLogo)
        
        self.loginLabel.frame = CGRect(x: 50, y: self.view.bounds.height/2 - 57.5, width: self.view.bounds.width - 80, height: 35)
        self.loginLabel.text = "Instance name:".localized
        self.loginLabel.textColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.6)
        self.loginLabel.font = UIFont.systemFont(ofSize: 14)
        self.view.addSubview(self.loginLabel)
        
        self.textField.frame = CGRect(x: 40, y: self.view.bounds.height/2 - 22.5, width: self.view.bounds.width - 80, height: 45)
        self.textField.backgroundColor = UIColor(named: "baseBlack")!.withAlphaComponent(0.04)
        self.textField.borderStyle = .none
        self.textField.layer.cornerRadius = 5
        self.textField.textColor = UIColor(named: "baseBlack")
        self.textField.spellCheckingType = .no
        self.textField.returnKeyType = .done
        self.textField.autocorrectionType = .no
        self.textField.autocapitalizationType = .none
        self.textField.keyboardType = .URL
        self.textField.delegate = self
        self.textField.attributedPlaceholder = NSAttributedString(string: "mastodon.social",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        self.textField.accessibilityLabel = "Enter Instance".localized
        self.view.addSubview(self.textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let returnedText = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if returnedText == "" || returnedText == " " || returnedText == "  " {} else {
            DispatchQueue.main.async {
                self.textField.resignFirstResponder()
                
                if self.newInstance {
                    GlobalStruct.newInstance = InstanceData()
                    GlobalStruct.newClient = Client(baseURL: "https://\(returnedText)")
                    let request = Clients.register(
                        clientName: "Mast",
                        redirectURI: "com.shi.Mast2://addNewInstance",
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
                            GlobalStruct.newInstance?.redirect = "com.shi.Mast2://addNewInstance".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
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
                        redirectURI: "com.shi.Mast2://success",
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

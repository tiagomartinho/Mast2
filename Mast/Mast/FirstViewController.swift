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

class FirstViewController: UIViewController, UITextFieldDelegate {
    
    var loginBG = UIView()
    var loginLogo = UIImageView()
    var loginLabel = UILabel()
    var textField = PaddedTextField()
    var safariVC: SFSafariViewController?
    
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
        
        // Log in
        if UserDefaults.standard.object(forKey: "accessToken") == nil {
            self.createLoginView()
        } else {
            GlobalStruct.client = Client(
                baseURL: "https://\(GlobalStruct.returnedText)",
                accessToken: GlobalStruct.accessToken
            )
        }
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
                            GlobalStruct.statusesHome = stat
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "refresh"), object: nil)
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

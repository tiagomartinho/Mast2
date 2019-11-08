//
//  AccountsSettingsViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 08/11/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class AccountsSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
    
    override func viewDidLayoutSubviews() {
        self.tableView.frame = CGRect(x: self.view.safeAreaInsets.left, y: 0, width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: self.view.bounds.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "lighterBaseWhite")
        self.title = "Accounts".localized
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(named: "baseBlack")!]
        
        // Add button
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
        let btn2 = UIButton(type: .custom)
        btn2.setImage(UIImage(systemName: "plus", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        btn2.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn2.addTarget(self, action: #selector(self.addTapped), for: .touchUpInside)
        btn2.accessibilityLabel = "Add".localized
        let settingsButton = UIBarButtonItem(customView: btn2)
        self.navigationItem.setRightBarButton(settingsButton, animated: true)
        
        self.tableView = UITableView(frame: .zero, style: .insetGrouped)
        self.tableView.register(AccountCell.self, forCellReuseIdentifier: "AccountCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.layer.masksToBounds = true
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.showsVerticalScrollIndicator = false
        self.view.addSubview(self.tableView)
        self.tableView.reloadData()
    }
    
    @objc func addTapped() {
        DispatchQueue.main.async {
            let vc = AddInstanceViewController()
            self.present(vc, animated: true, completion: {
//                vc.textField.becomeFirstResponder()
            })
        }
    }
    
    //MARK: TableView
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Account.getAccounts().count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let instances = InstanceData.getAllInstances()
        if instances.isEmpty || Account.getAccounts().isEmpty {
            cell.accessoryType = .none
        } else {
            let curr = InstanceData.getCurrentInstance()
            if curr?.clientID == instances[indexPath.item].clientID {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath) as! AccountCell
        cell.backgroundColor = UIColor(named: "baseWhite")

        var instance: InstanceData? = nil
        if InstanceData.getAllInstances().count == 0 {} else {
            instance = InstanceData.getAllInstances()[indexPath.row]
        }
        let instanceAndAccount = "@\(instance?.returnedText ?? "")"

        let account = Account.getAccounts()[indexPath.item]
        cell.configure(account.displayName, op2: "@\(account.username)\(instanceAndAccount)", op3: account.avatar)
        
//        if indexPath.row == (UserDefaults.standard.value(forKey: "sync-chosenAccount") as! Int) {
//            cell.accessoryType = .checkmark
//        } else {
//            cell.accessoryType = .none
//        }

        let instances = InstanceData.getAllInstances()
        if instances.isEmpty || Account.getAccounts().isEmpty {
            cell.accessoryType = .none
        } else {
            let curr = InstanceData.getCurrentInstance()
            if curr?.clientID == instances[indexPath.item].clientID {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        DispatchQueue.main.async {

            let instances = InstanceData.getAllInstances()
            if instances.isEmpty || Account.getAccounts().isEmpty {
                
            } else {
                let curr = InstanceData.getCurrentInstance()
                if curr?.clientID == instances[indexPath.item].clientID {
                    
                } else {
                    InstanceData.setCurrentInstance(instance: instances[indexPath.item])
                    GlobalStruct.client = Client(
                        baseURL: "https://\(instances[indexPath.item].returnedText)",
                        accessToken: instances[indexPath.item].accessToken
                    )
                    self.tableView.reloadData()
                    FirstViewController().initialFetches()
                }
            }
            
        }
    }
}





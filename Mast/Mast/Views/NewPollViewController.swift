//
//  NewPollViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 12/11/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class NewPollViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var currentOptions: [String] = []
    var tootLabel = UIButton()
    var textField = TextFieldP()
    var keyHeight = 0
    var tableView = UITableView()
    let timePicker = UIDatePicker()
    let toolBar = UIToolbar()
    var hiddenTextField = UITextField()
    var titlesOp = ["Allow Multiple Selections".localized, "Hide Totals".localized]
    var descriptionsOp = ["Allow users to select multiple options when voting.".localized, "Hide the running vote count from users.".localized]
    var pollPickerDate = Date()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.textField.frame = CGRect(x: self.view.safeAreaInsets.left, y: self.navigationController?.navigationBar.frame.height ?? 0, width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: 42)
        self.tableView.frame = CGRect(x: self.view.safeAreaInsets.left, y: (self.navigationController?.navigationBar.frame.height ?? 0) + 42, width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, height: self.view.bounds.height - (self.navigationController?.navigationBar.frame.height ?? 0) - 42)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "baseWhite")!
        self.title = "Add Poll".localized
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(named: "baseBlack")!]
        
        self.navigationController?.navigationBar.backgroundColor = GlobalStruct.baseDarkTint
        self.navigationController?.navigationBar.barTintColor = GlobalStruct.baseDarkTint
        
        textField.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        textField.delegate = self
        textField.keyboardType = .default
        textField.attributedPlaceholder = NSAttributedString(string: "Add at least two poll options...".localized,
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "baseBlack")!.withAlphaComponent(0.25)])
        textField.textColor = UIColor(named: "baseBlack")!
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.returnKeyType = .done
        self.view.addSubview(textField)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeDown.direction = .down
        textField.addGestureRecognizer(swipeDown)
        
        self.hiddenTextField.frame = CGRect.zero
        self.view.addSubview(self.hiddenTextField)
        
        self.tableView.register(PollOptionCell.self, forCellReuseIdentifier: "PollOptionCell")
        self.tableView.register(PollOptionCell.self, forCellReuseIdentifier: "PollOptionCell2")
        self.tableView.register(PollOptionCellToggle.self, forCellReuseIdentifier: "PollOptionCellToggle")
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
        
        self.openTimePicker()
    }
    
    func openTimePicker()  {
//        self.timePicker.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 250)
//        self.timePicker.tintColor = Colours.grayDark
//        self.timePicker.datePickerMode = .dateAndTime
//        self.timePicker.minimumDate = Date()
//
//        if (UserDefaults.standard.object(forKey: "theme") == nil || UserDefaults.standard.object(forKey: "theme") as! Int == 0) {
//            toolBar.barStyle = .default
//            self.timePicker.backgroundColor = UIColor.white
//            self.timePicker.setValue(UIColor.black, forKeyPath: "textColor")
//            self.timePicker.setValue(false, forKeyPath: "highlightsToday")
//        } else {
//            toolBar.barStyle = .blackOpaque
//            self.timePicker.backgroundColor = UIColor.black
//            self.timePicker.setValue(UIColor.white, forKeyPath: "textColor")
//            self.timePicker.setValue(false, forKeyPath: "highlightsToday")
//        }
//
//        toolBar.isTranslucent = false
//        toolBar.tintColor = Colours.tabUnselected
//        toolBar.sizeToFit()
//
//        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(timeChanged))
//        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker))
//        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: true)
//        toolBar.isUserInteractionEnabled = true
//
//        self.hiddenTextField.inputView = timePicker
//        self.hiddenTextField.inputAccessoryView = toolBar
    }
    
    @objc func cancelDatePicker() {
        self.hiddenTextField.resignFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.textField.resignFirstResponder()
        self.hiddenTextField.resignFirstResponder()
    }
    
    @objc func timeChanged() {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? PollOptionCell {
            cell.configure(formatter.string(from: self.timePicker.date), count: "This poll will expire on:")
        }
        
        self.pollPickerDate = self.timePicker.date
        let expiresIn = Calendar.current.dateComponents([.second], from: Date(), to: self.timePicker.date).second ?? 0
        
        self.hiddenTextField.resignFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        self.textField.becomeFirstResponder()
        
        var tabHeight = Int(UITabBarController().tabBar.frame.size.height) + Int(34)
        var offset = 88
        var closeB = 47
        var botbot = 20
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2688:
                offset = 88
                closeB = 47
                botbot = 40
            case 2436, 1792:
                offset = 88
                closeB = 47
                botbot = 40
            default:
                offset = 64
                closeB = 24
                botbot = 20
                tabHeight = Int(UITabBarController().tabBar.frame.size.height)
            }
        }
        
        let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
        switch (deviceIdiom) {
        case .pad:
            self.tableView.translatesAutoresizingMaskIntoConstraints = false
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: CGFloat(closeB + 40)).isActive = true
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        default:
            print("nothing")
        }
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.keyHeight = Int(keyboardHeight)
        }
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        }
        if gesture.direction == UISwipeGestureRecognizer.Direction.down {
            self.textField.resignFirstResponder()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func didTouchUpInsideCloseButton(_ sender: AnyObject) {
        if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        }
        
        self.textField.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text == "" || textField.text == " " {
            self.textField.resignFirstResponder()
        } else {
            self.currentOptions.append(textField.text ?? "")
            self.textField.text = ""
            self.tableView.reloadData()
        }
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if (UserDefaults.standard.object(forKey: "keyhap") == nil) || (UserDefaults.standard.object(forKey: "keyhap") as! Int == 0) {
            
        } else if (UserDefaults.standard.object(forKey: "keyhap") as! Int == 1) {
            let selection = UISelectionFeedbackGenerator()
            selection.selectionChanged()
        } else if (UserDefaults.standard.object(forKey: "keyhap") as! Int == 2) {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        }
        
        if (textField.text?.count)! > 0 && self.currentOptions.count < 2 {
            tootLabel.setTitleColor(GlobalStruct.baseTint, for: .normal)
        } else {
            tootLabel.setTitleColor(UIColor(named: "baseWhite")!, for: .normal)
        }
    }
    
    @objc func didTouchUpInsideTootButton(_ sender: AnyObject) {
        if self.currentOptions.count < 2 { return }
        if self.currentOptions.isEmpty && self.textField.text == "" { return }
        
//        GlobalStruct.newPollPost = [self.currentOptions, GlobalStruct.expiresIn, GlobalStruct.allowsMultiple, GlobalStruct.totalsHidden]
//        NotificationCenter.default.post(name: Notification.Name(rawValue: "addedPoll"), object: self)
        
        self.textField.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.currentOptions.count
        } else if section == 1 {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PollOptionCell", for: indexPath) as! PollOptionCell
            cell.configure(self.currentOptions[indexPath.row], count: "Option \(indexPath.row + 1)")
            cell.backgroundColor = UIColor(named: "baseWhite")!
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor(named: "baseWhite")!
            cell.selectedBackgroundView = bgColorView
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PollOptionCell2", for: indexPath) as! PollOptionCell
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            var dText = formatter.string(from: self.pollPickerDate)
            if self.pollPickerDate == Date() {
                dText = "Tomorrow"
            }
            cell.configure(dText, count: "This poll will expire on:")
            cell.backgroundColor = UIColor(named: "baseWhite")!
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor(named: "baseWhite")!
            cell.selectedBackgroundView = bgColorView
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PollOptionCellToggle", for: indexPath) as! PollOptionCellToggle
            cell.configure(status: self.titlesOp[indexPath.row], status2: self.descriptionsOp[indexPath.row])
            cell.backgroundColor = UIColor(named: "baseWhite")!
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor(named: "baseWhite")!
            cell.selectedBackgroundView = bgColorView
            cell.switchView.setOn(false, animated: false)
            if indexPath.row == 0 {
                cell.switchView.addTarget(self, action: #selector(self.handleToggle1), for: .touchUpInside)
            } else {
                cell.switchView.addTarget(self, action: #selector(self.handleToggle2), for: .touchUpInside)
            }
            return cell
        }
    }
    
    @objc func handleToggle1(sender: UISwitch) {
        if sender.isOn {
            GlobalStruct.allowsMultiple = true
            sender.setOn(true, animated: true)
        } else {
            GlobalStruct.allowsMultiple = false
            sender.setOn(false, animated: true)
        }
    }
    
    @objc func handleToggle2(sender: UISwitch) {
        if sender.isOn {
            GlobalStruct.totalsHidden = true
            sender.setOn(true, animated: true)
        } else {
            GlobalStruct.totalsHidden = false
            sender.setOn(false, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
//        if indexPath.section == 0 {
//            if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
//                let selection = UISelectionFeedbackGenerator()
//                selection.selectionChanged()
//            }
//            Alertift.actionSheet(title: nil, message: nil)
//                .backgroundColor(Colours.white)
//                .titleTextColor(Colours.grayDark)
//                .messageTextColor(Colours.grayDark.withAlphaComponent(0.8))
//                .messageTextAlignment(.left)
//                .titleTextAlignment(.left)
//                .action(.default("Remove Option".localized), image: UIImage(named: "block")) { (action, ind) in
//
//                    self.currentOptions = self.currentOptions.filter { $0 != self.currentOptions[indexPath.row] }
//                    self.tableView.reloadData()
//                    if self.currentOptions.count < 2 {
//                        self.tootLabel.setTitleColor(GlobalStruct.baseTint, for: .normal)
//                    } else {
//                        self.tootLabel.setTitleColor(Colours.grayDark.withAlphaComponent(0.38), for: .normal)
//                    }
//                }
//                .action(.cancel("Dismiss"))
//                .finally { action, index in
//                    if action.style == .cancel {
//                        return
//                    }
//                }
//                .popover(anchorView: self.tableView.cellForRow(at: indexPath) ?? self.view)
//                .show(on: self)
//        } else if indexPath.section == 1 {
//            if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
//                let selection = UISelectionFeedbackGenerator()
//                selection.selectionChanged()
//            }
//            self.textField.resignFirstResponder()
//            self.hiddenTextField.becomeFirstResponder()
//        } else {
//
//        }
    }
}

class TextFieldP: UITextField {

    let padding = UIEdgeInsets(top: 2, left: 18, bottom: 2, right: 18)

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}

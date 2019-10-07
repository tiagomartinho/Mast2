//
//  GlobalStruct.swift
//  Mast
//
//  Created by Shihab Mehboob on 11/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class GlobalStruct {
    static var client = Client(baseURL: "", accessToken: "")
    static var clientID = ""
    static var clientSecret = ""
    static var returnedText = ""
    static var accessToken = ""
    static var authCode = ""
    static var redirect = ""
    
    static var baseTint = UIColor.systemIndigo
    static var arrayCols: [UIColor] = [UIColor.systemIndigo, UIColor.systemPurple, UIColor.systemBlue, UIColor.systemGreen, UIColor.systemYellow, UIColor.systemOrange, UIColor.systemRed, UIColor.systemPink, UIColor.brown, UIColor.systemGray]
    static var colNames: [String] = ["Wild Indigo", "Electric Purple", "Calm Blue", "Lush Green", "Banana Yellow", "Sunset Orange", "Berry Red", "Bubblegum Pink", "Island Brown", "Ash Gray"]
    
    static var statusesHome: [Status] = []
    static var statusesLocal: [Status] = []
    static var statusesFed: [Status] = []
    
    static var statusesPinned: [Status] = []
    
    static var notifications: [Notificationt] = []
    static var notificationsMentions: [Notificationt] = []
    static var notificationsDirect: [Conversation] = []
    
    static var currentUser: Account!
    
    static var allLists: [List] = []
    
    static var currentTab = 1
    static var medType = 0
    static var avaFile = "avatar"
    static var heaFile = "header"
}

class PaddedTextField: UITextField {
    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}

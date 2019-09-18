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
    static var baseTint = UIColor(red: 123/255, green: 112/255, blue: 238/255, alpha: 1)
    
    static var statusesHome: [Status] = []
    static var statusesLocal: [Status] = []
    static var statusesFed: [Status] = []
    
    static var notifications: [Notificationt] = []
    static var notificationsMentions: [Notificationt] = []
    static var notificationsDirect: [Conversation] = []
    
    static var currentUser: Account!
    
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

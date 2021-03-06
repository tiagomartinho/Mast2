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
    init() {
        
    }
    static let shared = GlobalStruct()
    
//    static var client = Client(baseURL: "", accessToken: "")
    static var client = Client(baseURL: GlobalStruct.currentInstance.returnedText, accessToken: GlobalStruct.currentInstance.accessToken)
    static var clientID = ""
    static var clientSecret = ""
    static var returnedText = ""
    static var accessToken = ""
    static var authCode = ""
    static var redirect = ""
    
    static var currentInstance: InstanceData = InstanceData.getCurrentInstance() ?? InstanceData()
    static var allInstances: [InstanceData] = InstanceData.getAllInstances()
    static var newClient = Client(baseURL: "")
    static var newInstance: InstanceData?
    static var currentInstanceDetails: [Instance] = []
    static var maxChars: Int = 500
    
    static var baseDarkTint = (UserDefaults.standard.value(forKey: "sync-startDarkTint") == nil || UserDefaults.standard.value(forKey: "sync-startDarkTint") as? Int == 0) ? UIColor(named: "baseWhite")! : UIColor(named: "baseWhite2")!
    static var baseTint = UIColor(red: 156/255, green: 143/255, blue: 247/255, alpha: 1)
    static var arrayCols: [UIColor] = [UIColor(red: 156/255, green: 143/255, blue: 247/255, alpha: 1), UIColor.systemPurple, UIColor.systemBlue, UIColor(red: 84/255, green: 162/255, blue: 245/255, alpha: 1), UIColor(red: 34/255, green: 139/255, blue: 34/255, alpha: 1), UIColor.systemGreen, UIColor.systemYellow, UIColor.systemOrange, UIColor.systemRed, UIColor.systemPink, UIColor(red: 237/255, green: 121/255, blue: 195/255, alpha: 1), UIColor.brown, UIColor.systemGray]
    static var colNames: [String] = ["Mast Indigo", "Electric Purple", "Calm Blue", "Sky Blue", "Forest Green", "Lush Green", "Banana Yellow", "Sunset Orange", "Berry Red", "Bubblegum Pink", "Hot Pink", "Island Brown", "Ash Gray"]
    
    static var allEmoticons: [Emoji] = []
    static var emoticonToAdd: String = ""
    static var allDrafts: [String] = []
    static var currentDraft: String = ""
    static var curIDNoti = ""
    
    static var newPollPost: [Any]? = []
    static var isFollowing: Bool = false
    
    static var macWindow: Int = 0
    static var macReply: [Status] = []
    
    static var allowsMultiple = false
    static var totalsHidden = false
    
    static var siriPhrases: [String] = []
    static var iapPurchased: Bool = false
    
    static var gifVidDataToAttachArray: [Data] = []
    static var photoToAttachArray: [Data] = []
    static var gifVidDataToAttachArrayImage: [UIImage] = []
    static var photoToAttachArrayImage: [UIImage] = []
    static var mediaIDs: [String] = []
    
    static var notTypes: [NotificationType] = [.direct, .favourite, .follow, .mention, .poll, .reblog]
    static var notifications: [Notificationt] = []
    static var notificationsMentions: [Notificationt] = []
    static var notificationsDirect: [Conversation] = []
    
    static var statusSearch: [Status] = []
    static var statusSearch2: [Account] = []
    static var statusSearched: [Status] = []
    static var statusSearched2: [Account] = []
    
    static var currentUser: Account!
    
    static var allLists: [List] = []
    static var allCustomInstances: [String] = []
    static var markedReadIDs: [String] = []
    
    static var allPinned: [Status] = []
    static var allLikedStatuses: [String] = []
    static var allDislikedStatuses: [String] = []
    static var allBoostedStatuses: [String] = []
    static var allUnboostedStatuses: [String] = []
    
    static var currentTab = 1
    static var medType = 0
    static var avaFile = "avatar"
    static var heaFile = "header"
    
    static var tappedURL = URL(string: "www.google.com")
    static var tappedImageText = ""
    static var thePassedID = ""
    
    static var imagePercentage: Float = 0
    static var isImageUploading: Bool = false
    
    static var tempListIndex = 0
    static var postOnce: Bool = true
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

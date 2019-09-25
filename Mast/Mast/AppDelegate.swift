//
//  AppDelegate.swift
//  Mast
//
//  Created by Shihab Mehboob on 11/09/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UINavigationBar.appearance().backgroundColor = UIColor(named: "baseWhite")
        UINavigationBar.appearance().barTintColor = UIColor(named: "baseBlack")
        UINavigationBar.appearance().tintColor = UIColor(named: "baseBlack")
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(named: "baseBlack")!]
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if url.host == "success" {
            print("Response ==> \(url.absoluteString)")
            let x = url.absoluteString
            let y = x.split(separator: "=")
            GlobalStruct.authCode = y.last?.description ?? ""
            NotificationCenter.default.post(name: Notification.Name(rawValue: "logged"), object: nil)
            return true
        } else {
            return true
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        
        var state: PushNotificationState!
        let receiver = try! PushNotificationReceiver()
        let subscription = PushNotificationSubscription(endpoint: URL(string:"https://pushrelay1.your.org/relay-to/production/\(token)")!, alerts: PushNotificationAlerts.init(favourite: UserDefaults.standard.object(forKey: "pnlikes") as? Bool ?? true, follow: UserDefaults.standard.object(forKey: "pnfollows") as? Bool ?? true, mention: UserDefaults.standard.object(forKey: "pnmentions") as? Bool ?? true, reblog: UserDefaults.standard.object(forKey: "pnboosts") as? Bool ?? true))
        let deviceToken = PushNotificationDeviceToken(deviceToken: deviceToken)
        state = PushNotificationState(receiver: receiver, subscription: subscription, deviceToken: deviceToken)
        PushNotificationReceiver.setState(state: state)
        
        #if DEBUG
        let requestParams = PushNotificationSubscriptionRequest(endpoint: "https://pushrelay-mast1-dev.your.org/relay-to/development/\(token)", receiver: receiver, alerts: PushNotificationAlerts.init(favourite: UserDefaults.standard.object(forKey: "pnlikes") as? Bool ?? true, follow: UserDefaults.standard.object(forKey: "pnfollows") as? Bool ?? true, mention: UserDefaults.standard.object(forKey: "pnmentions") as? Bool ?? true, reblog: UserDefaults.standard.object(forKey: "pnboosts") as? Bool ?? true))
        #else
        let requestParams = PushNotificationSubscriptionRequest(endpoint: "https://pushrelay-mast1.your.org/relay-to/production/\(token)", receiver: receiver, alerts: PushNotificationAlerts.init(favourite: UserDefaults.standard.object(forKey: "pnlikes") as? Bool ?? true, follow: UserDefaults.standard.object(forKey: "pnfollows") as? Bool ?? true, mention: UserDefaults.standard.object(forKey: "pnmentions") as? Bool ?? true, reblog: UserDefaults.standard.object(forKey: "pnboosts") as? Bool ?? true))
        #endif
        
        //create the url with URL
        let url = URL(string: "https://\(GlobalStruct.returnedText)/api/v1/push/subscription")! //change the url
        
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST"// "POST" //set http method as POST
        
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(requestParams)
            request.httpBody = jsonData
        }
        catch {
            print(error.localizedDescription)
        }
        request.setValue("Bearer \(GlobalStruct.accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    print(json)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}


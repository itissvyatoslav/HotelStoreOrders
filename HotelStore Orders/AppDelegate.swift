//
//  AppDelegate.swift
//  HotelStore Orders
//
//  Created by Svyatoslav Vladimirovich on 18.08.2020.
//  Copyright © 2020 Svyatoslav Vladimirovich. All rights reserved.
//

import UIKit
import UserNotifications

@available(iOS 13.0, *)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let model = DataModel.sharedData

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        var modelNumber = 0
        UIApplication.shared.applicationIconBadgeNumber = 0
        // Override point for customization after application launch.
        registerForPushNotifications()
        UNUserNotificationCenter.current().delegate = self
        
        let notificationOption = launchOptions?[.remoteNotification]
        
        
        guard let notification = notificationOption as? [String: AnyObject], let aps = notification["aps"] as? [String: AnyObject], let orderStruct = aps["custom"] as? [String: AnyObject] else {
            return false
        }
        guard let orderNumber = orderStruct["OrderNumber"] as? Int else {
            return false
        }
        for number in 0..<self.model.orders.count {
            if orderNumber == self.model.orders[number].number {
                modelNumber = number
                break
            }
        }
        
        guard let rootViewController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController else {
            return false
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let vc = storyboard.instantiateViewController(withIdentifier: "OrderPageViewController") as? OrderPageViewController, let navController = rootViewController as? UINavigationController {
            vc.orderNumber = modelNumber
            navController.pushViewController(vc, animated: true)
        }
        
        return true
    }
    
    func registerForPushNotifications() {
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
        (granted, error) in
        print("Permission granted: \(granted)")
        
        guard granted else { return }
        self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        DataModel.sharedData.device_token = token
        print("Device Token: \(token)")
        NetworkService().regPushes(device_token: DataModel.sharedData.device_token)
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
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

@available(iOS 13.0, *)
extension AppDelegate: UNUserNotificationCenterDelegate{
    
    // This function will be called right after user tap on the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard let rootViewController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController else {
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if NetworkService().getOrders() {
            if  let vc = storyboard.instantiateViewController(withIdentifier: "OrderPageViewController") as? OrderPageViewController, let navController = rootViewController as? UINavigationController {
                navController.pushViewController(vc, animated: true)
            }
        } else {
            if  let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController, let navController = rootViewController as? UINavigationController {
                navController.pushViewController(vc, animated: true)
            }
            completionHandler()
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any]) {
        // Print notification payload data
        var modelNumber = 0
        guard let aps = data["aps"] as? [String: AnyObject], let orderStruct = aps["custom"] as? [String: AnyObject] else {
            return
        }
        guard let orderNumber = orderStruct["OrderNumber"] as? Int else {
            return
        }
        for number in 0..<self.model.orders.count {
            if orderNumber == self.model.orders[number].number {
                modelNumber = number
                break
            }
        }
        
        guard let rootViewController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController else {
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let vc = storyboard.instantiateViewController(withIdentifier: "OrderPageViewController") as? OrderPageViewController, let navController = rootViewController as? UINavigationController {
            vc.orderNumber = modelNumber
            navController.pushViewController(vc, animated: true)
        }
    }
}


//
//  AppDelegate.swift
//  ScreenOn
//
//  Created by Chin Wee Kerk on 30/06/2018.
//  Copyright © 2018 Chin Wee Kerk. All rights reserved.
//

import UIKit
import CoreData
import GoogleSignIn
import GoogleMobileAds
import FBSDKLoginKit
import PinterestSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        GIDSignIn.sharedInstance().clientID = "997117142453-g07648sd279ntfnbm03vbddnkj46dsoq.apps.googleusercontent.com"
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        PDKClient.configureSharedInstance(withAppId: "4972534596330596383")
        GADMobileAds.configure(withApplicationID: "ca-app-pub-1749500499268006~6194951492")
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        NetworkMonitor.shared.reachability?.stopNotifier()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        do {
            try NetworkMonitor.shared.reachability?.startNotifier()
        } catch let error {
            fatalError("Network monitor failed to start due to \(error.localizedDescription)")
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataManager.shared.saveContext()
    }
    
    // This method serves purpose of URL resource handling for iOS 9.0+
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let google = GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: [UIApplicationOpenURLOptionsKey.annotation])
        let facebook = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: [UIApplicationOpenURLOptionsKey.annotation])
        let pinterest = PDKClient.sharedInstance().handleCallbackURL(url)
        return google || facebook || pinterest
    }

}

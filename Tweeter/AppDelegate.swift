//
//  AppDelegate.swift
//  Tweeter
//
//  Created by Dylan Miller on 10/26/16.
//  Copyright © 2016 Dylan Miller. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    let storyboard = UIStoryboard(name: Constants.StoryboardName.main, bundle: nil)

    deinit
    {
        // Remove all of this object's observer entries.
        NotificationCenter.default.removeObserver(self)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        // Override point for customization after application launch.
        
        // If the current user is saved in UserDefaults, skip the login screen.
        if (CurrentUser.shared.isLoggedIn())
        {
            // Set up the hamburger view controller.
            let hamburgerViewController =
                storyboard.instantiateViewController(withIdentifier: "HamburgerViewController") as! HamburgerViewController
            let menuViewController =
                storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
            menuViewController.hamburgerViewController = hamburgerViewController
            hamburgerViewController.menuViewController = menuViewController
            window?.rootViewController = hamburgerViewController
        }
        
        // When the user logs out, return to the LoginViewController.
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(Constants.Notification.userDidLogout),
            object: nil,
            queue: OperationQueue.main)
            { (Notification) in
                
                UIView.animate(
                    withDuration: 1.0,
                    animations:
                    { () -> Void in
                        
                        let loginViewController = self.storyboard.instantiateInitialViewController()
                        self.window?.rootViewController = loginViewController
                    }
                )
            }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool
    {
        if let twitterClient = TwitterClient.shared
        {
            // Handle the open URL from the Twitter authorization page.
            twitterClient.handleOpenUrl(url)
        }
        
        return true
    }
}


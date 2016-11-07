//
//  CurrentUser.swift
//  Tweeter
//
//  Created by Dylan Miller on 10/29/16.
//  Copyright © 2016 Dylan Miller. All rights reserved.
//

import Foundation

// Represents the currently logged in user.
class CurrentUser
{
    static let shared = CurrentUser()

    // Log into Twitter.
    func login(success: @escaping () -> Void, failure: @escaping (Error?) -> Void)
    {
        if let twitterClient = TwitterClient.shared
        {
            twitterClient.login(
                success:
                { (user: User) in
                    
                    // Save the current User.
                    self.user = user
                    
                    success()
                },
                failure:
                { (error: Error?) in
                    
                    failure(error)
                }
            )
        }
        else
        {
            failure(nil)
        }
    }
    
    // Logout of Twitter, and post notification that user did log out.
    func logout()
    {
        if let twitterClient = TwitterClient.shared
        {
            twitterClient.logout()
            
            // Reset the current user.
            user = nil

            NotificationCenter.default.post(
                name: NSNotification.Name(Constants.Notification.userDidLogout),
                object: nil)
        }
    }
    
    // Returns true if a current user is logged in, false otherwise.
    func isLoggedIn() -> Bool
    {
        return user != nil
    }
    
    // The current user is saved in a member as well as in UserDefaults.
    private var _user: User?
    var user: User?
    {
        get
        {
            if _user == nil
            {
                // Load the current user from UserDefaults.
                let userDefaults = UserDefaults.standard
                if let data = userDefaults.object(forKey: Constants.UserDefaults.currentUserKey) as? Data
                {
                    _user = NSKeyedUnarchiver.unarchiveObject(with: data) as? User
                }
            }
            return _user
        }
        set
        {
            _user = newValue
            
            // Save the current user in UserDefaults.
            let userDefaults = UserDefaults.standard
            if newValue != nil
            {
                let data = NSKeyedArchiver.archivedData(withRootObject: newValue!)
                userDefaults.set(data, forKey: Constants.UserDefaults.currentUserKey)
            }
            else
            {
                userDefaults.removeObject(forKey: Constants.UserDefaults.currentUserKey)
            }
            userDefaults.synchronize()
        }
    }
}

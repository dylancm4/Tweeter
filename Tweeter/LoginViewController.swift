//
//  LoginViewController.swift
//  Twitter
//
//  Created by Dylan Miller on 10/26/16.
//  Copyright © 2016 Dylan Miller. All rights reserved.
//

import UIKit
import MBProgressHUD

class LoginViewController: UIViewController
{
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorBannerView: UIView!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Hide the error banner.
        errorBannerView.isHidden = true

        // Rounded login button.
        loginButton.layer.cornerRadius = 10.0
    }
    
    // Hide the status bar on the log in screen.
    override var prefersStatusBarHidden: Bool
    {
        return true
    }
    
    @IBAction func onLoginButton(_ sender: UIButton)
    {
        // Display progress HUD before the request is made.
        MBProgressHUD.showAdded(to: view, animated: true)
        
        // Log into Twitter.
        CurrentUser.shared.login(
            success:
            {
                self.requestDidSucceed(true)

                // Segue to the TweetsViewController.
                self.performSegue(withIdentifier: Constants.SegueName.login, sender: self)
            },
            failure:
            { (error: Error?) in
                
                self.requestDidSucceed(false)
            }
        )
    }
    
    // Show or hide the error banner based on success or failure. Hide the
    // progress HUD.
    func requestDidSucceed(_ success: Bool)
    {
        DispatchQueue.main.async
        {
            self.errorBannerView.isHidden = success
            
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
}


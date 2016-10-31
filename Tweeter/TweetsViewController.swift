//
//  TweetsViewController.swift
//  Tweeter
//
//  Created by Dylan Miller on 10/27/16.
//  Copyright © 2016 Dylan Miller. All rights reserved.
//

import UIKit
import MBProgressHUD

class TweetsViewController: UIViewController
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorBannerView: UIView!
    
    var tweets = [Tweet]()

    deinit
    {
        // Remove all of this object's observer entries.
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Set the navigationBar color to white.
        if let navigationController = navigationController
        {
            navigationController.navigationBar.barTintColor = UIColor.white
        }
        
        // Set the Tweeter logo as the navigation bar title.
        setNavigationBarTitleImage()
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.UIDeviceOrientationDidChange,
            object: nil,
            queue: OperationQueue.main)
        { (Notification) in
            
            self.setNavigationBarTitleImage()
        }
        
        // Set the left and right bar button images.
        navigationItem.leftBarButtonItem?.image = UIImage(named: Constants.ImageName.tweeterNavBarLogout)?.withRenderingMode(.alwaysOriginal)
        navigationItem.rightBarButtonItem?.image = UIImage(named: Constants.ImageName.tweeterNavBarCompose)?.withRenderingMode(.alwaysOriginal)
        
        // Hide the error banner.
        errorBannerView.isHidden = true

        // Set up the tableView.
        tableView.estimatedRowHeight = 90
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Create a UIRefreshControl and add it to the tableView.
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(
            self, action: #selector(refreshControlAction(_:)),
            for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        // Get tweets when the view controller loads.
        getHomeTimeLineTweets()
    }
    
    @IBAction func onSignOutButton(_ sender: UIBarButtonItem)
    {
        // Log out of Twitter.
        CurrentUser.shared.logout()
        
        // Post notification that user did log out.
        NotificationCenter.default.post(
            name: NSNotification.Name(Constants.Notification.userDidLogout),
            object: nil)
    }
    
    // Set the Tweeter logo as the navigation bar title.
    func setNavigationBarTitleImage()
    {
        if let navigationController = self.navigationController
        {
            let tweeterImageSize = navigationController.navigationBar.bounds.height
            let tweeterImageName: String
            if UIDeviceOrientationIsPortrait(UIDevice.current.orientation)
            {
                tweeterImageName = Constants.ImageName.tweeterNavBarTitlePortrait
            }
            else
            {
                tweeterImageName = Constants.ImageName.tweeterNavBarTitleLandscape
            }
            let tweeterImageView = UIImageView(
                frame: CGRect(x: 0, y: 0, width: tweeterImageSize, height: tweeterImageSize))
            tweeterImageView.contentMode = .scaleAspectFit
            tweeterImageView.image = UIImage(named: tweeterImageName)
            self.navigationItem.titleView = tweeterImageView
        }
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl)
    {
        // Get tweets when the user pulls to refresh.
        getHomeTimeLineTweets(refreshControl: refreshControl)
    }
    
    // Get a collection of the most recent Tweets and retweets posted by the
    // authenticating user and the users they follow.
    func getHomeTimeLineTweets(refreshControl: UIRefreshControl? = nil)
    {
        if let twitterClient = TwitterClient.shared
        {
            // Display progress HUD before the request is made.
            MBProgressHUD.showAdded(to: view, animated: true)
            
            twitterClient.getHomeTimeLineTweets(
                success:
                { (tweets: [Tweet]) in
                    
                    self.tweets = tweets
                    
                    self.requestDidSucceed(true, refreshControl: refreshControl)

                    DispatchQueue.main.async
                    {
                        self.tableView.reloadData()
                    }
                },
                failure:
                { (error: Error?) in
                    
                    self.requestDidSucceed(false, refreshControl: refreshControl)
                }
            )
        }
    }
    
    // Show or hide the error banner based on success or failure. Hide the
    // progress HUD. If the optional refreshControl parameter is specified,
    // tell it to stop spinning.
    func requestDidSucceed(_ success: Bool, refreshControl: UIRefreshControl?)
    {
        DispatchQueue.main.async
        {
            self.errorBannerView.isHidden = success
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let refreshControl = refreshControl
            {
                refreshControl.endRefreshing()
            }
        }
    }
}

// UITableView methods
extension TweetsViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return tweets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell") as! TweetTableViewCell
        
        // Set the cell contents.
        cell.setData(tweet: tweets[indexPath.row])
        
        return cell
    }
}


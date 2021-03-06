//
//  TweetsViewController.swift
//  Tweeter
//
//  Created by Dylan Miller on 10/27/16.
//  Copyright © 2016 Dylan Miller. All rights reserved.
//

import UIKit

class TweetsViewController: TimelineViewControllerBase
{
    @IBOutlet weak var tweetsTableView: UITableView!
    @IBOutlet weak var tweetsErrorBannerView: UIView!
    
    override var tableView: UITableView!
    {
        return tweetsTableView
    }
    override var errorBannerView: UIView!
    {
        return tweetsErrorBannerView
    }
    override var composeDelegate: ComposeViewControllerDelegate!
    {
        return self
    }
    
    var maxId: Int64?

    deinit
    {
        // Remove all of this object's observer entries.
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Set the Tweeter logo as the navigation bar title.
        setNavigationBarTitleImage()
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.UIDeviceOrientationDidChange,
            object: nil,
            queue: OperationQueue.main)
        { (Notification) in
            
            self.setNavigationBarTitleImage()
        }
    }
    
    // When the menu button is pressed, post notification to open/close
    // the menu.
    @IBAction func onHamburgerMenuButton(_ sender: UIBarButtonItem)
    {
        NotificationCenter.default.post(
            name: NSNotification.Name(Constants.Notification.onMenuButton),
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
    
    // Get a collection of the most recent Tweets and retweets posted by the
    // authenticating user and the users they follow.
    override func getTimelineTweets(refreshControl: UIRefreshControl? = nil)
    {
        if let twitterClient = TwitterClient.shared
        {
            willRequest()
            
            twitterClient.getHomeTimelineTweets(
                maxId: scrollLoadingData ? maxId : nil,
                success:
                { (tweets: [Tweet], nextMaxId: Int64?) in
                    
                    let shouldReloadData: Bool
                    if self.scrollLoadingData
                    {
                        // Infinite scroll.
                        self.scrollLoadingData = false
                        self.tweets.append(contentsOf: tweets)
                        shouldReloadData = tweets.count > 0
                    }
                    else
                    {
                        self.tweets = tweets
                        shouldReloadData = true
                    }
                    self.maxId = nextMaxId
                    
                    self.requestDidSucceed(true, refreshControl: refreshControl)

                    if shouldReloadData
                    {
                        DispatchQueue.main.async
                        {
                            self.tweetsTableView.reloadData()
                        }
                    }
                },
                failure:
                { (error: Error?) in
                    
                    self.requestDidSucceed(false, refreshControl: refreshControl)
                }
            )
        }
    }
}

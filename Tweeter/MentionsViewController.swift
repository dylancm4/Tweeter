//
//  MentionsViewController.swift
//  Tweeter
//
//  Created by Dylan Miller on 11/4/16.
//  Copyright © 2016 Dylan Miller. All rights reserved.
//

import UIKit

class MentionsViewController: TimelineViewControllerBase
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
        return tweetsViewController
    }

    var tweetsViewController: TweetsViewController!
    var maxId: Int64?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    // When the menu button is pressed, post notification to open/close
    // the menu.
    @IBAction func onHamburgerMenuButton(_ sender: UIBarButtonItem)
    {
        NotificationCenter.default.post(
            name: NSNotification.Name(Constants.Notification.onMenuButton),
            object: nil)
    }
    
    // Get a collection of the most recent mentions (tweets containing a
    // user's @screen_name) for the authenticating user.
    override func getTimelineTweets(refreshControl: UIRefreshControl? = nil)
    {
        if let twitterClient = TwitterClient.shared
        {
            willRequest()
            
            twitterClient.getMentionsTimelineTweets(
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


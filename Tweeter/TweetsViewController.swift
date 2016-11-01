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
    var maxId: Int64 = 0
    var inReplyToId: Int64?
    var inReplyToScreenName: String?
    var scrollLoadingData = false

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
        navigationItem.leftBarButtonItem?.image = navigationItem.leftBarButtonItem?.image?.withRenderingMode(.alwaysOriginal)
        navigationItem.rightBarButtonItem?.image = navigationItem.rightBarButtonItem?.image?.withRenderingMode(.alwaysOriginal)
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == Constants.SegueName.compose
        {
            // Set self as the ComposeViewController delegate.
            if let navigationController = segue.destination as? UINavigationController
            {
                if let composeViewController = navigationController.topViewController as? ComposeViewController
                {
                    composeViewController.delegate = self
                }
            }
        }
        else if segue.identifier == Constants.SegueName.reply
        {
            // Set self as the ComposeViewController delegate.
            if let navigationController = segue.destination as? UINavigationController
            {
                if let composeViewController = navigationController.topViewController as? ComposeViewController
                {
                    composeViewController.delegate = self
                    composeViewController.inReplyToId = inReplyToId
                    composeViewController.inReplyToScreenName = inReplyToScreenName
                }
            }
        }
        else if segue.identifier == Constants.SegueName.view
        {
            // Set ViewTweetViewController tweet and delegate.
            if let navigationController = segue.destination as? UINavigationController
            {
                if let viewTweetViewController = navigationController.topViewController as? ViewTweetViewController,
                    let indexPath = tableView.indexPathForSelectedRow
                {
                    viewTweetViewController.tweet = tweets[indexPath.row]
                    viewTweetViewController.composeDelegate = self
                    viewTweetViewController.updateTweetDelegate = self
                }
            }
        }
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
            
            twitterClient.getHomeTimelineTweets(
                maxId: scrollLoadingData ? maxId : nil,
                success:
                { (tweets: [Tweet], nextMaxId: Int64) in
                    
                    if self.scrollLoadingData
                    {
                        // Infinite scroll.
                        self.scrollLoadingData = false
                        self.tweets.append(contentsOf: tweets)
                    }
                    else
                    {
                        self.tweets = tweets
                    }
                    self.maxId = nextMaxId
                    
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
extension TweetsViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return tweets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell") as! TweetTableViewCell
        
        // Set the cell contents.
        cell.setData(tweet: tweets[indexPath.row], replyDelegate: self)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // Do not leave rows selected.
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// UIScrollView methods
extension TweetsViewController: UIScrollViewDelegate
{
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if (!scrollLoadingData)
        {
            // Calculate the position of one screen length before the bottom
            // of the results.
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if (scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging)
            {
                scrollLoadingData = true
                
                // Get more tweets.
                getHomeTimeLineTweets()
            }
        }
    }
}

// ReplyToTweetDelegate methods
extension TweetsViewController: ReplyToTweetDelegate
{
    func replyToTweet(inReplyToId: Int64?, inReplyToScreenName: String?)
    {
        self.inReplyToId = inReplyToId
        self.inReplyToScreenName = inReplyToScreenName
        performSegue(withIdentifier: Constants.SegueName.reply, sender: self)
    }
}

// ComposeViewController methods
extension TweetsViewController: ComposeViewControllerDelegate
{
    // Add the specified tweet.
    func composeViewController(composeViewController: ComposeViewController, addTweetStatus status: String, inReplyToId: Int64?)
    {
        if let twitterClient = TwitterClient.shared
        {
            // Insert a dummy tweet at the front of the tweets array so that
            // the user will immediately see the tweet they composed. This
            // dummy tweet will receive special treatment (e.g., no favoriting,
            // no retweeting).
            let dummyId = Int64(arc4random())
            let tweet = Tweet(dummyId: dummyId, status: status)
            tweets.insert(tweet, at: 0)
            tableView.reloadData()
            
            twitterClient.tweet(
                status: status,
                inReplyToId: inReplyToId,
                success:
                { (tweet: Tweet) in
                    
                    // Remove the dummy tweet.
                    self.removeTweetWith(id: dummyId)
                    
                    // Insert the real tweet.
                    self.tweets.insert(tweet, at: 0)
                   
                    DispatchQueue.main.async
                    {
                        self.tableView.reloadData()
                    }
                },
                failure:
                { (error: Error?) in
                    
                    // An error occurred, remove the dummy tweet.
                    self.removeTweetWith(id: dummyId)

                    DispatchQueue.main.async
                    {
                        self.tableView.reloadData()
                    }
                }
            )
        }
    }
    
    // Remove the tweet with the specified ID from the tweets array.
    func removeTweetWith(id: Int64)
    {
        var index = 0
        for tweet in tweets
        {
            if tweet.id == id
            {
                tweets.remove(at: index)
                return
            }
            index = index + 1
        }
    }
}


// ReplyToTweetDelegate methods
extension TweetsViewController: UpdateTweetDelegate
{
    // Update the specified tweet.
    func updateTweet(id: Int64?, isRetweeted: Bool, retweetsCount: Int, isFavorited: Bool, favoritesCount: Int)
    {
        for tweet in tweets
        {
            if tweet.id == id
            {
                tweet.isRetweeted = true
                tweet.retweetsCount = retweetsCount
                tweet.isFavorited = isFavorited
                tweet.favoritesCount = favoritesCount
                tableView.reloadData()
                return
            }
        }
    }
}



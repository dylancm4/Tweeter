//
//  TimelineViewControllerBase.swift
//  Tweeter
//
//  Created by Dylan Miller on 11/6/16.
//  Copyright © 2016 Dylan Miller. All rights reserved.
//

import UIKit
import MBProgressHUD

// Base class for view controllers which display a timeline of tweets.
class TimelineViewControllerBase: UIViewController
{
    // Derived classes must override these computed properties.
    var tableView: UITableView!
    {
        fatalError("tableView not implemented.")
    }
    var errorBannerView: UIView!
    {
        fatalError("errorBannerView not implemented.")
    }
    var composeDelegate: ComposeViewControllerDelegate!
    {
        fatalError("composeDelegate not implemented.")
    }
    
    var tweets = [Tweet]()
    var inReplyToId: Int64?
    var inReplyToScreenName: String?
    var profileSegueUser: User?
    var scrollLoadingData = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Set the navigationBar color to white.
        if let navigationController = navigationController
        {
            navigationController.navigationBar.barTintColor = UIColor.white
        }
        
        // Render the bar button images using the correct color.
        navigationItem.leftBarButtonItem?.image = navigationItem.leftBarButtonItem?.image?.withRenderingMode(.alwaysOriginal)
        navigationItem.rightBarButtonItem?.image = navigationItem.rightBarButtonItem?.image?.withRenderingMode(.alwaysOriginal)
        
        // Hide the error banner.
        errorBannerView.isHidden = true
        
        // Set up the tableView.
        tableView.estimatedRowHeight = 330
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(
            UINib(nibName: Constants.ClassName.tweetTableViewCellXib, bundle: nil),
            forCellReuseIdentifier: Constants.CellReuseIdentifier.tweetCell)
        
        // Create a UIRefreshControl and add it to the tableView.
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(
            self, action: #selector(refreshControlAction(_:)),
            for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        // Get tweets when the view controller loads.
        getTimelineTweets()
    }
    
    // Derived classes must override this method.
    func getTimelineTweets(refreshControl: UIRefreshControl? = nil)
    {
        fatalError("getTimelineTweets not implemented.")
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
                    composeViewController.delegate = composeDelegate
                }
            }
        }
        else if segue.identifier == Constants.SegueName.reply
        {
            // Set composeDelegate as the ComposeViewController delegate.
            if let navigationController = segue.destination as? UINavigationController
            {
                if let composeViewController = navigationController.topViewController as? ComposeViewController
                {
                    composeViewController.delegate = composeDelegate
                    composeViewController.inReplyToId = inReplyToId
                    composeViewController.inReplyToScreenName = inReplyToScreenName
                }
            }
        }
        else if segue.identifier == Constants.SegueName.viewTweetSegue
        {
            // Set ViewTweetViewController tweet and delegate.
            if let navigationController = segue.destination as? UINavigationController
            {
                if let viewTweetViewController = navigationController.topViewController as? ViewTweetViewController,
                    let indexPath = tableView.indexPathForSelectedRow
                {
                    viewTweetViewController.tweet = tweets[indexPath.row]
                    viewTweetViewController.composeDelegate = composeDelegate
                    
                    // Because we set tweetDelegate to self, updateTweet()
                    // will get called on this object, but not on other
                    // view controllers, which could also contain this
                    // tweet. To update the tweet there as well, a good
                    // implementation would be to use the observer model
                    // for updating a tweet rather than the delegate model.
                    viewTweetViewController.tweetDelegate = self
                }
            }
        }
        else if segue.identifier == Constants.SegueName.profile
        {
            // Set ProfileViewController user.
            if let navigationController = segue.destination as? UINavigationController
            {
                if let profileViewController = navigationController.topViewController as? ProfileViewController
                {
                    profileViewController.user = profileSegueUser
                }
            }
        }
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl)
    {
        // Get tweets when the user pulls to refresh.
        getTimelineTweets(refreshControl: refreshControl)
    }
    
    // Display progress HUD before the request is made.
    func willRequest()
    {
        MBProgressHUD.showAdded(to: view, animated: true)
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
extension TimelineViewControllerBase: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIdentifier.tweetCell) as! TweetTableViewCell
        
        // Set the cell contents.
        cell.setData(tweet: tweets[indexPath.row], tweetDelegate: self)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // Perform a segue to the ViewTweetViewController.
        performSegue(withIdentifier: Constants.SegueName.viewTweetSegue, sender: self)
        
        // Do not leave rows selected.
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// UIScrollView methods
extension TimelineViewControllerBase: UIScrollViewDelegate
{
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if (scrollView == tableView && !scrollLoadingData)
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
                getTimelineTweets()
            }
        }
    }
}

// ComposeViewController methods
extension TimelineViewControllerBase: ComposeViewControllerDelegate
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

// TweetDelegate methods
extension TimelineViewControllerBase: TweetDelegate
{
    // Perform a segue to the ComposeViewController to reply to the
    // specified tweet.
    func replyToTweet(inReplyToId: Int64?, inReplyToScreenName: String?)
    {
        self.inReplyToId = inReplyToId
        self.inReplyToScreenName = inReplyToScreenName
        performSegue(withIdentifier: Constants.SegueName.reply, sender: self)
    }
    
    // Update our copy of the specified tweet.
    func updateTweet(id: Int64?, isRetweeted: Bool, retweetsCount: Int, isFavorited: Bool, favoritesCount: Int)
    {
        for tweet in tweets
        {
            if tweet.id == id
            {
                tweet.isRetweeted = isRetweeted
                tweet.retweetsCount = retweetsCount
                tweet.isFavorited = isFavorited
                tweet.favoritesCount = favoritesCount
                DispatchQueue.main.async
                {
                    self.tableView.reloadData()
                }
                return
            }
        }
    }
    
    // Perform a segue to the ProfileViewController to view the specified
    // user profile.
    func viewProfile(user: User)
    {
        profileSegueUser = user
        performSegue(withIdentifier: Constants.SegueName.profile, sender: self)
    }
}

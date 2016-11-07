//
//  ViewTweetViewController.swift
//  Tweeter
//
//  Created by Dylan Miller on 10/30/16.
//  Copyright © 2016 Dylan Miller. All rights reserved.
//

import UIKit

class ViewTweetViewController: UIViewController
{
    @IBOutlet weak var tableView: UITableView!
    
    var tweet: Tweet?

    weak var composeDelegate: ComposeViewControllerDelegate!
    weak var tweetDelegate: TweetDelegate!
    var inReplyToId: Int64?
    var inReplyToScreenName: String?
    var profileSegueUser: User?

    enum Row: Int
    {
        case ViewTweetDetail = 0, ViewTweetButtons
        
        static let allValues = [ViewTweetDetail, ViewTweetButtons]
        static var count: Int
        {
            return allValues.count
        }
    }

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

        // Set up the tableView.
        tableView.estimatedRowHeight = 143
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    @IBAction func onBackButton(_ sender: AnyObject)
    {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onProfileImageViewTap(_ sender: UITapGestureRecognizer)
    {
        if sender.state == .ended
        {
            if let user = tweet?.user
            {
                // Since the gesture recogizer code is here rather than in
                // the cell class, we call viewProfile() on this calss. In the
                // cell code, the call would be made on its tweetDelegate,
                // which is this class.
                viewProfile(user: user)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == Constants.SegueName.reply
        {
            // Set self as the ComposeViewController delegate.
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
}

// UITableView methods
extension ViewTweetViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return tweet != nil ? Row.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let _tweet = tweet!
        let row = Row(rawValue: indexPath.row)!
        if row == Row.ViewTweetDetail
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ViewTweetDetailCell") as! ViewTweetDetailTableViewCell
            
            // Set the cell contents.
            cell.setData(tweet: _tweet)
            
            return cell
        }
        else // Row.ViewTweetButtonsTableViewCell
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ViewTweetButtonsCell") as! ViewTweetButtonsTableViewCell
            
            // Set the cell contents.
            cell.setData(tweet: _tweet, tweetDelegate: self)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // Do not leave rows selected.
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// TweetDelegate methods
extension ViewTweetViewController: TweetDelegate
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
        tweetDelegate.updateTweet(id: id, isRetweeted: isRetweeted, retweetsCount: retweetsCount, isFavorited: isFavorited, favoritesCount: favoritesCount)
    }
    
    // Perform a segue to the ProfileViewController to view the specified
    // user profile.
    func viewProfile(user: User)
    {
        profileSegueUser = user
        performSegue(withIdentifier: Constants.SegueName.profile, sender: self)
    }
}


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
    weak var updateTweetDelegate: UpdateTweetDelegate!
    var inReplyToId: Int64?
    var inReplyToScreenName: String?

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
        
        // Set the left and right bar button images.
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == Constants.SegueName.viewTweetReply
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
            cell.setData(tweet: _tweet, replyDelegate: self, updateTweetDelegate: updateTweetDelegate)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // Do not leave rows selected.
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// ReplyToTweetDelegate methods
extension ViewTweetViewController: ReplyToTweetDelegate
{
    func replyToTweet(inReplyToId: Int64?, inReplyToScreenName: String?)
    {
        self.inReplyToId = inReplyToId
        self.inReplyToScreenName = inReplyToScreenName
        performSegue(withIdentifier: Constants.SegueName.viewTweetReply, sender: self)
    }
}


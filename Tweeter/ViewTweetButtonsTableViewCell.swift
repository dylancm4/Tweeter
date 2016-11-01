//
//  ViewTweetButtonsTableViewCell.swift
//  Tweeter
//
//  Created by Dylan Miller on 10/30/16.
//  Copyright © 2016 Dylan Miller. All rights reserved.
//

import UIKit

protocol UpdateTweetDelegate: class
{
    func updateTweet(id: Int64?, isRetweeted: Bool, retweetsCount: Int, isFavorited: Bool, favoritesCount: Int)
}

class ViewTweetButtonsTableViewCell: UITableViewCell
{
    @IBOutlet weak var retweetButton: RetweetButtonDarkGray!
    @IBOutlet weak var favoriteButton: HeartButtonDarkGray!
    @IBOutlet weak var retweetsCountLabel: UILabel!
    @IBOutlet weak var favoritesCountLabel: UILabel!
    
    weak var replyDelegate: ReplyToTweetDelegate?
    weak var updateTweetDelegate: UpdateTweetDelegate?
    var id: Int64?
    var screenName: String?
    var isDummy = false

    // The integer count represented by retweetsCountLabel.
    var retweetsCount: Int
    {
        get
        {
            let count: Int
            if let retweetsCountLabelText = retweetsCountLabel.text
            {
                count = Int(retweetsCountLabelText) ?? 0
            }
            else
            {
                count = 0
            }
            return count
        }
        set
        {
            retweetsCountLabel.text = "\(newValue)"
        }
    }
    
    // The integer count represented by favoritesCountLabel.
    var favoritesCount: Int
    {
        get
        {
            let count: Int
            if let favoritesCountLabelText = favoritesCountLabel.text
            {
                count = Int(favoritesCountLabelText) ?? 0
            }
            else
            {
                count = 0
            }
            return count
        }
        set
        {
            favoritesCountLabel.text = "\(newValue)"
        }
    }
    
    // Set the cell contents based on the specified parameters.
    func setData(tweet: Tweet, replyDelegate: ReplyToTweetDelegate, updateTweetDelegate: UpdateTweetDelegate)
    {
        self.replyDelegate = replyDelegate
        self.updateTweetDelegate = updateTweetDelegate
        id = tweet.id
        screenName = tweet.user?.screenName
        retweetButton.isOn = tweet.isRetweeted ?? false
        if let tweetRetweetsCount = tweet.retweetsCount, tweetRetweetsCount > 0
        {
            retweetsCount = tweetRetweetsCount
        }
        else
        {
            retweetsCountLabel.text = nil
        }
        favoriteButton.isOn = tweet.isFavorited ?? false
        if let tweetFavoritesCount = tweet.favoritesCount, tweetFavoritesCount > 0
        {
            favoritesCount = tweetFavoritesCount
        }
        else
        {
            favoritesCountLabel.text = nil
        }
        isDummy = tweet.isDummy
    }
    
    @IBAction func onReplyButtonValueChanged(_ sender: OnOffButton)
    {
        // Let the replyDelegate handle the reply.
        if let replyDelegate = replyDelegate
        {
            replyDelegate.replyToTweet(inReplyToId: id, inReplyToScreenName: screenName)
        }
    }
    
    @IBAction func onRetweetButtonValueChanged(_ sender: OnOffButton)
    {
        if !retweetButton.isOn, let twitterClient = TwitterClient.shared, let id = id, !isDummy
        {
            // Increment retweetsCountLabel.
            retweetsCount = retweetsCount + 1
            
            twitterClient.retweet(
                id: id,
                success:
                {
                    // Update the tweet in the tweets view.
                    if let updateTweetDelegate = self.updateTweetDelegate
                    {
                        DispatchQueue.main.async
                        {
                            updateTweetDelegate.updateTweet(
                                id: self.id,
                                isRetweeted: self.retweetButton.isOn,
                                retweetsCount: self.retweetsCount,
                                isFavorited: self.favoriteButton.isOn,
                                favoritesCount: self.favoritesCount)
                        }
                    }
                },
                failure:
                { (error: Error?) in
                    
                    // If an error occurred, set retweetsButton and
                    // retweetsCountLabel back to old values.
                    DispatchQueue.main.async
                    {
                        self.retweetButton.isOn = !self.retweetButton.isOn
                        self.retweetsCount = self.retweetsCount - 1
                    }
                }
            )
        }
    }
    
    @IBAction func onFavoritesButtonValueChanged(_ sender: OnOffButton)
    {
        if let twitterClient = TwitterClient.shared, let id = id, !isDummy
        {
            // Increment favoritesCountLabel.
            favoritesCount = favoritesCount + 1
            
            twitterClient.setTweetFavorite(
                favoriteButton.isOn,
                id: id,
                success:
                {
                    // Update the tweet in the tweets view.
                    if let updateTweetDelegate = self.updateTweetDelegate
                    {
                        DispatchQueue.main.async
                            {
                                updateTweetDelegate.updateTweet(
                                    id: self.id,
                                    isRetweeted: self.retweetButton.isOn,
                                    retweetsCount: self.retweetsCount,
                                    isFavorited: self.favoriteButton.isOn,
                                    favoritesCount: self.favoritesCount)
                        }
                    }
                },
                failure:
                { (error: Error?) in
                    
                    // If an error occurred, set favoriteButton and
                    // favoritesCountLabel back to old values.
                    DispatchQueue.main.async
                    {
                        self.favoriteButton.isOn = !self.favoriteButton.isOn
                        self.favoritesCount = self.favoritesCount - 1
                    }
                }
            )
        }
    }
}

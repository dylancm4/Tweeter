//
//  ViewTweetButtonsTableViewCell.swift
//  Tweeter
//
//  Created by Dylan Miller on 10/30/16.
//  Copyright © 2016 Dylan Miller. All rights reserved.
//

import UIKit

class ViewTweetButtonsTableViewCell: UITableViewCell
{
    @IBOutlet weak var retweetButton: RetweetButtonDarkGray!
    @IBOutlet weak var favoriteButton: HeartButtonDarkGray!
    @IBOutlet weak var retweetsCountLabel: UILabel!
    @IBOutlet weak var favoritesCountLabel: UILabel!
    
    weak var tweetDelegate: TweetDelegate!
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
    func setData(tweet: Tweet, tweetDelegate: TweetDelegate)
    {
        self.tweetDelegate = tweetDelegate
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
        // Let the tweetDelegate handle the reply.
        tweetDelegate.replyToTweet(inReplyToId: id, inReplyToScreenName: screenName)
    }
    
    @IBAction func onRetweetButtonValueChanged(_ sender: OnOffButton)
    {
        if let twitterClient = TwitterClient.shared, let id = id, !isDummy
        {
            // Increment or decrement retweetsCountLabel.
            let incrementDecrement = retweetButton.isOn ? 1 : -1
            retweetsCount = retweetsCount + incrementDecrement
            
            twitterClient.setRetweet(
                retweetButton.isOn,
                id: id,
                success:
                {
                    // Update our copy of the tweet.
                    self.tweetDelegate.updateTweet(
                        id: self.id,
                        isRetweeted: self.retweetButton.isOn,
                        retweetsCount: self.retweetsCount,
                        isFavorited: self.favoriteButton.isOn,
                        favoritesCount: self.favoritesCount)
                },
                failure:
                { (error: Error?) in
                    
                    // If an error occurred, set retweetsButton and
                    // retweetsCountLabel back to old values.
                    DispatchQueue.main.async
                    {
                        self.retweetButton.isOn = !self.retweetButton.isOn
                        self.retweetsCount = self.retweetsCount - incrementDecrement
                    }
                }
            )
        }
    }
    
    @IBAction func onFavoritesButtonValueChanged(_ sender: OnOffButton)
    {
        if let twitterClient = TwitterClient.shared, let id = id, !isDummy
        {
            // Increment or decrement favoritesCountLabel.
            let incrementDecrement = favoriteButton.isOn ? 1 : -1
            favoritesCount = favoritesCount + incrementDecrement
            
            twitterClient.setTweetFavorite(
                favoriteButton.isOn,
                id: id,
                success:
                {
                    // Update our copy of the tweet.
                    self.tweetDelegate.updateTweet(
                        id: self.id,
                        isRetweeted: self.retweetButton.isOn,
                        retweetsCount: self.retweetsCount,
                        isFavorited: self.favoriteButton.isOn,
                        favoritesCount: self.favoritesCount)
                },
                failure:
                { (error: Error?) in
                    
                    // If an error occurred, set favoriteButton and
                    // favoritesCountLabel back to old values.
                    DispatchQueue.main.async
                    {
                        self.favoriteButton.isOn = !self.favoriteButton.isOn
                        self.favoritesCount = self.favoritesCount - incrementDecrement
                    }
                }
            )
        }
    }
}

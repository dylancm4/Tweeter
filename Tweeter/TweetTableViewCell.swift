//
//  TweetTableViewCell.swift
//  Tweeter
//
//  Created by Dylan Miller on 10/27/16.
//  Copyright © 2016 Dylan Miller. All rights reserved.
//

import UIKit

protocol TweetDelegate: class
{
    func replyToTweet(inReplyToId: Int64?, inReplyToScreenName: String?)
    func updateTweet(id: Int64?, isRetweeted: Bool, retweetsCount: Int, isFavorited: Bool, favoritesCount: Int)
}

class TweetTableViewCell: UITableViewCell
{
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameAndDateLabel: UILabel!
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var retweetButton: RetweetButtonLightGray!
    @IBOutlet weak var favoriteButton: HeartButtonLightGray!
    @IBOutlet weak var retweetsCountLabel: UILabel!
    @IBOutlet weak var favoritesCountLabel: UILabel!
    
    weak var tweetDelegate: TweetDelegate!
    var id: Int64?
    var screenName: String?
    var isDummy = false
    
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
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        // Initialization code
        profileImageView.layer.cornerRadius = 3
        profileImageView.clipsToBounds = true
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
    
    @IBAction func onFavoriteButtonValueChanged(_ sender: OnOffButton)
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
    
    // Set the cell contents based on the specified parameters.
    func setData(tweet: Tweet, tweetDelegate: TweetDelegate)
    {
        self.tweetDelegate = tweetDelegate
        id = tweet.id
        if let imageUrl = tweet.user?.profileImageUrl
        {
            setImage(imageView: profileImageView, imageUrl: imageUrl)
        }
        else
        {
            profileImageView.image = nil
        }
        nameLabel.text = tweet.user?.name
        screenNameAndDateLabel.text = nil
        if let screenName = tweet.user?.screenName
        {
            screenNameAndDateLabel.text = "@" + screenName + " · " + tweet.timeSinceCreatedAtText
            self.screenName = screenName
        }
        else
        {
            screenNameAndDateLabel.text = tweet.timeSinceCreatedAtText
            self.screenName = nil
        }
        tweetTextView.text = tweet.text
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

    // Fade in the specified image if it is not cached, or simply update
    // the image if it was cached.
    func setImage(imageView: UIImageView, imageUrl: URL)
    {
        imageView.image = nil
        let imageRequest = URLRequest(url: imageUrl)
        imageView.setImageWith(
            imageRequest,
            placeholderImage: nil,
            success:
            { (request: URLRequest, response: HTTPURLResponse?, image: UIImage) in
                
                DispatchQueue.main.async
                {
                    let imageIsCached = response == nil
                    if !imageIsCached
                    {
                        imageView.alpha = 0.0
                        imageView.image = image
                        UIView.animate(
                            withDuration: 0.3,
                            animations:
                            { () -> Void in
                                
                                imageView.alpha = 1.0
                            }
                        )
                    }
                    else
                    {
                        imageView.image = image
                    }
                }
            },
            failure:
            { (request: URLRequest, response: HTTPURLResponse?, error: Error) in
                
                DispatchQueue.main.async
                {
                    imageView.image = nil
                }
            }
        )
    }
}

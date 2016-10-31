//
//  TweetTableViewCell.swift
//  Tweeter
//
//  Created by Dylan Miller on 10/27/16.
//  Copyright © 2016 Dylan Miller. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell
{
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameAndDateLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var replyButton: ReplyButtonLightGray!
    @IBOutlet weak var retweetButton: RetweetButtonLightGray!
    @IBOutlet weak var favoriteButton: HeartButtonLightGray!
    @IBOutlet weak var retweetsCountLabel: UILabel!
    @IBOutlet weak var favoritesCountLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        // Initialization code
        profileImageView.layer.cornerRadius = 3
        profileImageView.clipsToBounds = true
    }

    @IBAction func onReplyButton(_ sender: ReplyButtonLightGray)
    {
        // implement!!!
    }
    
    @IBAction func onRetweetButton(_ sender: RetweetButtonLightGray)
    {
        // implement!!!
    }
    
    @IBAction func onFavoriteButton(_ sender: HeartButtonLightGray)
    {
        // implement!!!
    }
    
    // Set the cell contents based on the specified parameters.
    func setData(tweet: Tweet)
    {
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
        }
        else
        {
            screenNameAndDateLabel.text = tweet.timeSinceCreatedAtText
        }
        tweetTextLabel.text = tweet.text
        if let retweetsCount = tweet.retweetsCount, retweetsCount > 0
        {
            retweetsCountLabel.text = "\(retweetsCount)"
        }
        else
        {
            retweetsCountLabel.text = nil
        }
        if let favoritesCount = tweet.favoritesCount, favoritesCount > 0
        {
            favoritesCountLabel.text = "\(favoritesCount)"
        }
        else
        {
            favoritesCountLabel.text = nil
        }
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

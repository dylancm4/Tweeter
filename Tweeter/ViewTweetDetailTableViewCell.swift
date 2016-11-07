//
//  ViewTweetDetailTableViewCell.swift
//  Tweeter
//
//  Created by Dylan Miller on 10/30/16.
//  Copyright © 2016 Dylan Miller. All rights reserved.
//

import UIKit

class ViewTweetDetailTableViewCell: UITableViewCell
{
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var mediaImageView: UIImageView!

    var mediaImageViewAspectConstraint : NSLayoutConstraint?
    {
        didSet
        {
            if let oldAspectConstraint = oldValue
            {
                mediaImageView.removeConstraint(oldAspectConstraint)
            }
            if let aspectConstraint = mediaImageViewAspectConstraint
            {
                mediaImageView.addConstraint(aspectConstraint)
            }
        }
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        // Initialization code
        profileImageView.layer.cornerRadius = 3
        profileImageView.clipsToBounds = true

        // Do not round corners on mediaImageView.
        //mediaImageView.layer.cornerRadius = 3
        //mediaImageView.clipsToBounds = true
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
        if let screenName = tweet.user?.screenName
        {
            screenNameLabel.text = "@" + screenName
        }
        else
        {
            screenNameLabel.text = nil
        }
        tweetTextView.text = tweet.text
        if let mediaImage = tweet.mediaImage
        {
            // Create mediaImageView aspect ratio constraint to match
            // image aspect ratio.
            let aspect: CGFloat = mediaImage.size.width / mediaImage.size.height
            mediaImageViewAspectConstraint = NSLayoutConstraint(
                item: mediaImageView,
                attribute: NSLayoutAttribute.width,
                relatedBy: NSLayoutRelation.equal,
                toItem: mediaImageView,
                attribute: NSLayoutAttribute.height,
                multiplier: aspect,
                constant: 0.0)
            mediaImageView.image = mediaImage
        }
        else
        {
            // No image, create mediaImageView height constraint of 0 so
            // that it has no effect on auto layout.
            mediaImageViewAspectConstraint = NSLayoutConstraint(
                item: mediaImageView,
                attribute: NSLayoutAttribute.height,
                relatedBy: NSLayoutRelation.equal,
                toItem: nil,
                attribute: NSLayoutAttribute.notAnAttribute,
                multiplier: 1,
                constant: 0)
            
            mediaImageView.image = nil
        }
        dateLabel.text = tweet.createdAtDateText
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

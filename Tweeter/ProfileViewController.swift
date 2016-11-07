//
//  ProfileViewController.swift
//  Tweeter
//
//  Created by Dylan Miller on 11/4/16.
//  Copyright © 2016 Dylan Miller. All rights reserved.
//

import UIKit

class ProfileViewController: TimelineViewControllerBase
{
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var headerNameLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var numTweetsLabel: UILabel!
    @IBOutlet weak var numFollowingLabel: UILabel!
    @IBOutlet weak var numFollowersLabel: UILabel!
    @IBOutlet weak var tweetsTableView: UITableView!
    @IBOutlet weak var tweetsErrorBannerView: UIView!
    
    @IBOutlet var profileBackgroundImageView: UIImageView!
    @IBOutlet var profileBackgroundBlurImageView:UIImageView!
    
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
        return self
    }
    
    var isInMenu = false
    var user: User!
    var maxId: Int64?

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let navigationController = navigationController
        {
            // Set the navigationBar color to clear.
            navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController.navigationBar.shadowImage = UIImage()
            navigationController.navigationBar.backgroundColor = UIColor.clear
        }
        
        // Set the left bar button image
        if isInMenu
        {
            navigationItem.leftBarButtonItem?.image =
                UIImage(named: Constants.ImageName.hamburgerNavBarButtonWhite)
        }
        else
        {
            navigationItem.leftBarButtonItem?.image =
                UIImage(named: Constants.ImageName.backNavBarButtonWhite)
        }
        
        // Render the bar button images using the correct color.
        navigationItem.leftBarButtonItem?.image = navigationItem.leftBarButtonItem?.image?.withRenderingMode(.alwaysOriginal)
        navigationItem.rightBarButtonItem?.image = navigationItem.rightBarButtonItem?.image?.withRenderingMode(.alwaysOriginal)
        
        profileImageView.layer.cornerRadius = 3
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.borderWidth = 3.0
        profileImageView.clipsToBounds = true

        profileBackgroundImageView = UIImageView(frame: header.bounds)
        header.insertSubview(profileBackgroundImageView, belowSubview: headerNameLabel)
        profileBackgroundBlurImageView = UIImageView(frame: header.bounds)
        header.insertSubview(profileBackgroundBlurImageView, belowSubview: headerNameLabel)

        headerNameLabel.text = user.name
        if let profileImageUrl = user.profileImageUrl
        {
            setImage(imageView: profileImageView, imageUrl: profileImageUrl, isBlurred: false)
        }
        else
        {
            profileImageView.image = nil
        }
        if let profileBackgroundImageUrl = user.profileBackgroundImageUrl
        {
            setImage(imageView: profileBackgroundImageView, imageUrl: profileBackgroundImageUrl, isBlurred: false)
            profileBackgroundImageView?.contentMode = UIViewContentMode.scaleAspectFill

            setImage(imageView: profileBackgroundBlurImageView, imageUrl: profileBackgroundImageUrl, isBlurred: true)
            profileBackgroundBlurImageView?.contentMode = UIViewContentMode.scaleAspectFill
            profileBackgroundBlurImageView?.alpha = 0.0
        }
        else
        {
            profileBackgroundImageView.image = nil
        }
        nameLabel.text = user.name
        if let screenName = user.screenName
        {
            screenNameLabel.text = "@" + screenName
        }
        else
        {
            screenNameLabel.text = nil
        }
        numTweetsLabel.text = getNumberText(user.tweetsCount ?? 0)
        numFollowingLabel.text = getNumberText(user.followingCount ?? 0)
        numFollowersLabel.text = getNumberText(user.followersCount ?? 0)
    }

    @IBAction func onLeftBarButton(_ sender: UIBarButtonItem)
    {
        if isInMenu
        {
            NotificationCenter.default.post(
                name: NSNotification.Name(Constants.Notification.onMenuButton),
                object: nil)
        }
        else
        {
            dismiss(animated: true, completion: nil)

        }
    }
    
    // Get a collection of the most recent Tweets and retweets posted by the
    // authenticating user and the users they follow.
    override func getTimelineTweets(refreshControl: UIRefreshControl? = nil)
    {
        if let twitterClient = TwitterClient.shared,
            let screenName = user.screenName
        {
            willRequest()
            
            twitterClient.getUserTimelineTweets(
                screenName: screenName,
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
    
    // Fade in the specified image if it is not cached, or simply update
    // the image if it was cached.
    func setImage(imageView: UIImageView, imageUrl: URL, isBlurred: Bool)
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
                    if isBlurred
                    {
                        imageView.image = image.blurredImage(withRadius: 10, iterations: 20, tintColor: UIColor.clear)
                    }
                    else if !imageIsCached
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
    
    // Return formatted text corresponding to the specified number.
    func getNumberText(_ number: Int) -> String
    {
        if (number < 1000)
        {
            return "\(number)"
        }
        else if (number < 1000000)
        {
            let thousands = Double(number) / 1000.0
            return String(format: "%.1fK", thousands)
        }
        else
        {
            let millions = Double(number) / 1000000.0
            return String(format: "%.1fM", millions)
        }
    }

    // UIScrollView methods

    // The code in the function is based on the following tutorial:
    //    http://www.thinkandbuild.it/implementing-the-twitter-ios-app-ui/
    override func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        super.scrollViewDidScroll(scrollView)
        
        if scrollView == self.scrollView
        {
            let offset = scrollView.contentOffset.y
            var headerTransform: CATransform3D
            var profileImageViewTransform: CATransform3D
            
            if offset < 0 // pulling down when scroll view is already at top
            {
                // Scale the header proportionally with the offset.
                let headerScaleFactor: CGFloat = 1.0 + -offset / header.bounds.height
                let headerSizeTransform =
                    (header.bounds.height * headerScaleFactor - header.bounds.height)/2.0
                headerTransform =
                    CATransform3DTranslate(CATransform3DIdentity, 0, headerSizeTransform, 0)
                headerTransform =
                    CATransform3DScale(headerTransform, headerScaleFactor, headerScaleFactor, 0)
                
                // Do not transform the profile image.
                profileImageViewTransform = CATransform3DIdentity
            }
            else
            {
                // Code could be improved by calculating these dynamically.
                let offsetHeaderStopTransforms: CGFloat = 40.0
                let offsetBlackLabelReachesHeader: CGFloat = 95.0
                let distanceBottomHeaderToTopWhiteLabel: CGFloat = 35.0
                
                // Header
                headerTransform =
                    CATransform3DTranslate(
                        CATransform3DIdentity, 0, max(-offsetHeaderStopTransforms, -offset), 0)
                
                // Label
                let labelTransform =
                    CATransform3DMakeTranslation(
                        0,
                        max(-distanceBottomHeaderToTopWhiteLabel, offsetBlackLabelReachesHeader - offset),
                        0)
                headerNameLabel.layer.transform = labelTransform
                
                // Blur
                profileBackgroundBlurImageView.alpha =
                    min(1.0, (offset - offsetBlackLabelReachesHeader)/distanceBottomHeaderToTopWhiteLabel)
                
                // Profile image
                let profileImageViewScaleFactor =
                    (min(offsetHeaderStopTransforms, offset)) / profileImageView.bounds.height / 1.4 // Slow down the animation
                let profileImageViewSizeTransform =
                    ((profileImageView.bounds.height * (1.0 + profileImageViewScaleFactor)) - profileImageView.bounds.height) / 2.0
                profileImageViewTransform =
                    CATransform3DTranslate(
                        CATransform3DIdentity, 0, profileImageViewSizeTransform, 0)
                profileImageViewTransform =
                    CATransform3DScale(
                        profileImageViewTransform,
                        1.0 - profileImageViewScaleFactor,
                        1.0 - profileImageViewScaleFactor,
                        0)
                
                if offset <= offsetHeaderStopTransforms
                {
                    if profileImageView.layer.zPosition < header.layer.zPosition
                    {
                        header.layer.zPosition = 0
                    }
                }
                else
                {
                    if profileImageView.layer.zPosition >= header.layer.zPosition
                    {
                        header.layer.zPosition = 2
                    }
                }
            }
            
            // Apply the transformations.
            header.layer.transform = headerTransform
            profileImageView.layer.transform = profileImageViewTransform
        }
    }
}


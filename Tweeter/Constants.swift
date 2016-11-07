//
//  Constants.swift
//  Tweeter
//
//  Created by Dylan Miller on 10/26/16.
//  Copyright © 2016 Dylan Miller. All rights reserved.
//

import Foundation

enum Constants
{
    enum Twitter
    {
        static let apiBaseUrl = "https://api.twitter.com"
        static let apiConsumerKey = "NV6IIlxvzgc43RKrVCCXfmhX9"
        static let apiConsumerSecret = "axTxzycoFcxa5ljKiYV3NhosxASFS1wpzHiPA6lHBLuLfJLgFV"
        static let apiRequestTokenPath = "/oauth/request_token"
        static let apiRequestTokenMethod = "GET"
        static let apiAuthorizePath = "/oauth/authorize?oauth_token="
        static let apiCallbackUrl = "tweeter://oath"
        static let apiCallbackQueryContainsOauthToken = "oauth_token"
        static let apiAccessTokenPath = "/oauth/access_token"
        static let apiAccessTokenMethod = "POST"
        static let apiVerifyCredentialsPath = "/1.1/account/verify_credentials.json"
        static let apiHomeTimelinePath = "/1.1/statuses/home_timeline.json"
        static let apiMentionsTimelinePath = "1.1/statuses/mentions_timeline.json"
        static let apiUserTimelinePath = "/1.1/statuses/user_timeline.json"        
        static let apiStatusesUpdate = "/1.1/statuses/update.json"
        static let apiRetweetWithId = "/1.1/statuses/retweet"
        static let apiUnretweetWithId = "/1.1/statuses/unretweet"
        static let apiFavoritesCreatePath = "/1.1/favorites/create.json"
        static let apiFavoritesDestroyPath = "/1.1/favorites/destroy.json"
        static let dateFormat = "EEE MMM d HH:mm:ss Z y"
        static let maxTweetCharsCount = 140
    }
    
    enum TwitterUserDictKey
    {
        static let description = "description"
        static let name = "name"
        static let profileImageUrlHttps = "profile_image_url_https"
        static let profileBannerImageUrlHttps = "profile_banner_url"
        static let screenName = "screen_name"
        static let tweetsCount = "statuses_count"
        static let followingCount = "friends_count"
        static let followersCount = "followers_count"
    }
    
    enum TwitterTimelineParameter
    {
        static let maxId = "max_id"
        static let screenName = "screen_name"
    }
    
    enum TwitterStatusesUpdateParameter
    {
        static let status = "status"
        static let inReplyToStatusId = "in_reply_to_status_id"
    }
    
    enum TwitterFavoritesParameter
    {
        static let id = "id"
    }
    
    enum TwitterTimelineDictKey
    {
        static let createdAt = "created_at"
        static let entities = "entities"
        static let retweetedStatus = "retweeted_status"
        static let favorited = "favorited"
        static let favoritesCount = "favorite_count"
        static let id = "id"
        static let retweeted = "retweeted"
        static let retweetsCount = "retweet_count"
        static let text = "text"
        static let user = "user"
        
        enum Entities
        {
            static let media = "media"
            
            enum Media
            {
                static let mediaUrlHttps = "media_url_https"
            }
        }
    }
    
    enum ImageName
    {
        static let tweeterNavBarTitlePortrait = "Tweeter-1DA1F2xFFFFFF-44"
        static let tweeterNavBarTitleLandscape = "Tweeter-1DA1F2xFFFFFF-32"
        static let hamburgerNavBarButtonWhite = "Hamburger-FFFFFF-22"
        static let backNavBarButtonWhite = "Left-Arrow-FFFFFF-22"
        static let homeMenuItem = "Home-1DA1F2-30"
        static let mentionsMenuItem = "Mentions-1DA1F2-30"
        static let accountsMenuItem = "Accounts-1DA1F2-30"
        static let signOutMenuItem = "Logout-1DA1F2-30"
    }
    
    enum Notification
    {
        static let onMenuButton = "OnMenuButton"
        static let userDidLogout = "UserDidLogout"
    }
    
    enum ClassName
    {
        static let tweetTableViewCellXib = "TweetTableViewCell"
    }
    
    enum CellReuseIdentifier
    {
        static let tweetCell = "TweetCell"
    }
    
    enum StoryboardName
    {
        static let main = "Main"
    }
    
    enum SegueName
    {
        static let login = "loginSegue"
        static let compose = "composeSegue"
        static let reply = "replySegue"
        static let profile = "profileSegue"
        static let viewTweetSegue = "viewTweetSegue"
    }
    
    enum UserDefaults
    {
        static let currentUserKey = "currentUser"
    }
    
    // Twitter GUI Colors
    // Blue: 1DA1F2
    // Light Gray: AAB8C2
    // Dark Gray: 657786
    // Green: 17BF63
    // Red: E0245E
}

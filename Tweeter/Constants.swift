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
        static let apiVerifyCredentialsPath = "1.1/account/verify_credentials.json"
        static let apiHomeTimelinePath = "/1.1/statuses/home_timeline.json"
        static let apiStatusesUpdate = "/1.1/statuses/update.json"
        static let apiRetweetWithId = "/1.1/statuses/retweet"
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
        static let screenName = "screen_name"
    }
    
    enum TwitterHomeTimelineParameter
    {
        static let maxId = "max_id"
    }
    
    enum TwitterStatusesUpdateParameter
    {
        static let status = "parameters"
        static let inReplyToStatusId = "in_reply_to_status_id"
    }
    
    enum TwitterFavoritesParameter
    {
        static let id = "id"
    }
    
    enum TwitterHomeTimelineDictKey
    {
        static let createdAt = "created_at"
        static let favorited = "favorited"
        static let favoritesCount = "favourites_count"
        static let id = "id"
        static let retweeted = "retweeted"
        static let retweetsCount = "retweet_count"
        static let text = "text"
        static let user = "user"
    }
    
    enum ImageName
    {
        static let tweeterNavBarTitlePortrait = "Tweeter-1DA1F2xFFFFFF-44.png"
        static let tweeterNavBarTitleLandscape = "Tweeter-1DA1F2xFFFFFF-32.png"
        static let tweeterNavBarLogout = "Logout-1DA1F2-22"
        static let tweeterNavBarCompose = "Compose-1DA1F2-22"
    }
    
    enum Notification
    {
        static let userDidLogout = "UserDidLogout"
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

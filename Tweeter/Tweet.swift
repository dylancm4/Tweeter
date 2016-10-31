//
//  Tweet.swift
//  Twitter
//
//  Created by Dylan Miller on 10/26/16.
//  Copyright © 2016 Dylan Miller. All rights reserved.
//

import Foundation

// Represents a single tweet.
class Tweet
{
    var id: Int64?
    var user: User?
    var text: String?
    var createdAt: Date?
    var isFavorited: Bool?
    var isRetweeted: Bool?
    var retweetsCount: Int?
    var favoritesCount: Int?
    var isDummy: Bool

    init(dictionary: NSDictionary)
    {
        if let idNumber = dictionary[Constants.TwitterHomeTimelineDictKey.id] as? NSNumber
        {
           id = idNumber.int64Value
        }
        else
        {
            id = nil
        }
        if let userDict = dictionary[Constants.TwitterHomeTimelineDictKey.user] as? NSDictionary
        {
            user = User(dictionary: userDict)
        }
        else
        {
            user = nil
        }
        text = dictionary[Constants.TwitterHomeTimelineDictKey.text] as? String
        if let createdAtString = dictionary[Constants.TwitterHomeTimelineDictKey.createdAt] as? String
        {
            let formatter = DateFormatter()
            formatter.dateFormat = Constants.Twitter.dateFormat
            createdAt = formatter.date(from: createdAtString)
        }
        else
        {
            createdAt = nil
        }
        isFavorited = dictionary[Constants.TwitterHomeTimelineDictKey.favorited] as? Bool
        isRetweeted = dictionary[Constants.TwitterHomeTimelineDictKey.retweeted] as? Bool
        retweetsCount = dictionary[Constants.TwitterHomeTimelineDictKey.retweetsCount] as? Int
        favoritesCount = dictionary[Constants.TwitterHomeTimelineDictKey.favoritesCount] as? Int
        isDummy = false
    }
    
    // For dummy temporary Tweets which are created locally.
    init(dummyId: Int64, status: String)
    {
        id = dummyId
        user = CurrentUser.shared.user
        text = status
        createdAt = Date()
        isFavorited = nil
        isRetweeted = nil
        retweetsCount = nil
        favoritesCount = nil
        isDummy = true
    }
    
    // The string representing the time elapsed since the tweet was created.
    var timeSinceCreatedAtText: String
    {
        if let createdAt = createdAt
        {
            let components : Set<Calendar.Component> = [.year, .month, .weekOfMonth, .day, .hour, .minute, .second]
            let differenceComponents = Calendar.current.dateComponents(components, from: createdAt, to: Date())
            var years = differenceComponents.year!
            var months = differenceComponents.month!
            var days = differenceComponents.day!
            var weeks = differenceComponents.weekOfMonth!
            var hours = differenceComponents.hour!
            var minutes = differenceComponents.minute!
            let seconds = differenceComponents.second!
            if years > 0
            {
                if months > 6
                {
                    years = years + 1
                }
                return "\(years)y"
            }
            else if months > 0
            {
                if weeks > 2
                {
                    months = months + 1
                }
                return "\(months)mo"
            }
            else if weeks > 0
            {
                if days > 4
                {
                    weeks = weeks + 1
                }
                return "\(months)mo"
            }
            else if days > 0
            {
                if hours > 12
                {
                    days = days + 1
                }
                return "\(days)d"
            }
            else if hours > 0
            {
                if minutes > 30
                {
                    hours = hours + 1
                }
                return "\(hours)h"
            }
            else if minutes > 0
            {
                if seconds > 30
                {
                    minutes = minutes + 1
                }
                return "\(minutes)m"
            }
            else if seconds > 0
            {
                return "\(seconds)s"
            }
            else
            {
                return "now"
            }
        }
        else
        {
            return ""
        }
    }
    
    // Returns an array of Tweet objects based on the specified Twitter
    // dictionary. Also returns the max_id parameter to use in a
    // home_timeline request to get the next set of tweets.
    class func getTweetsWithArray(_ dictionaries: [NSDictionary]) -> ([Tweet], Int64)
    {
        var tweets = [Tweet]()
        var lowestId = Int64.max
        for dictionary in dictionaries
        {
            let tweet = Tweet(dictionary: dictionary)
            tweets.append(tweet)
            
            if let id = tweet.id, id < lowestId
            {
                lowestId = id
            }
        }
        
        // "Subtract 1 from the lowest Tweet ID returned from the previous
        // request and use this for the value of max_id."
        let maxId = lowestId - 1
        
        return (tweets, maxId)
    }
}

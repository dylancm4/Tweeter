//
//  Tweet.swift
//  Twitter
//
//  Created by Dylan Miller on 10/26/16.
//  Copyright © 2016 Dylan Miller. All rights reserved.
//

import UIKit

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
    var mediaImage: UIImage?
    var isDummy: Bool

    init(dictionary: NSDictionary)
    {
        if let idNumber = dictionary[Constants.TwitterTimelineDictKey.id] as? NSNumber
        {
           id = idNumber.int64Value
        }
        else
        {
            id = nil
        }
        if let userDict = dictionary[Constants.TwitterTimelineDictKey.user] as? NSDictionary
        {
            user = User(dictionary: userDict)
        }
        else
        {
            user = nil
        }
        text = dictionary[Constants.TwitterTimelineDictKey.text] as? String
        if let createdAtString = dictionary[Constants.TwitterTimelineDictKey.createdAt] as? String
        {
            let formatter = DateFormatter()
            formatter.dateFormat = Constants.Twitter.dateFormat
            createdAt = formatter.date(from: createdAtString)
        }
        else
        {
            createdAt = nil
        }
        isFavorited = dictionary[Constants.TwitterTimelineDictKey.favorited] as? Bool
        isRetweeted = dictionary[Constants.TwitterTimelineDictKey.retweeted] as? Bool
        retweetsCount = dictionary[Constants.TwitterTimelineDictKey.retweetsCount] as? Int
        favoritesCount = dictionary[Constants.TwitterTimelineDictKey.favoritesCount] as? Int
        mediaImage = nil
        isDummy = false
        
        // Load the media image in this class so that the image view
        // constraints can be adjusted before setting its image. Note
        // that we wait for the image to be loaded before returning,
        // otherwise the tweets table view could load before the images
        // have loaded, and the constraints will not be set correctly.
        // There are likely better ways of solving this problem than
        // using a semaphore here.
        if let entitiesDict = dictionary[Constants.TwitterTimelineDictKey.entities] as? NSDictionary,
            let mediaArray = entitiesDict[Constants.TwitterTimelineDictKey.Entities.media] as? NSArray,
            let mediaDict = mediaArray[0] as? NSDictionary,
            let mediaUrlString =
                mediaDict[Constants.TwitterTimelineDictKey.Entities.Media.mediaUrlHttps] as? String
        {
            if let mediaImageUrl = URL(string: mediaUrlString)
            {
                let semaphore = DispatchSemaphore(value: 0)
                let task = URLSession.shared.dataTask(
                    with: mediaImageUrl,
                    completionHandler:
                    { (data: Data?, response: URLResponse?, error: Error?) in
                        
                        if error == nil,
                            let statusCode = (response as? HTTPURLResponse)?.statusCode,
                            statusCode >= 200 && statusCode <= 299,
                            let data = data,
                            let image = UIImage(data: data)
                        {
                            self.mediaImage = image
                        }
                        semaphore.signal()
                    }
                )
                task.resume()
                let _ = semaphore.wait(timeout: .distantFuture)
            }
        }
        if mediaImage == nil
        {
            if let retweetedStatusDict = dictionary[Constants.TwitterTimelineDictKey.retweetedStatus] as? NSDictionary,
                let entitiesDict = retweetedStatusDict[Constants.TwitterTimelineDictKey.entities] as? NSDictionary,
                let mediaArray = entitiesDict[Constants.TwitterTimelineDictKey.Entities.media] as? NSArray,
                let mediaDict = mediaArray[0] as? NSDictionary,
                let mediaUrlString =
                mediaDict[Constants.TwitterTimelineDictKey.Entities.Media.mediaUrlHttps] as? String
            {
                if let mediaImageUrl = URL(string: mediaUrlString)
                {
                    let semaphore = DispatchSemaphore(value: 0)
                    let task = URLSession.shared.dataTask(
                        with: mediaImageUrl,
                        completionHandler:
                        { (data: Data?, response: URLResponse?, error: Error?) in
                            
                            if error == nil,
                                let statusCode = (response as? HTTPURLResponse)?.statusCode,
                                statusCode >= 200 && statusCode <= 299,
                                let data = data,
                                let image = UIImage(data: data)
                            {
                                self.mediaImage = image
                            }
                            semaphore.signal()
                    }
                    )
                    task.resume()
                    let _ = semaphore.wait(timeout: .distantFuture)
                }
            }
        }
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
    
    // A string representing the time elapsed since the tweet was created.
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
    
    // A string representing date the tweet was created.
    var createdAtDateText: String
    {
        if let createdAt = createdAt
        {
            let components : Set<Calendar.Component> = [.year, .month, .day, .hour, .minute]
            let dateComponents = Calendar.current.dateComponents(components, from: createdAt)
            let year = dateComponents.year!
            let month = dateComponents.month!
            let day = dateComponents.day!
            var hour = dateComponents.hour!
            let minute = dateComponents.minute!
            let amPm = hour < 12 ? "AM" : "PM"
            if hour > 12
            {
                hour = hour - 12
            }
            
            return String(format: "%d/%d/%02d, %d:%02d ",
                          month, day, year, hour, minute) + amPm
        }
        else
        {
            return ""
        }
    }
    
    // Returns an array of Tweet objects based on the specified Twitter
    // dictionary. Also returns the max_id parameter to use in a
    // home_timeline request to get the next set of tweets.
    class func getTweetsWithArray(_ dictionaries: [NSDictionary], lastMaxId: Int64?) -> ([Tweet], Int64?)
    {
        var tweets = [Tweet]()
        if dictionaries.count == 0
        {
            // Keep the same max_id if there are no more tweets.
            return (tweets, lastMaxId)
        }
        
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

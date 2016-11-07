//
//  User.swift
//  Tweeter
//
//  Created by Dylan Miller on 10/26/16.
//  Copyright © 2016 Dylan Miller. All rights reserved.
//

import Foundation

// Represents a user.
class User: NSObject, NSCoding
{
    var name: String?
    var screenName: String?
    var profileImageUrl: URL?
    var profileBackgroundImageUrl: URL?
    var tagLine: String?
    var tweetsCount: Int?
    var followingCount: Int?
    var followersCount: Int?
        
    init(dictionary: NSDictionary)
    {
        name = dictionary[Constants.TwitterUserDictKey.name] as? String
        screenName = dictionary[Constants.TwitterUserDictKey.screenName] as? String
        if let profileImageUrlString =
            dictionary[Constants.TwitterUserDictKey.profileImageUrlHttps] as? String
        {
            // Get a larger image than what is provided by default.
            let profileImageUrlString =
                profileImageUrlString.replacingOccurrences(of: "_normal", with: "")
            
            profileImageUrl = URL(string: profileImageUrlString)
        }
        else
        {
            profileImageUrl = nil
        }
        if let profileBackgroundImageUrlString =
            dictionary[Constants.TwitterUserDictKey.profileBannerImageUrlHttps] as? String
        {
            // Get the correctly sized image.
            let profileBackgroundImageUrlString = profileBackgroundImageUrlString + "/mobile_retina"
            
            profileBackgroundImageUrl = URL(string: profileBackgroundImageUrlString)
        }
        else
        {
            profileBackgroundImageUrl = nil
        }
        tagLine = dictionary[Constants.TwitterUserDictKey.description] as? String
        tweetsCount = dictionary[Constants.TwitterUserDictKey.tweetsCount] as? Int
        followingCount = dictionary[Constants.TwitterUserDictKey.followingCount] as? Int
        followersCount = dictionary[Constants.TwitterUserDictKey.followersCount] as? Int
    }
    
    // Decodes User object using NSCoder.
    required init(coder aDecoder: NSCoder)
    {
        name = aDecoder.decodeObject(
            forKey: Constants.TwitterUserDictKey.name) as? String
        screenName = aDecoder.decodeObject(
            forKey: Constants.TwitterUserDictKey.screenName) as? String
        profileImageUrl = aDecoder.decodeObject(
            forKey: Constants.TwitterUserDictKey.profileImageUrlHttps) as? URL
        profileBackgroundImageUrl = aDecoder.decodeObject(
            forKey: Constants.TwitterUserDictKey.profileBannerImageUrlHttps) as? URL
        tagLine = aDecoder.decodeObject(
            forKey: Constants.TwitterUserDictKey.description) as? String
        tweetsCount = aDecoder.decodeObject(
            forKey: Constants.TwitterUserDictKey.tweetsCount) as? Int
        followingCount = aDecoder.decodeObject(
            forKey: Constants.TwitterUserDictKey.followingCount) as? Int
        followersCount = aDecoder.decodeObject(
            forKey: Constants.TwitterUserDictKey.followersCount) as? Int
    }
    
    // Encodes User object using NSCoder.
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(name, forKey: Constants.TwitterUserDictKey.name)
        aCoder.encode(screenName, forKey: Constants.TwitterUserDictKey.screenName)
        aCoder.encode(profileImageUrl, forKey: Constants.TwitterUserDictKey.profileImageUrlHttps)
        aCoder.encode(profileBackgroundImageUrl, forKey: Constants.TwitterUserDictKey.profileBannerImageUrlHttps)
        aCoder.encode(tagLine, forKey: Constants.TwitterUserDictKey.description)
        aCoder.encode(tweetsCount, forKey: Constants.TwitterUserDictKey.tweetsCount)
        aCoder.encode(followingCount, forKey: Constants.TwitterUserDictKey.followingCount)
        aCoder.encode(followersCount, forKey: Constants.TwitterUserDictKey.followersCount)
    }
}

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
    var tagLine: String?
    
    init(dictionary: NSDictionary)
    {
        name = dictionary[Constants.TwitterUserDictKey.name] as? String
        screenName = dictionary[Constants.TwitterUserDictKey.screenName] as? String
        if let profileImageUrlString =
            dictionary[Constants.TwitterUserDictKey.profileImageUrlHttps] as? String
        {
            profileImageUrl = URL(string: profileImageUrlString)
        }
        else
        {
            profileImageUrl = nil
        }
        tagLine = dictionary[Constants.TwitterUserDictKey.description] as? String
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
        tagLine = aDecoder.decodeObject(
            forKey: Constants.TwitterUserDictKey.description) as? String
     }
    
    // Encodes User object using NSCoder.
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(name, forKey: Constants.TwitterUserDictKey.name)
        aCoder.encode(screenName, forKey: Constants.TwitterUserDictKey.screenName)
        aCoder.encode(profileImageUrl, forKey: Constants.TwitterUserDictKey.profileImageUrlHttps)
        aCoder.encode(tagLine, forKey: Constants.TwitterUserDictKey.description)
    }
}

//
//  TwitterClient.swift
//  Twitter
//
//  Created by Dylan Miller on 10/26/16.
//  Copyright © 2016 Dylan Miller. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

// An OAuth session manager to interface with the Twitter API.
class TwitterClient: BDBOAuth1SessionManager
{
    static let shared = TwitterClient(
        baseURL: URL(string: Constants.Twitter.apiBaseUrl),
        consumerKey: Constants.Twitter.apiConsumerKey,
        consumerSecret: Constants.Twitter.apiConsumerSecret)
    
    var loginSuccess: ((User) -> Void)?
    var loginFailure: ((Error?) -> Void)?
    
    // Log into Twitter, fetching an OAuth request token and redirecting to
    // authorization page, which will lead to handleOpenUrl() being called.
    func login(success: @escaping (User) -> Void, failure: @escaping (Error?) -> Void)
    {
        // Save the success and failure closures.
        loginSuccess = success
        loginFailure = failure
        
        // Initialize keychain for this session.
        deauthorize()
        
        // Fetch an OAuth request token.
        fetchRequestToken(
            withPath: Constants.Twitter.apiRequestTokenPath,
            method: Constants.Twitter.apiRequestTokenMethod,
            callbackURL: URL(string: Constants.Twitter.apiCallbackUrl),
            scope: nil,
            success:
            { (requestToken: BDBOAuth1Credential?) in
                
                // Use the OAuth request token to request user authorization.
                // The callback URL response will come through AppDelegate.
                let authorizeUrl = URL(
                    string: Constants.Twitter.apiBaseUrl + Constants.Twitter.apiAuthorizePath + requestToken!.token)!
                UIApplication.shared.open(
                    authorizeUrl, options: [:], completionHandler: nil)
            },
            failure:
            { (error: Error?) in
                
                failure(error)
            }
        )
    }
    
    // Log out of Twitter, deauthorizing this manager instance and removing any
    // associated OAuth access token from the keychain.
    func logout()
    {
        deauthorize()
    }
    
    // Handle the open URL from the Twitter authorization page. If the login was
    // successful, the loginSuccess() closure is called. If there was an error
    // logging in, the loginFailure() closure is called.
    func handleOpenUrl(_ url: URL)
    {
        if let loginSuccess = loginSuccess, let loginFailure = loginFailure
        {
            // If the URL query does not contain "oauth_token", the user likely
            // cancelled authentication.
            if let urlQuery = url.query,
                urlQuery.range(of: Constants.Twitter.apiCallbackQueryContainsOauthToken) != nil
            {
                // Fetch an OAuth access token using the request token.
                if let requestToken = BDBOAuth1Credential(queryString: urlQuery)
                {
                    fetchAccessToken(
                        withPath: Constants.Twitter.apiAccessTokenPath,
                        method: Constants.Twitter.apiAccessTokenMethod,
                        requestToken: requestToken,
                        success:
                        { (accessToken: BDBOAuth1Credential?) in
                            
                            // Get a representation of the requesting user.
                            self.getCurrentUser(
                                success: { (user: User) in
                                    
                                    loginSuccess(user)
                                },
                                failure: { (error: Error?) in
                                    
                                    loginFailure(error)
                                }
                            )
                        },
                        failure:
                        { (error: Error?) in
                            
                            loginFailure(error)
                        }
                    )
                }
            }
            else
            {
                // Not technically an error, but this is a good way to test the
                // error banner.
                loginFailure(nil)
            }
        }
    }
    
    // Get a representation of the requesting user.
    func getCurrentUser(success: @escaping (User) -> Void, failure: @escaping (Error?) -> Void)
    {
        get(
            Constants.Twitter.apiVerifyCredentialsPath,
            parameters: nil,
            success:
            { (task: URLSessionDataTask, response: Any) in
                
                if let responseDict = response as? NSDictionary
                {
                    let user = User(dictionary: responseDict)
                    success(user)
                }
                else
                {
                    failure(nil)
                }
            },
            failure:
            { (task: URLSessionDataTask?, error: Error) in
                
                failure(error)
            }
        )
    }
    
    // Get a collection of the most recent Tweets and retweets posted by the
    // authenticating user and the users they follow.
    func getHomeTimeLineTweets(success: @escaping ([Tweet]) -> Void, failure: @escaping (Error?) -> Void)
    {
        get(
            Constants.Twitter.apiHomeTimelinePath,
            parameters: nil,
            success:
            { (URLSessionDataTask, response: Any) in
                
                if let responseDicts = response as? [NSDictionary]
                {
                    let tweets = Tweet.getTweetsWithArray(responseDicts)
                    success(tweets)
                }
                else
                {
                    failure(nil)
                }                
            },
            failure:
            { (_: URLSessionDataTask?, error: Error) in
                
                failure(error)
            }
        )
    }
}

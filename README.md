# Tweeter

Tweeter is a Twitter client app for iOS submitted as [Assignment #3](https://github.com/dylancm4/Yelp) for the CodePath October 2016 iOS bootcamp.

Time spent: **33** hours

## User Stories

**Required** functionality:

* [X] User can sign in using OAuth login flow.
* [X] User can view last 20 tweets from their home timeline.
* [X] The current signed in user will be persisted across restarts.
* [X] In the home timeline, user can view tweet with the user profile picture, username, tweet text, and timestamp.
* [X] User can pull to refresh.
* [ ] User can compose a new tweet by tapping on a compose button.
* [ ] User can tap on a tweet to view it, with controls to retweet, favorite, and reply.

**Optional** functionality:

* [X] When composing, you should have a countdown in the upper right for the tweet limit.
* [ ] After creating a new tweet, a user should be able to view it in the timeline immediately without refetching the timeline from the network.
* [ ] Retweeting and favoriting should increment the retweet and favorite count.
* [ ] User should be able to unretweet and unfavorite and should decrement the retweet and favorite count.
* [ ] Replies should be prefixed with the username and the reply_id should be set when posting the tweet.
* [ ] User can load more tweets once they reach the bottom of the feed using infinite loading similar to the actual Twitter client.

**Additional** functionality:

* [X] Used NSCoding and NSKeyedArchiver to save/load current user to/from UserDefaults.
* [X] User sees loading state while waiting for Twitter API.
* [x] User sees an error message when there's a networking error.
* [X] Table images fade in as they are loading.
* [x] Customized the navigation bar.
* [x] UI extensively customized.

## Walkthrough

![Video Walkthrough](TweeterDemo.gif)

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Open-Source Libraries Used
* AFNetworking
* BDBOAuth1Manager
* MBProgressHUD

## License

Copyright [2016] Dylan Miller

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

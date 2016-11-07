
# Tweeter, version 2.0 (Week 4 Project: Twitter Redux)

Tweeter is a Twitter client app for iOS submitted as [Assignment #4](https://github.com/dylancm4/Tweeter) for the CodePath October 2016 iOS bootcamp.

Time spent: **35** hours

## User Stories

**Required** functionality:

Hamburger menu:
* [x] Dragging anywhere in the view should reveal the menu.
* [x] The menu should include links to your profile, the home timeline, and the mentions view.
* [x] The menu can look similar to the example menu or feel free to take liberty with the UI.

Profile page:
* [x] Contains the user header view.
* [x] Contains a section with the users basic stats: # tweets, # following, # followers.
* [x] Shows the user timeline.

Home timeline:
* [x] Tapping on a user image should bring up that user's profile page

**Optional** functionality:

Profile page:
* [ ] Implement the paging view for the user description.
* [ ] As the paging view moves, increase the opacity of the background screen.
* [x] Pulling down the profile page should blur and resize the header image.

Account switching:
* [ ] Long press on tab bar to bring up Account view with animation.
* [ ] Tap account to switch to.
* [ ] Include a plus button to add an account.
* [ ] Swipe to delete an account.

**Additional** functionality:
* [x] Display media images for tweets.

## Walkthrough

![Video Walkthrough](TweeterDemo2.gif)

GIF created with [LiceCap](http://www.cockos.com/licecap/).


# Tweeter, version 1.0 (Week 3 Project: Simple Twitter Client)

Tweeter is a Twitter client app for iOS submitted as [Assignment #3](https://github.com/dylancm4/Tweeter) for the CodePath October 2016 iOS bootcamp.

Time spent: **50** hours

## User Stories

**Required** functionality:

* [x] User can sign in using OAuth login flow.
* [x] User can view last 20 tweets from their home timeline.
* [x] The current signed in user will be persisted across restarts.
* [x] In the home timeline, user can view tweet with the user profile picture, username, tweet text, and timestamp.
* [x] User can pull to refresh.
* [x] User can compose a new tweet by tapping on a compose button.
* [x] User can tap on a tweet to view it, with controls to retweet, favorite, and reply.

**Optional** functionality:

* [x] When composing, you should have a countdown in the upper right for the tweet limit.
* [x] After creating a new tweet, a user should be able to view it in the timeline immediately without refetching the timeline from the network.
* [x] Retweeting and favoriting should increment the retweet and favorite count.
* [x] User should be able to unretweet and should decrement the retweet count.
* [x] User should be able to unfavorite and should decrement the favorite count.
* [x] Replies should be prefixed with the username and the reply_id should be set when posting the tweet.
* [x] User can load more tweets once they reach the bottom of the feed using infinite loading similar to the actual Twitter client.

**Additional** functionality:

* [x] Used NSCoding and NSKeyedArchiver to save/load current user to/from UserDefaults.
* [x] User sees loading state while waiting for Twitter API.
* [x] User sees an error message when there's a networking error.
* [x] Table images fade in as they are loading.
* [x] Customized the navigation bar.
* [x] UI extensively customized.

## Walkthrough

![Video Walkthrough](TweeterDemo.gif)

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Open-Source Libraries Used
* AFNetworking
* BDBOAuth1Manager
* MBProgressHUD
* FXBlurView

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

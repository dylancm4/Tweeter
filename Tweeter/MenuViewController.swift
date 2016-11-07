//
//  MenuViewController.swift
//  Tweeter
//
//  Created by Dylan Miller on 11/4/16.
//  Copyright © 2016 Dylan Miller. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController
{
    @IBOutlet weak var tableView: UITableView!
    
    var profileNavigationController: UINavigationController!
    var tweetsNavigationController: UINavigationController!
    var mentionsNavigationController: UINavigationController!
    var navigationControllers = [UINavigationController]()
    
    weak var hamburgerViewController: HamburgerViewController!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Create menu item navigation controllers and add them to the
        // navigationControllers[] array.
        let storyboard = UIStoryboard(name: Constants.StoryboardName.main, bundle: nil)
        profileNavigationController =
            storyboard.instantiateViewController(withIdentifier: "ProfileNavigationController") as! UINavigationController
        tweetsNavigationController =
            storyboard.instantiateViewController(withIdentifier: "TweetsNavigationController") as! UINavigationController
        mentionsNavigationController =
            storyboard.instantiateViewController(withIdentifier: "MentionsNavigationController") as! UINavigationController
        navigationControllers.append(profileNavigationController)
        navigationControllers.append(tweetsNavigationController)
        navigationControllers.append(mentionsNavigationController)
        
        if let tweetsViewController = tweetsNavigationController.topViewController as? TweetsViewController
        {
            // Set up the profile view controller.
            if let profileViewController = profileNavigationController.topViewController as? ProfileViewController
            {
                profileViewController.isInMenu = true
                profileViewController.user = CurrentUser.shared.user
            }

            // Set up the mentions view controller.
            if let mentionsViewController = mentionsNavigationController.topViewController as? MentionsViewController
            {
                mentionsViewController.tweetsViewController = tweetsViewController
            }
        }
        
        // Set up the tableView.
        tableView.estimatedRowHeight = 55
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Set TweetsViewController as the initial view controller.
        hamburgerViewController.contentViewController = tweetsNavigationController
    }
}

// UITableView methods
extension MenuViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // Set the cell contents.
        if indexPath.row == 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemUserCell") as! MenuItemUserTableViewCell
            cell.setData(user: CurrentUser.shared.user)
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemIconCell") as! MenuItemIconTableViewCell
            if indexPath.row == 1
            {
                cell.setData(itemImageName: Constants.ImageName.homeMenuItem, itemTitle: "Home")
            }
            else if indexPath.row == 2
            {
                cell.setData(itemImageName: Constants.ImageName.mentionsMenuItem, itemTitle: "Mentions")
            }
            else
            {
                cell.setData(itemImageName: Constants.ImageName.signOutMenuItem, itemTitle: "Sign out")
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // Do not leave rows selected.
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 3
        {
            // Log out of Twitter, and post notification that user did log out.
            CurrentUser.shared.logout()
        }
        else
        {
            // Switch to the selected navigation controller.
            hamburgerViewController.contentViewController = navigationControllers[indexPath.row]
        }
    }
}

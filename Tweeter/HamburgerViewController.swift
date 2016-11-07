//
//  HamburgerViewController.swift
//  Tweeter
//
//  Created by Dylan Miller on 11/4/16.
//  Copyright © 2016 Dylan Miller. All rights reserved.
//

import UIKit

class HamburgerViewController: UIViewController
{
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentViewLeadingConstraint: NSLayoutConstraint!
    
    var menuViewController: UIViewController!
    {
        didSet
        {
            view.layoutIfNeeded() // ensure members are set
            menuView.addSubview(menuViewController.view)
        }
    }
    var contentViewController: UIViewController!
    {
        didSet
        {
            view.layoutIfNeeded() // ensure members are set
            
            // Remove the old content view controller.
            if oldValue != nil
            {
                oldValue.willMove(toParentViewController: nil)
                oldValue.view.removeFromSuperview()
                oldValue.didMove(toParentViewController: nil)
            }
            
            // Add the new content view controller.
            contentViewController.willMove(toParentViewController: self)
            contentView.addSubview(contentViewController.view)
            contentViewController.didMove(toParentViewController: self)
            
            // Close the menu.
            closeMenu()
        }
    }
    var originalContentViewLeadingConstraint: CGFloat!
    var isMenuOpen = false

    deinit
    {
        // Remove all of this object's observer entries.
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Open/close the menu when the menu button is pressed.
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(Constants.Notification.onMenuButton),
            object: nil,
            queue: OperationQueue.main)
        { (Notification) in
            
            if self.isMenuOpen
            {
                self.closeMenu()
            }
            else
            {
                self.openMenu()
            }
        }
    }
    
    @IBAction func onPanGesture(_ sender: UIPanGestureRecognizer)
    {
        if sender.state == UIGestureRecognizerState.began
        {
            originalContentViewLeadingConstraint = contentViewLeadingConstraint.constant
        }
        else if sender.state == UIGestureRecognizerState.changed
        {
            let translation = sender.translation(in: view)
            contentViewLeadingConstraint.constant = originalContentViewLeadingConstraint + translation.x
        }
        else if sender.state == UIGestureRecognizerState.ended
        {
            let velocity = sender.velocity(in: view)
            let shouldOpenMenu = velocity.x > 0
            if shouldOpenMenu
            {
                openMenu()
            }
            else
            {
                closeMenu()
            }
        }
    }
    
    // Open the menu.
    func openMenu()
    {
        isMenuOpen = true
        UIView.animate(withDuration: 0.3)
        {
            self.contentViewLeadingConstraint.constant = self.view.frame.size.width - 50
            self.view.layoutIfNeeded()
        }
    }
    
    // Close the menu.
    func closeMenu()
    {
        isMenuOpen = false
        UIView.animate(withDuration: 0.3)
        {
            self.contentViewLeadingConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
}

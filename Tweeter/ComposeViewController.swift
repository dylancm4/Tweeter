//
//  ComposeViewController.swift
//  Tweeter
//
//  Created by Dylan Miller on 10/30/16.
//  Copyright © 2016 Dylan Miller. All rights reserved.
//

import UIKit

protocol ComposeViewControllerDelegate: class
{
    func composeViewController(composeViewController: ComposeViewController, addTweetStatus status: String, inReplyToId: Int64?)
}

class ComposeViewController: UIViewController, UITextViewDelegate
{
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewPlaceholderLabel: UILabel!
    @IBOutlet weak var charsLeftLabel: UILabel!
    @IBOutlet weak var tweetButton: UIButton!
    @IBOutlet weak var bottomViewBottomConstraint: NSLayoutConstraint!
    
    weak var delegate: ComposeViewControllerDelegate?
    var inReplyToId: Int64?
    var inReplyToScreenName: String?
    let profileImageView = UIImageView()
    
    deinit
    {
        // Remove all of this object's observer entries.
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Set the navigationBar color to white.
        navigationController!.navigationBar.barTintColor = UIColor.white
        
        // Set the user profile image in the left navigation bar button.
        setProfileImage()
        
        // Rounded tweet button, disabled until there is text.
        tweetButton.layer.cornerRadius = 8.0
        tweetButton.isEnabled = false
        
        // If this is a reply, add the reply screen name to the start of the
        // text view.
        if let inReplyToScreenName = inReplyToScreenName
        {
            textView.text = "@" + inReplyToScreenName + " "
            textViewDidChange(textView)
        }
        
        // Show the keyboard, and make sure it is shown again when the app goes
        // into the background and comes back.
        textView.becomeFirstResponder()
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil,
            queue: OperationQueue.main)
        { (notification: Notification) in
            
            self.textView.becomeFirstResponder()
        }

        // Adjust constraints for keyboard.
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.UIKeyboardWillShow,
            object: nil,
            queue: OperationQueue.main)
        { (notification: Notification) in
            
            let keyboardHeight = self.getKeyboardHeight(notification: notification)
            self.bottomViewBottomConstraint.constant = -keyboardHeight
        }
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.UIKeyboardWillHide,
            object: nil,
            queue: OperationQueue.main)
        { (notification: Notification) in
            
            self.bottomViewBottomConstraint.constant = 0
        }
    }
    
    // Only allow a maximum of maxTweetCharsCount.
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        let newTextCount: Int
        if let textViewText = textView.text
        {
            let oldText = textViewText as NSString
            let newText = oldText.replacingCharacters(in: range, with: text)
            newTextCount = newText.characters.count
        }
        else
        {
            newTextCount = 0
        }
        return newTextCount <= Constants.Twitter.maxTweetCharsCount
    }
    
    // Adjust controls based on changes to textView.
    func textViewDidChange(_ textView: UITextView)
    {
        if let textViewText = textView.text
        {
            let charCount = textViewText.characters.count
            textViewPlaceholderLabel.isHidden = charCount > 0
            tweetButton.isEnabled = charCount > 0
            
            let charsLeft = Constants.Twitter.maxTweetCharsCount - charCount
            charsLeftLabel.text = "\(charsLeft)"
        }
    }
    
    @IBAction func onCancelButton(_ sender: UIBarButtonItem)
    {
        dismiss(animated: true, completion: nil)
    }
    
    // Pass the tweet to the delegate to handle.
    @IBAction func onTweetButton(_ sender: UIButton)
    {
        if let delegate = delegate
        {
            delegate.composeViewController(
                composeViewController: self,
                addTweetStatus: textView.text,
                inReplyToId: inReplyToId)
        }
        dismiss(animated: true, completion: nil)
    }
    
    // Set the user profile image in the left navigation bar button.
    func setProfileImage()
    {
        let leftBarButtonItem = self.navigationItem.leftBarButtonItem!
        leftBarButtonItem.title = nil
        leftBarButtonItem.isEnabled = false
        if let profileImageUrl = CurrentUser.shared.user?.profileImageUrl
        {
            let imageRequest = URLRequest(url: profileImageUrl)
            profileImageView.setImageWith(
                imageRequest,
                placeholderImage: nil,
                success:
                { (request: URLRequest, response: HTTPURLResponse?, image: UIImage) in
                    
                    DispatchQueue.main.async
                    {
                        leftBarButtonItem.image = image.withRenderingMode(.alwaysOriginal)
                    }
                },
                failure:
                { (request: URLRequest, response: HTTPURLResponse?, error: Error) in
                    
                    DispatchQueue.main.async
                    {
                        leftBarButtonItem.image = nil
                    }
                }
            )
        }
    }
    
    // Get the keyboard height.
    func getKeyboardHeight(notification: Notification) -> CGFloat
    {
        if let userInfo = notification.userInfo
        {
            if let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue // of CGRect
            {
                return keyboardSize.cgRectValue.height
            }
        }
        return 0
    }
}

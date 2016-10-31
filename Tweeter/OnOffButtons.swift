//
//  OnOffButton.swift
//  Tweeter
//
//  Created by Dylan Miller on 10/30/16.
//  Copyright © 2016 Dylan Miller. All rights reserved.
//

import UIKit

// Base class for buttons which have an on state and an off state. Derived
// classes must override onImageName and offImageName computed properties.
class OnOffButton: UIButton
{
    var buttonImage: UIImage?

    var onImageName: String?
    {
        return nil
    }

    var offImageName: String?
    {
        return nil
    }
    
    var isOn = false
    {
        didSet
        {
            updateImage()
        }
    }
    
    override func awakeFromNib()
    {
        addTarget(self, action: #selector(onTouchUpInside(_:)), for: UIControlEvents.touchUpInside)
        updateImage()
    }
    
    func onTouchUpInside(_ sender: UIButton)
    {
        if sender == self
        {
            isOn = !isOn
        }
    }
    
    func updateImage()
    {
        let imageName = isOn ? onImageName! : offImageName!
        setImage(UIImage(named: imageName)!, for: .normal)
    }
}

class ReplyButtonLightGray : OnOffButton
{
    override var onImageName: String?
    {
        return "Left-Arrow-AAB8C2-30"
    }
    
    override var offImageName: String?
    {
        return "Left-Arrow-AAB8C2-30"
    }
}

class ReplyButtonDarkGray : OnOffButton
{
    override var onImageName: String?
    {
        return "Left-Arrow-657786-30"
    }
    
    override var offImageName: String?
    {
        return "Left-Arrow-657786-30"
    }
}

class RetweetButtonLightGray : OnOffButton
{
    override var onImageName: String?
    {
        return "Retweet-17BF63-30"
    }
    
    override var offImageName: String?
    {
        return "Retweet-AAB8C2-30"
    }
}

class RetweetButtonDarkGray : OnOffButton
{
    override var onImageName: String?
    {
        return "Retweet-17BF63-30"
    }
    
    override var offImageName: String?
    {
        return "Retweet-657786-30"
    }
}

class HeartButtonLightGray : OnOffButton
{
    override var onImageName: String?
    {
        return "Heart-E0245E-30"
    }
    
    override var offImageName: String?
    {
        return "Heart-AAB8C2-30"
    }
}

class HeartButtonDarkGray : OnOffButton
{
    override var onImageName: String?
    {
        return "Heart-E0245E-30"
    }
    
    override var offImageName: String?
    {
        return "Heart-657786-30"
    }
}

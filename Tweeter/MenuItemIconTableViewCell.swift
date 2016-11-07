//
//  MenuItemIconTableViewCell.swift
//  Tweeter
//
//  Created by Dylan Miller on 11/4/16.
//  Copyright © 2016 Dylan Miller. All rights reserved.
//

import UIKit

class MenuItemIconTableViewCell: UITableViewCell
{
    @IBOutlet weak var itemImageView: UIImageView!    
    @IBOutlet weak var itemTitleLabel: UILabel!
    
    // Set the cell contents based on the specified parameters.
    func setData(itemImageName: String, itemTitle: String)
    {
        itemImageView.image = UIImage(named: itemImageName)
        itemTitleLabel.text = itemTitle
    }
}

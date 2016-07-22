//
//  UserCell.swift
//  JamChat
//
//  Created by Simon Posada Fishman on 7/17/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import AFNetworking

class UserCell: UICollectionViewCell {
    
    @IBOutlet weak var mainUserView: UIView!
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var countView: UIView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var countImageView: UIImageView!
    
    
    var user: User! {
        didSet {
            if let nameLabel = nameLabel {
                nameLabel.text = user.firstName
            }
            profilePictureView.setImageWithURL(user.profileImageURL)
        }
    }
    
    override func awakeFromNib() {
        // Make image circular:
        profilePictureView.layer.cornerRadius = profilePictureView.frame.size.width / 2;
        profilePictureView.clipsToBounds = true;
        
    }
    
    @IBAction func onUserTap(sender: AnyObject) {
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            
            
            if (self.countView.alpha == 0.0) {
                self.countView.alpha = 0.6
                
                self.countImageView.backgroundColor = UIColor(red: 33/255.0, green: 174/255.0, blue: 67/255.0, alpha: 1.0)
                self.countImageView.layer.cornerRadius = self.countImageView.frame.size.width / 2;
                self.countImageView.clipsToBounds = true;

                self.mainUserView.alpha = 0.3
                
            } else {
                self.countView.alpha = 0.0
                self.mainUserView.alpha = 1.0
            }
            
            }, completion: nil)
    }
}

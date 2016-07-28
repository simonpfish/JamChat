//
//  FriendCell.swift
//  JamChat
//
//  Created by Meena Sengottuvelu on 7/21/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit

class FriendCell: UICollectionViewCell {

    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    var user: User! {
        didSet {
            if let nameLabel = nameLabel {
                nameLabel.text = user.name
            }
            profilePictureView.setImageWithURL(user.profileImageURL)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Make image circular:
        profilePictureView.layer.cornerRadius = profilePictureView.frame.size.width / 2;
        profilePictureView.clipsToBounds = true;
    }

}

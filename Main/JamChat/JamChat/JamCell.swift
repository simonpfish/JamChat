//
//  ChatCell.swift
//  JamChat
//
//  Created by Simon Posada Fishman on 7/12/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit

class JamCell: UITableViewCell {

    @IBOutlet weak var usersLabel: UILabel!
    
    var jam: Jam? {
        didSet {
            var usersString = ""
            for user in jam!.users {
                usersString += user.name + ", "
            }
            usersLabel.text = usersString
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

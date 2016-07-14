//
//  MessageCell.swift
//  JamChat
//
//  Created by Simon Posada Fishman on 7/12/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    
    var message: Message?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onPlay(sender: AnyObject) {
        message?.loadTracks({ 
            self.message?.play()
        })
    }
}

//
//  InstrumentCell.swift
//  JamChat
//
//  Created by Meena Sengottuvelu on 7/21/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import AFNetworking

class InstrumentCell: UICollectionViewCell {
    
    @IBOutlet weak var instrumentView: UIImageView!
    @IBOutlet weak var instrumentLabel: UILabel!
    
    var instrument: Instrument! {
        didSet {
            instrumentLabel.text = instrument.name
            instrumentView.image = instrument.image
        }
    }
    
    override func awakeFromNib() {
        // Make image circular:
        instrumentView.layer.cornerRadius = instrumentView.frame.size.width / 2;
        instrumentView.clipsToBounds = true;
        
        //instrumentView.layer.borderColor = instrument.color.CGColor
    }
    
}

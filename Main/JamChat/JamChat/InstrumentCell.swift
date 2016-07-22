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
    
    
    @IBOutlet weak var mainInstrumentView: UIView!
    
    @IBOutlet weak var instrumentView: UIImageView!
    @IBOutlet weak var instrumentLabel: UILabel!
    
    @IBOutlet weak var countView: UIView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var countImageView: UIImageView!
    
    var instrument: Instrument! {
        didSet {
            instrumentLabel.text = instrument.name
            instrumentView.image = instrument.image
            instrumentView.backgroundColor = instrument.color
        }
    }
    
    override func awakeFromNib() {
        // Make image circular:
        instrumentView.layer.cornerRadius = instrumentView.frame.size.width / 2;
        instrumentView.clipsToBounds = true;
    }
    
    @IBAction func onInstrumentTap(sender: AnyObject) {
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            
            if (self.countView.alpha == 0.0) {
                self.countView.alpha = 1.0
                
                self.countImageView.backgroundColor = self.instrument.color
                self.countImageView.layer.cornerRadius = self.countImageView.frame.size.width / 2;
                self.countImageView.clipsToBounds = true;
                
                self.mainInstrumentView.alpha = 0.0
                
            } else {
                self.countView.alpha = 0.0
                self.mainInstrumentView.alpha = 1.0
            }
            
            }, completion: nil)
    }
}

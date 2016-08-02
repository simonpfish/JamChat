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
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var countButton: UIButton!
    
    var user: User!
    
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
        
        if let button = countButton {
            button.layer.cornerRadius = countButton.frame.size.width / 2;
        }
    }
    
    var numberIsDisplayed = false
    
    @IBAction func onInstrumentTap(sender: AnyObject) {
        
        var instrumentNum: [Instrument : Int] = [:]
        instrumentNum = (user.instrumentCount)
        
        var num = 0
        
        for curInstrument in instrumentNum.keys {
            if curInstrument.name == instrument.name {
                num = instrumentNum[curInstrument]!
            }
        }
        
        self.countButton.backgroundColor = instrument.color
        self.countLabel.hidden = false
        self.countLabel.text = String(num)
        
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            
            if self.numberIsDisplayed {
                self.countButton.backgroundColor = self.countButton.backgroundColor?.colorWithAlphaComponent(0.0)
                self.countLabel.hidden = true
                self.numberIsDisplayed = false
            } else {
                self.countButton.backgroundColor = self.countButton.backgroundColor?.colorWithAlphaComponent(1)
                self.countLabel.hidden = false
                self.numberIsDisplayed = true
            }
            
            // reverts back to the instrument's image after 5 seconds, if the count label is still showing
            self.delay(4.0, closure: {
                
                if self.numberIsDisplayed {
                    UIView.animateWithDuration(1, animations: {
                        self.countButton.backgroundColor = self.countButton.backgroundColor?.colorWithAlphaComponent(0.0)
                        self.countLabel.hidden = true
                        self.numberIsDisplayed = false
                    })
                }
                
            })
            
            }, completion: nil)
        
    }
    
    func delay(delay: Double, closure: ()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(),
            closure
        )
    }
    
}

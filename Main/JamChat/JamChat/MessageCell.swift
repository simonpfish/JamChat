//
//  MessageCell.swift
//  JamChat
//
//  Created by Simon Posada Fishman on 7/12/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import AVFoundation
import RBBAnimation
import EasyAnimation
import AudioKit
import FDWaveformView

class MessageCell: UITableViewCell {
    
    @IBOutlet weak var plot: FDWaveformView!
    
    var message: Message? {
        didSet {
            if let filepath = message?.tracks.first?.filepath {
                
                let fileURL = NSURL(fileURLWithPath: filepath)
                
                self.plot.audioURL = fileURL
                self.plot.doesAllowScrubbing = false
                self.plot.doesAllowScroll = false
                self.plot.doesAllowStretch = false
            }
        }
    }
    
    @IBOutlet weak var waveformView: UIView!
    
    let replicatorLayer = CAReplicatorLayer()
    let dot = CALayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    
    // sets up the sine wave layout
    func setUpSineWave() {
        
        replicatorLayer.frame = waveformView.bounds
        waveformView.layer.addSublayer(replicatorLayer)
        
        dot.bounds = CGRect(x: 0.0, y: 0.0, width: 5.0, height: 5.0)
        dot.position = CGPoint(x: 18.0, y: waveformView.center.y)
        dot.backgroundColor = UIColor.magentaColor().CGColor
        dot.borderColor = UIColor(white: 1.0, alpha: 1.0).CGColor
        dot.borderWidth = 1.0
        dot.cornerRadius = 2.0
        replicatorLayer.addSublayer(dot)
        
        replicatorLayer.instanceCount = 35
        replicatorLayer.instanceTransform = CATransform3DMakeTranslation(20.0, 0.0, 0.0)
        replicatorLayer.instanceDelay = 0.1
        
    }
    
    //starts the sine wave animations
    func sineWaveOn() {
        
        self.setUpSineWave()
        
        //creates a 3D wave-like effect
        UIView.animateWithDuration(0.5, delay: 0.0, options: [.CurveEaseOut, .Repeat, .Autoreverse, .FillModeForwards], animations: {
            self.dot.transform = CATransform3DMakeScale(1.4, 10, 1.0)
            self.dot.backgroundColor = UIColor.purpleColor().CGColor
            
            }, completion: nil)
        dot.transform = CATransform3DIdentity
        
        //causes the sine wave to compress and decompress
        UIView.animateWithDuration(1.25, delay: 0.0, options: [.Repeat, .Autoreverse], animations: {
            self.replicatorLayer.instanceTransform = CATransform3DMakeTranslation(10.0, 0.0, 0.0)
            }, completion: nil)
    }
    
    //stops the sine wave animations
    func sineWaveOff() {
        UIView.animateWithDuration(0.5, delay: 0.0, options: [.CurveEaseOut, .Repeat, .Autoreverse, .FillModeForwards], animations: {
            self.dot.transform = CATransform3DMakeScale(0.0, 0.0, 0.0)
            self.dot.backgroundColor = UIColor.purpleColor().CGColor
            
            }, completion: nil)
        dot.transform = CATransform3DIdentity
        
        UIView.animateWithDuration(1.25, delay: 0.0, options: [.Repeat, .Autoreverse], animations: {
            self.replicatorLayer.instanceTransform = CATransform3DMakeTranslation(0.0, 0.0, 0.0)
            }, completion: nil)
    }


    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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

    @IBAction func onPlay(sender: AnyObject) {
        
        message?.loadTracks({
            self.sineWaveOn()
            self.message?.play()
        })
        
        // each track is 5 seconds
        // allows the sine wave to play until the track is finished
        
        delay(5.0) {
            self.sineWaveOff()
        }
    }
}


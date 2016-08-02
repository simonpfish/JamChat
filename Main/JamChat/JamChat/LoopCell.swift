//
//  LoopCell.swift
//  JamChat
//
//  Created by Alexina Boudreaux-Allen on 7/27/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import BAPulseView
import RandomColorSwift

class LoopCell: UICollectionViewCell, UIGestureRecognizerDelegate {

    @IBOutlet weak var loopView: BAPulseView!
    @IBOutlet weak var loopImage: UIImageView!
    
    var loop: Loop!{
        didSet{
            loopImage.image = loop.image
            loopView.backgroundColor = loop.color
        }
    }
    
    var isMoving: Bool = false {
        didSet{
            self.loopView!.alpha = isMoving ? 0.0: 1.0
            print("ISMOVING")
        }
    }

    var snapshot: UIView{
        let snapshot: UIView = self.snapshotViewAfterScreenUpdates(true)
        let layer: CALayer = snapshot.layer
        layer.masksToBounds = true
        layer.cornerRadius = 0.5*bounds.size.width
        
        return snapshot
    }
    
    override func awakeFromNib() {
        loopView.layer.cornerRadius = 0.5*loopView.bounds.size.width
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoopCell.tapLoop(_:)))
            tap.delegate = self
            loopView.addGestureRecognizer(tap)
        
            super.awakeFromNib()
    }
    
    var timer: NSTimer!
    var count: Int!
    
    func tapLoop(sender: UITapGestureRecognizer){
        loop.play()
        
        // sets the background of the selected view to a random color
        loopView.backgroundColor = randomColor(hue: .Random, luminosity: .Light)
        
        count = 0
        
        // changes the color of the selected view according to its tempo
        timer = NSTimer.scheduledTimerWithTimeInterval(60.0/Double(loop.tempo), target: self, selector: #selector(changeColor), userInfo: nil, repeats: true)
        
    }
    
    func changeColor() {
        
        if count < 3 {
            loopView.backgroundColor = randomColor(hue: .Random, luminosity: .Light)
        } else if count == 3 {
            
            // sets the color back to the default color once the track has finished playing
            loopView.backgroundColor = loop.color
        } else if count == 4{
            
            // stops the timer once the track has finished playing
            timer.invalidate()
        }

        count = count + 1
    }

}

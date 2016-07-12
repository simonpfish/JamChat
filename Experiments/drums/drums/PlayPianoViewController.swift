//
//  PlayPianoViewController.swift
//  drums
//
//  Created by Meena Sengottuvelu on 7/8/16.
//  Copyright © 2016 Meena Sengottuvelu. All rights reserved.
//

import UIKit
import AudioKit

class PlayPianoViewController: UIViewController, KeyboardDelegate {

    let sampler = AKSampler()
    var alreadyLoaded = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let keyboard = PianoView(width: 325, height: 190, lowestKey: 60, totalKeys: 13)
        keyboard.frame.origin.y = CGFloat(335)
        keyboard.setNeedsDisplay()
        keyboard.delegate = self
        self.view.addSubview(keyboard)
        
        sampler.loadWav("PianoC")
        let reverb = AKReverb(sampler)
        reverb.loadFactoryPreset(.SmallRoom)
        AudioKit.output = reverb
        AudioKit.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func noteOn(note: Int) {
        // start from the correct note if amplitude is zero
        sampler.playNote(note)
    }
    
    func noteOff(note: Int) {
        sampler.stopNote(note)
    }
    
    //performs the appropriate segue depending on which button on the navigation bar is pressed
    //you must stop the AudioKit before switching to a new ViewController
    
    @IBAction func toDrums(sender: AnyObject) {
        AudioKit.stop()
        performSegueWithIdentifier("fromPlayPianotoPlayDrums", sender: self)
    }
    
    
    @IBAction func toSelection(sender: AnyObject) {
        AudioKit.stop()
        performSegueWithIdentifier("fromPlayPianotoSelection", sender: self)
    }
    
    @IBAction func onRight(sender: AnyObject) {
        AudioKit.stop()
        performSegueWithIdentifier("fromPlayPianotoPlaySax", sender: self)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

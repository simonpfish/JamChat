//
//  ScaleInstrumentViewController.swift
//  drums
//
//  Created by Alexina Boudreaux-Allen on 7/13/16.
//  Copyright © 2016 Meena Sengottuvelu. All rights reserved.
//

import UIKit
import AudioKit

class ScaleInstrumentViewController: UIViewController, KeyboardDelegate {
    
    var sampler = AKSampler()
    var wah: AKAutoWah?
    var soundString: String = ""
    var instrumentColor: UIColor?
    
    @IBOutlet weak var wahSlider: UISlider!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let keyboard = ScaleInstrumentView(width: 310, height: 40, lowestKey: 60, totalKeys: 13, color: self.instrumentColor!)
        keyboard.frame.origin.y = CGFloat(480)
        keyboard.setNeedsDisplay()
        keyboard.delegate = self
        self.view.addSubview(keyboard)
        
        sampler.loadWav(self.soundString)
        
        wah = AKAutoWah(sampler)
        wah!.wah = 0
        wah!.amplitude = 1
        wahSlider.value = 0
        wahSlider.transform = CGAffineTransformMakeScale(0.5, 0.5)
        
       AudioKit.output = wah
       AudioKit.start()
    }
    
    func noteOn(note: Int) {
        sampler.playNote(note)
    }
    
    func noteOff(note: Int) {
        sampler.stopNote(note)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
     
    }
    
    @IBAction func onGrid (sender: AnyObject?){
     print("yes")
        self.performSegueWithIdentifier("ScaleToSelection", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        AudioKit.stop()
    }

    @IBAction func wahSlider(sender: UISlider) {
         wah!.wah = Double(wahSlider.value)
    }
}

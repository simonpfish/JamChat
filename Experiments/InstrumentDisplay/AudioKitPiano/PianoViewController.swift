//
//  PianoViewController.swift
//  AudioKitPiano
//
//  Created by Alexina Boudreaux-Allen on 7/11/16.
//  Copyright © 2016 Alexina Boudreaux-Allen. All rights reserved.
//

import UIKit
import AudioKit

class PianoViewController: UIViewController, KeyboardDelegate {
    
        var sampler = AKSampler()
        var wah: AKAutoWah?
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let keyboard = PianoView(width: 310, height: 400, lowestKey: 60, totalKeys: 13)
        keyboard.frame.origin.y = CGFloat(150)
        keyboard.setNeedsDisplay()
        keyboard.delegate = self
        self.view.addSubview(keyboard)
        sampler.loadWav("RockGuitarC")
        //let reverb = AKReverb(sampler)
        //reverb.loadFactoryPreset(.SmallRoom)
        
        wah = AKAutoWah(sampler)
        wah!.wah = 0
        wah!.amplitude = 1
        wahSlider.value = 0
        
        AudioKit.output = wah
        AudioKit.start()
    }
    
    func noteOn(note: Int) {
        sampler.playNote(note)
    }
    
    func noteOff(note: Int) {
        sampler.stopNote(note)
    }

    @IBOutlet weak var wahSlider: UISlider!
   
    @IBAction func setSlider(sender: UISlider) {
        wah!.wah = Double(wahSlider.value)
        
    }
    
}

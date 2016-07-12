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
    
    let sampler = AKSampler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let keyboard = PianoView(width: 420, height: 400, lowestKey: 60, totalKeys: 13)
        keyboard.frame.origin.y = CGFloat(50)
        keyboard.setNeedsDisplay()
        keyboard.delegate = self
        self.view.addSubview(keyboard)
        
        sampler.loadWav("LongPianoC")
        let reverb = AKReverb(sampler)
        reverb.loadFactoryPreset(.SmallRoom)
        AudioKit.output = reverb
        AudioKit.start()
    }
    
    func noteOn(note: Int) {
        // start from the correct note if amplitude is zero
        sampler.playNote(note)
    }
    
    func noteOff(note: Int) {
        sampler.stopNote(note)
    }

}

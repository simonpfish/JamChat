//
//  Instrument.swift
//  JamChat
//
//  Created by Alexina Boudreaux-Allen on 7/18/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import AudioKit

class Instrument: NSObject {
    
    static let mixer = AKMixer()
    
    private(set) var name: String!
    private(set) var color: UIColor!
    private(set) var image: UIImage?
    
    private let sampler =  AKSampler()
    
    private init(name: String, color: UIColor, image: UIImage?, fileName: String) {
        self.name = name
        self.color = color
        self.image = image
        
        let bundle = NSBundle.mainBundle()
        let filepath = bundle.URLForResource(fileName, withExtension: "wav")
        
        sampler.loadWav(fileName)
        
        print("Loaded instrument: " + filepath!.absoluteString)
        Instrument.mixer.connect(self.sampler)
    }
    
    func play(note: Int) {
        sampler.playNote(note)
    }
    
    func stop(note: Int) {
        sampler.stopNote(note)
    }
    
    // Instruments:
    static let electricGuitar = Instrument(name: "Electric Guitar", color: UIColor(red: 0, green: 0.7882, blue: 0.7608, alpha: 1.0), image: nil, fileName: "RockGuitarC")
    static let saxophone = Instrument(name: "Electric Guitar", color: UIColor(red: 0.9294, green: 0.8353, blue: 0, alpha: 1.0), image: nil, fileName: "SaxC")
    static let choir = Instrument(name: "Electric Guitar", color: UIColor(red: 0.6392, green: 0, blue: 0.6275, alpha: 1.0), image: nil, fileName: "ChoirC")
    static let piano = Instrument(name: "Electric Guitar", color: UIColor.whiteColor(), image: nil, fileName: "PianoC")
    static let acousticBass = Instrument(name: "Electric Guitar", color: UIColor(red: 0.5294, green: 0.1294, blue: 0, alpha: 1.0), image: nil, fileName: "AcousticBassC")
    static let electricBass = Instrument(name: "Electric Guitar", color: UIColor(red: 0.4118, green: 0.6863, blue: 0, alpha: 1.0), image: nil, fileName: "ElectricBassC")
    
}

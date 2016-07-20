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
    static let electricGuitar = Instrument(name: "Electric Guitar", color: UIColor(red: 0, green: 0.7882, blue: 0.7608, alpha: 1.0), image: UIImage(named: "electric_guitar"), fileName: "RockGuitarC")
    static let saxophone = Instrument(name: "Saxophone", color: UIColor(red: 0.9294, green: 0.8353, blue: 0, alpha: 1.0), image: UIImage(named: "saxo"), fileName: "SaxC")
    static let choir = Instrument(name: "Choir", color: UIColor(red: 0.6392, green: 0, blue: 0.6275, alpha: 1.0), image: UIImage(named: "choir"), fileName: "ChoirC")
    static let piano = Instrument(name: "Piano", color: UIColor(red:0.19, green:0.57, blue:1, alpha:1), image: UIImage(named: "piano"), fileName: "PianoC")
    static let acousticBass = Instrument(name: "Acoustic Bass", color: UIColor(red: 0.5294, green: 0.1294, blue: 0, alpha: 1.0), image: UIImage(named: "acoustic_bass"), fileName: "AcousticBassC")
    static let electricBass = Instrument(name: "Electric Bass", color: UIColor(red: 0.4118, green: 0.6863, blue: 0, alpha: 1.0), image: UIImage(named: "electric_bass"), fileName: "ElectricBassC")
    
}

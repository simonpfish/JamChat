//
//  Metronome.swift
//  JamChat
//
//  Created by Alexina Boudreaux-Allen on 7/29/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import AVFoundation
import AudioKit

class Metronome: NSObject {
    
    private(set) var tempo: Int!
    private (set) var fileName: String!
    
    private var metronome: AVAudioPlayer!
    
    private init(fileName: String, tempo: Int) {
        self.tempo = tempo
        self.fileName = fileName
    }
    
    func play() {
        
        let path = NSBundle.mainBundle().pathForResource(self.fileName, ofType: "wav")!
        let url = NSURL(fileURLWithPath: path)
        do {
            let sound = try AVAudioPlayer(contentsOfURL: url)
            self.metronome = sound
            sound.play()
        } catch {
            // couldn't load file :(
            print("Failed to load loop")
        }
        
    }
    
    func stop(){
        metronome.stop()
    }
    
    // Metronomes:
    static let metronomeBPM80 = Metronome(fileName: "80BPM", tempo: 80)
    static let metronomeBPM110 = Metronome(fileName: "110BPM", tempo: 110)
    static let metronomeBPM140 = Metronome(fileName: "140BPM", tempo: 140)
}




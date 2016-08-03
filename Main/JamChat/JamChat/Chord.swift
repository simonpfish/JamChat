//
//  Chord.swift
//  JamChat
//
//  Created by Alexina Boudreaux-Allen on 8/2/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import AudioKit

class Chord: NSObject {
    static let mixer = AKMixer()
    
    private(set) var name: String!
    private(set) var note: Int!
    
    private(set) var sampler: AKSampler!
    
    private var urls: [NSURL] = []
    private var fileName: String!
    
    private var loaded = false
    
    private init(name: String, fileName: String, note: Int) {
        self.name = name
        self.fileName = fileName
        self.note = note
    }
    
    func load() {
        AudioKit.stop()
        sampler = AKSampler()
        sampler.loadWav(fileName)
        
        Instrument.mixer.connect(self.sampler)
        
        AudioKit.start()
        print("Loaded ", name)
    }
    
    func play() {
        if !loaded {
            load()
        }
        print("Playing " + name)
        sampler.play(noteNumber: self.note)
    }
    
    func stop() {
        sampler.stop(noteNumber: self.note)
    }
    
    func reload() {
        print("Reloading ", name)
        sampler = AKSampler()
        sampler.loadWav(fileName)
        Instrument.mixer.connect(sampler)
    }
    
    // Major Chords 80 BPM:
    static let CMaj80 = Chord(name: "C", fileName: "MajChord80", note: 48)
    static let DbMaj80 = Chord(name: "D♭", fileName: "MajChord80", note: 49)
    static let DMaj80 = Chord(name: "D", fileName: "MajChord80", note: 50)
    static let EbMaj80 = Chord(name: "E♭", fileName: "MajChord80", note: 51)
    static let EMaj80 = Chord(name: "E", fileName: "MajChord80", note: 52)
    static let FMaj80 = Chord(name: "F", fileName: "MajChord80", note: 53)
    static let GbMaj80 = Chord(name: "G♭", fileName: "MajChord80", note: 54)
    static let GMaj80 = Chord(name: "G", fileName: "MajChord80", note: 55)
    static let AbMaj80 = Chord(name: "A♭", fileName: "MajChord80", note: 56)
    static let AMaj80 = Chord(name: "A", fileName: "MajChord80", note: 57)
    static let BbMaj80 = Chord(name: "B♭", fileName: "MajChord80", note: 58)
    static let BMaj80 = Chord(name: "B", fileName: "MajChord80", note: 59)
    
    // Major Chords 110 BPM:
    static let CMaj110 = Chord(name: "C", fileName: "MajChord110", note: 48)
    static let DbMaj110 = Chord(name: "D♭", fileName: "MajChord110", note: 49)
    static let DMaj110 = Chord(name: "D", fileName: "MajChord110", note: 50)
    static let EbMaj110 = Chord(name: "E♭", fileName: "MajChord110", note: 51)
    static let EMaj110 = Chord(name: "E", fileName: "MajChord110", note: 52)
    static let FMaj110 = Chord(name: "F", fileName: "MajChord110", note: 53)
    static let GbMaj110 = Chord(name: "G♭", fileName: "MajChord110", note: 54)
    static let GMaj110 = Chord(name: "G", fileName: "MajChord110", note: 55)
    static let AbMaj110 = Chord(name: "A♭", fileName: "MajChord110", note: 56)
    static let AMaj110 = Chord(name: "A", fileName: "MajChord110", note: 57)
    static let BbMaj110 = Chord(name: "B♭", fileName: "MajChord110", note: 58)
    static let BMaj110 = Chord(name: "B", fileName: "MajChord110", note: 59)
    
    // Major Chords 140 BPM:
    static let CMaj140 = Chord(name: "C", fileName: "MajChord140", note: 48)
    static let DbMaj140 = Chord(name: "D♭", fileName: "MajChord140", note: 49)
    static let DMaj140 = Chord(name: "D", fileName: "MajChord140", note: 50)
    static let EbMaj140 = Chord(name: "E♭", fileName: "MajChord140", note: 51)
    static let EMaj140 = Chord(name: "E", fileName: "MajChord140", note: 52)
    static let FMaj140 = Chord(name: "F", fileName: "MajChord140", note: 53)
    static let GbMaj140 = Chord(name: "G♭", fileName: "MajChord140", note: 54)
    static let GMaj140 = Chord(name: "G", fileName: "MajChord140", note: 55)
    static let AbMaj140 = Chord(name: "A♭", fileName: "MajChord140", note: 56)
    static let AMaj140 = Chord(name: "A", fileName: "MajChord140", note: 57)
    static let BbMaj140 = Chord(name: "B♭", fileName: "MajChord140", note: 58)
    static let BMaj140 = Chord(name: "B", fileName: "MajChord140", note: 59)
    
    // Minor Chords 80 BPM:
    static let CMin80 = Chord(name: "C", fileName: "MinChord80", note: 48)
    static let DbMin80 = Chord(name: "D♭", fileName: "MinChord80", note: 49)
    static let DMin80 = Chord(name: "D", fileName: "MinChord80", note: 50)
    static let EbMin80 = Chord(name: "E♭", fileName: "MinChord80", note: 51)
    static let EMin80 = Chord(name: "E", fileName: "MinChord80", note: 52)
    static let FMin80 = Chord(name: "F", fileName: "MinChord80", note: 53)
    static let GbMin80 = Chord(name: "G♭", fileName: "MinChord80", note: 54)
    static let GMin80 = Chord(name: "G", fileName: "MinChord80", note: 55)
    static let AbMin80 = Chord(name: "A♭", fileName: "MinChord80", note: 56)
    static let AMin80 = Chord(name: "A", fileName: "MinChord80", note: 57)
    static let BbMin80 = Chord(name: "B♭", fileName: "MinChord80", note: 58)
    static let BMin80 = Chord(name: "B", fileName: "MinChord80", note: 59)
    
    // Minor Chords 110 BPM:
    static let CMin110 = Chord(name: "C", fileName: "MinChord110", note: 48)
    static let DbMin110 = Chord(name: "D♭", fileName: "MinChord110", note: 49)
    static let DMin110 = Chord(name: "D", fileName: "MinChord110", note: 50)
    static let EbMin110 = Chord(name: "E♭", fileName: "MinChord110", note: 51)
    static let EMin110 = Chord(name: "E", fileName: "MinChord110", note: 52)
    static let FMin110 = Chord(name: "F", fileName: "MinChord110", note: 53)
    static let GbMin110 = Chord(name: "G♭", fileName: "MinChord110", note: 54)
    static let GMin110 = Chord(name: "G", fileName: "MinChord110", note: 55)
    static let AbMin110 = Chord(name: "A♭", fileName: "MinChord110", note: 56)
    static let AMin110 = Chord(name: "A", fileName: "MinChord110", note: 57)
    static let BbMin110 = Chord(name: "B♭", fileName: "MinChord110", note: 58)
    static let BMin110 = Chord(name: "B", fileName: "MinChord110", note: 59)
    
    // Minor Chords 140 BPM:
    static let CMin140 = Chord(name: "C", fileName: "MinChord140", note: 48)
    static let DbMin140 = Chord(name: "D♭", fileName: "MinChord140", note: 49)
    static let DMin140 = Chord(name: "D", fileName: "MinChord140", note: 50)
    static let EbMin140 = Chord(name: "E♭", fileName: "MinChord140", note: 51)
    static let EMin140 = Chord(name: "E", fileName: "MinChord140", note: 52)
    static let FMin140 = Chord(name: "F", fileName: "MinChord140", note: 53)
    static let GbMin140 = Chord(name: "G♭", fileName: "MinChord140", note: 54)
    static let GMin140 = Chord(name: "G", fileName: "MinChord140", note: 55)
    static let AbMin140 = Chord(name: "A♭", fileName: "MinChord140", note: 56)
    static let AMin140 = Chord(name: "A", fileName: "MinChord140", note: 57)
    static let BbMin140 = Chord(name: "B♭", fileName: "MinChord140", note: 58)
    static let BMin140 = Chord(name: "B", fileName: "MinChord140", note: 59)
    
    // Seventh Chords 80 BPM:
    static let CSev80 = Chord(name: "C", fileName: "MajChord80", note: 48)
    static let DbSev80 = Chord(name: "D♭", fileName: "MajChord80", note: 49)
    static let DSev80 = Chord(name: "D", fileName: "MajChord80", note: 50)
    static let EbSev80 = Chord(name: "E♭", fileName: "MajChord80", note: 51)
    static let ESev80 = Chord(name: "E", fileName: "MajChord80", note: 52)
    static let FSev80 = Chord(name: "F", fileName: "MajChord80", note: 53)
    static let GbSev80 = Chord(name: "G♭", fileName: "MajChord80", note: 54)
    static let GSev80 = Chord(name: "G", fileName: "MajChord80", note: 55)
    static let AbSev80 = Chord(name: "A♭", fileName: "MajChord80", note: 56)
    static let ASev80 = Chord(name: "A", fileName: "MajChord80", note: 57)
    static let BbSev80 = Chord(name: "B♭", fileName: "MajChord80", note: 58)
    static let BSev80 = Chord(name: "B", fileName: "MajChord80", note: 59)
    
    // Major Chords 110 BPM:
    static let CSev110 = Chord(name: "C", fileName: "MajChord110", note: 48)
    static let DbSev110 = Chord(name: "D♭", fileName: "MajChord110", note: 49)
    static let DSev110 = Chord(name: "D", fileName: "MajChord110", note: 50)
    static let EbSev110 = Chord(name: "E♭", fileName: "MajChord110", note: 51)
    static let ESev110 = Chord(name: "E", fileName: "MajChord110", note: 52)
    static let FSev110 = Chord(name: "F", fileName: "MajChord110", note: 53)
    static let GbSev110 = Chord(name: "G♭", fileName: "MajChord110", note: 54)
    static let GSev110 = Chord(name: "G", fileName: "MajChord110", note: 55)
    static let AbSev110 = Chord(name: "A♭", fileName: "MajChord110", note: 56)
    static let ASev110 = Chord(name: "A", fileName: "MajChord110", note: 57)
    static let BbSev110 = Chord(name: "B♭", fileName: "MajChord110", note: 58)
    static let BSev110 = Chord(name: "B", fileName: "MajChord110", note: 59)
    
    // Major Chords 140 BPM:
    static let CSev140 = Chord(name: "C", fileName: "MajChord140", note: 48)
    static let DbSev140 = Chord(name: "D♭", fileName: "MajChord140", note: 49)
    static let DSev140 = Chord(name: "D", fileName: "MajChord140", note: 50)
    static let EbSev140 = Chord(name: "E♭", fileName: "MajChord140", note: 51)
    static let ESev140 = Chord(name: "E", fileName: "MajChord140", note: 52)
    static let FSev140 = Chord(name: "F", fileName: "MajChord140", note: 53)
    static let GbSev140 = Chord(name: "G♭", fileName: "MajChord140", note: 54)
    static let GSev140 = Chord(name: "G", fileName: "MajChord140", note: 55)
    static let AbSev140 = Chord(name: "A♭", fileName: "MajChord140", note: 56)
    static let ASev140 = Chord(name: "A", fileName: "MajChord140", note: 57)
    static let BbSev140 = Chord(name: "B♭", fileName: "MajChord140", note: 58)
    static let BSev140 = Chord(name: "B", fileName: "MajChord140", note: 59)
    
    static let MajChords80: [Chord] = [CMaj80, DbMaj80, DMaj80, EbMaj80, EMaj80, FMaj80, GbMaj80, GMaj80, AbMaj80, AMaj80, BbMaj80 ,BMaj80]
    static let MajChords110: [Chord] = [CMaj110, DbMaj110, DMaj110, EbMaj110, EMaj110, FMaj110, GbMaj110, GMaj110, AbMaj110, AMaj110, BbMaj110 ,BMaj110]
    static let MajChords140: [Chord] = [CMaj140, DbMaj140, DMaj140, EbMaj140, EMaj140, FMaj140, GbMaj140, GMaj140, AbMaj140, AMaj140, BbMaj140 ,BMaj140]
    
    static let MinChords80: [Chord] = [CMin80, DbMin80, DMin80, EbMin80, EMin80, FMin80, GbMin80, GMin80, AbMin80, AMin80, BbMin80 ,BMin80]
    static let MinChords110: [Chord] = [CMin110, DbMin110, DMin110, EbMin110, EMin110, FMin110, GbMin110, GMin110, AbMin110, AMin110, BbMin110 ,BMin110]
    static let MinChords140: [Chord] = [CMin140, DbMin140, DMin140, EbMin140, EMin140, FMin140, GbMin140, GMin140, AbMin140, AMin140, BbMin140 ,BMin140]
    
    static let SevChords80: [Chord] = [CSev80, DbSev80, DSev80, EbSev80, ESev80, FSev80, GbSev80, GSev80, AbSev80, ASev80, BbSev80 ,BSev80]
    static let SevChords110: [Chord] = [CSev110, DbSev110, DSev110, EbSev110, ESev110, FSev110, GbSev110, GSev110, AbSev110, ASev110, BbSev110 ,BSev110]
    static let SevChords140: [Chord] = [CSev140, DbSev140, DSev140, EbSev140, ESev140, FSev140, GbSev140, GSev140, AbSev140, ASev140, BbSev140 ,BSev140]

}

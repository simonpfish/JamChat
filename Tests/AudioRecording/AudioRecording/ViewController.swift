//
//  ViewController.swift
//  AudioRecording
//
//  Created by Simon Posada Fishman on 7/8/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import AudioKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bundle = NSBundle.mainBundle()
        
        let drumFile   = bundle.pathForResource("drumloop", ofType: "wav")
        let bassFile   = bundle.pathForResource("bassloop", ofType: "wav")
        let guitarFile = bundle.pathForResource("guitarloop", ofType: "wav")
        let leadFile   = bundle.pathForResource("leadloop", ofType: "wav")
        
        
        let drums  = AKAudioPlayer(drumFile!)
        let bass   = AKAudioPlayer(bassFile!)
        let guitar = AKAudioPlayer(guitarFile!)
        let lead   = AKAudioPlayer(leadFile!)
        
        let recordFile = bundle.bundlePath + "/recording.wav"

//        print(bundle.bundlePath)
//        print(recordFile.absoluteString)
        
//        let player = AKAudioPlayer(recordFile)
        
        
        let mixer = AKMixer(drums, bass, guitar, lead)

        drums.looping  = true
        bass.looping   = true
        guitar.looping = true
        lead.looping   = true
//        player.looping = true
        
        //: Any number of inputs can be summed into one output
        
        AudioKit.output = mixer
        AudioKit.start()
        
        
        drums.play()
        bass.play()
        guitar.play()
        lead.play()
        
//        player.play()
        
        let tape = try? AKAudioFile()
        let recorder = try? AKNodeRecorder(node: AudioKit.output!)
        
        print(tape?.directoryPath.absoluteString)
        
        recorder!.record()
        
        sleep(4)
        recorder!.stop()
        
        print(tape?.duration)
        
        recorder?.export()
        
        //: Adjust the individual track volumes here
        drums.volume  = 0.9
        bass.volume   = 0.9
        guitar.volume = 0.6
        lead.volume   = 0.7
        
        drums.pan  = 0.0
        bass.pan   = 0.0
        guitar.pan = 0.2
        lead.pan   = -0.2
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


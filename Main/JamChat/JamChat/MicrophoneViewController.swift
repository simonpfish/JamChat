//
//  MicrophoneViewController.swift
//  JamChat
//
//  Created by Alexina Boudreaux-Allen on 8/1/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import AVFoundation

class MicrophoneViewController: UIViewController, AVAudioRecorderDelegate
{
    var audioRecorder: AVAudioRecorder!
    var isRecording: Bool = false
    
    @IBOutlet weak var waveformView: SiriWaveformView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isRecording {
            waveformView.waveColor = UIColor(red:0.928, green:0.103, blue:0.176, alpha:1)
        } else {
            waveformView.waveColor = UIColor.blackColor()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        audioRecorder = audioRecorder(NSURL(fileURLWithPath:"/dev/null"))
        audioRecorder.prepareToRecord()
        audioRecorder.record()
        
        let displayLink = CADisplayLink(target: self, selector: #selector(MicrophoneViewController.updateMeters))
        displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    func updateMeters() {
        audioRecorder.updateMeters()
        let normalizedValue = pow(10, audioRecorder.averagePowerForChannel(0) / 30)
        waveformView.updateWithLevel(CGFloat(normalizedValue))
    }
    
    func audioRecorder(filePath: NSURL) -> AVAudioRecorder {
        let recorderSettings: [String : AnyObject] = [
            AVSampleRateKey: 44100.0,
            AVFormatIDKey: NSNumber(unsignedInt: kAudioFormatMPEG4AAC),
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.Min.rawValue
        ]
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
        
        let audioRecorder = try! AVAudioRecorder(URL: filePath, settings: recorderSettings)
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        
        return audioRecorder
    }
    
}

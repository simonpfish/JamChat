//
//  MicrophoneViewController.swift
//  JamChat
//
//  Created by Alexina Boudreaux-Allen on 8/1/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import AVFoundation
import AudioKit

class MicrophoneViewController: UIViewController {
    var audioRecorder: AVAudioRecorder!
    
    @IBOutlet weak var waveformView: SiriWaveformView!

    var displayLink: CADisplayLink!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        waveformView.waveColor = UIColor.blackColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            self.audioRecorder = self.audioRecorder(NSURL(fileURLWithPath:"/dev/null"))
            self.audioRecorder.prepareToRecord()
            self.audioRecorder.record()
            
            dispatch_async(dispatch_get_main_queue()) {
                self.displayLink = CADisplayLink(target: self, selector: #selector(MicrophoneViewController.updateMeters))
                self.displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        audioRecorder.stop()
        displayLink.invalidate()
        audioRecorder = nil
    }
    
    func reloadRecorderWaveform() {
        print("reloading waveform")
        audioRecorder.stop()
        audioRecorder = nil
        displayLink.invalidate()
        
        audioRecorder = audioRecorder(NSURL(fileURLWithPath:"/dev/null"))
        audioRecorder.prepareToRecord()
        audioRecorder.record()
        
        displayLink = CADisplayLink(target: self, selector: #selector(MicrophoneViewController.updateMeters))
        displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    func redWaveform() {
        waveformView.waveColor = UIColor(red:0.928, green:0.103, blue:0.176, alpha:1)
    }
    
    func blackWaveform() {
        waveformView.waveColor = UIColor.blackColor()
    }
    
    func updateMeters() {
        if audioRecorder != nil {
            audioRecorder.updateMeters()
            let normalizedValue = pow(10, audioRecorder.averagePowerForChannel(0) / 30)
            waveformView.updateWithLevel(CGFloat(normalizedValue))
        }
    }
    
    func audioRecorder(filePath: NSURL) -> AVAudioRecorder {
        let recorderSettings: [String : AnyObject] = [
            AVSampleRateKey: 44100.0,
            AVFormatIDKey: NSNumber(unsignedInt: kAudioFormatMPEG4AAC),
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.Min.rawValue
        ]
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: AVAudioSessionCategoryOptions.DefaultToSpeaker)
        
        let audioRecorder = try! AVAudioRecorder(URL: filePath, settings: recorderSettings)
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        
        return audioRecorder
    }
    
}

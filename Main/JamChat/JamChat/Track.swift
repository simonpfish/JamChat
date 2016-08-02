//
//  Track.swift
//  JamChat
//
//  Created by Simon Posada Fishman on 7/9/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import Parse
import AudioKit

class Track: NSObject {
    
    static let mixer = AKMixer()
    
    private(set) var author: User!
    let identifier: String!
    
    var player: AKAudioPlayer?
    var filepath: String!
    var color: UIColor = UIColor.grayColor()
    
    var playbackTime: Double{
        get {
            return player?.playhead ?? 0
        }
    }
    
    var instrumentName: String?
    
    private(set) var object: PFObject!
    
    private var recorder: AKNodeRecorder?
    private var exportSession: AKAudioFile.ExportSessionFixed?
    
    var isPlaying: Bool {
        get {
            return player!.isPlaying
        }
    }
    
    /**
     Initializes a track based on a PFObject, useful for downloading them from Parse.
     */
    init(object: PFObject) {
        
        self.object = object
        let parseUser = object["author"] as! PFUser
        author = User(user: parseUser)
        identifier = object["identifier"] as! String
        if let hex = object["color"] as? String {
            color = UIColor(hexString: hex)
        }
        
        filepath =  (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]) +  "/" + self.identifier + ".m4a"
        
        instrumentName = object["instrumentName"] as? String
        
        super.init()
    }
    
    func loadMedia(success: () -> (), failure: (NSError) -> ()) {
        let fileManager = NSFileManager()
        let file = object["media"] as! PFFile
        
        if fileManager.fileExistsAtPath(filepath) {
            print("Audio file found in storage")
            self.player = try? AKAudioPlayer(file: AKAudioFile(forReading: NSURL(string: self.filepath)!))
            Track.mixer.connect(self.player!)
            success()
        } else {
            print("Downloading audio file")

            file.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) in
                if let error = error {
                    failure(error)
                } else {
                    
                    fileManager.createFileAtPath(self.filepath, contents: data, attributes: nil)
                    self.player = try? AKAudioPlayer(file: AKAudioFile(forReading: NSURL(string: self.filepath)!))
                    Track.mixer.connect(self.player!)
                    
                    success()
                }
            }
        }
    }
    
    /**
     Initializes a new empty track
     */
    override init() {
        object = PFObject(className: "Track")
        identifier = NSUUID().UUIDString
        author = User.currentUser
        filepath =  (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]) +  "/" + identifier + ".m4a"
    }
    
    func playLooping() {
        player?.looping = true
        player?.endTime = floor((self.player?.audioFile.duration)!)
        player?.play()
    }
    
    func play() {
        self.player?.playFrom(0, to: floor((self.player?.audioFile.duration)!))
    }
    
    func stopLooping() {
        player?.stop()
        player?.looping = false
    }
    
    func recordInstrument(instrument: Instrument, duration: Double, completion: () -> ()) {
        color = instrument.color
        instrumentName = instrument.name
        recordNode(instrument.sampler, duration: duration, completion: completion)
    }
    
    func recordMicrophone(duration: Double, completion: ()->()) {
        color = UIColor.redColor()
        instrumentName = "Microphone"
//        AudioKit.stop()
//        let microphone = AKMicrophone()
//        AudioKit.start()
//        recordNode(microphone, duration: duration) {
//            completion()
//            AppDelegate.restartAudiokit()
//        }
        
        let file = try! AKAudioFile()
        let recorder = AKMicrophoneRecorder(file)
        recorder.record()
        delay(duration) { 
            recorder.stop()
            let recorded = try! AKAudioFile(forReading: file.url)
            self.export(recorded, completion: { 
                completion()
                AppDelegate.restartAudiokit()
            })
        }
    }
    
    /**
     Records the track from an AKNode, overwriting any previous content
     */
    private func recordNode(node: AKNode, duration: Double, completion: ()->()) {
        recorder = try? AKNodeRecorder(node: node)
        
        try! recorder!.recordFor(duration, completion: { 
            self.export(self.recorder!.audioFile!, completion: completion)
        })
    }
    
    private func export(file: AKAudioFile, completion: ()->()) {
        
        self.exportSession =  try! file.exportFixed(self.identifier, ext: .m4a, baseDir: .Documents, callBack: { () in
            
            if self.exportSession!.succeeded {
                
                self.filepath =  (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]) +  "/" + self.identifier + ".m4a"
                
                self.player = try? AKAudioPlayer(file: AKAudioFile(forReading: NSURL(string: self.filepath)!))
                Track.mixer.connect(self.player!)
                
                completion()
                
            } else {
                print ("Export failed")
            }
            
        })
    }
    
    // utility function
    private func delay(delay: Double, closure: ()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    /**
     Uploads track to parse
     */
    func upload(completion: PFBooleanResultBlock?) {
        
        // Add relevant fields to the object
        object["media"] = PFFile(name: "audio.m4a", data: NSData(contentsOfFile: filepath)!)
        object["author"] = author.parseUser // Pointer column type that points to PFUser
        object["identifier"] = identifier
        object["color"] = color.toHexString()
        object["instrumentName"] = instrumentName
        
        object.saveInBackgroundWithBlock(completion)
    }
}

extension UIColor {
    convenience init(hexString:String) {
        let hexString = hexString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let scanner = NSScanner(string: hexString)
        
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        
        var color:UInt32 = 0
        scanner.scanHexInt(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:1)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"#%06x", rgb)
    }
}

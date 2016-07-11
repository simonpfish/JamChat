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
    
    static let mainMixer = AKMixer()
    
    private(set) var author: User!
    let identifier: String!
    
    private var player: AKAudioPlayer?
    private var filepath: String!
    private var object: PFObject!
    
    private var recorder: AKNodeRecorder?
    private var exportSession: AKAudioFile.ExportSession?
    
    /**
     Initializes a track based on a PFObject, useful for downloading them from Parse.
     */
    init(object: PFObject, success: () -> (), failure: (NSError) -> ()) {
        
        self.object = object
        let file = object["media"] as! PFFile
        let parseUser = object["author"] as! PFUser
        
        author = User(user: parseUser)
        identifier = object["identifier"] as! String
        
        filepath =  (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]) +  "/" + self.identifier + ".m4a"
        
        super.init()
        
        let fileManager = NSFileManager()
        
        if fileManager.fileExistsAtPath(filepath) {
            self.player = AKAudioPlayer(self.filepath)
            Track.mainMixer.connect(self.player!)
            success()
        } else {
            file.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) in
                if let error = error {
                    failure(error)
                } else {
                    
                    data?.writeToURL(NSURL(string: self.filepath)!, atomically: true)
                    self.player = AKAudioPlayer(self.filepath)
                    Track.mainMixer.connect(self.player!)
                    
                    success()
                }
            }
        }
        
    }
    
    /**
     Initializes a new empty track
     */
    override init() {
        super.init()
        object = PFObject(className: "Track")
        identifier = NSUUID().UUIDString
        author = User.currentUser
        filepath =  (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]) +  "/" + identifier + ".m4a"
    }
    
    func play() {
        player?.play()
    }
    
    func stop() {
        player?.stop()
    }
    
    /**
     Records the track from an AKNode, overwriting any previous content
     */
    func record(node: AKNode, duration: Double, completion: ()->()) {
        recorder = try? AKNodeRecorder(node: node)
        
        recorder!.record()
        
        delay(duration) { 
            self.recorder!.stop()
            
            self.exportSession =  try! self.recorder?.internalAudioFile.export(self.identifier, ext: .m4a, baseDir: .Documents, callBack: { () in
                
                if self.exportSession!.succeeded {
                    
                    self.filepath =  (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]) +  "/" + self.identifier + ".m4a"
                    
                    self.player = AKAudioPlayer(self.filepath)
                    Track.mainMixer.connect(self.player!)
                    
                    completion()
                    
                } else {
                    print ("Export failed")
                }
                
            })
        }
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
        
        object.saveInBackgroundWithBlock(completion)
    }
}

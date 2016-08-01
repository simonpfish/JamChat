//
//  Message.swift
//  JamChat
//
//  Created by Simon Posada Fishman on 7/9/16.
//  Copyright © 2016 Jammers. All rights reserved.
//

import UIKit
import Parse

class Message: NSObject {
    
    var track: Track!
    private var newTracks: [Track] = []
    private(set) var id: String?
    private var object: PFObject!
    private var tracksAreLoaded = false
    
    var isPlaying: Bool {
            return track.isPlaying
    }
    
    var currentTime: Double {
            return track.playbackTime
    }
    
    /**
     Initializes a new message based on a parse object
     */
    init(object: PFObject) {
        super.init()
        
        self.object = object
        id = object.objectId
    }
    
    func loadTrack(completion: () -> ()) {
        print("Loading tracks for message \(self.id ?? "NEW")")
        if tracksAreLoaded {
            print("Tracks are already loaded for message \(self.id ?? "NEW")")
            completion()
        } else {
            object.fetchIfNeededInBackgroundWithBlock { (_: PFObject?, error: NSError?) in
                let trackObject = self.object["track"] as! PFObject
                self.track = Track(object: trackObject)
                
                self.track.loadMedia({
                    print("Succesfully loaded track for message \(self.id ?? "NEW")")
                    self.tracksAreLoaded = true
                    completion()
                }, failure: { (error: NSError) in
                    print(error.localizedDescription)
                })
            }
        }
    }
    
    /**
     Initializes a new message that builds on top of an older one
     */
    init(track: Track) {
        super.init()
        
        self.track = track
    }
    
    /**
     Plays the message to the main audio output
     */
    func play(startedPlaying: (() -> ())?) {
        print("Playing message \(self.id ?? "NEW")")
        track.playLooping()
        startedPlaying?()
    }
    
    func stop() {
        print("Playing message \(self.id ?? "NEW")")
        track.stopLooping()
    }
    
    /**
     Uploads message to parse, creating a new one in the server. Will not upload anything if no new tracks were added.
     */
    func send(completion: PFBooleanResultBlock?) {
        object = PFObject(className: "Message")
    
        object["track"] = track.object

        track.upload({ (success: Bool, error: NSError?) in
            if let error = error {
                completion?(false, error)
            } else {
                self.object.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                    self.id = self.object.objectId
                    print("Sent message \(self.id!)")
                    completion!(success, error)
                })
            }
        })
    }
    
}

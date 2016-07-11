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
    
    private var tracks: [Track] = []
    
    /**
     Initializes a new message that builds on top of an existing one
     */
    init(oldMessage: PFObject, completion: () -> ()) {
        super.init()
        
        let trackIDs = oldMessage["tracks"] as! [String]
        
        let query = PFQuery(className: "Track")
        query.orderByDescending("createdAt")
        query.whereKey("identifier", containedIn: trackIDs)
        
        query.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) in
            for object in objects! {
                self.tracks.append(Track(object: object, success: { 
                    if self.tracks.count == objects?.count {
                        completion()
                    }
                }, failure: { (error: NSError) in
                        print("failed to load message")
                }))
            }
        }
    }
    
    /**
     Plays the message to the main audio output
     */
    func play() {
        for track in tracks {
            track.play()
        }
    }
    
    /**
     Adds a new track to the message
     */
    func add(track: Track) {
        tracks.append(track)
    }
    
    /**
     Uploads message to parse
     */
    func send(completion: PFBooleanResultBlock?) {
        let object = PFObject(className: "Message")
        
        var trackIDs: [String] = []
        
        for track in tracks {
            trackIDs.append(track.identifier)
        }
        
        object["tracks"] = trackIDs

        object.saveInBackgroundWithBlock(completion)
    }
    
}
